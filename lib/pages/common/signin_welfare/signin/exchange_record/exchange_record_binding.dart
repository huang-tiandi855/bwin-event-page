import 'package:get/get.dart';

import 'exchange_record_logic.dart';

class ExchangeRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExchangeRecordLogic>(() => ExchangeRecordLogic());
  }
}
