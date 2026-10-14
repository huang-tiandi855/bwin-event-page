import 'package:get/get.dart';

import 'logic.dart';

class MineHistoryRecordBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MineHistoryRecordLogic>()) {
      Get.put(MineHistoryRecordLogic(), permanent: false);
    }
  }
}
