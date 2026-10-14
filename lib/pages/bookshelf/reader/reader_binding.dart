import 'package:get/get.dart';

import 'reader_logic.dart';

class ReaderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReaderLogic());
  }
}
