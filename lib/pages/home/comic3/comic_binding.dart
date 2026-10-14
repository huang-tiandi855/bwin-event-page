import 'package:get/get.dart';

import 'comic_logic.dart';

class ComicBinding3 extends Bindings {
  @override
  void dependencies() {

    //Get.lazyPut<ComicLogic>(() => ComicLogic(""));

    Get.lazyPut(() => ComicLogic3(""));

   // Get.put(ComicLogic(""));

  }
}
