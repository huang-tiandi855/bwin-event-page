import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/routers/app_navigator.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';

extension AdsInfoListJumpExt on AdsInfoList {
  void jumpAdvByType(AdsType adsType) {
    AppNavigator.to.jumpAdv(
      id: id ?? '',
      title: title ?? '',
      url: externalLink ?? '',
      planId: planId ?? '',
      slotCode: adsType.value,
    );
  }
}
