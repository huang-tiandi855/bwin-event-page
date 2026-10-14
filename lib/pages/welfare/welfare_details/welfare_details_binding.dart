import 'package:get/get.dart';

import 'welfare_details_logic.dart';

class WelfareDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WelfareDetailsLogic());
  }
}
