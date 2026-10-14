import 'package:comics_app/common/entities/post_entity.dart';
import 'package:comics_app/common/widgets/comment/comment_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../style/color.dart';
import '../style/location.dart';
import 'comment/msg_send/msg_send_view.dart';
import 'comment_pop/comment_pop_view.dart';

/// 打开评论底部弹层。背景默认采用页面主背景色（深色），与 [CommentPopComponent]
/// 的深色卡片风格一致。
Future openBottomSheetComment(
  String id, {
  required CommentType commentType,
  PostList? postItem,
  VoidCallback? commentSuccessFun,
  String? sid,
  int? totalCount,
}) async {
  return await Get.bottomSheet(
    isScrollControlled: true,
    SafeArea(
      child: Container(
        color: AppColor.scaffoldBackground,
        height: 1.sh * 0.6,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: AppLocation.appHorizontal,
                right: AppLocation.appHorizontal,
                bottom: 80.w,
                top: AppLocation.appHorizontal,
              ),
              child: CommentPopComponent(
                id: id,
                postItem: postItem,
                type: commentType,
                totalCount: totalCount,
              ),
            ),
            Positioned(
              top: 10.w,
              right: 10.w,
              child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Icon(
                  Icons.close,
                  size: 24.sp,
                  color: AppColor.primaryText,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: MsgSendComponent(
                id: id,
                postItem: postItem,
                commentSuccessFun: commentSuccessFun,
                isSendList: true,
                type: commentType,
                sid: sid,
                isPop: true,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
