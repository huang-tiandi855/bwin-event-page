import 'package:get/get.dart';

import 'promotion_data_logic.dart';

class PromotionDataBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PromotionDataLogic>(() => PromotionDataLogic());
  }
}
