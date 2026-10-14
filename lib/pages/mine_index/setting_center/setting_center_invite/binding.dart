import 'package:get/get.dart';

import 'logic.dart';

class SettingCenterInviteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingCenterInviteLogic());
  }
}
