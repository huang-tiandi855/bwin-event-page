import 'package:get/get.dart';

import 'logic.dart';

class MyFollowBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MyFollowLogic>()) {
      Get.put(MyFollowLogic(), permanent: false);
    }
  }
}
