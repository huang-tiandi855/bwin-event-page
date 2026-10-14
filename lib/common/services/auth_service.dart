// ignore_for_file: constant_identifier_names

import 'package:comics_app/common/apis/user.dart';
import 'package:comics_app/common/entities/user_info_model_entity.dart';
import 'package:comics_app/common/services/storage.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/logger.dart';
import 'package:comics_app/common/values/storage.dart';
import 'package:flutter/services.dart';

/// 鉴权 / 登录态维护：把 freeRegister 从 SplashLogic 抽出来共用。
///
/// SplashLogic 走 [ensureLogin]（force=false，本地 token 还在有效期内直接跳过）；
/// HttpRespInterceptor 1019 走 [ensureLogin]（force=true，强制刷新）。
/// 内部用 [_inflight] 做单飞，并发只发一次 freeRegister。
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const String _TAG = 'AuthService';

  Future<void>? _inflight;

  Future<void> ensureLogin({bool force = false}) {
    final Future<void>? cur = _inflight;
    if (cur != null) return cur;
    if (!force && _isLocalTokenStillValid()) return Future<void>.value();

    final Future<void> task = _runLogin();
    _inflight = task;
    return task.whenComplete(() {
      if (identical(_inflight, task)) _inflight = null;
    });
  }

  bool _isLocalTokenStillValid() {
    final dynamic raw = StorageService.to.read(Storage.tokenValidDate);
    if (raw == null) return false;
    final int? epoch = int.tryParse(raw.toString());
    if (epoch == null || epoch == 0) return false;
    return DateTime.fromMillisecondsSinceEpoch(epoch).isAfter(DateTime.now());
  }

  Future<void> _runLogin() async {
    try {
      final ConfigStore configStore = ConfigStore.to;
      final String ts13 = DateTime.now().millisecondsSinceEpoch.toString();
      final String deviceId = await configStore.getUniqueId();
      String cutInfos = '';
      var channel = await ConfigStore.to.getChannel();
      if (channel != null && channel != "") {
        cutInfos = channel;
      } else {
        final ClipboardData? clip =
            await Clipboard.getData(Clipboard.kTextPlain);
        if (clip != null && clip.text != "") {
          cutInfos = clip.text ?? "";
        }
      }

      final Map<String, dynamic> body = <String, dynamic>{
        'version': configStore.version,
        'machineCode': "Android",
        'phone': ts13,
        'password': ts13,
        'osType': configStore.getSysType(),
        'key': cutInfos,
        'sign': deviceId,
        'channelCode': '',
      };
      final UserInfoModelEntity entity = await UserApi.freeRegister(body);
      const MethodChannel openInstallChannel = MethodChannel("com.yaoJin/device");
      await openInstallChannel.invokeMethod("reportRegister");
      UserStore.to.saveUserInfo(entity);
    } catch (e) {
      // 失败时清掉脏 token，避免下一次请求继续带过期 token 触发 1019 风暴
      UserStore.to.removeToken();
      l.d('ensureLogin failed: $e', tag: _TAG);
      rethrow;
    }
  }
}
