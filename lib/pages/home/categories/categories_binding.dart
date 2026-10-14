import 'package:get/get.dart';

import 'categories_logic.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CategoriesLogic());
  }
}
