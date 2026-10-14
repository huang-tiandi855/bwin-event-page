import 'package:get/get.dart';

import 'short_video_main_logic.dart';

class ShortVideoMainBinding extends Bindings {
  @override
  void dependencies() {
    final initialId = Get.arguments?['initialId'];
    Get.lazyPut(() => ShortVideoMainLogic(initialId: initialId));
  }
}
