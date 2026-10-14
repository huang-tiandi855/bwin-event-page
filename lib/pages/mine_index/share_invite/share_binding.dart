import 'package:get/get.dart';

import 'logic.dart';

class ShareInviteBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ShareInviteLogic>()) {
      Get.put(ShareInviteLogic(), permanent: false);
    }
  }
}
