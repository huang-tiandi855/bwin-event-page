import 'package:get/get.dart';

import 'cartoon_logic.dart';

class CartoonBinding2 extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CartoonLogic2(""));
  }
}
