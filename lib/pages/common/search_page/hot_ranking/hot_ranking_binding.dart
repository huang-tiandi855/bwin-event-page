import 'package:get/get.dart';

import 'hot_ranking_logic.dart';

class HotRankingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HotRankingLogic());
  }
}
