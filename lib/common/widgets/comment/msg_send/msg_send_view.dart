import 'package:comics_app/common/entities/post_entity.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../style/location.dart';
import '../comment_view.dart';
import 'msg_send_logic.dart';

class MsgSendComponent extends StatelessWidget {
  final String id;
  final bool? isPop;
  final bool isSendList; //评论成功是否向评论列表加数据
  final PostList? postItem;
  final VoidCallback? commentSuccessFun;
  final CommentType type;
  final String? sid;

  const MsgSendComponent(
      {Key? key,
      required this.id,
      required this.type,
      this.isPop = false,
      this.isSendList = true,
      this.postItem,
      this.sid,
      this.commentSuccessFun})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logic =
        Get.put(MsgSendLogic(id, postItem, type, isPop ?? false, sid: sid));
    logic.state.isSendList = isSendList;
    logic.state.commentSuccessFun = commentSuccessFun;
    return _body(logic);
  }

  Widget _body(MsgSendLogic logic) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => logic.updateShowSendStatus(isPop),
      child: Container(
        height: 72.w,
        color: Colors.black,
        padding: EdgeInsets.all(AppLocation.appHorizontal),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.15),
                    borderRadius: BorderRadius.circular(10.r)),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('请输入您的文字内容',
                      style: TextStyle(
                          fontSize: 14.w,
                          color: Colors.white.withOpacity(.3),
                          fontWeight: FontWeight.w500)),
                ),
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.only(left: 23.w),
            //   child: AssetsGen.images.video.icCommentPic
            //       .image(width: 36.w, height: 36.h),
            // ),
            Padding(
              padding: EdgeInsets.only(left: 14.w),
              child: AssetsGen.images.video.icCommentSend
                  .image(width: 36.w, height: 36.h),
            ),
          ],
        ),
      ),
    );
  }
}
