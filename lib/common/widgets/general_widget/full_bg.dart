// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 自己定义的通用背景
class FullBg extends StatelessWidget {
  final Widget? child;
  final AssetGenImage? bgImage;
  final double? height;
  final Color? bgColor;
  final Alignment alignment;

  const FullBg(
      {Key? key,
      @required this.child,
      this.bgImage,
      this.height,
      this.bgColor,
      this.alignment = Alignment.center})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        child: getBgImgView(bgImage!,
            bgColor: bgColor,
            alignment: alignment,
            width: ScreenUtil().screenWidth,
            height: height ?? ScreenUtil().screenHeight,
            child: Container(color: Colors.transparent, child: child)));
  }
}
