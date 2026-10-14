import 'package:get/get.dart';

import 'logic.dart';

class SettingCenterPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingCenterLogic());
  }
}
