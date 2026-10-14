import 'package:get/get.dart';

import 'film_search_result_logic.dart';

class FilmSearchResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FilmSearchResultLogic(videoType: 0));
  }
}
