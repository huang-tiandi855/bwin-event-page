import 'dart:convert';

import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/http/gateway_crypto.dart'
    show decryptGatewayCipherWithResponseTime, decryptGatewayEnvelopeString, pickGatewayEncryptKey;
import 'package:comics_app/common/utils/logger.dart';
import 'package:comics_app/common/values/config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'http_gateway_log.dart';

/// 网络日志拦截器
class HttpLogInterceptor extends InterceptorsWrapper {
  static const String TAG = "http_log";

  HttpLogInterceptor();

  static String _logPath(RequestOptions options) {
    final dynamic v = options.extra[gatewayInnerUriLogExtraKey];
    if (v is String && v.trim().isNotEmpty) {
      return v.trim();
    }
    return options.path;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: implement onRequest
    l.d('################# BEGIN REQUEST #####################', tag: TAG);
    l.d(
        'method:${options.method}  path:${_logPath(options)} url:${options.uri.toString()}',
        tag: TAG);
    if (options.method == "POST") {
      l.d('bodyParam:${options.data.toString()} extra:${options.extra.toString()}',
          tag: TAG);
      _logDecryptedGatewayRequestBodyIfEnabled(options);
    } else if (options.method == "GET") {
      l.d('queryParam:${options.queryParameters.toString()} extra:${options.extra.toString()}',
          tag: TAG);
    }
    l.d('header:${options.headers.toString()}', tag: TAG);
    l.d(
      '################# END REQUEST #####################\n',
      tag: TAG,
    );
    super.onRequest(options, handler);
  }

  /// 网关 POST：`{ time, data }` 中 [data] 为 AES-128-ECB 信封密文，按 [time] 选密钥解密后打印内层 JSON。
  static void _logDecryptedGatewayRequestBodyIfEnabled(RequestOptions options) {
    if (!Config.GATEWAY_LOG_DECRYPT_REQUEST_BODY) {
      return;
    }
    final dynamic raw = options.data;
    if (raw is! Map) {
      return;
    }
    final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
    final dynamic timeVal = map['time'];
    final dynamic dataVal = map['data'];
    if (dataVal is! String || dataVal.trim().isEmpty) {
      return;
    }
    int timeMillis = 0;
    if (timeVal is int) {
      timeMillis = timeVal;
    } else if (timeVal is String) {
      timeMillis = int.tryParse(timeVal) ?? 0;
    }
    if (timeMillis == 0) {
      return;
    }
    try {
      final String key = pickGatewayEncryptKey(timeMillis);
      final String plain = decryptGatewayEnvelopeString(
        dataVal,
        key,
        logDecryptedPlaintext: false,
      );
      String out = plain;
      try {
        final Object? decoded = json.decode(plain);
        out = const JsonEncoder.withIndent('  ').convert(decoded);
      } catch (_) {}
      l.d('bodyParam decrypted (inner):\n$out', tag: TAG);
    } catch (e) {
      l.d('bodyParam decrypt failed: $e', tag: TAG);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // TODO: implement onResponse
    if (kDebugMode) {
      l.d('################# BEGIN RESPONSE #####################', tag: TAG);
      l.d(
          'url:${response.requestOptions.uri}  path:${_logPath(response.requestOptions)}',
          tag: TAG);
      final dynamic raw = response.data;
      if (raw is BaseRespBean) {
        final BaseRespBean b = raw;
        if (b.hash == true && b.data != null) {
          final String cipher =
              b.data is String ? b.data as String : b.data.toString();
          try {
            final String enData =
                decryptGatewayCipherWithResponseTime(cipher, b.time);
            l.d('begin resp: $enData', tag: TAG);
          } catch (_) {}
        }
      } else if (raw is Map) {
        final Map<String, dynamic> newData =
            Map<String, dynamic>.from(json.decode(json.encode(raw)) as Map);
        if (newData['hash'] == true && newData['data'] != null) {
          final String cipher = newData['data'].toString();
          try {
            final String enData = decryptGatewayCipherWithResponseTime(
              cipher,
              newData['time'],
            );
            l.d('begin resp: $enData', tag: TAG);
          } catch (_) {}
        }
      }

      l.d('################# END RESPONSE #####################', tag: TAG);
    }
    super.onResponse(response, handler);
  }
}
