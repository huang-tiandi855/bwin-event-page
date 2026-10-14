import 'package:get/get.dart';

import 'channel_logic.dart';

class ChannelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChannelLogic());
  }
}
