import 'package:get/get.dart';

import 'account_credentials_logic.dart';

class AccountCredentialsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AccountCredentialsLogic());
  }
}
