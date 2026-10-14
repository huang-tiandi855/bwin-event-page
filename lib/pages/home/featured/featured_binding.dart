import 'package:get/get.dart';

import 'featured_logic.dart';

class FeaturedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FeaturedLogic());
  }
}
