import 'package:get/get.dart';

import 'search_page_logic.dart';

class SearchPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchPageLogic());
  }
}
