import 'package:comics_app/common/utils/logger.dart';
import 'package:get/get.dart';

class H5PageState {
  RxBool isLoading = true.obs;
  String? title;
  String? url;
  bool isWeb = false;
  bool showAppBar = true;
  bool showBack = false;

  H5PageState() {
    ///Initialize variables
    isWeb = identical(0, 0.0);
    title = Get.arguments?["title"] ?? "";
    url = Get.arguments?["url"] ?? "";
    isWeb = Get.arguments?['isWeb'] ?? false;
    showAppBar = Get.arguments?['showAppBar'] ?? true;
    showBack = Get.arguments?['showBack'] ?? false;
    l.d("title:$title");
    l.d("url:$url");
  }
}
