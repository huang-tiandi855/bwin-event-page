import 'package:bot_toast/bot_toast.dart';
// import 'package:comics_app/common/style/style.dart';
// import 'package:comics_app/common/utils/flutter_base.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//import 'package:fluttertoast/fluttertoast.dart';

// import 'text_util.dart';

/// 显示统一的toast 无context
dynamic showToast({
  required String msg,
  /*Toast toastLength = Toast.LENGTH_LONG,
    ToastGravity gravity = ToastGravity.CENTER*/
}) {
  //if (TextUtil.isEmpty(msg)) return Future.value(false);

  return BotToast.showText(text: msg);

  // return customShowToast.showToast(msg,position: ToastPosition.center,context: FlutterBase.appContext);

  /*return Fluttertoast.showToast(
      webPosition: 'center',
      webBgColor: "rgba(0,0,0,0.5)",
      msg: msg,
      gravity: gravity,
      toastLength: toastLength,
      timeInSecForIosWeb: 1,
      // backgroundColor:AppColor.c1b164c,
      backgroundColor: Colors.black.withOpacity(0.75),
      fontSize: 13.w);*/
}

/// 显示统一的toast 无context
dynamic CustomshowToast({
  required String msg,
  /*Toast toastLength = Toast.LENGTH_LONG,
    ToastGravity gravity = ToastGravity.CENTER*/
}) {
  //if (TextUtil.isEmpty(msg)) return Future.value(false);

  return BotToast.showText(text: msg);

  /*return Fluttertoast.showToast(
      webPosition: 'center',
      webBgColor: "rgba(0,0,0,0.5)",
      msg: msg,
      gravity: gravity,
      toastLength: toastLength,
      timeInSecForIosWeb: 3,
      backgroundColor: AppColor.bluishPurple,
      fontSize: 13.w);*/
}
