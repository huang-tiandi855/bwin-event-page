import 'package:get/get.dart';

import 'logic.dart';

class AiTextToVideoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AiTextToVideoLogic());
  }
}
