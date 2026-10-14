import 'package:get/get.dart';

import 'tag_detail_logic.dart';

class TagDetailBinding extends Bindings {
  String? tagName;
  TagDetailBinding({this.tagName});
  @override
  void dependencies() {
    Get.lazyPut(() => TagDetailLogic(), tag: '${Get.arguments["tags"]??"==="}-$tagName');
  }
}
