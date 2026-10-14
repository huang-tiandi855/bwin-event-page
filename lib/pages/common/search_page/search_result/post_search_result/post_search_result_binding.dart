import 'package:get/get.dart';

import 'post_search_result_logic.dart';

class PostSearchResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PostSearchResultLogic());
  }
}
