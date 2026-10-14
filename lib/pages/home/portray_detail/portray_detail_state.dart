import 'package:comics_app/common/entities/MediaListInfo.dart';
import 'package:comics_app/common/entities/media_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PortrayDetailState {
  String? mediaInfoId;

  MediaInfo? mediaInfo;

  MediaListInfo? mediaListInfo;

  int index = 0;

  List<MediaList> mediaList = [];

  RxBool isMenuVisiable = false.obs;

  ScrollController scrollController = ScrollController();

  String? title;

  bool showDialog = false;

  PortrayDetailState() {
    ///Initialize variables

    mediaInfoId = Get.arguments["id"];

    index = Get.arguments["index"]??0;

    mediaList = Get.arguments["imageList"]??[];
    printInfo(info:"$mediaInfoId====$index====${mediaList.length}");
  }
}
