import 'package:comics_app/common/entities/module_detail_model/content_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/entities/module_detail_model/all_media_info_model.dart';

class ComicReadingState {
  // int chaptersNumber = 1; //章节
  int index = 0;
  ContentModel? mediaInfoContents;
  AllMediaInfoModel? mediaInfoEntity;
  RxBool isMenuVisiable = false.obs;
  bool isAutoPlayShow = false;

  double scaleValue = 1.0;

  bool directoryReverseOrder = false; //目录倒序
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController scrollController = ScrollController();
  var readSpeed = ["0.5x","1.0x","1.5x","2.0x",];
  ComicReadingState() {
    ///Initialize variables
  }
}
