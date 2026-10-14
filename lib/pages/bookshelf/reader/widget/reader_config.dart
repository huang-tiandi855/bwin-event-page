import 'package:comics_app/pages/bookshelf/reader/widget/reader_bg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/style/color.dart';
import '../../../../common/utils/screen.dart';

class ReaderConfig {
  static ReaderConfig instance = ReaderConfig();

  double fontSize = 18.0.h;
}

fixedFontSize(double fontSize) {
  return fontSize / Screen.contentTextScale;
}

//牛皮纸
class ThemeKraftPaper {
  static ThemeKraftPaper instance = ThemeKraftPaper();

  BgType bgType = BgType.greenBg; //背景

  TextStyle textStyle = TextStyle(
    fontSize: fixedFontSize(ReaderConfig.instance.fontSize),
    color: AppColor.c333333,
  ); //正文颜色
  Color bottomOverlayerColor = AppColor.c333333;

  Color menuBg = AppColor.white; //menu 背景
  Color menuColor = AppColor.c333333; //menu 颜色

  Color drawerColor = AppColor.warmGrey; //目录 颜色
  Color drawerColorSeTitle = AppColor.c333333; // 二级标题颜色
  Color drawerBg = AppColor.white; //目录 背景
  Color drawerActiveColor = AppColor.c333333; //目录选中颜色
  Color drawerLine = AppColor.cf5ebea.withOpacity(0.1); //目录线颜色
}

//黑夜
class ThemeDarkNight {
  static ThemeDarkNight instance = ThemeDarkNight();

  BgType bgType = BgType.night; //背景

  TextStyle textStyle = TextStyle(
    fontSize: fixedFontSize(ReaderConfig.instance.fontSize),
    color: Colors.white,
  ); //正文颜色
  Color bottomOverlayerColor = Colors.white;

  Color menuBg = Colors.black; //menu 背景
  Color menuColor = Colors.white; //menu 颜色

  Color drawerColor = AppColor.warmGrey; //目录 颜色
  Color drawerColorSeTitle = AppColor.white; // 二级标题颜色
  Color drawerBg = AppColor.black; //目录 背景
  Color drawerActiveColor = AppColor.white; //目录选中颜色
  Color drawerLine = AppColor.cf5ebea.withOpacity(0.1); //目录线颜色
}
