import 'package:get/get.dart';

import 'logic.dart';

class MyPurchaseBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MyPurchaseLogic>()) {
      Get.put(MyPurchaseLogic(), permanent: false);
    }
  }
}
