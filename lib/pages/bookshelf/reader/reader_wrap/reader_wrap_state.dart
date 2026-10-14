import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/entities/readerChapterModel.dart';
import 'package:comics_app/common/utils/nested_page_view_utils.dart';
import 'package:comics_app/pages/bookshelf/reader/widget/reader_bg.dart';
import 'package:comics_app/pages/bookshelf/reader/widget/reader_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReaderWrapState {
  late PageController pageController;
  late NestedPageViewUtils pageViewScrollUtils =
      NestedPageViewUtils(pageController);

  late AllMediaInfoModel mediaInfoEntity;

  TextStyle textStyle = ThemeDarkNight.instance.textStyle;
  BgType bgType = ThemeDarkNight.instance.bgType;
  Color bottomOverlayerColor = ThemeDarkNight.instance.bottomOverlayerColor;
  Color menuBg = ThemeDarkNight.instance.menuBg;
  Color menuColor = ThemeDarkNight.instance.menuColor;

  Color drawerColor = ThemeDarkNight.instance.drawerColor;
  Color drawerColorSeTitle = ThemeDarkNight.instance.drawerColorSeTitle;
  Color drawerBg = ThemeDarkNight.instance.drawerBg;
  Color drawerActiveColor = ThemeDarkNight.instance.drawerActiveColor;
  Color drawerLine = ThemeDarkNight.instance.drawerLine;

  bool directoryReverseOrder = false; //目录倒序

  double topSafeHeight = 0;
  double bottomSafeHeight = 0;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  RxBool isMenuVisiable = false.obs;

  int lastChapter = 0;
  int page = 0;

  bool isShowDialog = false;

  List<ReaderChapterModel?> get dataList {
    final list = directory.values.map<List<ReaderChapterModel?>>((e) {
      return data.containsKey(e.episodeNumber)
          ? data[e.episodeNumber]!
          : [null];
    });

    return list.expand((element) => element).toList();
  }

  List<ReaderChapterModel?> get renderList {
    // List<ReaderChapterModel?> list = [];
    // final temp = dataList;
    if (data.isEmpty) {
      return [null];
    }
    // return [
    //   //if (!data.containsKey(mediaInfoEntity.contents.first.episodeNumber)) null,
    //   ...temp,
    //   // if (!data.containsKey(mediaInfoEntity.contents.last.episodeNumber)) null,
    // ];
    return dataList;
  }

  Map<int, List<ReaderChapterModel>> data = {};

  Map<int, ReaderChapterModel> directory = {};

  int get currentChapter {
    if (renderList.elementAt(page) == null) {
      return lastChapter;
    }
    return renderList.elementAt(page)!.episodeNumber;
  }
}
