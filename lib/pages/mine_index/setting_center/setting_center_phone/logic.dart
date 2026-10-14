import 'package:comics_app/common/apis/user.dart';
import 'package:comics_app/common/http/code.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/logger.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'state.dart';

class SettingCenterPhoneLogic extends GetxController {
  final SettingCenterPhoneState state = SettingCenterPhoneState();

  @override
  void onClose() {
    // 须晚于本帧卸载 TextField，否则会出现 TextEditingController used after disposed
    FocusManager.instance.primaryFocus?.unfocus();
    final s = state;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      s.dispose();
    });
    super.onClose();
  }

  void clearPhone() {
    state.phoneController.clear();
    _refreshSubmit();
    update();
  }

  void clearPassword() {
    state.passwordController.clear();
    _refreshSubmit();
    update();
  }

  void onPasswordChanged(String v) {
    _refreshSubmit();
  }

  void onPhoneChanged(String v) {
    _refreshSubmit();
    update();
  }

  void _refreshSubmit() {
    if (isClosed) return;
    state.canSubmit = state.phoneController.text.trim().isNotEmpty &&
        state.passwordController.text.trim().isNotEmpty;
    update(['canSubmit']);
  }

  /// 密码找回
  void findPassword() {
    Get.toNamed(AppRoutes.ACCOUNT_SAFE);
  }

  Future<void> submit() async {
    if (!state.canSubmit) return;
    final phoneNum = state.phoneController.text.trim();
    final password = state.passwordController.text.trim();
    if (phoneNum.isEmpty) {
      showToast(msg: '请输入手机号');
      return;
    }
    if (password.isEmpty) {
      showToast(msg: '请输入密码');
      return;
    }
    try {
      final full = phoneNum.replaceAll(' ', '');
      final result = await UserApi.mobileBindWithPassword(full, password);
      if (result.isSuccess && Code.isDocSuccess(result.bizCode)) {
        showToast(msg: '绑定手机号成功');
        await UserStore.to.refreshUser();
        Get.back(result: true);
      } else {
        showToast(msg: result.tip ?? '绑定失败，请稍后再试');
      }
    } catch (e) {
      l.d('mobileBindWithPassword $e');
    }
  }
}
