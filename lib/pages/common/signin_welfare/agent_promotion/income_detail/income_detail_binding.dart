import 'package:get/get.dart';

import 'income_detail_logic.dart';

class IncomeDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IncomeDetailLogic>(() => IncomeDetailLogic());
  }
}
