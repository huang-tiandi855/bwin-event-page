import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/pages/original/original_topic/topic_logic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/apis/user.dart';
import '../../../../../common/entities/MediaListInfo.dart';
import '../../../../../common/http/code.dart';
import '../../../../../common/utils/ads_manage/getAdv.dart';
import '../../../../../common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'topic_detail_state.dart';

class OriginalTopicDetailLogic extends GetxController {
  final int simpleSort;
  OriginalTopicDetailLogic(this.simpleSort);
  final OriginalTopicDetailState state = OriginalTopicDetailState();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    final topicLogicState = Get.find<OriginalTopicLogic>().state;
    state.id = topicLogicState.id;
    state.title = topicLogicState.title;

    state.homePageSpecialMoreAds = getAdsByType(AdsType.banner);

    state.homePageSpecialMoreAdsHorizontal =
        getAdsByType(AdsType.banner);

    doInit();


    Map map = {};

    map["state.title"] = topicLogicState.tabs.elementAt(topicLogicState.tabController.index);
    map["链路"] = "首页-${topicLogicState.tabs.elementAt(topicLogicState.tabController.index)}-更多";

    ConfigStore.to.trackData('首页浏览',map);

  }

  //初始化数据
  void doInit() async {
    state.pullRefreshController.code =
        ValueNotifier(PULL_REQUEST_CODE.REQUESTING);

    try {
      if (state.id != null) {
        Map<String, dynamic> data = {
          'page': state.pageNum,
          'pageSize': 20,
          "sectionID": state.id,
          "simpleSort": simpleSort,
        };

        Map<String, dynamic> featureEntityInfo =
            await UserApi.getOriginalTopicDetail(data);

        if (Code.isDocSuccess(featureEntityInfo['code'])) {
          MediaListInfo info = MediaListInfo.fromJson(featureEntityInfo);
          if (state.pageNum > 1) {
            info.data!.mediaList?.forEach((element) {
              state.topicDetail?.data?.mediaList?.add(element);
            });
          } else {
            state.topicDetail = info;
            state.pullRefreshController.refreshController
                .refreshCompleted(resetFooterState: true);
          }
          state.pullRefreshController.requestSuccess(
              isFirstPageNum: state.pageNum == 1 ? true : false,
              hasMore: info.data!.hasNext ?? false,
              isEmpty:
                  state.pageNum == 1 && (info.data?.mediaList ?? []).isEmpty
                      ? true
                      : false);
        } else {
          state.pullRefreshController
              .requestFail(isFirstPageNum: state.pageNum == 1);
        }
      }
    } catch (e) {
      state.pullRefreshController
          .requestFail(isFirstPageNum: state.pageNum == 1);
    }

    update();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}
