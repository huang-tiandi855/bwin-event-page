import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



/// 左边icon 右边文字｜ 只有文字
/// [topLeft] 左上圆角
/// [topRight] 右上圆角
/// [bottomLeft] 左下圆角
/// [bottomRight] 右下圆角
/// [text] 文字
/// [iconPath] 图片路径
enum IconAndTextType {
  onlyText,
  onlyIcon,
  leftText,
  rightText,
}

Widget rowIconAndText(
    {required IconAndTextType type,
      String? iconPath,
      Size? iconSize,
      String? text,
      Color? bjColor,
      TextStyle? onlyTextStyle,
      TextStyle? rightTextStyle,
      TextStyle? leftTextStyle,
      BorderSide? borderSide,
      double? rootHorizontal,
      double? rootVertical,
      double? spacing,
      double? topLeft,
      double? topRight,
      double? bottomLeft,
      double? bottomRight,
      int? maxLine,
      double? textMaxWidth,
      MainAxisAlignment? mainAxisAlignment,
      CrossAxisAlignment? crossAxisAlignment,
      Alignment? onlyTextAlignment}) {
  Widget body;

  switch (type) {
    case IconAndTextType.onlyText:
      body = Container(
          alignment: onlyTextAlignment ?? Alignment.center, child: Text(text ?? '', style: onlyTextStyle, maxLines: 1));
      break;
    case IconAndTextType.onlyIcon:
      body = Container(
          alignment: Alignment.center,
          child: Image.asset(iconPath ?? '', width: iconSize?.width ?? 24.w, height: iconSize?.height ?? 24.h));
      break;
    case IconAndTextType.leftText:
      body = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        children: [
          textMaxWidth == null
              ? Expanded(child:Text(
            text ?? '',
            style: rightTextStyle,
            maxLines: maxLine ?? 1,
          ))
              : Container(
              constraints: BoxConstraints(maxWidth: textMaxWidth.w),
              child: Text(
                text ?? '',
                style: rightTextStyle,
                maxLines: maxLine ?? 1,
                overflow: TextOverflow.ellipsis,
              )),
          spacing == null ? 6.horizontalSpace : SizedBox(width: spacing.w),
          Image.asset(iconPath ?? '', width: iconSize?.width ?? 24.w, height: iconSize?.height ?? 24.h),
        ],
      );
      break;
    default:
      body = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:  MainAxisAlignment.start,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        children: [
          Image.asset(iconPath ?? '', width: iconSize?.width ?? 24.w, height: iconSize?.height ?? 24.h),
          spacing == null ? 6.horizontalSpace : SizedBox(width: spacing.w),
          textMaxWidth == null
              ? Text(
            text ?? '',
            style: rightTextStyle,
            maxLines: maxLine ?? 1,
          )
              : Container(
              constraints: BoxConstraints(maxWidth: textMaxWidth.w),
              child: Text(
                text ?? '',
                style: rightTextStyle,
                maxLines: maxLine ?? 1,
              )),
        ],
      );
      break;
  }
  Decoration? decoration;
  if (borderSide == null && (topLeft == 0 && topRight == 0 && bottomLeft == 0 && bottomRight == 0)) {
    decoration = null;
  } else {
    decoration = ShapeDecoration(
      color: bjColor,
      shape: RoundedRectangleBorder(
        side: borderSide ?? BorderSide.none,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(topLeft ?? 0),
          bottomLeft: Radius.circular(bottomLeft ?? 0),
          topRight: Radius.circular(topRight ?? 0),
          bottomRight: Radius.circular(bottomRight ?? 0),
        ),
      ),
    );
  }

  body = Container(
      padding: EdgeInsets.symmetric(horizontal: rootHorizontal ?? 0.w, vertical: rootVertical ?? 0.h),
      decoration: decoration,
      child: body);
  return body;
}