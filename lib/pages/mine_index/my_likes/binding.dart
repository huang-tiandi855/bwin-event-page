import 'package:get/get.dart';

import 'logic.dart';

class MyLikesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MyLikesLogic>()) {
      Get.put(MyLikesLogic(), permanent: false);
    }
  }
}
