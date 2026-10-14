import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/utils/utils.dart';
import 'package:comics_app/common/values/address.dart';
import 'package:comics_app/common/widgets/item/home_topic_widget.dart';
import 'package:comics_app/pages/short_video_main/play/short_video_play_view.dart';
import 'package:get/get.dart';

import 'video_model.dart';

// 用到业务逻辑，model解藕
extension VideoModelExtension on VideoModel {
  String? get _token => UserStore.to.getToken();

  String get realVideoUrl {
    return Address.buildH5VideoUrl(sourceUrl, token: _token);
    // return '${Address.baseHost}${Address.API_PREFIX}${Address.VIDEO_SUFFIX}/$sourceURL?Authorization=${Address.token}';
  }

  String get realUncodeUrl {
    return Address.buildH5VideoUrl(codelessLink, token: _token);
    // return '${Address.baseHost}${Address.API_PREFIX}${Address.VIDEO_SUFFIX}/$sourceURL?Authorization=${Address.token}';
  }

  String get realChineseUrl {
    return Address.buildH5VideoUrl(chineseLink, token: _token);
    // return '${Address.baseHost}${Address.API_PREFIX}${Address.VIDEO_SUFFIX}/$sourceURL?Authorization=${Address.token}';
  }

  String get realPreviewUrl {
    return Address.buildH5VideoUrl(previewUrl, token: _token);
    // return '${Address.baseHost}${Address.API_PREFIX}${Address.VIDEO_SUFFIX}/$previewURL';
  }

  int get coin {
    bool isVip = UserStore.to.isVip();
    if (isVip) {
      return coins ?? 0;
    } else {
      return originCoins ?? 0;
    }
  }

  // 付费类型
  // 视频付费类型+用户身份结合判断
  int get needPermission {
    // 至尊会员 返回免费
    // if (UserStore.to.getUserInfoModel?.videoFreeExpiration != null &&
    //     isBeforeToday(UserStore.to.getUserInfoModel?.videoFreeExpiration)) {
    //   return 2;
    // } else {
    //   if ((vidStatus?.hasPaid ?? false)) {
    //     return 2;
    //   } else {
    //     // vip视频
    //     if (permission == 0 && UserStore.to.isVip()) {
    //       return 2;
    //     } else if (permission == 1 && coin == 0) {
    //       // 金豆视频
    //       // 应付金豆 = 0时免费观看
    //       // 当前用户已经购买过该视频时免费观看
    //       return 2;
    //     }
    //   }

    //   return permission;
    // }
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

  void navigateTo({
    List<VideoModel> shortVideoList = const [],
  }) {
    if (isAd) {
      AppNavigator.to.jumpAdv(url: adUrl, id: id, title: title, planId: '', slotCode: '');
      return;
    }
    if (newsType == 'MOVIE') {
      // 旧版直接 push `VideoPlayPage`（lib/pages/video_main/play），现已迁到
      // 项目主流的长视频详情路由 [AppRoutes.VIDEO_PAGE]（lib/pages/video_page）。
      jumpMediaPlay(id ?? '');
    } else if (newsType == 'SP') {
      final list = shortVideoList.isEmpty ? [this] : shortVideoList;
      final index = list.indexOf(this);
      Get.to(
        () => ShortVideoPlayPage(
          initialIndex: index,
          initialList: list,
        ),
      );
    }
  }
}
