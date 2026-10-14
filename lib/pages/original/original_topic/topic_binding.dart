import 'package:comics_app/pages/original/original_topic/topic_logic.dart';
import 'package:get/get.dart';

class OriginalTopicBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OriginalTopicLogic());
  }
}
