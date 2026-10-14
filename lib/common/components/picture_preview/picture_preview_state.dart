import 'package:card_swiper/card_swiper.dart';
import 'package:comics_app/common/entities/post_entity.dart';
import 'package:get/get.dart';

class PicturePreviewState {
  List urlList = [];
  var curIndex = 1.obs;
  SwiperController swiperController = SwiperController();
  bool limit = false;
  String? title;
  PostList? postItem;
  bool isLocalImg = false;

  PicturePreviewState() {
    ///Initialize variables
    urlList = Get.arguments['seriesCover'] ?? [];
    curIndex.value =  Get.arguments?['index'] ?? 1;
    isLocalImg =  Get.arguments?['isLocalImg'] ?? false;
    title =  Get.arguments['title'];

    postItem =  Get.arguments['postItem'];
  }
}
