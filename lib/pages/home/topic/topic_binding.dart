import 'package:comics_app/pages/home/topic/topic_logic.dart';
import 'package:get/get.dart';

class TopicBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TopicLogic());
  }
}
