import 'package:get/get.dart';

import 'portray_detail_logic.dart';

class PortrayDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PortrayDetailLogic());
  }
}
