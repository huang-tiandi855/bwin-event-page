import 'package:get/get.dart';

import 'novel_logic.dart';

class NovelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NovelHotRankingLogic());
  }
}
