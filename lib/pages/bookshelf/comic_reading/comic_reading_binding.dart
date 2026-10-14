import 'package:get/get.dart';

import 'comic_reading_logic.dart';

class ComicReadingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ComicReadingLogic());
  }
}
