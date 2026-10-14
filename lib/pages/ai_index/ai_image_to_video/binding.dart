import 'package:get/get.dart';

import 'logic.dart';

class AiImageToVideoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AiImageToVideoLogic());
  }
}
