import 'package:get/get.dart';

import 'phone_recovery_logic.dart';

class PhoneRecoveryBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PhoneRecoveryLogic>()) {
      Get.put(PhoneRecoveryLogic(), permanent: false);
    }
  }
}
