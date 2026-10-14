import 'dart:convert';

import 'package:comics_app/common/http/gateway_crypto.dart';
import 'package:comics_app/common/http/http_header_interceptor.dart';
import 'package:comics_app/common/http/http_resp_interceptor.dart';
import 'package:comics_app/common/http/logInterceptor.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/text_util.dart';
import 'package:comics_app/common/values/address.dart';
import 'package:comics_app/common/values/config.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'CustomHttpClientAdapter.dart';
import 'http_gateway_log.dart';
import 'http_signature_interceptor.dart';

/// 文档《接口加密流程》网关内层 [method]：1 GET、2 POST、3 PUT。
abstract final class MainGatewayMethod {
  MainGatewayMethod._();
  static const int get = 1;
  static const int post = 2;
  static const int put = 3;
}

class HTTPConfig {
  static const String baseURL = 'https://wbsqht.cestalt.com';

  /// 连接超时时间
  static const int _connectTimeout = 15000;

  /// 接收超时时间
  static const int _receiveTimeout = 4000000;

  /// 发送超时时间
  static const int _sendTimeout = 15000;
}

class HttpRequest {
  static late Dio dio;

  final CancelToken _cancelToken = CancelToken();

  static String _originOf(String baseApiPath) {
    final Uri u = Uri.parse(baseApiPath);
    if (!u.hasScheme) {
      return baseApiPath;
    }
    return u.origin;
  }

  String _normApiPath(String path) {
    if (path.startsWith('/')) {
      return path;
    }
    return '/$path';
  }

  static String _trimSlashes(String s) {
    var t = s.trim();
    while (t.startsWith('/')) {
      t = t.substring(1);
    }
    while (t.endsWith('/')) {
      t = t.length > 1 ? t.substring(0, t.length - 1) : '';
    }
    return t;
  }

  /// 文档网关内层 [uri]：由 [baseApiPath] 的 path 与 [businessPath] 拼接，**不**自动补前导 `/`（结果不以 `/` 开头）。
  static String gatewayInnerUriForPath(String businessPath,
      {required String baseApiPath}) {
    final Uri root = Uri.parse(baseApiPath);
    String basePath = _trimSlashes(root.path);
    final String p = _trimSlashes(businessPath);
    if (basePath.isEmpty) {
      return p;
    }
    if (p.isEmpty) {
      return basePath;
    }
    return '$basePath/$p';
  }

  /// Dio 使用的网关相对路径，形如 `/a/main/request`（与 [Address.gatewayPath] 一致）。
  static String mainGatewayRequestPath() {
    final String p = Address.gatewayPath.trim();
    if (p.startsWith('/')) {
      return p;
    }
    return '/$p';
  }

  /// 与写入密文的内层 `uri` 一致：trim 并去掉首部 `/`（网关 uri **不**带前导 `/`）。
  static String normalizeGatewayInnerUri(String innerUri) {
    return _trimSlashes(innerUri);
  }

  /// 文档：POST body 仅含 [time]（毫秒时间戳）与 [data]（密文）。
  /// 密文明文 JSON：`uri`、`method`、`body`（JSON 字符串）、`params`（**JSON 字符串**，无参时为 `"{}"`）；密钥 `time % 密钥数组长度`。
  /// 外层 `data` 与 `gatewayCrypto.ts` 一致：AES-128-ECB PKCS7，密文纯 Base64。
  static Map<String, dynamic> buildMainGatewayRequestBody({
    required int timeMillis,
    required String innerUri,
    required int method,
    String bodyJson = '',
    Map<String, dynamic>? params,
  }) {
    final String key = pickGatewayEncryptKey(timeMillis);
    final String u = normalizeGatewayInnerUri(innerUri);
    final String paramsStr =
        params == null || params.isEmpty ? '{}' : jsonEncode(params);
    final Map<String, dynamic> inner = <String, dynamic>{
      'uri': u,
      'method': method,
      'body': bodyJson,
      'params': paramsStr,
    };
    return <String, dynamic>{
      'time': timeMillis,
      'data': encryptGatewayEnvelopeString(json.encode(inner), key),
    };
  }

  /// 将 [queryParameters] 转为网关内层 [params] 对象（空则 `{}`）。
  static Map<String, dynamic> gatewayParamsFromQuery(
      Map<String, dynamic>? queryParameters) {
    if (queryParameters == null || queryParameters.isEmpty) {
      return <String, dynamic>{};
    }
    return Map<String, dynamic>.from(queryParameters);
  }

  /// 文档统一网关：仅传业务 [uri]（全路径）、[method]、[body]（JSON 字符串）、[params]（对象，内层会序列化为 JSON 字符串）。
  ///
  /// [dio.baseUrl] 为选线域名根（仅 origin），实际请求 `POST /a/main/request`。
  Future<dynamic> requestMainGateway({
    required String uri,
    required int method,
    String body = '',
    Map<String, dynamic>? params,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    return _sendMainGatewayEnvelope(
      innerUri: uri,
      method: method,
      bodyJson: body,
      params: params,
      cancelToken: cancelToken,
      options: options,
    );
  }

  /// POST [mainGatewayRequestPath]，body 为 [buildMainGatewayRequestBody]。
  Future<dynamic> _sendMainGatewayEnvelope({
    required String innerUri,
    required int method,
    String bodyJson = '',
    Map<String, dynamic>? params,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    final int ts = getFixedCurTime().millisecondsSinceEpoch;
    final Map<String, dynamic> payload = buildMainGatewayRequestBody(
      timeMillis: ts,
      innerUri: innerUri,
      method: method,
      bodyJson: bodyJson,
      params: params,
    );
    final Options logOptions = HttpRequest._optionsWithGatewayInnerUriForLog(
      options,
      innerUri,
    );
    final Response response = await dio.post(
      mainGatewayRequestPath(),
      data: payload,
      cancelToken: cancelToken ?? _cancelToken,
      options: logOptions,
    );
    return response.data;
  }

  /// 供 [HttpLogInterceptor] 打印业务 path（而非 `/a/main/request`）。
  static Options _optionsWithGatewayInnerUriForLog(
    Options? options,
    String innerUri,
  ) {
    final Map<String, dynamic> extra =
        Map<String, dynamic>.from(options?.extra ?? <String, dynamic>{});
    extra[gatewayInnerUriLogExtraKey] = normalizeGatewayInnerUri(innerUri);
    if (options == null) {
      return Options(extra: extra);
    }
    return options.copyWith(extra: extra);
  }

  static init(String baseUrl) {
    // BaseOptions、Options、RequestOptions 都可以配置参数，优先级别依次递增，且可以根据优先级别覆盖参数
    final String effectiveBase = _originOf(baseUrl);
    BaseOptions options = BaseOptions(
      // 请求基地址,可以包含子路径
      baseUrl: effectiveBase,
      //连接服务器超时时间，单位是毫秒.
      connectTimeout: HTTPConfig._connectTimeout,
      // 响应流上前后两次接受到数据的间隔，单位为毫秒。
      receiveTimeout: HTTPConfig._receiveTimeout,
      // 发送数据 单位为毫秒。
      sendTimeout: HTTPConfig._sendTimeout,
      // Http请求头.
      headers: {},

      /// 请求的Content-Type，默认值是"application/json; charset=utf-8".
      /// 如果您想以"application/x-www-form-urlencoded"格式编码请求数据,
      /// 可以设置此选项为 `Headers.formUrlEncodedContentType`,  这样[Dio]
      /// 就会自动编码请求体.
      contentType: 'application/json; charset=utf-8',

      /// [responseType] 表示期望以那种格式(方式)接受响应数据。
      /// 目前 [ResponseType] 接受三种类型 `JSON`, `STREAM`, `PLAIN`.
      ///
      /// 默认值是 `JSON`, 当响应头中content-type为"application/json"时，dio 会自动将响应内容转化为json对象。
      /// 如果想以二进制方式接受响应数据，如下载一个二进制文件，那么可以使用 `STREAM`.
      ///
      /// 如果想以文本(字符串)格式接收响应数据，请使用 `PLAIN`.
      responseType: ResponseType.json,
    );
    dio = Dio(options);

    /// 日志
    /// Dio 4：响应拦截器按**添加顺序**执行，须先 [HttpRespInterceptor] 再 [HttpLogInterceptor]，
    /// 否则日志里仍是原始 Map，且 `logInterceptor` 对 `hash==null` 的判断会触发 bool 转型异常。
    dio.interceptors.add(HttpHeaderInterceptor());
    dio.interceptors.add(SignatureInterceptor());
    dio.interceptors.add(HttpRespInterceptor());
    dio.interceptors.add(HttpLogInterceptor());

    if (Config.DNS_CUSTOM && TextUtil.isNotEmpty(Config.DNS_IP)) {
      dio.httpClientAdapter = CustomHttpClientAdapter(Config.DNS_IP);
    }
  }

  static reset() {
    init(Address.baseApiPath);
  }

  //获取ua
  Future<String> userAgent() async {
    const bool kIsWeb = identical(0, 0.0);
    late String? userAgent;
    if (kIsWeb) {
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      var deviceData = await deviceInfoPlugin.webBrowserInfo;
      userAgent = deviceData.userAgent;
    } else {
      userAgent = await _genUserAgent();
    }
    return userAgent ?? "";
  }

  //生成ua
  Future<String> _genUserAgent() async {
    String deviceId = await ConfigStore.to.getUniqueId();
    ConfigStore configStore = ConfigStore.to;
    String devType = await configStore.getDevType();
    String sysType = configStore.getSysType();
    String version = configStore.version;
    PackageInfo? packageInfo = await configStore.getPlatform();
    String ua = Uri.encodeComponent(
        "DevID=$deviceId;DevType=$devType;SysType=$sysType;Ver=$version;BuildID=${packageInfo?.packageName}");
    return ua;
  }

  /// restful get 操作
  Future get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    return _sendMainGatewayEnvelope(
      innerUri: gatewayInnerUriForPath(path, baseApiPath: Address.baseApiPath),
      method: MainGatewayMethod.get,
      params: gatewayParamsFromQuery(queryParameters),
      cancelToken: cancelToken,
      options: options,
    );
  }

  /// restful post 操作
  Future post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    final String bodyJson =
        data == null ? '' : (data is String ? data : jsonEncode(data));
    return _sendMainGatewayEnvelope(
      innerUri: gatewayInnerUriForPath(path, baseApiPath: Address.baseApiPath),
      method: MainGatewayMethod.post,
      bodyJson: bodyJson,
      params: gatewayParamsFromQuery(queryParameters),
      cancelToken: cancelToken,
      options: options,
    );
  }

  /// restful put 操作
  Future put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    final String bodyJson =
        data == null ? '' : (data is String ? data : jsonEncode(data));
    return _sendMainGatewayEnvelope(
      innerUri: gatewayInnerUriForPath(path, baseApiPath: Address.baseApiPath),
      method: MainGatewayMethod.put,
      bodyJson: bodyJson,
      params: gatewayParamsFromQuery(queryParameters),
      cancelToken: cancelToken,
      options: options,
    );
  }

  /// restful patch 操作
  Future patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    // 文档仅定义 GET/POST/PUT；PATCH 按 PUT 透传
    final String bodyJson =
        data == null ? '' : (data is String ? data : jsonEncode(data));
    return _sendMainGatewayEnvelope(
      innerUri: gatewayInnerUriForPath(path, baseApiPath: Address.baseApiPath),
      method: MainGatewayMethod.put,
      bodyJson: bodyJson,
      params: gatewayParamsFromQuery(queryParameters),
      cancelToken: cancelToken,
      options: options,
    );
  }

  /// restful patch 操作
  Future delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    final bool hasBody = data != null;
    if (hasBody) {
      final String bodyJson = data is String ? data : jsonEncode(data);
      return _sendMainGatewayEnvelope(
        innerUri:
            gatewayInnerUriForPath(path, baseApiPath: Address.baseApiPath),
        method: MainGatewayMethod.post,
        bodyJson: bodyJson,
        params: gatewayParamsFromQuery(queryParameters),
        cancelToken: cancelToken,
        options: options,
      );
    }
    return _sendMainGatewayEnvelope(
      innerUri: gatewayInnerUriForPath(path, baseApiPath: Address.baseApiPath),
      method: MainGatewayMethod.get,
      params: gatewayParamsFromQuery(queryParameters),
      cancelToken: cancelToken,
      options: options,
    );
  }

  /// Multipart 表单上传。网关信封仅支持 JSON 密文，与 [FormData] 不兼容，故仍 POST 至 [Address.baseApiPath] 完整业务 URL。
  Future postForm(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    final String abs = '${Address.baseApiPath}${_normApiPath(path)}';
    final Response response = await dio.post(
      abs,
      data: FormData.fromMap(data),
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return response.data;
  }

  /// restful post Stream 流数据
  Future postStream(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    final String abs = '${Address.baseApiPath}${_normApiPath(path)}';
    final Response response = await dio.post(
      abs,
      data: Stream.fromIterable(data.map((e) => [e])),
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return response.data;
  }

  ///下载文件
  Future downApk(
    String path,
    String savePath, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onReceiveProgress,
  }) async {
    final String abs = path.startsWith('http')
        ? path
        : '${Address.baseApiPath}${_normApiPath(path)}';
    final Response response = await dio.download(
      abs,
      savePath,
      options: options,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken ?? _cancelToken,
    );

    return response.data;
  }

  /// 服务器时间
  DateTime? _serverTime;

  /// 服务器时间和本地时间的差值
  int _diffTimeInSeconds = 0;

  /// 获取上一次服务器返回的时间
  DateTime? getServerTime() {
    if (null != _serverTime) {
      return _serverTime;
    } else {
      return DateTime.now();
    }
  }

  /// 设置服务器时间（ISO8601 字符串，或 **毫秒** 时间戳数字串，如网关根级 `time`）。
  void setServerTime(String? serverTimeS) {
    if (serverTimeS == null || serverTimeS.trim().isEmpty) {
      return;
    }
    final String s = serverTimeS.trim();
    try {
      final int? epoch = int.tryParse(s);
      if (epoch != null && s.length >= 12) {
        _serverTime = DateTime.fromMillisecondsSinceEpoch(epoch);
      } else if (epoch != null && s.length >= 10) {
        _serverTime = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
      } else {
        _serverTime = DateTime.parse(s);
      }
      _diffTimeInSeconds = DateTime.now().difference(_serverTime!).inSeconds;
    } catch (_) {}
  }

  /// 获取修复后的本地时间,应该是和服务器时间是同步的
  DateTime getFixedCurTime() {
    return DateTime.now().add(Duration(seconds: -_diffTimeInSeconds));
  }
}
