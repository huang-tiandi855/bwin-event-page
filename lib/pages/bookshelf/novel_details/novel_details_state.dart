import 'dart:async';

import 'package:comics_app/common/entities/media_list_entity.dart';
import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../common/utils/const.dart';
import '../../../common/values/enum.dart';

class NovelDetailsState {
  ScrollController scrollController = ScrollController();
  RxBool isShowTitle = false.obs;
  late MediaKind mediaKind;
 // int oldEpisode = 0;
  bool isOpenDirectory = false;
  AllMediaInfoModel? mediaInfoEntity;
  List<MediaListMediaList> mediaList = [];
  List<int> hasRead = [];
  var isLoading = true.obs;
  String id = "";
  double rate = 1.0;
  Timer? timer;
  int countdownTime = 0;
  int endTime = 0;
  int index = 0;
  NovelDetailsState() {}

  void reset(){
   // oldEpisode = 0;
    index = 0;
    mediaList = [];
    rate = 1.0;
    timer?.cancel();
    timer = null;
    countdownTime = 0;
  }

  bool isAllStop = false;

  bool isNovelKind(){
    var kind = mediaInfoEntity?.kind??0;
    return kind == KindConst.NOVELKIND || kind == KindConst.AUDIOKIND;
  }
}
