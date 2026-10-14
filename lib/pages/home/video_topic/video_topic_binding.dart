import 'package:get/get.dart';

import 'video_topic_logic.dart';

class VideoTopicBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VideoTopicLogic());
  }
}
