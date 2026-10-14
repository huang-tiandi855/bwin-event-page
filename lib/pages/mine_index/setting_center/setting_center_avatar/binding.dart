import 'package:get/get.dart';

import 'logic.dart';

class SettingCenterAvatarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingCenterAvatarLogic());
  }
}
