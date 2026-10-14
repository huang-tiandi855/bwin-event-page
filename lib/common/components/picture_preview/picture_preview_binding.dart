import 'package:get/get.dart';

import 'picture_preview_logic.dart';

class PicturePreviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PicturePreviewLogic());
  }
}
