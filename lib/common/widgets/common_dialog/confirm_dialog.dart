import 'package:comics_app/common/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Future<bool> showConfirm(String title, String contentText,
    {barrierDismissible = false, String? rightButtonTitle}) async {
  var res = await Get.defaultDialog(
      title: title,
      titleStyle: TextStyle(fontSize: 14.w, fontWeight: FontWeight.w400),
      radius: 10.0.r,
      backgroundColor: AppColor.primaryDialogBgColor,
      barrierDismissible: false,
      middleText: contentText,
      middleTextStyle: TextStyle(fontSize: 13.w),
      confirm: GestureDetector(
        onTap: () => Get.back(result: true),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 5.w),
          margin: EdgeInsets.only(bottom: 12.w),
          decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 1.0.w)],
              color: AppColor.primaryButtonColor,
              borderRadius: BorderRadius.circular(100.w)),
          child: Text(
            rightButtonTitle ?? "确认",
            style: TextStyle(color: Colors.white, fontSize: 13.w),
          ),
        ),
      ),
      cancel: GestureDetector(
        onTap: () => Get.back(result: false),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 5.w),
          margin: EdgeInsets.only(bottom: 12.w),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(100.r)),
          child: Text(
            "取消",
            style: TextStyle(color: Colors.black, fontSize: 13.w),
          ),
        ),
      ));
  return res ?? false;
}

Future<bool> showConfirmCustom(String title, String contentText,
    {barrierDismissible = false, VoidCallback? onTap}) async {
  var res = await Get.defaultDialog(
      title: title,
      titleStyle: TextStyle(fontSize: 14.w, fontWeight: FontWeight.w400),
      radius: 15.0,
      backgroundColor: Colors.white,
      barrierDismissible: false,
      middleText: contentText,
      middleTextStyle: TextStyle(fontSize: 13.w),
      confirm: GestureDetector(
        onTap: () {
          onTap?.call();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 5.w),
          margin: EdgeInsets.only(bottom: 12.w),
          decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 1.0.w)],
              color: const Color(0xffffc833),
              borderRadius: BorderRadius.circular(12.w)),
          child: Text(
            "确认",
            style: TextStyle(color: const Color(0xff191641), fontSize: 13.w),
          ),
        ),
      ),
      cancel: GestureDetector(
        onTap: () => Get.back(result: false),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 5.w),
          margin: EdgeInsets.only(bottom: 12.w),
          decoration: BoxDecoration(
              color: const Color(0xffeae9ea),
              borderRadius: BorderRadius.circular(12.w)),
          child: Text(
            "取消",
            style: TextStyle(color: const Color(0xff191641), fontSize: 13.w),
          ),
        ),
      ));
  return res ?? false;
}
