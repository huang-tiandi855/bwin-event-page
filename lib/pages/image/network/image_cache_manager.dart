import 'dart:io';

import 'package:comics_app/common/http/http_detect_line_dio.dart';
import 'package:comics_app/common/utils/array_util.dart';
import 'package:comics_app/common/utils/logger.dart';
import 'package:comics_app/common/utils/text_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'decrypt_image.dart';

class ImgCacheMgr extends CacheManager with ImageCacheManager {
  static const key = "customCache";

  static final ImgCacheMgr _instance = ImgCacheMgr._();

  factory ImgCacheMgr() {
    return _instance;
  }

  ImgCacheMgr._()
      : super(Config(key,
            maxNrOfCacheObjects: 100,
            stalePeriod: const Duration(days: 7),
            fileService: CustomFileRespons()));

  /// 与包内 [IOFileSystem] 一致：`getTemporaryDirectory()/[key]/` 下文件总字节数。
  Future<int> diskCacheFolderBytes() async {
    final base = await getTemporaryDirectory();
    final root = Directory(p.join(base.path, key));
    if (!await root.exists()) return 0;
    var total = 0;
    await for (final ent in root.list(recursive: true, followLinks: false)) {
      if (ent is File) {
        try {
          total += await ent.length();
        } on Object {
          // 并发删除等导致 length 失败时跳过
        }
      }
    }
    return total;
  }
}

class CustomFileRespons extends HttpFileService {
  final Dio _dio = createDio(
    options: BaseOptions(
      connectTimeout: 15000,
      receiveTimeout: 15000,
      sendTimeout: 15000,
    ),
  );

  @override
  Future<FileServiceResponse> get(String url,
      {Map<String, String>? headers}) async {
    l.d("get()...begin...ulr:$url...", tag: 'image_request');
    headers?['cache-control'] = 'max-age=31104000';
    var resp = await _dio.request(url,
        options: Options(responseType: ResponseType.bytes, method: "GET"));

    Map<String, String> respHeaders = {};
    var contentLengthS = "0";
    resp.headers.forEach((key, arrayValue) {
      if (ArrayUtil.isNotEmpty(arrayValue)) {
        respHeaders[key] = arrayValue[0];
      }
    });
    final List? array = resp.headers["Content-Length"];
    if (ArrayUtil.isNotEmpty(array)) {
      contentLengthS = array![0];
    }

    int contentLength = int.parse(
        TextUtil.isNotEmpty(contentLengthS[0]) ? contentLengthS : "0");
    if (contentLength <= 0) {
      contentLength = resp.data?.length ?? 0;
    }
    StreamedResponse streamedResponse = StreamedResponse(
      Stream.fromFuture(Future.value(decryptImage(resp.data))),
      resp.statusCode ?? HttpStatus.badRequest,
      contentLength: contentLength,
      headers: respHeaders,
    );
    return HttpGetResponse(streamedResponse);
  }
}
