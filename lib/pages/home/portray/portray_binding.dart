import 'package:get/get.dart';

import 'portray_logic.dart';

class PortrayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PortrayLogic());
  }
}
