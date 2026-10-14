import 'package:comics_app/common/apis/apis.dart';
import 'package:comics_app/common/entities/feature_info.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'portray_state.dart';

class PortrayLogic extends GetxController {
  final PortrayState state = PortrayState();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    state.banner = getAdsByType(AdsType.banner);
    doInit();

    Map map = {};

    map["链路"] = "首页-写真";

    ConfigStore.to.trackData('首页浏览',map);
  }

  //初始化数据
  void doInit() async {
    state.pullRefreshPortrayController.code =
        ValueNotifier(PULL_REQUEST_CODE.REQUESTING);

    Map<String, dynamic> data = {
      'page': state.pageNum,
      'pageSize': 12,
      'topicMediaSize': 6,
      'zone': "写真",
    };

    Map<String, dynamic> featureEntityInfo = await UserApi.initRecommend(data);

    FeatureEntity? featureEntityTemp =
        FeatureEntity.fromJson(featureEntityInfo);

    if (state.pageNum == 1) {
      state.featureEntity = FeatureEntity.fromJson(featureEntityInfo);
    } else {
      for (int i = 0; i < featureEntityTemp.data!.list!.length; i++) {
        state.featureEntity?.data?.list!.add(featureEntityTemp.data!.list![i]);
      }
    }

    state.pullRefreshPortrayController.requestSuccess(
        isFirstPageNum: state.pageNum == 1 ? true : false,
        hasMore: featureEntityTemp.data?.hasNext ?? false);

    update();
  }
}
