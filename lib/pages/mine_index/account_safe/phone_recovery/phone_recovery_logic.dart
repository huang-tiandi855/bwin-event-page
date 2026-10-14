import 'package:comics_app/common/utils/toast_util.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../common/routers/app_routes.dart';
import '../../../../common/store/user.dart';
import 'phone_recovery_state.dart';

class PhoneRecoveryLogic extends GetxController {
  PhoneRecoveryLogic();

  final PhoneRecoveryState state = PhoneRecoveryState();

  static const String canSubmitId = 'phone_recovery_can_submit';

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

  void onPhoneChanged(String _) {
    _refreshSubmit();
    update();
  }

  void onPasswordChanged(String _) {
    _refreshSubmit();
  }

  void _refreshSubmit() {
    if (isClosed) return;
    state.canSubmit = state.phoneController.text.trim().isNotEmpty &&
        state.passwordController.text.trim().isNotEmpty;
    update([canSubmitId]);
  }

  void submitRecover() {
    final phone = state.phoneController.text.trim();
    final password = state.passwordController.text.trim();
    if (phone.isEmpty) {
      showToast(msg: '请输入手机号');
      return;
    }
    if (password.isEmpty) {
      showToast(msg: '请输入密码');
      return;
    }
    UserStore.to.loginByAccount(phone, password).then((value) {
      if (value) {
        showToast(msg: '登录成功');
        Get.until((routes) {
          if (routes is GetPageRoute) {
            GetPageRoute getRoute = routes;
            if (getRoute.settings.name == AppRoutes.APPLICATION_PAGE) {
              return true;
            }
          }
          return false;
        });
      } else {
        showToast(msg: '登录失败');
      }
    });
  }

  @override
  void onClose() {
    FocusManager.instance.primaryFocus?.unfocus();
    final s = state;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      s.phoneController.dispose();
      s.passwordController.dispose();
    });
    super.onClose();
  }
}
