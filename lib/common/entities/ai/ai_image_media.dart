import 'dart:typed_data';

import 'package:comics_app/common/http/dio_cli.dart';
import 'package:comics_app/pages/image/network/decrypt_image.dart';
import 'package:comics_app/pages/image/network/network_image_urls.dart';
import 'package:dio/dio.dart';

/// AI 图片下载地址。
///
/// 后端可能直接返回完整下载链接，也可能返回图片 CDN 相对路径。完整链接与
/// H5 一致直接拉取；相对路径需要拼接图片线路并执行项目统一的图片解码。
class AiImageDownloadSource {
  const AiImageDownloadSource({
    required this.url,
    required this.shouldDecrypt,
  });

  final String url;
  final bool shouldDecrypt;
}

AiImageDownloadSource resolveAiImageDownloadSource(String pathOrUrl) {
  final String raw = pathOrUrl.trim();
  if (raw.isEmpty) {
    throw const FormatException('图片地址为空');
  }

  final Uri? uri = Uri.tryParse(raw);
  final bool isAbsoluteHttp = uri != null &&
      uri.hasScheme &&
      (uri.scheme.toLowerCase() == 'http' ||
          uri.scheme.toLowerCase() == 'https');
  if (isAbsoluteHttp) {
    return AiImageDownloadSource(url: raw, shouldDecrypt: false);
  }

  final String url = resolveCdnImageUrl(raw);
  if (url.isEmpty) {
    throw const FormatException('图片地址无效');
  }
  return AiImageDownloadSource(url: url, shouldDecrypt: true);
}

class AiImageMedia {
  AiImageMedia._();

  static final Dio _dio = createDio(
    options: BaseOptions(
      connectTimeout: 30 * 1000,
      receiveTimeout: 100 * 1000,
      validateStatus: (int? status) =>
          status != null && status >= 200 && status < 400,
    ),
  );

  /// 下载可直接写入相册的图片字节。
  static Future<Uint8List> downloadBytes(String pathOrUrl) async {
    final AiImageDownloadSource source =
        resolveAiImageDownloadSource(pathOrUrl);
    final Response<List<int>> response = await _dio.get<List<int>>(
      source.url,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
      ),
    );
    final List<int> data = response.data ?? const <int>[];
    if (data.isEmpty) {
      throw const FormatException('下载后的图片为空');
    }

    final Uint8List bytes = Uint8List.fromList(data);
    return source.shouldDecrypt ? decryptImage(bytes) : bytes;
  }
}
