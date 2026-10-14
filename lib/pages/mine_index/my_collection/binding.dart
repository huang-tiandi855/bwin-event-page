import 'package:get/get.dart';

import 'logic.dart';

class MyCollectionBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MyCollectionLogic>()) {
      Get.put(MyCollectionLogic(), permanent: false);
    }
  }
}
