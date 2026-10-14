import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/pages/bookshelf/reader/widget/reader_bg.dart';
import 'package:comics_app/pages/bookshelf/reader/widget/reader_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/entities/readerChapterModel.dart';

class ReaderState {
  late PageController pageController;
  bool isPlay = false;

  late TextStyle textStyle;
  late BgType bgType;
  late Color bottomOverlayerColor;
  late Color menuBg;
  late Color menuColor;

  late Color drawerColor;
  late Color drawerColorSeTitle;
  late Color drawerBg;
  late Color drawerActiveColor;
  late Color drawerLine;

  AllMediaInfoModel mediaInfoEntity = AllMediaInfoModel();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  RxBool isMenuVisiable = false.obs;
  int pageIndex = 0; //当前页数
  int curChapterNum = 1; // 当前章节
  double topSafeHeight = 0;
  double bottomSafeHeight = 0;
  int chapterTotal = 0; //总章节
  bool directoryReverseOrder = false; //目录倒序
  List<ReaderChapterModel> readerList = [];
  ReaderChapterModel? preArticle;
  ReaderChapterModel? currentArticle;
  ReaderChapterModel? nextArticle;

  ReaderState() {
    ///Initialize variables
    bgType = ThemeDarkNight.instance.bgType;
    textStyle = ThemeDarkNight.instance.textStyle;
    bottomOverlayerColor = ThemeDarkNight.instance.bottomOverlayerColor;
    menuBg = ThemeDarkNight.instance.menuBg;
    menuColor = ThemeDarkNight.instance.menuColor;

    drawerColor = ThemeDarkNight.instance.drawerColor;
    drawerColorSeTitle = ThemeDarkNight.instance.drawerColorSeTitle;
    drawerBg = ThemeDarkNight.instance.drawerBg;
    drawerActiveColor = ThemeDarkNight.instance.drawerActiveColor;
    drawerLine = ThemeDarkNight.instance.drawerLine;
  }
}
