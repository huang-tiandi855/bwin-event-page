import 'dart:convert';
import 'package:comics_app/common/http/app_exceptions.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/http/http_request.dart';
import 'package:comics_app/common/services/auth_service.dart';
import 'package:comics_app/common/services/jwt_token_service.dart';
import 'package:comics_app/common/utils/logger.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'code.dart';
import 'gateway_crypto.dart'
    show
        decryptGatewayCipherWithResponseTime,
        decryptGatewayEnvelopeString,
        pickGatewayEncryptKey;

/// 响应拦截器=>返回数据转换
class HttpRespInterceptor extends InterceptorsWrapper {
  static const String TAG = "HttpRespInterceptor";

  HttpRespInterceptor();

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handleResponse(response);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    AppException appException = AppException.create(err);
    err.error = appException;

    l.d('onError()...path:${err.response?.requestOptions.path} url:${err.response?.requestOptions.baseUrl} err:${err.toString()}',
        tag: 'resp_interceptor');
    super.onError(err, handler);
  }

  handleResponse(Response response) {
    BaseRespBean baseResp;
    if (response.statusCode != 200) {
      return Future.error(
          ApiException(response.statusCode, "statusCode is not 200"));
    }
    try {
      if (response.data is Map) {
        final Map<String, dynamic> raw =
            Map<String, dynamic>.from(response.data as Map);
        maybeDecryptGatewayResultEnvelope(raw);
        baseResp = BaseRespBean.fromJson(raw);
      } else if (response.data is String) {
        baseResp = BaseRespBean.fromJson(json.decode(response.data));
      } else {
        BaseRespBean baseRespBean =
            BaseRespBean(Code.LOCAL_RESPONSE_SHAPE_ERROR, msg: '数据返回异常');
        l.d("response.data is not map", tag: "http_log");
        return Future.value((baseRespBean));
      }
      HttpRequest().setServerTime(baseResp.time);

      // 仅当 [data] 仍为 **密文字符串** 时再解密。网关若已在外层把 [data] 解成 Map/List，
      // 但 [hash] 仍为 true 时，不能对 Map.toString() 再解密，否则会抛错并落入外层 catch，
      // 整包被替换成 [Code.NETWORK_ERROR]（config/query 等会表现为「数据处理异常」）。
      if (baseResp.hash == true) {
        final dynamic payload = baseResp.data;
        if (payload is String && payload.trim().isNotEmpty) {
          try {
            final String decryptData = decryptGatewayCipherWithResponseTime(
              payload.trim(),
              baseResp.time,
            );
            try {
              baseResp.data = json.decode(decryptData);
            } catch (_) {
              // 如 jwt-token：明文为 JWT 串本身，非 JSON
              baseResp.data = decryptData;
            }
          } catch (e) {
            l.d('HttpRespInterceptor hash decrypt failed: $e', tag: TAG);
          }
        }
      }
      if (baseResp.isSuccess) {
        var data = baseResp.data;
        baseResp.data = data;
      } else {
        switch (baseResp.code) {
          case Code.MUTE:
            showToast(msg: "您已被禁言");
            break;
          case Code.REDEMPTION_FAILED:
            showToast(msg: baseResp.tip ?? "兑换失败");
            break;
          case Code.DOC_TOKEN_EXPIRED:
          case Code.DOC_TOKEN_EMPTY:
            // 后台续期，不 await（拦截器是同步链路，await 会阻塞解析）；
            // [AuthService] 内部做单飞，并发 1019 只发一次 freeRegister。
            showToast(msg: "账号登录过期");
            AuthService.instance.ensureLogin(force: true).catchError((e) {
              l.d('token expired re-login failed: $e', tag: TAG);
            });
            break;
            case Code.DOC_JWT_TOKEN_EXPIRED:
            case Code.DOC_JWT_TOKEN_EMPTY:
            // 1034 — JwtToken 过期。文档码为字符串，无法纳入下方 [int?] switch，
            // 拆出来用 bizCode 比对。后台续期，不 await（拦截器是同步链路，
            // await 会阻塞解析）；[JwtTokenService] 内部单飞，并发 1034 只发
            // 一次 jwt-token，复用 [SplashLogic._ensureJwtToken] 的实现路径。
            JwtTokenService.instance.ensureJwtToken(force: true).catchError((e) {
              l.d('jwt expired refresh failed: $e', tag: TAG);
            });
            break;
          default:
            l.d(
              '${baseResp.bizCode ?? baseResp.code}:${baseResp.tip ?? '服务器错误'}',
              tag: "http_log",
            );
        }
      }
    } catch (e) {
      baseResp = BaseRespBean(Code.NETWORK_ERROR, msg: "数据处理异常了");
    }
    response.data = baseResp;
  }
}

/// 网关若将业务 JSON 整体加密放在 [data] 字符串中，则尝试按 [time] 选密钥解密
void maybeDecryptGatewayResultEnvelope(Map<String, dynamic> m) {
  if (!m.containsKey('data')) {
    return;
  }
  final dynamic r = m['data'];
  if (r is! String) {
    return;
  }
  final String s = r.trim();
  if (s.length < 16) {
    return;
  }
  int ts = 0;
  final dynamic tv = m['time'];
  if (tv is int) {
    ts = tv;
  } else if (tv is String) {
    ts = int.tryParse(tv) ?? 0;
  }
  if (ts == 0) {
    ts = DateTime.now().millisecondsSinceEpoch;
  }
  final String key = pickGatewayEncryptKey(ts);
  try {
    final String plain = decryptGatewayEnvelopeString(s, key);
    try {
      m['data'] = json.decode(plain);
    } catch (_) {
      m['data'] = plain;
    }
  } catch (_) {
    // 非网关 ECB 密文或密钥不匹配时保持原字符串
  }
}
