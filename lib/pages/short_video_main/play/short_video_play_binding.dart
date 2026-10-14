import 'package:get/get.dart';

import 'short_video_play_logic.dart';

class ShortVideoPlayBinding extends Bindings {
  @override
  void dependencies() {
    final initialList = Get.arguments['initialList'];

    final initialIndex = Get.arguments['initialIndex'];

    final videoProvider = Get.arguments['videoProvider'];

    Get.lazyPut(
      () => ShortVideoPlayLogic(
        initialList: initialList,
        initialIndex: initialIndex,
        videoProvider: videoProvider,
      ),
    );
  }
}
