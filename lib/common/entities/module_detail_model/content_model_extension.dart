import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/values/address.dart';

import 'content_model.dart';

extension ContentModelExtension on ContentModel {
  String get getRealVideoUrl {
    return Address.buildH5VideoUrl(videoUrl, token: UserStore.to.getToken());
  }

  bool get canPlayShortMedia {
    return needPermission == 2;
  }

  // 付费类型
  // 视频付费类型+用户身份结合判断
  int get needPermission {
    // 至尊会员 返回免费
    // if (UserStore.to.getUserInfoModel?.videoFreeExpiration != null &&
    //     isBeforeToday(UserStore.to.getUserInfoModel?.videoFreeExpiration)) {
    //   return 2;
    // } else {
    //   if ((mediaStatus?.hasPaid ?? false)) {
    //     return 2;
    //   } else {
    //     // vip视频
    //     if (listenPermission == 0 && UserStore.to.isVip()) {
    //       return 2;
    //     } else if (listenPermission == 1 && price == 0) {
    //       // 金豆视频
    //       // 当前用户是vip，且vip应付金豆 = 0时免费观看
    //       // 当前用户已经购买过该视频时免费观看
    //       return 2;
    //     }
    //   }

    return 1;
  }

  bool isBeforeToday(String time) {
    if (time != "0001-01-01T00:00:00Z") {
      var startDate = time;
      var endDate = DateTime.now();
      return DateTime.parse(startDate).isBefore(endDate);
    } else {
      return true;
    }
  }
}
