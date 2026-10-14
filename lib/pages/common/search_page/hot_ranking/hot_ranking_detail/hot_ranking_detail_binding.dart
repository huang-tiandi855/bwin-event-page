import 'package:get/get.dart';

import 'hot_ranking_detail_logic.dart';

class HotRankingDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HotRankingDetailLogic());
  }
}
