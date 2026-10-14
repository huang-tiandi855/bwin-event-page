import 'package:dio/dio.dart';

final _defaultOptions = BaseOptions(
  connectTimeout: 1000 * 5,
  receiveTimeout: 1000 * 5,
);

Dio createDio({BaseOptions? options}) {
  options ??= _defaultOptions;
  // dio 原生会加上 request header:accept-encoding gzip，导致部分请求失败
  // options.headers[HttpHeaders.acceptEncodingHeader] = "*";
  var dio = Dio(options);
  return dio;
}
