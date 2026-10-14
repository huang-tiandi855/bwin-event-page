import 'package:comics_app/common/entities/video_model/tags_model.dart';
import 'package:comics_app/pages/home/tag_detail/tag_detail_view.dart';
import 'package:get/get.dart';

extension TagsModelExtension on TagsModel {
  void navigateTo() {
    navigateToAsync();
  }

  Future<dynamic> navigateToAsync() {
    if (id == null) {
      return Future.value();
    }
    return Get.to(
          () => TagDetailPage(
            id: id,
            title: name ?? '',
          ),
          preventDuplicates: false,
        ) ??
        Future.value();
  }
}
