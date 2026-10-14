import 'package:get/get.dart';

import 'rank_detail_logic.dart';

class RankDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(RankDetailLogic.new);
  }
}
