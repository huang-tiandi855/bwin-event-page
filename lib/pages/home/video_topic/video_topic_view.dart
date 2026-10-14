import 'package:comics_app/common/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/entities/feature_info.dart';
import '../../../common/routers/app_routes.dart';
import '../../../common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import '../../../common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'video_topic_logic.dart';

class VideoTopicPage extends StatelessWidget {
  VideoTopicPage({Key? key}) : super(key: key);

  final logic = Get.find<VideoTopicLogic>();
  final state = Get.find<VideoTopicLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar('全部专题'),
      body: GetBuilder<VideoTopicLogic>(builder: (logic) {
        return PullRefreshView(
          retryOnTap: () async {
            logic.onRefresh();
          },
          controller: state.pullRefreshController,
          child: _item(),
          onRefresh: () async {
            logic.onRefresh();
          },
          onLoading: () async {
            logic.onLoad();
          },
        );
      }),
    );
  }

//item
  Widget _item() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 11.w),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        ListElement section = state.topicList[index];
        String cover = section.img ?? "";
        return Container(
          margin: EdgeInsets.only(top: index == 0 ? 18.w : 20.w),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: AppColor.boxShadow,
          ),
          padding: EdgeInsets.all(10.w),
          child: GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.TOPIC_PAGE, arguments: {
                  "title": section.name.toString(),
                  "id": section.id.toString(),
                  "isJinGangZone": true,
                  // "zone": listElement?.zone,
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 333 / 186,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10.r)),
                      child: CustomImage(
                        url: cover,
                        aspectRatio: 333 / 186,
                      ),
                    ),
                  ),
                  8.verticalSpaceFromWidth,
                  Text(
                    section.desc ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColor.c333333,
                    ),
                  ),
                ],
              )),
        );
      },
      itemCount: state.topicList.length,
    );
  }
}
