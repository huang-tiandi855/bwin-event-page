import 'package:get/get.dart';

import 'comic_logic.dart';

class ComicBinding4 extends Bindings {
  @override
  void dependencies() {

    //Get.lazyPut<ComicLogic>(() => ComicLogic(""));

    Get.lazyPut(() => ComicLogic4(""));

   // Get.put(ComicLogic(""));

  }
}
