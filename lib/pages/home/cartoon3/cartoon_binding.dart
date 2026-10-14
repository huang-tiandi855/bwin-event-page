import 'package:get/get.dart';

import 'cartoon_logic.dart';

class CartoonBinding3 extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CartoonLogic3(""));
  }
}
