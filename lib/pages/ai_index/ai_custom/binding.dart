import 'package:get/get.dart';

import 'logic.dart';

class AiCustomBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AiCustomLogic());
  }
}
