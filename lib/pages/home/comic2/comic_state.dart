import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/pages/home/comic2/tab_info.dart';
import 'package:flutter/material.dart';

import '../../../common/entities/module_detail_model/module_detail_model.dart';

class ComicState2 {
  ModuleDetailModel? moduleDetailModel;

  late PullRefreshController pullRefreshControllerComic =
      PullRefreshController();

  late List<AdsInfoList> banner = [];

  int pageNum = 1;

  int selectIndex = 0;

  bool isLoading = false;
  int? moduleSort;
  late TabController tabController;
  var tabValues = [TabInfo(name: "最新", value: 1),TabInfo(name: "最热", value: 2)];
  var tabVal = [TabInfo(name: "最新连载", value: 1),TabInfo(name: "精彩完结", value: 7),TabInfo(name: "热门推荐", value: 2)];
  var currentTabs = [];
  int itemCount = 0;
  ComicState2() {
    ///Initialize variables
  }
}
