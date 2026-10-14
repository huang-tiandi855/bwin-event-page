import 'package:get/get.dart';

import 'logic.dart';

class SimplePlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SimplePlayerLogic());
  }
}