import 'package:get/get.dart';

import 'comic_logic.dart';

class ComicBinding10 extends Bindings {
  @override
  void dependencies() {

    //Get.lazyPut<ComicLogic>(() => ComicLogic(""));

    Get.lazyPut(() => ComicLogic10(""));

   // Get.put(ComicLogic(""));

  }
}
