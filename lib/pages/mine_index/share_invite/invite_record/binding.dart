import 'package:get/get.dart';

import 'logic.dart';

class InviteRecordBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<InviteRecordLogic>()) {
      Get.put(InviteRecordLogic(), permanent: false);
    }
  }
}
