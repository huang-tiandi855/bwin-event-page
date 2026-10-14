import 'package:get/get.dart';

import 'commic_hot_ranking_logic.dart';

class CommicHotRankingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CommicHotRankingLogic());
  }
}
