import 'package:get/get.dart';

import 'scan_voucher_logic.dart';

class ScanVoucherBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(ScanVoucherLogic.new);
  }
}
