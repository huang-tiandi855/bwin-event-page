import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/widgets/comment/comment_view.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../entities/comment_entity.dart';
import '../../res/r.dart';
import '../../utils/date_util.dart';
import '../../widgets/comment/msg_send/msg_send_view.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'comment_details_logic.dart';

class CommentDetailsPage extends StatelessWidget {
  CommentDetailsPage({Key? key}) : super(key: key);

  final logic = Get.find<CommentDetailsLogic>();
  final state = Get.find<CommentDetailsLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                // 返回一个 Sliver 数组给外部可滚动组件。
                return <Widget>[
                  SliverAppBar(
                    leading: commonBack(),
                    title: const Text('评论详情'),
                    pinned: true, // 固定在顶部
                    forceElevated: innerBoxIsScrolled,
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: AppLocation.appHorizontal),
                      child: commentItem(state.commentList, -1),
                    ),
                  )
                ];
              },
              body: replyItemDetails(context),
            )),
            MsgSendComponent(id: state.objID,postItem: state.postItem, type: CommentType.video)
          ],
        ),
      ),
    );
  }

  //回复
  Widget replyItemDetails(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xfff2f2f2)),
      padding: EdgeInsets.all(AppLocation.appHorizontal),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            return Text('共${state.commCount.value}条回复', style: TextStyle(fontSize: 15.sp, color: AppColor.black));
          }),
          Expanded(child: GetBuilder<CommentDetailsLogic>(builder: (logic) {
            return PullRefreshView(
              onRefresh: () => logic.onRefresh(),
              retryOnTap: () => logic.onRefresh(),
              onLoading: () => logic.onLoading(),
              controller: state.pullRefreshController,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.only(top: 12.w),
                    child: Column(
                      children: [
                        commentItem(state.list[index], index),
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: EdgeInsets.only(left: 18.w),
                          height: 1,
                          color: const Color(0xffe5e5e5),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: state.list.length,
              ),
            );
          }))
        ],
      ),
    );
  }

  //单条评论
  Widget commentItem(CommentList commentList, int index) {
    String name = commentList.userName ?? "";
    String userPortrait = commentList.userPortrait ?? "";
    String content = commentList.content ?? "";
    String createdAt = commentList.createdAt ?? "";
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 18.w),
          child: CustomImage(
            width: 34.w,
            height: 34.w,
            url: userPortrait,
            borderRadius: BorderRadius.circular(16.5.w),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TextStyle(fontSize: 15.sp, color: AppColor.black)),
                       const SizedBox(height: 3),
                      Text(DataFormats.formatDateHNS(createdAt), style: TextStyle(fontSize: 12.sp, color: AppColor.ca09fb1)),
                    ],
                  ),
                  GetBuilder<CommentDetailsLogic>(
                    id: index == -1 ? 'likeAndUnlikeSingle' : 'likeAndUnlike',
                    builder: (logic) {
                      int likeCount = commentList.likeCount ?? 0;
                      return InkWell(
                        onTap: () => logic.likeAndUnlike(index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset((commentList.isLike ?? false) ? R.redHeart1 : R.greyHeart, width: 16.w),
                            SizedBox(height: 2.w),
                            Text("$likeCount", style: TextStyle(fontSize: 12.sp, color: AppColor.ca09fb1)),
                          ],
                        ),
                      );
                    },
                  )
                ],
              ),
              SizedBox(height: 6.w),
              Text(
                content,
                style: TextStyle(fontSize: 15.sp, color: AppColor.black, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 6.w),
            ],
          ),
        )
      ],
    );
  }
}
