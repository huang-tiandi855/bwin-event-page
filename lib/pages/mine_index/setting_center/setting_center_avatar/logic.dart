import 'package:comics_app/common/apis/user.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/utils/logger.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:get/get.dart';

import 'state.dart';

class SettingCenterAvatarLogic extends GetxController {
  final SettingCenterAvatarState state = SettingCenterAvatarState();

  @override
  void onInit() {
    super.onInit();
    _loadList();
  }

  Future<void> _loadList() async {
    try {
      final data = await UserApi.headImageListReq();
      state.avatarList = data ?? [];
      final portrait = UserStore.to.getUserInfoModel?.avatarUrl ?? '';
      if (portrait.isNotEmpty) {
        state.selectedIndex =
            state.avatarList.indexWhere((e) => e?.url == portrait);
      }
      update();
    } catch (e) {
      l.d('headImageListReq error: $e');
    }
  }

  void selectIndex(int i) {
    if (i < 0 || i >= state.avatarList.length) return;
    state.selectedIndex = i;
    update();
  }

  Future<void> save() async {
    final url = state.avatarList[state.selectedIndex]?.url ?? '';
    if (url.isEmpty) {
      showToast(msg: '暂无可用头像');
      return;
    }
    // if (!UserStore.to.isVip()) {
    //   showNeedVipDialog(bodyLine1: '您还不是VIP无法修改头像');
    //   return;
    // }
    final ok = await UserStore.to.updateUser({'avatar': url});
    if (ok) {
      await Future.delayed(const Duration(milliseconds: 400));
      showToast(msg: '修改成功');
      Get.back(result: true);
    }
  }

  String get previewUrl {
    if (state.selectedIndex == -1 || state.selectedIndex > state.avatarList.length - 1) {
      return UserStore.to.getUserInfoModel?.avatarUrl ?? '';
    }
    return state.avatarList[state.selectedIndex]?.url ?? '';
  }
}
