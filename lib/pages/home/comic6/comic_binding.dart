import 'package:get/get.dart';

import 'comic_logic.dart';

class ComicBinding6 extends Bindings {
  @override
  void dependencies() {

    //Get.lazyPut<ComicLogic>(() => ComicLogic(""));

    Get.lazyPut(() => ComicLogic6(""));

   // Get.put(ComicLogic(""));

  }
}
