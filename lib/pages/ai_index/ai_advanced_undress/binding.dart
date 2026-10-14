import 'package:get/get.dart';

import 'logic.dart';

class AiAdvancedUndressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AiAdvancedUndressLogic());
  }
}
