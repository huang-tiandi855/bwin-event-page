import 'package:get/get.dart';

import 'bookshelf_logic.dart';

class BookshelfBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BookshelfLogic());
  }
}
