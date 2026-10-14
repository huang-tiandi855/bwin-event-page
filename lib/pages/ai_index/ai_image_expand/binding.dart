import 'package:get/get.dart';

import 'logic.dart';

class AiImageExpandBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AiImageExpandLogic());
  }
}
