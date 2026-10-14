import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../http/http_detect_line_dio.dart';
import '../../utils/logger.dart';

typedef AiVideoProgress = void Function(double progress);

/// AI 视频下载结果。
///
/// 后端为 MP4 时直接下载；后端为 HLS 时下载 TS 分片并按播放列表顺序
/// 拼接，最终以 `.mp4` 文件名落到缓存目录，供 Android 播放器和相册使用。
class AiVideoMedia {
  AiVideoMedia._();

  static final Dio _dio = createDio(
    options: BaseOptions(
      connectTimeout: 30 * 1000,
      receiveTimeout: 180 * 1000,
      validateStatus: (int? status) =>
          status != null && status >= 200 && status < 400,
    ),
  );

  static final Map<String, Future<File>> _inFlight = <String, Future<File>>{};

  static bool looksLikeHls(String url) {
    final String raw = url.trim().toLowerCase();
    if (raw.isEmpty) return false;
    final Uri? uri = Uri.tryParse(raw);
    final String pathValue = uri?.path ?? raw;
    return pathValue.endsWith('.m3u8') || pathValue.contains('/hls/');
  }

  /// URL 后缀无法判断时，再通过响应头识别 HLS。
  static Future<bool> isHls(String url) async {
    if (looksLikeHls(url)) return true;
    try {
      final Response<dynamic> response = await _dio.head<dynamic>(
        url,
        options: Options(
          followRedirects: true,
          headers: <String, dynamic>{
            HttpHeaders.acceptHeader:
                'application/vnd.apple.mpegurl, application/x-mpegURL, video/*',
          },
        ),
      );
      final String contentType =
          response.headers.value(HttpHeaders.contentTypeHeader) ?? '';
      if (_isHlsMime(contentType)) return true;
      if (contentType.toLowerCase().startsWith('video/')) return false;
    } catch (_) {}

    // 部分签名 CDN 禁止 HEAD，请求头无法判断时读取少量文件头兜底。
    try {
      final Response<List<int>> response = await _dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          headers: <String, dynamic>{
            HttpHeaders.rangeHeader: 'bytes=0-1023',
          },
        ),
      );
      final String contentType =
          response.headers.value(HttpHeaders.contentTypeHeader) ?? '';
      if (_isHlsMime(contentType)) return true;
      final List<int> bytes = response.data ?? const <int>[];
      final int prefixLength = bytes.length < 32 ? bytes.length : 32;
      final String prefix = ascii
          .decode(bytes.take(prefixLength).toList(), allowInvalid: true)
          .trimLeft();
      return prefix.startsWith('#EXTM3U');
    } catch (_) {
      return false;
    }
  }

  /// HLS 返回本地“MP4”缓存；MP4 等普通视频返回 null，调用方可直接网络播放。
  static Future<File?> prepareHlsForPlayback(
    String url, {
    AiVideoProgress? onProgress,
  }) async {
    if (!await isHls(url)) return null;
    return downloadAsMp4(url, onProgress: onProgress);
  }

  /// 将视频保存到本地 MP4 路径。
  ///
  /// HLS：解析 m3u8 并顺序拼接 TS。
  /// 普通视频：直接下载原始字节到 `.mp4`。
  static Future<File> downloadAsMp4(
    String url, {
    String? fileName,
    AiVideoProgress? onProgress,
  }) async {
    final String source = url.trim();
    if (source.isEmpty) {
      throw const FormatException('视频地址为空');
    }

    final String key = source;
    final Future<File>? running = _inFlight[key];
    if (running != null) return running;

    final Future<File> task = _downloadAsMp4(
      source,
      fileName: fileName,
      onProgress: onProgress,
    );
    _inFlight[key] = task;
    try {
      return await task;
    } finally {
      _inFlight.remove(key);
    }
  }

  static Future<File> _downloadAsMp4(
    String url, {
    String? fileName,
    AiVideoProgress? onProgress,
  }) async {
    final Directory cacheRoot = Directory(
      path.join((await getTemporaryDirectory()).path, 'ai_video_cache'),
    );
    if (!await cacheRoot.exists()) {
      await cacheRoot.create(recursive: true);
    }

    final String safeName = _safeMp4Name(
      fileName ?? md5.convert(utf8.encode(url)).toString(),
    );
    final File target = File(path.join(cacheRoot.path, safeName));
    if (await target.exists() && await target.length() > 0) {
      onProgress?.call(1);
      return target;
    }

    final File partial = File('${target.path}.part');
    if (await partial.exists()) {
      await partial.delete();
    }

    try {
      if (await isHls(url)) {
        await _downloadHls(url, partial, onProgress: onProgress);
      } else {
        await _dio.download(
          url,
          partial.path,
          onReceiveProgress: (int received, int total) {
            if (total > 0) {
              onProgress?.call(received / total);
            }
          },
          options: Options(followRedirects: true),
        );
      }
      if (!await partial.exists() || await partial.length() == 0) {
        throw const FileSystemException('下载后的视频文件为空');
      }
      return partial.rename(target.path);
    } catch (_) {
      if (await partial.exists()) {
        await partial.delete();
      }
      rethrow;
    }
  }

  static Future<void> _downloadHls(
    String entryUrl,
    File target, {
    AiVideoProgress? onProgress,
  }) async {
    String playlistUrl = entryUrl;
    int depth = 0;
    AiHlsPlaylist playlist =
        await _loadPlaylist(playlistUrl, recursionDepth: depth);

    while (playlist.variants.isNotEmpty) {
      depth++;
      playlistUrl = playlist.variants.last;
      playlist = await _loadPlaylist(playlistUrl, recursionDepth: depth);
    }

    if (playlist.encrypted) {
      throw const FormatException('暂不支持加密的 M3U8 视频');
    }
    if (playlist.hasByteRange) {
      throw const FormatException('暂不支持 BYTERANGE 类型的 M3U8 视频');
    }
    if (playlist.hasInitMap) {
      throw const FormatException('暂不支持 fMP4 分片的 M3U8 视频');
    }
    if (playlist.segments.isEmpty) {
      throw const FormatException('M3U8 中未找到 TS 视频分片');
    }

    final IOSink sink = target.openWrite();
    try {
      for (int i = 0; i < playlist.segments.length; i++) {
        final Response<List<int>> response = await _dio.get<List<int>>(
          playlist.segments[i],
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
          ),
        );
        final List<int>? bytes = response.data;
        if (bytes == null || bytes.isEmpty) {
          throw FileSystemException('视频分片下载为空', playlist.segments[i]);
        }
        sink.add(bytes);
        onProgress?.call((i + 1) / playlist.segments.length);
      }
      await sink.flush();
    } finally {
      await sink.close();
    }
  }

  static Future<AiHlsPlaylist> _loadPlaylist(
    String url, {
    required int recursionDepth,
  }) async {
    if (recursionDepth > 3) {
      throw const FormatException('M3U8 主播放列表层级过深');
    }
    try {
      final Response<String> response = await _dio.get<String>(
        url,
        options: Options(
          responseType: ResponseType.plain,
          followRedirects: true,
        ),
      );
      final String text = response.data ?? '';
      if (!text.trimLeft().startsWith('#EXTM3U')) {
        throw const FormatException('服务端返回的内容不是有效 M3U8');
      }
      return parseAiHlsPlaylist(text, url);
    } on DioError catch (e) {
      l.d('loadPlaylist error: $e');
      return const AiHlsPlaylist();
    }
  }

  static bool _isHlsMime(String contentType) {
    final String mime = contentType.toLowerCase();
    return mime.contains('mpegurl') || mime.contains('vnd.apple.mpegurl');
  }

  static String _safeMp4Name(String raw) {
    String value = raw.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_.-]'), '_');
    if (value.isEmpty) {
      value = DateTime.now().millisecondsSinceEpoch.toString();
    }
    if (!value.toLowerCase().endsWith('.mp4')) {
      value = '$value.mp4';
    }
    return value;
  }
}

class AiHlsPlaylist {
  const AiHlsPlaylist({
    this.variants = const <String>[],
    this.segments = const <String>[],
    this.encrypted = false,
    this.hasByteRange = false,
    this.hasInitMap = false,
  });

  final List<String> variants;
  final List<String> segments;
  final bool encrypted;
  final bool hasByteRange;
  final bool hasInitMap;
}

/// 解析 AI 视频的 HLS 播放列表，供业务代码和单元测试复用。
AiHlsPlaylist parseAiHlsPlaylist(String text, String baseUrl) {
  final List<String> lines = text
      .split(RegExp(r'\r?\n'))
      .map((String line) => line.trim())
      .where((String line) => line.isNotEmpty)
      .toList();

  final List<String> variants = <String>[];
  final List<String> segments = <String>[];
  bool encrypted = false;
  bool hasByteRange = false;
  bool hasInitMap = false;

  for (int i = 0; i < lines.length; i++) {
    final String line = lines[i];
    if (line.startsWith('#EXT-X-KEY') && !line.contains('METHOD=NONE')) {
      encrypted = true;
    }
    if (line.startsWith('#EXT-X-BYTERANGE')) {
      hasByteRange = true;
    }
    if (line.startsWith('#EXT-X-MAP')) {
      hasInitMap = true;
    }
    if (line.startsWith('#EXT-X-STREAM-INF')) {
      final String? value = _nextPlaylistValue(lines, i + 1);
      if (value != null) {
        variants.add(_resolveHlsReference(baseUrl, value));
      }
    }
    if (line.startsWith('#EXTINF')) {
      final String? value = _nextPlaylistValue(lines, i + 1);
      if (value != null) {
        segments.add(_resolveHlsReference(baseUrl, value));
      }
    }
  }

  return AiHlsPlaylist(
    variants: variants,
    segments: segments,
    encrypted: encrypted,
    hasByteRange: hasByteRange,
    hasInitMap: hasInitMap,
  );
}

String? _nextPlaylistValue(List<String> lines, int start) {
  for (int i = start; i < lines.length; i++) {
    final String value = lines[i];
    if (!value.startsWith('#')) return value;
  }
  return null;
}

String _resolveHlsReference(String baseUrl, String reference) {
  final Uri? base = Uri.tryParse(baseUrl);
  if (base == null) return reference;
  return base.resolve(reference).toString();
}
