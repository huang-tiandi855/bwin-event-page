import 'package:get/get.dart';

import 'comic_logic.dart';

class ComicBinding7 extends Bindings {
  @override
  void dependencies() {

    //Get.lazyPut<ComicLogic>(() => ComicLogic(""));

    Get.lazyPut(() => ComicLogic7(""));

   // Get.put(ComicLogic(""));

  }
}
