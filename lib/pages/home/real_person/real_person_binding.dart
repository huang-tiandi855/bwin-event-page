import 'package:get/get.dart';

import 'real_person_logic.dart';

class RealPersonBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RealPersonLogic());
  }
}
