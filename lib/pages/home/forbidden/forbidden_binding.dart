import 'package:get/get.dart';

import 'forbidden_logic.dart';

class ForbiddenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ForbiddenLogic());
  }
}
