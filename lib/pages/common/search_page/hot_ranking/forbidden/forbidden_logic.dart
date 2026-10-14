import 'package:comics_app/common/apis/apis.dart';
import 'package:comics_app/common/entities/ranking.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'forbidden_state.dart';

class ForbiddenHotRankingLogic extends GetxController {
  final ForbiddenState state = ForbiddenState();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    getMediaInfo();



    Map map = {};

    map["链路"] = "首页-热门排行榜-原作";

    ConfigStore.to.trackData('首页浏览',map);
  }

  //初始化数据
  void getMediaInfo() async {
    state.pullRefreshController.code =
        ValueNotifier(PULL_REQUEST_CODE.REQUESTING);

    Map<String, dynamic> data = {
      "kind": 6,
      "page": state.pageNumber,
      "pageSize": 20,
    };

    Map<String, dynamic> mediaInfo = await UserApi.getHotRanking(data);

    Ranking ranking = Ranking.fromJson(mediaInfo);

    if (state.pageNumber! > 1) {
      ranking.data!.mediaList?.forEach((element) {
        state.ranking?.data?.mediaList?.add(element);
      });

      if (ranking.data!.hasNext ?? false) {
        state.pullRefreshController.refreshController.loadComplete();
      } else {
        state.pullRefreshController.refreshController.loadNoData();
      }
    } else {
      state.ranking = ranking;

      state.pullRefreshController.refreshController
          .refreshCompleted(resetFooterState: true);
    }

    state.pullRefreshController.requestSuccess(
        isFirstPageNum: state.pageNumber == 1 ? true : false,
        hasMore: ranking.data?.hasNext ?? false);

    update();
  }
}
