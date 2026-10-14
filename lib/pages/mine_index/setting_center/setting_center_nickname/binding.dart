import 'package:get/get.dart';

import 'logic.dart';

class SettingCenterNicknameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingCenterNicknameLogic());
  }
}
