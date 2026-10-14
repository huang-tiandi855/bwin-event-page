import 'package:get/get.dart';

import 'h5_page_logic.dart';

class H5PageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => H5PageLogic());
  }
}
