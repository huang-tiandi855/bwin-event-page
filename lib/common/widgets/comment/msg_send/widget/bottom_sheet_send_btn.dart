import 'package:comics_app/common/entities/post_entity.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../style/color.dart';
import '../../../../style/location.dart';
import '../../comment_view.dart';
import '../msg_send_logic.dart';

openSendMsgBtn(
    {required CommentType type,
    String? id,
    PostList? postItem,
    Function(String result)? result}) {
  final logic = Get.find<MsgSendLogic>();
  final state = Get.find<MsgSendLogic>().state;
  return Get.bottomSheet(
    SafeArea(
      child: Container(
        color: Colors.black,
        padding: EdgeInsets.symmetric(
            horizontal: AppLocation.appHorizontal, vertical: 14.w),
        child: Row(
          children: [
            Expanded(
              child: Obx(
                () {
                  return TextField(
                    maxLines: 3,
                    minLines: 1,
                    controller: state.textEditingController,
                    style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                    cursorColor: AppColor.c00ffff,
                    decoration: InputDecoration(
                      hintText: state.hintText.value,
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(.3),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(.15),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.w),
                      isDense: true,
                      border: OutlineInputBorder(
                        gapPadding: 0,
                        borderRadius: BorderRadius.all(Radius.circular(10.r)),
                        borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                    ),
                    autofocus: true,
                  );
                },
              ),
            ),
            GestureDetector(
              onTap: () {
                if (result != null) {
                  if (logic.judgeInputText()) {
                    result(logic.state.textEditingController.text);
                    Get.back(result: logic.state.textEditingController.text);
                  }
                } else {
                  logic.sendMsg();
                }
              },
              child: Padding(
                padding: EdgeInsets.only(left: 14.w),
                child: AssetsGen.images.video.icCommentSend
                    .image(width: 36.w, height: 36.h),
              ),
            )
          ],
        ),
      ),
    ),
  );
}
