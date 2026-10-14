import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/pages/home/home_logic.dart';
import 'package:comics_app/pages/original/original_topic/topic_logic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/loading_widget.dart';
import '../../../../../common/widgets/space_widget.dart';
import 'topic_detail_logic.dart';

class OriginalTopicDetailPage extends StatelessWidget {
  final int simpleSort;

  const OriginalTopicDetailPage({Key? key, required this.simpleSort}) : super(key: key);

  @override

  Widget build(BuildContext context) {
    Get.put(OriginalTopicDetailLogic(simpleSort), tag: simpleSort.toString());
    final state = Get.find<OriginalTopicDetailLogic>(tag: simpleSort.toString()).state;

    return Scaffold(
      backgroundColor: AppColor.bgGrey,
        body: GetBuilder<OriginalTopicDetailLogic>(
      builder: (logic) {
        return Padding(
          padding: const EdgeInsets.only(left: 12, top: 12),
          child: state.title.contains("免费")
              ? (state.topicDetail?.data!.mediaList ?? []).isEmpty
                  ? const LoadingWidget()
                  : getVerticalGridView(
                      context, state.topicDetail?.data?.mediaList?.length,
                      mediaList: state.topicDetail?.data?.mediaList ?? [],
                      isFreeZone: true)
              : PullRefreshView(
                  controller: state.pullRefreshController,
                  onRefresh: () {
                    state.pageNum = 1;
                    logic.doInit();
                  },
                  onLoading: () {
                    state.pageNum += 1;
                    logic.doInit();
                  },
                  retryOnTap: () {
                    state.pageNum = 1;
                    logic.doInit();
                  },
                  child: (state.topicDetail?.data!.mediaList ?? []).isEmpty
                      ? const LoadingWidget()
                      : isVertical(state.topicDetail?.data!.mediaList![0].kind,
                              state)
                          ? getVerticalGridView(context,
                              state.topicDetail?.data?.mediaList?.length,
                              mediaList: state.topicDetail?.data?.mediaList,
                              linkName:
                                  "首页-${Get.find<HomeLogic>().state.tabs[Get.find<HomeLogic>().state.tabController.index]}-${state.title}-更多-${Get.find<OriginalTopicLogic>().state.tabs.elementAt(Get.find<OriginalTopicLogic>().state.tabController.index)}",
                              homePageSpecialMoreAds:
                                  state.homePageSpecialMoreAds)
                          : getHorizontalGridView(context,
                              state.topicDetail?.data?.mediaList?.length,
                              mediaList: state.topicDetail?.data?.mediaList,
                              linkName:
                                  "首页-${Get.find<HomeLogic>().state.tabs[Get.find<HomeLogic>().state.tabController.index]}-${state.title}-更多-${Get.find<OriginalTopicLogic>().state.tabs.elementAt(Get.find<OriginalTopicLogic>().state.tabController.index)}",
                              homePageSpecialMoreAdsHorizontal:
                                  state.homePageSpecialMoreAdsHorizontal),
                ),
        );
      },
      tag: simpleSort.toString(),
    ));
  }

  bool isVertical(int? kind, state) {
    if (kind == 2) {
      return false;
    }

    if (kind == 3) {
      return false;
    }

    ///排版方向 0横 1竖
    /*if ((state.topicDetail?.data!.mediaList ?? []).isNotEmpty) {
      if ((state.topicDetail?.data!.mediaList![0].direction ?? 0) == 0) {
        return false;
      }
    }*/

    return true;
  }
}
