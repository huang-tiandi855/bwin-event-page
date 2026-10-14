import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/common/widgets/video_section/skits_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/loading_widget.dart';
import '../../../common/widgets/acg_section/acg_media_card.dart';
import '../../../common/widgets/acg_section/acg_media_grid_view.dart';
import 'topic_detail_logic.dart';

class TopicDetailPage extends StatelessWidget {
  int simpleSort;

  String? zone;

  bool? isJinGangZone;
  bool? isSkits;

  TopicDetailPage({
    Key? key,
    required this.simpleSort,
    this.zone,
    this.isJinGangZone,
    this.isSkits,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(TopicDetailLogic(simpleSort, isJinGangZone), tag: simpleSort.toString());
    final state = Get.find<TopicDetailLogic>(tag: simpleSort.toString()).state;

    return Scaffold(
        backgroundColor: AppColor.bgGrey,
        body: GetBuilder<TopicDetailLogic>(
          builder: (logic) {
            return Padding(
              padding: const EdgeInsets.only(left: 12, top: 0),
              child: PullRefreshView(
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
                child: (state.topicDetail?.mediaList ?? []).isEmpty
                    ? const LoadingWidget()
                    : MediaGridView(
                        crossAxisCount: state.isVerticalCover ? 3 : 2, //横向数量
                        crossAxisSpacing: 8, //间距
                        mainAxisSpacing: 8, //行距
                        aspectRatio: state.isVerticalCover ? 113.w / 216.w : 173 / 148,
                        itemBuilder: (p0, index) {
                          final e = state.topicDetail!.mediaList![index];
                          if (isSkits == true) {
                            return SkitsCard.fromMediaModel(
                              e,
                              verticalCover: true,
                            );
                          }
                          return MediaCard.fromVideoModel(
                            e,
                            forceVerticalCover: state.isVerticalCover,
                            index: index,
                          );
                        },
                        itemCount: state.topicDetail?.mediaList?.length ?? 0,
                      ),
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
    /*if ((state.topicDetail?.mediaList ?? []).isNotEmpty) {
      if ((state.topicDetail?.mediaList![0].direction ?? 0) == 0) {
        return false;
      }
    }*/

    return true;
  }
}
