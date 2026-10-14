import 'dart:async';
import 'dart:convert';

import 'package:comics_app/common/http/http_request.dart';
import 'package:comics_app/common/store/config.dart';
import 'package:comics_app/common/utils/array_util.dart';
import 'package:comics_app/common/utils/logger.dart';
import 'package:comics_app/common/utils/text_util.dart';
import 'package:comics_app/common/values/config.dart';
import 'package:dio/dio.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';

import 'CustomHttpClientAdapter.dart';
import 'base_resp_bean.dart';
import 'http_detect_line_dio.dart' as line_dio;
import 'http_resp_interceptor.dart' show maybeDecryptGatewayResultEnvelope;

class DetectLineManager {
  final Dio _dio = line_dio.createDio();

  // 取消列表
  final _cancelList = <CancelToken>[];

  Future<String> detectLineOnce() async {
    var line = await _detectLineOnce();
    if (TextUtil.isNotEmpty(line)) {
      for (var it in _cancelList) {
        it.cancel();
      }
      _cancelList.clear();
      return line;
    }
    return line;
  }

  /// 一次完整的批量选线过程：
  /// 先 ping 拉池写下来的 [Config.DEFAULT_BASE_HOST]（命中即返回），
  /// 不可用再并发 ping [Config.BASE_HOSTS_REPLACE]。
  ///
  /// 测试 / 正式两套环境现在都先经 [detectLineFromPools] 拉对应池子写入
  /// [Config.DEFAULT_BASE_HOST] / [Config.BASE_HOSTS_REPLACE]，所以这里不再
  /// 按 [Config.DEBUG] 单独 ping [Config.BASE_HOSTS_DEBUG]（那批 URL 现在是
  /// 「测试域名池入口」而非可直接 ping 的 base host）。
  Future<String> _detectLineOnce() async {
    final String defaultHost = Config.DEFAULT_BASE_HOST.trim();
    if (TextUtil.isNotEmpty(defaultHost)) {
      l.d('选线优先默认域名:$defaultHost', tag: 'selectLine');
      final CancelToken cancelToken = CancelToken();
      _cancelList.add(cancelToken);
      final bool defaultOk = await _pingCheck(defaultHost, cancelToken);
      _cancelList.remove(cancelToken);
      if (defaultOk) {
        FBroadcast.instance().broadcast("closeLoadingDialog");
        return defaultHost;
      }
      l.d('_detectLineOnce()...默认域名不可用，轮询备用域名池', tag: 'selectLine');
    }
    final List<String> lines = Config.BASE_HOSTS_REPLACE
        .map((e) => e.trim())
        .where((s) => TextUtil.isNotEmpty(s))
        .where((s) => s != defaultHost)
        .toList();
    l.d('当前选线域名(备用池):$lines', tag: 'selectLine');
    return _pingCheckPatch(lines);
  }

  ///检查一批线路
  Future<String> _pingCheckPatch(List<String> lines) async {
    if (ArrayUtil.isEmpty(lines)) return "";
    //开启一连串异步任务
    Completer<String> completer = Completer();
    var listFuture = <Future<bool>>[];
    List<String> pingOKList = [];

    Future.forEach(lines, (line) {
      if (TextUtil.isNotEmpty(line.toString())) {
        listFuture.add((String s) async {
          l.d("_selectLineOnce()...开始选线:$s", tag: 'selectLine');
          final cancelToken = CancelToken();
          _cancelList.add(cancelToken);
          final bool suc = await _pingCheck(s, cancelToken);
          _cancelList.remove(cancelToken);
          if (suc) {
            if (completer.isCompleted) {
              pingOKList.add(s);
            } else {
              completer.complete(s);
              FBroadcast.instance().broadcast("closeLoadingDialog");
            }
          } else {
            l.d("_selectLineOnce()...线路不可用:$s");
          }
          return suc;
        }(line.toString()));
      }
    });

    Future.wait<bool>(listFuture).whenComplete(() {
      if (completer.isCompleted) {
        l.d("_selectLineOnce()...is already success", tag: "selectLine");
        return;
      }
      if (pingOKList.isNotEmpty) {
        completer.complete(pingOKList[0]);
        FBroadcast.instance().broadcast("closeLoadingDialog");
      } else {
        l.d("_selectLineOnce()...not avalible line}", tag: 'selectLine');
        completer.complete('');
      }
    });
    return completer.future;
  }

  /// 单次网络请求：经网关 POST `…/a/main/request`，内层 GET jwt-token（与业务一致）。
  Future<bool> _pingCheck(String line, [CancelToken? cancelToken]) async {
    return _pingCheckViaGateway(line, cancelToken);
  }

  /// 文档：业务请求经 POST `…/a/main/request`，内层 GET [Config.JWT_TOKEN_API_PATH]
  Future<bool> _pingCheckViaGateway(String line,
      [CancelToken? cancelToken]) async {
    late Response resp;
    final String probeUrl =
        _appendPathSuffix(line, HttpRequest.mainGatewayRequestPath());
    try {
      final String machineCode = await ConfigStore.to.getUniqueId();
      final Map<String, dynamic> headers = <String, dynamic>{
        'Content-Type': 'application/json;charset=UTF-8',
        'machineCode': machineCode,
        'api_version': '1.0.0',
        'device': await ConfigStore.to.getDevType(),
        'User-Agent': await HttpRequest().userAgent(),
      };

      final int ts = HttpRequest().getFixedCurTime().millisecondsSinceEpoch;
      // 与正式请求一致：内层 uri = [JWT_TOKEN_API_PATH]（不拼选线 host）
      final String innerUri =
          HttpRequest.normalizeGatewayInnerUri(Config.JWT_TOKEN_API_PATH);

      final Map<String, dynamic> envelope =
          HttpRequest.buildMainGatewayRequestBody(
        timeMillis: ts,
        innerUri: innerUri,
        method: MainGatewayMethod.get,
      );

      resp = await _dio.post(
        probeUrl,
        data: envelope,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
    } catch (e) {
      _logPingTransportError(probeUrl, e);
      return false;
    }
    if (resp.statusCode != HttpStatus.ok) {
      return false;
    }
    final Map<String, dynamic>? respMap = _parseResponseMap(resp.data);
    if (respMap == null) {
      return false;
    }
    maybeDecryptGatewayResultEnvelope(respMap);
    final BaseRespBean baseResp = BaseRespBean.fromJson(respMap);
    if (TextUtil.isNotEmpty(baseResp.time ?? '')) {
      HttpRequest().setServerTime(baseResp.time);
    }
    return baseResp.isSuccess;
  }

  void _logPingTransportError(String url, Object e) {
    if (e is DioError) {
      l.d(
        'pingCheck 传输失败 url=$url type=${e.type} msg=${e.message} '
        'status=${e.response?.statusCode}',
        tag: 'selectLine',
      );
    } else {
      l.d('pingCheck error url=$url err=$e', tag: 'selectLine');
    }
  }

  /// [suffix] 以 `/` 开头（业务 path 或 `/a/main/request`）
  String _appendPathSuffix(String line, String suffix) {
    final String host = line.trim();
    try {
      final Uri uri = Uri.parse(host);
      String path = uri.path;
      if (path == '/') {
        path = '';
      } else if (path.endsWith('/')) {
        path = path.substring(0, path.length - 1);
      }
      return uri
          .replace(path: '$path$suffix', query: null, fragment: null)
          .toString();
    } catch (_) {
      if (host.endsWith('/')) {
        return '${host.substring(0, host.length - 1)}$suffix';
      }
      return '$host$suffix';
    }
  }

  /// 依次轮询当前环境对应的域名池：每条池子地址 [fetchDomainPool] →
  /// 拉取成功后立刻 [detectLineOnce] 在该池子下选线。任一池子选出可用 host 即返回，
  /// 否则继续下一条；池子全部用完仍未命中返回 `''`。
  ///
  /// 池子来源按 [Config.DEBUG] 分流：
  ///   * 测试包（`DEBUG=true`）→ [Config.BASE_HOSTS_DEBUG]
  ///   * 正式包（`DEBUG=false`）→ [Config.DOMAIN_POOL_URLS]
  ///
  /// 与旧实现「单池子拉一次 + 单轮选线」相比，新流程把「池子轮询」做成最外层循环，
  /// 由 caller（如 [SplashLogic._checkNetAlways]）继续在更外层无限重试。
  Future<String> detectLineFromPools() async {
    final List<String> sourcePool =
        Config.DEBUG ? Config.BASE_HOSTS_DEBUG : Config.DOMAIN_POOL_URLS;
    const String poolTag =
        Config.DEBUG ? 'BASE_HOSTS_DEBUG' : 'DOMAIN_POOL_URLS';
    final List<String> poolUrls = sourcePool
        .map((e) => e.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (poolUrls.isEmpty) {
      l.d(
        'detectLineFromPools() $poolTag 为空，回退到已有域名直接选线',
        tag: 'selectLine',
      );
      return detectLineOnce();
    }
    for (int i = 0; i < poolUrls.length; i++) {
      final String poolUrl = poolUrls[i];
      l.d(
        'detectLineFromPools() 尝试第 ${i + 1}/${poolUrls.length} 个域名池($poolTag): $poolUrl',
        tag: 'selectLine',
      );
      final bool poolOk = await fetchDomainPool(poolUrl);
      if (!poolOk) {
        l.d('detectLineFromPools() 域名池拉取失败，尝试下一条', tag: 'selectLine');
        continue;
      }
      final String line = await detectLineOnce();
      if (TextUtil.isNotEmpty(line)) {
        return line;
      }
      l.d('detectLineFromPools() 当前池子无可用线，尝试下一条域名池',
          tag: 'selectLine');
    }
    l.d('detectLineFromPools() 所有域名池均无可用线', tag: 'selectLine');
    return '';
  }

  /// 通过 Dio 拉取指定 [url] 域名池，写入 [Config.DEFAULT_BASE_HOST]、
  /// [Config.BASE_HOSTS_REPLACE]。
  ///
  /// 注意：每次调用都会覆盖上述全局状态（在响应里有 `result`/`pool` 字段时），
  /// 因此 [detectLineFromPools] 串行调用是安全的；外部如需并发请自行加锁。
  Future<bool> fetchDomainPool(String url) async {
    final String target = url.trim();
    if (target.isEmpty) {
      l.d('fetchDomainPool() url 为空', tag: 'selectLine');
      return false;
    }
    final Dio dio = line_dio.createDio(
      options: BaseOptions(
        connectTimeout: 10000,
        receiveTimeout: 10000,
        sendTimeout: 10000,
      ),
    );
    if (Config.DNS_CUSTOM && TextUtil.isNotEmpty(Config.DNS_IP)) {
      dio.httpClientAdapter = CustomHttpClientAdapter(Config.DNS_IP);
    }
    late final Response resp;
    try {
      resp = await dio.request(
        target,
        options: Options(method: 'GET', responseType: ResponseType.plain),
      );
    } catch (e) {
      l.d('fetchDomainPool() error url=$target err=$e', tag: 'selectLine');
      return false;
    }
    if (resp.statusCode != HttpStatus.ok) {
      l.d('fetchDomainPool() bad status: ${resp.statusCode} url=$target',
          tag: 'selectLine');
      return false;
    }
    final Map<String, dynamic>? root = _parseResponseMap(resp.data);
    if (root == null) {
      l.d('fetchDomainPool() parse failed url=$target', tag: 'selectLine');
      return false;
    }
    Map<String, dynamic> fields = root;
    final dynamic dataNode = root['data'];
    if (dataNode is Map &&
        (dataNode.containsKey('result') || dataNode.containsKey('pool'))) {
      fields = Map<String, dynamic>.from(dataNode);
    }
    if (fields.containsKey('result')) {
      final dynamic resultVal = fields['result'];
      if (resultVal is String) {
        Config.DEFAULT_BASE_HOST = resultVal.trim();
      } else if (resultVal != null) {
        Config.DEFAULT_BASE_HOST = resultVal.toString().trim();
      } else {
        Config.DEFAULT_BASE_HOST = '';
      }
    }
    if (fields.containsKey('pool')) {
      Config.BASE_HOSTS_REPLACE = _parsePoolList(fields['pool']);
    }
    l.d(
      'fetchDomainPool() ok url=$target default:${Config.DEFAULT_BASE_HOST} pool:${Config.BASE_HOSTS_REPLACE.length}',
      tag: 'selectLine',
    );
    return true;
  }

  Map<String, dynamic>? _parseResponseMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return Map<String, dynamic>.from(raw);
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(
          raw.map((k, v) => MapEntry(k.toString(), v)));
    }
    if (raw is String) {
      var s = raw.trim();
      if (s.startsWith('\uFEFF')) {
        s = s.substring(1);
      }
      if (s.isEmpty) {
        return null;
      }
      try {
        final decoded = json.decode(s);
        return _parseResponseMap(decoded);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  List<String> _parsePoolList(dynamic poolVal) {
    if (poolVal == null) {
      return [];
    }
    if (poolVal is List) {
      return poolVal
          .map((e) => e?.toString().trim() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (poolVal is String) {
      final s = poolVal.trim();
      if (s.isEmpty) {
        return [];
      }
      try {
        final decoded = json.decode(s);
        if (decoded is List) {
          return _parsePoolList(decoded);
        }
      } catch (_) {
        // 逗号分隔
        return s
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }
    return [];
  }

}
