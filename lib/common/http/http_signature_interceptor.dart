import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

import '../store/user.dart';
import '../values/config.dart';
import 'http_request.dart';

/// 验签拦截器，主要是做接口安全，加时间戳，加盐，加crc
class SignatureInterceptor extends InterceptorsWrapper {
  @override
  onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    Uri? baseUri = Uri.tryParse(options.baseUrl);
    Uri(
        scheme: baseUri?.scheme,
        host: baseUri?.host,
        port: baseUri?.port,
        path: (baseUri?.path ?? '') + options.path);
    //options.headers["x-api-key"] = await sign(targetUri.path);
    super.onRequest(options, handler);
  }

  ///生成签名
  static Future<String> sign(String path) async {
    Map<String, dynamic> signObj = {};
    int timestamp =
        HttpRequest().getFixedCurTime().toUtc().millisecondsSinceEpoch ~/ 1000;

    signObj['nonce'] = const Uuid().v4();

    signObj['path'] = path;
    signObj['timestamp'] = timestamp.toString();
    signObj['token'] = UserStore.to.getToken();
    signObj['userAgent'] = await HttpRequest().userAgent();
    var key = utf8.encode(Config.ANTI_REPLAY_ATTACK_KEY);
    var bytes = utf8.encode(jsonEncode(signObj).toString());
    var sha1Encrypt = Hmac(sha1, key);
    var digest = sha1Encrypt.convert(bytes);
    return Future.value(
        'timestamp=$timestamp;sign=${digest.toString()};nonce=${signObj['nonce']}');
  }
}
