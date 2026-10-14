import 'package:get/get.dart';

import 'cos_logic.dart';

class CosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CosHorRankingLogic());
  }
}
