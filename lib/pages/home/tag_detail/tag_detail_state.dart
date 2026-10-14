import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:flutter/material.dart';

import '../../../common/entities/MediaListInfo.dart';
import '../../../common/widgets/pullRefreshView/pull_refresh_view.dart';

class TagDetailState {
  final List<String> tabs = [
    "最多观看",
    "最多收藏",
    "最新上架",
  ];

  late TabController tabController;
  String title="标签";
  int kind = 0;
  String? id;
  List<String>? tagsId;
  int sortType = 0;
  late PullRefreshController pullRefreshController = PullRefreshController();

  List<MediaList> tagMediaList = [];
  List<MediaList> mediaList = [];
  List<AllMediaInfoModel> tagSubMediaList = [];
  List<AllMediaInfoModel> realTagSubMediaList = [];
  int pageNum = 1;
  int pageSize = 24;
  bool isLoading = false;

  bool get isVerticalCover => mediaList.isNotEmpty ? mediaList.first.isVerticalCover : false;
  bool get isSubVerticalCover => tagSubMediaList.isNotEmpty ? tagSubMediaList.first.isVerticalCover : false;
}
