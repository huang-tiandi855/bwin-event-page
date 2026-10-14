// ignore_for_file: constant_identifier_names

import 'package:comics_app/common/apis/user.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/logger.dart';

/// JwtToken 维护：把 [UserApi.fetchJwtToken] + [UserStore.saveJwtToken] 流程
/// 从 [SplashLogic] 抽出来共用。
///
/// [SplashLogic] 冷启动走 [ensureJwtToken]（force=false，本地 jwt 还在就跳过）；
/// [HttpRespInterceptor] 1034 走 [ensureJwtToken]（force=true，强制刷新）。
/// 内部用 [_inflight] 做单飞，并发 1034 只发一次 jwt-token。
///
/// 与 [AuthService] 行为对齐：失败时清掉脏 jwt 避免下一次请求继续带过期串
/// 触发 1034 风暴，但 [_runFetch] 不主动判断「本地是否还有效」——
/// jwt-token 接口本身轻量、且无明确过期时间字段，由调用方按 [force] 决定。
class JwtTokenService {
  JwtTokenService._();
  static final JwtTokenService instance = JwtTokenService._();

  static const String _TAG = 'JwtTokenService';

  Future<void>? _inflight;

  /// 确保本地存在可用 jwt。
  ///
  /// - [force]=false：本地已有 jwt 直接 short-circuit；
  /// - [force]=true ：强制刷新（拦截器 1034 场景）。
  Future<void> ensureJwtToken({bool force = false}) {
    final Future<void>? cur = _inflight;
    if (cur != null) return cur;
    if (!force && _hasLocalJwt()) return Future<void>.value();

    final Future<void> task = _runFetch();
    _inflight = task;
    return task.whenComplete(() {
      if (identical(_inflight, task)) _inflight = null;
    });
  }

  bool _hasLocalJwt() {
    final String? jwt = UserStore.to.getJwtToken();
    return jwt != null && jwt.isNotEmpty;
  }

  Future<void> _runFetch() async {
    try {
      final String jwt = await UserApi.fetchJwtToken();
      UserStore.to.saveJwtToken(jwt);
    } catch (e) {
      UserStore.to.removeJwtToken();
      l.d('ensureJwtToken failed: $e', tag: _TAG);
      rethrow;
    }
  }
}
