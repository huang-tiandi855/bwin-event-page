import 'package:get/get.dart';

import 'new_logic.dart';

class NewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NewLogic());
  }
}
