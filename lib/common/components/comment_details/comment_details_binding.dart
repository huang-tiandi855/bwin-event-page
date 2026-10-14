import 'package:get/get.dart';

import 'comment_details_logic.dart';

class CommentDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CommentDetailsLogic());
  }
}
