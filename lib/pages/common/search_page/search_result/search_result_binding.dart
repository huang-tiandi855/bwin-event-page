import 'package:get/get.dart';

import 'search_result_logic.dart';

class SearchResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchResultLogic());
  }
}
