import 'dart:convert';

import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../generated/assets.dart';

class WidgetUtils {
  WidgetUtils._internal();

  static WidgetUtils? instance;

  static getInstance() {
    instance ??= WidgetUtils._internal();
    return instance;
  }

  factory WidgetUtils() => getInstance();

  Widget buildElevatedButton(String text,
      {Color? bg = AppColor.ce6e6e6,
      Color textColor = Colors.white,
      double padding = 0,
      double margin = 0,
      double height = 44,
      double width = double.infinity,
      double bottom = 0,
      double opacity = 1,
      double textSize = 16,
      FontWeight fontWeight = FontWeight.w600,
      VoidCallback? onPressed}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: padding, right: padding),
        margin: EdgeInsets.only(
          left: margin,
          right: margin,
          bottom: bottom,
        ),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(40)),
            color: AppColor.primaryColor),
        child: Text(
          text,
          style: TextStyle(
              fontSize: textSize, color: Colors.white, fontWeight: fontWeight),
        ),
      ),
    );
  }

  Widget buildTitle(String title, {double padding = 12, double fontSize = 14}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 22,
          decoration: const BoxDecoration(
              color: AppColor.primaryColor,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4))),
        ),
        SizedBox(
          width: padding,
        ),
        Text(
          title,
          style: TextStyle(
            color: AppColor.primaryColor,
            fontSize: fontSize,
          ),
        )
      ],
    );
  }

  buildTips(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "支付遇到问题请联系",
          style:
              TextStyle(fontSize: 12, color: Color.fromRGBO(161, 162, 168, 1)),
        ),
        const SizedBox(
          width: 8,
        ),
        GestureDetector(
            onTap: () async {},
            child: const Text(
              "在线客服",
              style: TextStyle(fontSize: 12, color: AppColor.primaryText),
            )),
      ],
    );
  }

  Widget buildOutlineButton(
      String text, double width, double height, Color lineColor,
      {Color? bg,
      Color textColor = Colors.white,
      double textSize = 14,
      VoidCallback? onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        side: BorderSide(color: lineColor, width: 1.r),
        backgroundColor: bg,
        minimumSize: Size(width, height),
        maximumSize: Size(width, height),
        padding: EdgeInsets.zero,
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: textSize.sp,
            color: textColor,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  void clickCopy(String value) {
    if (ObjectUtil.isNotEmpty(value)) {
      Clipboard.setData(ClipboardData(text: value));
      showToast(msg: "复制成功");
    }
  }

  Widget buildDrawNum(String num, Color bg) {
    return Container(
      width: 24.r,
      height: 24.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Text(
        num,
        style: TextStyle(
            fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget buildQRCode(
    String code,
    double width,
    double height,
  ) {
    // 移除Base64头信息
    String base64String = code.split(',').last;
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.fill,
      width: width,
      height: height,
    );
  }
}

newYearContainer({String? url, BoxFit? fit, double? height}) {
  var image = url ?? Assets.imagesNewYearHomeBg;
  return Container(
    width: 1.sw,
    height: height ?? 1.sh,
    decoration: BoxDecoration(
      color: const Color(0xfff5f5f5),
      image: DecorationImage(
          image: AssetImage(image),
          fit: fit ?? BoxFit.fitHeight,
          alignment: Alignment.topCenter),
    ),
  );
}

newYearDecorationImage({String? url, BoxFit? fit}) {
  return BoxDecoration(
      color: const Color(0xfff5f5f5),
      image: DecorationImage(
          image: AssetImage(url ?? Assets.imagesNewYearHomeBg),
          fit: fit ?? BoxFit.fitHeight,
          alignment: Alignment.topCenter));
}
