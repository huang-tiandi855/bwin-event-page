import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'state.dart';

class SettingCenterNicknameLogic extends GetxController {
  late final SettingCenterNicknameState state;

  void _onFocusChanged() {
    if (isClosed) return;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    final initial = UserStore.to.getUserInfoModel?.name ?? '';
    state = SettingCenterNicknameState(initial);
    state.focusNode.addListener(_onFocusChanged);
  }

  @override
  void onClose() {
    state.focusNode.removeListener(_onFocusChanged);
    state.focusNode.unfocus();
    final s = state;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      s.dispose();
    });
    super.onClose();
  }

  void clear() {
    state.controller.clear();
    update();
  }

  Future<void> save() async {
    final nick = state.controller.text.trim();
    if (nick.isEmpty) {
      showToast(msg: '昵称不能为空');
      return;
    }
    // if (!UserStore.to.isVip()) {
    //   showNeedVipDialog(bodyLine1: '您还不是VIP无法修改昵称');
    //   return;
    // }
    final ok = await UserStore.to.updateUser({'nickName': nick});
    if (ok) {
      await Future.delayed(const Duration(milliseconds: 500));
      showToast(msg: '修改成功');
      Get.back(result: true);
    }
  }
}
