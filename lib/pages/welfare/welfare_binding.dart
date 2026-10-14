import 'package:get/get.dart';

import 'welfare_logic.dart';

class WelfareBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WelfareLogic());
  }
}
