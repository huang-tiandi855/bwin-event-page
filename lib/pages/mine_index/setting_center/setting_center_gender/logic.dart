import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:get/get.dart';

import 'state.dart';

class SettingCenterGenderLogic extends GetxController {
  final SettingCenterGenderState state = SettingCenterGenderState();

  @override
  void onInit() {
    super.onInit();
    final g = UserStore.to.getUserInfoModel?.gender;
      // 0女 ，1男
    if (g == 0) {
      state.selected = 1;
    } else if (g == 1) {
      state.selected = 0;
    } else {
      state.selected = 2;
    }
    update();
  }

  void select(int index) {
    state.selected = index;
    update();
  }

  Future<void> save() async {
    int gender;
    switch (state.selected) {
      case 0:
        gender = 1;
        break;
      case 1:
        gender = 0;
        break;
      default:
        gender = 2;
    }
    // if (!UserStore.to.isVip()) {
    //   showNeedVipDialog(bodyLine1: '您还不是VIP无法修改性别');
    //   return;
    // }
    final ok = await UserStore.to.updateUser({'sex': gender});
    if (ok) {
      await Future.delayed(const Duration(milliseconds: 400));
      showToast(msg: '修改成功');
      Get.back(result: true);
    }
  }
}
