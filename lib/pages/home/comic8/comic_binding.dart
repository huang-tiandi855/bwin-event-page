import 'package:get/get.dart';

import 'comic_logic.dart';

class ComicBinding8 extends Bindings {
  @override
  void dependencies() {

    //Get.lazyPut<ComicLogic>(() => ComicLogic(""));

    Get.lazyPut(() => ComicLogic8(""));

   // Get.put(ComicLogic(""));

  }
}
