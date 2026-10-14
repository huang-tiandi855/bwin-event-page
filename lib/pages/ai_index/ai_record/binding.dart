import 'package:get/get.dart';

import 'logic.dart';

class AiRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AiRecordLogic());
  }
}
