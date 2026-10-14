import 'package:get/get.dart';

import 'logic.dart';

class SettingCenterPhoneBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingCenterPhoneLogic());
  }
}
