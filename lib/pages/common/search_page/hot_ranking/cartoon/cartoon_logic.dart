import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../../../common/apis/acg_api.dart';
import '../../../../../common/entities/acg_section/rank_model.dart';
import 'cartoon_state.dart';

class CartoonHotRankingLogic extends GetxController {
  final CartoonState state = CartoonState();

  final int kind;
  CartoonHotRankingLogic(this.kind);
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    getMediaInfo();

    Map map = {};

    map["链路"] = "首页-热门排行榜-动漫";

    ConfigStore.to.trackData('首页浏览', map);
  }

  //初始化数据
  void getMediaInfo() async {
    state.pullRefreshController.code =
        ValueNotifier(PULL_REQUEST_CODE.REQUESTING);

    Map<String, dynamic> data = {
      "kind": kind,
      "page": state.pageNumber,
      "pageSize": 20,
    };

    var result = await ACGApi.getRank(paramV: data);

    RankModel ranking = RankModel.fromJson(result.data);

    if (state.pageNumber! > 1) {
      ranking.mediaList?.forEach((element) {
        state.ranking?.mediaList?.add(element);
      });

      if (ranking.hasNext ?? false) {
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
        hasMore: ranking.hasNext ?? false);

    update();
  }
}
