import 'package:comics_app/common/entities/acg_section/rank_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/apis/acg_api.dart';
import 'cartoon/cartoon_view.dart';
import 'hot_ranking_state.dart';

class HotRankingLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  final HotRankingState state = HotRankingState();

  @override
  void onInit() {
    // TODO: implement onInit

    super.onInit();

    getData();
  }

  getData() async {
    var result = await ACGApi.getRank();
    if (result.isSuccess) {
      state.rankModel = RankModel.fromJson(result.data);
      state.tabController = TabController(
          length: state.rankModel?.rankList?.length ?? 0,
          vsync: this,
          initialIndex: 0);
      fillData();
    }
  }

  fillData() {
    var rankList = state.rankModel?.rankList;
    if (rankList?.isNotEmpty == true) {
      for (int i = 0; i < rankList!.length; i++) {
        var item = rankList[i];
        state.tabViews.add(CartoonRankingPage(
          kind: item.kind ?? 0,
          key: ValueKey('${item.name}-${item.kind}-${item.sort}'),
        ));
      }
    }
    update();
  }
}
