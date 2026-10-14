import 'package:flutter/material.dart';

import '../../../../common/entities/acg_section/rank_model.dart';

class HotRankingState {
  late TabController tabController;
  late List<String> tabs = [];
  List<Widget> tabViews = [];
  RankModel? rankModel;
  HotRankingState() {
    ///Initialize variables
    tabs = [
      "动漫",
      "漫画",
      // "COS",
      "真人",
      "写真",
      "小说",
      "原作",
    ];
  }
}
