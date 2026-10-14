import 'package:get/get.dart';

import 'select_tag_logic.dart';

class SelectTagBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SelectTagLogic());
  }
}
