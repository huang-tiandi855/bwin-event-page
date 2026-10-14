import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/utils/short_media_util.dart';
import 'package:comics_app/common/utils/utils.dart';

extension MediaInfoModelExtension on AllMediaInfoModel {
  void navigateToSkits() {
    if (isAd) {
      AppNavigator.to.jumpAdv(url: adUrl, id: id, title: title, planId: '', slotCode: '');
      return;
    }
    if (id == null) {
      return;
    }
    ShortMediaUtil.jumpBySingleMediaId(id!);
  }
}
