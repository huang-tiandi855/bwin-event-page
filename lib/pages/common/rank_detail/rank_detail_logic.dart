import 'package:comics_app/common/apis/home_apis.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/utils/tab_controller_dispose.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'rank_detail_state.dart';

class RankDetailLogic extends GetxController with GetTickerProviderStateMixin {
  final RankDetailState state = RankDetailState();

  TabController? primaryTabController;

  int _prevPrimaryIndex = -1;

  /// 当前一级 Tab 是否为「影片 / 动漫」且处于选中（用于与 4 个周期刷新控制器绑定）。
  bool isPrimaryRankVisible(int primaryTabIndex) {
    final TabController? c = primaryTabController;
    if (c == null) return false;
    return c.index == primaryTabIndex &&
        (primaryTabIndex == 0 || primaryTabIndex == 1);
  }

  void _onPrimaryTabTick() {
    final c = primaryTabController;
    if (c == null || c.indexIsChanging) return;
    if (c.index == _prevPrimaryIndex) return;
    _prevPrimaryIndex = c.index;
    update();
  }

  void _attachPrimaryTabController() {
    final n = RankDetailState.primaryTabs.length;
    primaryTabController?.removeListener(_onPrimaryTabTick);
    primaryTabController?.dispose();
    primaryTabController = TabController(length: n, vsync: this)
      ..addListener(_onPrimaryTabTick);
    _prevPrimaryIndex = primaryTabController!.index;
  }

  @override
  void onInit() {
    super.onInit();
    _attachPrimaryTabController();
  }

  List<MediaVideoModel> rankListFor(int primaryTabIndex, int periodIndex) {
    if (primaryTabIndex == 0) return state.filmRankLists[periodIndex];
    if (primaryTabIndex == 1) return state.animeRankLists[periodIndex];
    return const <MediaVideoModel>[];
  }

  /// 列表为空时拉首屏（切换日/周/月/总或首次进入）。
  void ensureRankPeriodLoaded({
    required int primaryTabIndex,
    required int periodIndex,
  }) {
    if (primaryTabIndex != 0 && primaryTabIndex != 1) return;
    if (rankListFor(primaryTabIndex, periodIndex).isNotEmpty) return;
    loadRankList(primaryTabIndex: primaryTabIndex, periodIndex: periodIndex);
  }

  void onRankRefresh({
    required int primaryTabIndex,
    required int periodIndex,
  }) {
    if (primaryTabIndex == 0) {
      state.filmRankPage[periodIndex] = 1;
    } else {
      state.animeRankPage[periodIndex] = 1;
    }
    loadRankList(
      primaryTabIndex: primaryTabIndex,
      periodIndex: periodIndex,
    );
  }

  void onRankLoad({
    required int primaryTabIndex,
    required int periodIndex,
  }) {
    if (primaryTabIndex == 0) {
      state.filmRankPage[periodIndex]++;
    } else {
      state.animeRankPage[periodIndex]++;
    }
    loadRankList(
      primaryTabIndex: primaryTabIndex,
      periodIndex: periodIndex,
    );
  }

  /// 排行榜列表请求：
  /// - 日/周/月榜：`HomeApis.getRankList`（`cms/rank/list`，按 `rankDataType` 区分周期）；
  /// - 总榜：`HomeApis.getHomeMediaList`（`cms/vod/search-json`，固定 `sortType: 4, videoType: 0`）。
  ///
  /// 首屏替换，加载更多追加；按周期使用对应 [PullRefreshController]。
  Future<void> loadRankList({
    required int primaryTabIndex,
    required int periodIndex,
  }) async {
    if (primaryTabIndex != 0 && primaryTabIndex != 1) return;
    final bool isFilm = primaryTabIndex == 0;
    final int page = isFilm
        ? state.filmRankPage[periodIndex]
        : state.animeRankPage[periodIndex];
    final bool isFirstPage = page == 1;
    final bool isTotalRank =
        periodIndex == RankDetailState.periodLabels.length - 1;

    try {
      final List<MediaVideoModel> list = isTotalRank
          ? await HomeApis.getHomeMediaList(
              sortType: 4,
              pageNumber: page,
              pageSize: RankDetailState.rankListPageSize,
            )
          : await HomeApis.getRankList(
              rankType: isFilm
                  ? RankDetailState.filmPeriodRankDataTypes[periodIndex]
                  : RankDetailState.animePeriodRankDataTypes[periodIndex],
              pageNumber: page,
              pageSize: RankDetailState.rankListPageSize,
            );
      if (isFirstPage) {
        if (isFilm) {
          state.filmRankLists[periodIndex] = List<MediaVideoModel>.from(list);
        } else {
          state.animeRankLists[periodIndex] = List<MediaVideoModel>.from(list);
        }
      } else {
        if (isFilm) {
          state.filmRankLists[periodIndex] = <MediaVideoModel>[
            ...state.filmRankLists[periodIndex],
            ...list,
          ];
        } else {
          state.animeRankLists[periodIndex] = <MediaVideoModel>[
            ...state.animeRankLists[periodIndex],
            ...list,
          ];
        }
      }
      final bool hasMore = list.length >= RankDetailState.rankListPageSize;
      final bool isEmpty = rankListFor(primaryTabIndex, periodIndex).isEmpty;
      state.rankPeriodPullRefreshControllers[periodIndex].requestSuccess(
        isFirstPageNum: isFirstPage,
        hasMore: hasMore,
        isEmpty: isEmpty,
      );
      update();
    } catch (_) {
      if (!isFirstPage) {
        if (isFilm) {
          state.filmRankPage[periodIndex] = state.filmRankPage[periodIndex] > 1
              ? state.filmRankPage[periodIndex] - 1
              : 1;
        } else {
          state.animeRankPage[periodIndex] =
              state.animeRankPage[periodIndex] > 1
                  ? state.animeRankPage[periodIndex] - 1
                  : 1;
        }
      }
      state.rankPeriodPullRefreshControllers[periodIndex].requestFail(
        isFirstPageNum: isFirstPage,
      );
      update();
    }
  }

  @override
  void onClose() {
    final c = primaryTabController;
    c?.removeListener(_onPrimaryTabTick);
    disposeTabControllerAfterRouteExit(c);
    for (final PullRefreshController c
        in state.rankPeriodPullRefreshControllers) {
      c.refreshController.dispose();
      c.code.dispose();
    }
    super.onClose();
  }
}
