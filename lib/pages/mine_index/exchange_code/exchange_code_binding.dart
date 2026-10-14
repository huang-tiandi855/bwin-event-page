import 'package:get/get.dart';

import 'exchange_code_logic.dart';

class ExchangeCodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ExchangeCodeLogic());
  }
}
