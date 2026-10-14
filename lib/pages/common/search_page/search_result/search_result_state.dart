import 'package:comics_app/common/entities/MediaListInfo.dart';
import 'package:comics_app/common/utils/const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchResultState {
  SearchResultState({
    String? initialKeyword,
    TextEditingController? textEditingController,
  }) {
    keyWord = initialKeyword ?? Get.arguments?["keyWord"];
    this.textEditingController =
        textEditingController ?? TextEditingController(text: keyWord ?? '');
  }

  late TextEditingController textEditingController;
  String? keyWord;

  late TabController tabController;

  MediaListInfo? mediaListInfo;

  dynamic doSearch;

  List<MediaList> mediaList = [];

  bool isLoading = false;

  int selectedKindIndex = 0;

  final List<String> tabs = [
    "影片",
    "抖音",
    "帖子",
    // "图集",
  ];

  final List<int> kinds = [
    KindConst.CARTTONKIND,
    KindConst.COMMICKIND,
    KindConst.QUANZI,
    KindConst.PORTRAYKIND,
  ];

  void setDoSearch(dynamic doSearch) {
    this.doSearch = doSearch;
  }
}
