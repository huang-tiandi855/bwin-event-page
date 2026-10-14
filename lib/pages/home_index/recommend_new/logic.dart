import 'package:comics_app/common/apis/home_apis.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/utils/tab_controller_dispose.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'state.dart';

class RecommendNewLogic extends GetxController
    with GetTickerProviderStateMixin {
  final RecommendNewState state = RecommendNewState();

  final ModuleModel? module;

  /// 数据接口的 `videoType` 入参（0 普通 / 1 短视频 / 2 暗网）。
  ///
  /// 默认 0 兼容首页（[HomeIndexLogic.primaryTabPage] 不显式传），
  /// 暗网入口（[DarkLogic.primaryTabPage]）显式传 2 —— 让本 logic 和
  /// dark/home 这两类页面共用同一份 Recommend* 组件，但底层 `cms/vod/search-json`
  /// / `cms/rank/list` 走的是各自的数据集。
  final int videoType;

  RecommendNewLogic({
    required this.module,
    this.videoType = 0,
  });
  TabController? subTabController;

  /// 与 [subTabController] 同步，避免重复刷新
  int _prevFilterTabIndex = -1;

  void _onSubTabControllerTick() {
    final c = subTabController;
    if (c == null || c.indexIsChanging) return;
    if (c.index == _prevFilterTabIndex) return;
    _prevFilterTabIndex = c.index;
    setFilterTab(c.index);
  }

  void _attachSubTabController() {
    final n = state.filterTabs.length;
    if (n <= 0) return;
    subTabController?.removeListener(_onSubTabControllerTick);
    subTabController?.dispose();
    subTabController = TabController(
      length: n,
      vsync: this,
      initialIndex: state.filterTabIndex.clamp(0, n - 1),
    )..addListener(_onSubTabControllerTick);
    _prevFilterTabIndex = subTabController!.index;
    state.filterTabIndex = _prevFilterTabIndex;
  }

  @override
  void onInit() {
    super.onInit();
    _attachSubTabController();
    // 初次进入只触发当前选中 tab 的首屏拉取；其余 tab 的首屏在切到它们时
    // 再按需触发，避免一次性发 3 个并发请求。
    if (state.filterTabs.isNotEmpty) {
      onRefreshTab(state.filterTabIndex);
    } else {
      onRefresh();
    }
  }

  /// 切到目标 tab：
  /// - 已加载过：直接 [update]，view 渲染各自的 [tabVideoItems]；
  /// - 未加载过：切到「请求中」让页面级 loading 接管，并触发首次拉取。
  ///
  /// 不再每次切 tab 都 [onRefresh]，否则旁边那一页会先清空再被接口结果填充，
  /// 产生「切 tab 闪烁」的体感问题。
  void setFilterTab(int index) {
    if (index < 0 || index >= state.filterTabs.length) return;
    if (index == state.filterTabIndex) return;
    state.filterTabIndex = index;
    _prevFilterTabIndex = index;
    final c = subTabController;
    if (c != null && c.length > index && c.index != index) {
      c.animateTo(index);
    }
    if (state.tabLoaded[index]) {
      update();
    } else {
      state.tabPullRefreshControllers[index].requesting();
      update();
      onRefreshTab(index);
    }
  }

  void toggleLayoutMode() {
    state.isGridLayout = !state.isGridLayout;
    update();
  }

  /// 下拉刷新**指定 tab**：把该 tab 页码归 1 后请求第一页。
  ///
  /// view 的每个 [PullRefreshView] 都用自己的 tabIndex 闭包捕获本回调，与
  /// [state.filterTabIndex] 解耦：即便 await 期间用户切了 tab，结果也只
  /// 落回它自己的 [tabVideoItems][tabIndex]，不会污染其他 tab。
  void onRefreshTab(int tabIndex) {
    if (tabIndex < 0 || tabIndex >= state.filterTabs.length) return;
    state.tabPageNumbers[tabIndex] = 1;
    _getDataForTab(tabIndex);
  }

  /// 上拉加载**指定 tab**：把该 tab 页码 +1 后请求下一页。
  void onLoadTab(int tabIndex) {
    if (tabIndex < 0 || tabIndex >= state.filterTabs.length) return;
    state.tabPageNumbers[tabIndex] += 1;
    _getDataForTab(tabIndex);
  }

  /// 「无 sub tabs」回退分支的入口；正常分支请走 [onRefreshTab]。
  void onRefresh() {
    state.pageNumber = 1;
    getData();
  }

  /// 「无 sub tabs」回退分支的入口；正常分支请走 [onLoadTab]。
  void onLoad() {
    state.pageNumber++;
    getData();
  }

  /// 拉取**指定 tab** 当前页码下的数据；接口分支由 [_fetchListForTab] 决定。
  Future<void> _getDataForTab(int tabIndex) async {
    final int pageNumber = state.tabPageNumbers[tabIndex];
    final PullRefreshController controller =
        state.tabPullRefreshControllers[tabIndex];
    try {
      final List<MediaVideoModel> list = await _fetchListForTab(
        tabIndex: tabIndex,
        pageNumber: pageNumber,
      );
      final bool isFirstPage = pageNumber == 1;
      if (isFirstPage) {
        state.tabVideoItems[tabIndex] = list;
      } else {
        state.tabVideoItems[tabIndex] = <MediaVideoModel>[
          ...state.tabVideoItems[tabIndex],
          ...list,
        ];
      }
      state.tabLoaded[tabIndex] = true;
      final bool hasMore = list.length >= state.pageSize;
      final bool isEmpty = state.tabVideoItems[tabIndex].isEmpty;
      controller.requestSuccess(
        isFirstPageNum: isFirstPage,
        hasMore: hasMore,
        isEmpty: isEmpty,
      );
      update();
    } catch (_) {
      controller.requestFail(isFirstPageNum: pageNumber == 1);
      update();
    }
  }

  /// 二级 Tab 与接口的映射（按 [tabIndex] 路由）：
  /// - 0 今日最新：[HomeApis.getHomeMediaList] `sortType=2`
  /// - 1 本周最热：[HomeApis.getRankList] `rankType=3`
  /// - 2 本月收藏：[HomeApis.getRankList] `rankType=5, rankDataType=1`
  ///
  /// 把分支抽出来后 [_getDataForTab] 不再读 [state.filterTabIndex]，
  /// 也便于「无 sub tabs」回退分支 [getData] 共用同一份映射。
  Future<List<MediaVideoModel>> _fetchListForTab({
    required int tabIndex,
    required int pageNumber,
  }) {
    if (tabIndex == 0) {
      return HomeApis.getHomeMediaList(
        sortType: 2,
        videoType: videoType,
        pageNumber: pageNumber,
        pageSize: state.pageSize,
      );
    }
    if (tabIndex == 1) {
      return HomeApis.getRankList(
        rankType: 3,
        videoType: videoType,
        pageNumber: pageNumber,
        pageSize: state.pageSize,
      );
    }
    return HomeApis.getRankList(
      rankType: 5,
      rankDataType: 1,
      videoType: videoType,
      pageNumber: pageNumber,
      pageSize: state.pageSize,
    );
  }

  /// 「无 sub tabs」回退分支的数据拉取；正常分支请走 [_getDataForTab]。
  Future<void> getData() async {
    try {
      final List<MediaVideoModel> list = await _fetchListForTab(
        tabIndex: state.filterTabIndex,
        pageNumber: state.pageNumber,
      );
      if (state.pageNumber == 1) {
        state.videoItems = list;
      } else {
        state.videoItems = <MediaVideoModel>[
          ...state.videoItems,
          ...list,
        ];
      }
      final bool hasMore = list.length >= state.pageSize;
      final bool isEmpty = state.videoItems.isEmpty;
      state.activeBodyPullRefresh.requestSuccess(
        isFirstPageNum: state.pageNumber == 1,
        hasMore: hasMore,
        isEmpty: isEmpty,
      );
      update();
    } catch (_) {
      state.activeBodyPullRefresh.requestFail(
        isFirstPageNum: state.pageNumber == 1,
      );
      update();
    }
  }

  @override
  void onClose() {
    final c = subTabController;
    c?.removeListener(_onSubTabControllerTick);
    disposeTabControllerAfterRouteExit(c);
    for (final pc in state.tabPullRefreshControllers) {
      pc.dispose();
    }
    state.pullRefreshController.dispose();
    super.onClose();
  }
}
