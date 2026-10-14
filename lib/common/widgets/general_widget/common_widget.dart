import 'dart:ui';

import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/array_util.dart';
import 'package:comics_app/common/utils/click_util.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 通用点击事件
Widget clickButton(
    {VoidCallback? onTap,
    Widget? child,
    bool openLimit = false,
    HitTestBehavior behavior = HitTestBehavior.opaque}) {
  return GestureDetector(
      behavior: behavior,
      onTap: () {
        if (ClickUtil.isFastClick() && openLimit) {
          return;
        }
        onTap?.call();
      },
      child: child);
}

/// 极简 [TextStyle] 工厂。统一项目里散落各处的内联 `TextStyle(...)` 拼装，
/// 让排版相关代码更短，方便后续要批量调整字号 / 字重时只改一处。
TextStyle textStyle(double fontSize, Color color, FontWeight fontWeight) {
  return TextStyle(
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
  );
}

/// 富文本辅助：根据若干 [InlineSpan] 拼出一个 `Text.rich`。
///
/// 历史上散落在 `comment_view.dart` 里，与 [textStyle] / [textSpan] 是一套
/// 工具函数；旧评论模块清理后统一搬到本文件，业务侧只 import 一个地方即可。
Text textSpans(List<InlineSpan> spans,
    {int maxLines = 1, TextAlign? textAlign}) {
  return Text.rich(
    textAlign: textAlign,
    TextSpan(children: spans),
    maxLines: maxLines,
    overflow: TextOverflow.ellipsis,
  );
}

/// 富文本辅助：构造一段 [TextSpan]，复用 [textStyle] 形成短调用。
TextSpan textSpan(
    String title, Color color, int fontSize, FontWeight fontWeight) {
  return TextSpan(
    text: title,
    style: textStyle(fontSize.toDouble(), color, fontWeight),
  );
}

/// 竖线
Widget getSuLine({
  double h = 0,
  double w = 0,
  Color? color,
  double radius = 0.0,
  List<Color>? colors,
  double top = 0,
  double bottom = 0,
  double left = 0,
  double right = 0,
  AlignmentGeometry? begin,
  AlignmentGeometry? end,
}) {
  if (w == 0) w = 1.w;
  if (h == 0) h = 14.h;
  return Container(
      margin:
          EdgeInsets.only(top: top, bottom: bottom, left: left, right: right),
      height: h,
      width: w,
      decoration: BoxDecoration(
          color: color ?? Colors.white.withOpacity(.5),
          borderRadius: BorderRadius.circular(radius),
          gradient: ArrayUtil.isNotEmpty(colors)
              ? LinearGradient(
                  begin: begin ?? Alignment.topCenter,
                  end: end ?? Alignment.bottomCenter,
                  colors: colors ??
                      [
                        Colors.white.withOpacity(0),
                        Colors.white.withOpacity(.5),
                        Colors.white.withOpacity(0)
                      ])
              : null));
}

/// 获取水平分割线
Widget getHengLine(
    {double w = 0,
    double h = .5,
    Color? color,
    double top = 0,
    double bottom = 0,
    double left = 0,
    double right = 0}) {
  if (w <= 0) w = double.infinity;
  return Container(
      margin:
          EdgeInsets.only(top: top, bottom: bottom, left: left, right: right),
      height: h,
      width: w,
      color: color ?? Colors.white.withOpacity(.5));
}

/// 字体渐变遮罩 自定义
Widget textLinearGradient(
    {Widget? child,
    Rect? bound,
    List<Color>? colors,
    AlignmentGeometry? begin,
    AlignmentGeometry? end}) {
  return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: begin ?? Alignment.centerLeft,
          end: end ?? Alignment.centerRight,
          colors: colors ??
              [
                Colors.white,
                Colors.white,
              ],
        ).createShader(bound ?? bounds);
      },
      blendMode: BlendMode.modulate,
      child: child);
}

/// 获取通用button
Widget getCommonButton(
  String text, {
  double? width,
  double? height,
  VoidCallback? onClick,
  TextStyle? textStyle,
  Color? color, //背景色
  Color? textColor, //按钮字体颜色
  bool showShadow = false,
  double borderWidth = 0.0,
  Color? borderColor, //边框颜色
  bool enable = true,
  BoxShadow? boxShadow,
  bool isBorder = false, //边框开关
  double? radius, //圆角大小默认是高度的一半
  Widget? childWidget,
  bool openLimit = false,
}) {
  width = width ?? 260.w;
  height = height ?? 40.h;
  color = color ?? Colors.white.withOpacity(.5);
  borderColor = borderColor ?? Colors.transparent;
  textColor = textColor ?? Colors.white;
  return clickButton(
      onTap: onClick,
      openLimit: openLimit,
      child: Container(
          height: height,
          width: width,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(radius ?? (height / 2)),
              border: enable
                  ? isBorder
                      ? Border.all(color: borderColor, width: borderWidth)
                      : null
                  : Border.all(width: borderWidth, color: borderColor),
              boxShadow: showShadow
                  ? [
                      boxShadow ??
                          BoxShadow(
                              color: Colors.black.withOpacity(.1),
                              offset: const Offset(0, .5),
                              blurRadius: 3.5)
                    ]
                  : []),
          child: childWidget ??
              Text(text,
                  style: textStyle ??
                      TextStyle(color: textColor, letterSpacing: 1))));
}

// 创建一个自定义渐变按钮
Widget getConfirmButton(
  String text, {
  double? width,
  double? height,
  VoidCallback? onClick,
  TextStyle? textStyle,
  Color? textColor, //按钮字体颜色
  List<Color>? colors, // 渐变背景色
  Color? borderColor, //边框颜色
  bool showShaw = false,
  bool enable = true,
  double? radius, //圆角大小默认是高度的一半
  Gradient? gradient, //渐变径向
  AlignmentGeometry? begin,
  AlignmentGeometry? end,
  Widget? childWidget,
  double? borderWidth,
  List<BoxShadow>? boxShadow,
  bool openLimit = false,
}) {
  width = width ?? 210.w;
  height = height ?? 35.h;
  textColor = textColor ?? AppColor.primaryText;
  return clickButton(
      onTap: onClick,
      openLimit: openLimit,
      child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              gradient: gradient ??
                  LinearGradient(
                      begin: begin ?? Alignment.centerLeft,
                      end: end ?? Alignment.centerRight,
                      colors: colors ?? AppColor.scaffoldContentLinearGradient),
              borderRadius: BorderRadius.circular(radius ?? (height / 2)),
              border: null == borderColor
                  ? null
                  : Border.all(width: borderWidth ?? 1, color: borderColor),
              boxShadow: showShaw
                  ? boxShadow ??
                      [
                        const BoxShadow(
                            offset: Offset(0, 1.5),
                            color: Color(0xff575858),
                            blurRadius: 3)
                      ]
                  : null),
          alignment: Alignment.center,
          child: childWidget ??
              Text(text,
                  style: textStyle ??
                      TextStyle(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w400))));
}

/// 获取page背景色
Widget getBgColorsView(
    {Widget? child,
    double? width,
    double? height,
    List<Color>? colors,
    bool isTopBottom = true,
    AlignmentGeometry? begin,
    AlignmentGeometry? end}) {
  return Stack(children: [
    Container(
        width: width ?? ScreenUtil().screenWidth,
        height: height ?? ScreenUtil().screenHeight,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: begin ??
                    (isTopBottom ? Alignment.topCenter : Alignment.centerLeft),
                end: end ??
                    (isTopBottom
                        ? Alignment.bottomCenter
                        : Alignment.centerRight),
                colors: colors ?? AppColor.scaffoldContentLinearGradient))),
    child!
  ]);
}

/// 毛玻璃效果（[alignment] 默认居中；侧栏可传 [Alignment.centerRight] 等）
Widget getPhotoMaskView(
    {double? height,
    double? width,
    double? sigmaXY,
    double? opacity,
    Color? color,
    AlignmentGeometry alignment = Alignment.center,
    Widget? child}) {
  return Align(
      alignment: alignment,
      child: ClipRect(
          child: BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: (sigmaXY != null) ? sigmaXY : 5.0,
                  sigmaY: (sigmaXY != null) ? sigmaXY : 5.0),
              child: Opacity(
                  opacity: (opacity != null) ? opacity : 0.5,
                  child: Container(
                      width:
                          (width != null) ? width : ScreenUtil().screenHeight,
                      height:
                          (height != null) ? height : ScreenUtil().screenHeight,
                      color: (color != null)
                          ? color
                          : Colors.black.withOpacity(.6),
                      child: child)))));
}

/// 获取page背景图片
Widget getBgImgView(
  AssetGenImage image, {
  margin,
  double? width,
  double? height,
  Widget? child,
  double? scale,
  double? opacity,
  double? radius,
  Color? bgColor,
  BoxFit fit = BoxFit.cover,
  bool customHeight = false,
  bool isTransparent = false,
  Alignment alignment = Alignment.center,
}) {
  return Stack(children: [
    Container(
        width: width,
        color: bgColor ?? AppColor.scaffoldBackground,
        height: customHeight ? height : ScreenUtil().screenHeight),
    Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius ?? 0),
        child: image.image(
            scale: scale,
            width: width,
            fit: fit,
            height: height,
            alignment: alignment),
      ),
    ),
    SizedBox(
        width: width,
        height: customHeight ? height : ScreenUtil().screenHeight,
        child: child)
  ]);
}

/// 获取空Widget
Widget getEmptyWidget({String? emptyText, Color? color}) {
  return Center(
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AssetsGen.images.mine.inviteEmptyImg
              .image(width: 206.w, height: 172.h),
          23.h.verticalSpace,
          Text(emptyText ?? '暂无数据',
              style: TextStyle(
                  fontSize: 16.sp, color: AppColor.primaryButtonColor))
        ]),
  );
}
