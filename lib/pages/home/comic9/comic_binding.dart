import 'package:get/get.dart';

import 'comic_logic.dart';

class ComicBinding9 extends Bindings {
  @override
  void dependencies() {

    //Get.lazyPut<ComicLogic>(() => ComicLogic(""));

    Get.lazyPut(() => ComicLogic9(""));

   // Get.put(ComicLogic(""));

  }
}
