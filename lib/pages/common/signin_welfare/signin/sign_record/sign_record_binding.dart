import 'package:get/get.dart';

import 'sign_record_logic.dart';

class SignRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignRecordLogic>(() => SignRecordLogic());
  }
}
