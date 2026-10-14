import 'package:get/get.dart';

import 'logic.dart';

class AiTextToImageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AiTextToImageLogic());
  }
}
