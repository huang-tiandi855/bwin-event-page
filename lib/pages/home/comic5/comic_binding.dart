import 'package:get/get.dart';

import 'comic_logic.dart';

class ComicBinding5 extends Bindings {
  @override
  void dependencies() {

    //Get.lazyPut<ComicLogic>(() => ComicLogic(""));

    Get.lazyPut(() => ComicLogic5(""));

   // Get.put(ComicLogic(""));

  }
}
