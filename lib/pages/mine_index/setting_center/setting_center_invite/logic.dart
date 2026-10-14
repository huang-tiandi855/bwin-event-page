import 'package:comics_app/common/apis/user.dart';
import 'package:comics_app/pages/mine_index/setting_center/logic.dart'
    show SettingCenterLogic;
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/utils/logger.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'state.dart';

class SettingCenterInviteLogic extends GetxController {
  final SettingCenterInviteState state = SettingCenterInviteState();

  @override
  void onClose() {
    FocusManager.instance.primaryFocus?.unfocus();
    final s = state;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      s.dispose();
    });
    super.onClose();
  }

  void onTextChanged(String v) {
    final upper = v.toUpperCase();
    if (upper != v) {
      state.controller.value = TextEditingValue(
        text: upper,
        selection: TextSelection.collapsed(offset: upper.length),
      );
    }
    state.canSubmit = state.controller.text.trim().length >= 6;
    update(['canSubmit']);
  }

  Future<void> submit() async {
    final code = state.controller.text.trim();
    if (code.length < 6) {
      showToast(msg: '请输入至少6位邀请码');
      return;
    }
    // if (!UserStore.to.isVip()) {
    //   showNeedVipDialog(bodyLine1: '您还不是VIP无法绑定邀请码');
    //   return;
    // }
    try {
      final result = await UserApi.inviteBind(code);
      if (result.isSuccess) {
        showToast(msg: '绑定成功');
        await UserStore.to.refreshUser();
        if (Get.isRegistered<SettingCenterLogic>()) {
          Get.find<SettingCenterLogic>().update();
        }
        Get.back();
      } else {
        showToast(msg: result.tip.toString());
      }
    } catch (e) {
      l.d('inviteBind $e');
    }
  }
}
