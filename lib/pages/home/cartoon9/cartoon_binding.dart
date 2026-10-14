import 'package:get/get.dart';

import 'cartoon_logic.dart';

class CartoonBinding9 extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CartoonLogic9(""));
  }
}
