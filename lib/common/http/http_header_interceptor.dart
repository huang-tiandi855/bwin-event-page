import 'package:comics_app/common/http/http_request.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:dio/dio.dart';

/// 验签拦截器，主要是做接口安全，加时间戳，加盐，加crc
class HttpHeaderInterceptor extends InterceptorsWrapper {
  @override
  onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // TODO: implement onRequest
    String devType = await ConfigStore.to.getDevType();
    const bool kIsWeb = identical(0, 0.0);
    final bool skipJwtBootstrap = options.extra['skipJwtAuth'] ==
        true; // 文档：获取 JwtToken 的请求仅带 machineCode

    if (!skipJwtBootstrap) {
      final String? jwt = UserStore.to.getJwtToken();
      if (jwt != null && jwt.isNotEmpty) {
        options.headers["jwtToken"] = jwt;
      }
      final String? sessionToken = UserStore.to.getToken();
      if (sessionToken != null && sessionToken.isNotEmpty) {
        options.headers["Authorization"] = sessionToken;
      }
      final String? accessToken = UserStore.to.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers["accessToken"] = accessToken;
      }
    }
    if (options.method == "GET") {
      options.headers["Content-Type"] = "application/x-www-form-urlencoded";
    } else if (options.method == "POST") {
      options.headers["Content-Type"] = "application/json;charset=UTF-8";
    }
    if (!kIsWeb) {
      options.headers["User-Agent"] = await HttpRequest().userAgent();
    }
    options.headers["api_version"] = "1.0.0";
    options.headers["device"] = devType;
    super.onRequest(options, handler);
  }
}
