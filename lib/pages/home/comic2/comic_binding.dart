import 'package:get/get.dart';

import 'comic_logic.dart';

class ComicBinding2 extends Bindings {
  @override
  void dependencies() {

    //Get.lazyPut<ComicLogic>(() => ComicLogic(""));

    Get.lazyPut(() => ComicLogic2(""));

   // Get.put(ComicLogic(""));

  }
}
