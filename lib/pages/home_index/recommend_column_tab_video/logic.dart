import 'package:comics_app/common/apis/home_apis.dart';
import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/utils/tab_controller_dispose.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/pages/home_index/home_column_video_feed_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'state.dart';

class RecommendColumnTabVideoLogic extends GetxController
    with GetTickerProviderStateMixin {
  final RecommendColumnTabVideoState state = RecommendColumnTabVideoState();
  final ModuleModel? module;
  final String uniqueTag;

  RecommendColumnTabVideoLogic({
    required this.module,
    required this.uniqueTag,
  });

  TabController? subTabController;

  int _prevSubTabIndex = -1;

  void _onSubTabControllerTick() {
    final c = subTabController;
    if (c == null || c.indexIsChanging) return;
    if (c.index == _prevSubTabIndex) return;
    _prevSubTabIndex = c.index;
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
    _prevSubTabIndex = subTabController!.index;
    state.sortType = homeTabVideoSortTypeFromIndex(_prevSubTabIndex);
  }

  void toggleLayoutMode() {
    state.isGridLayout = !state.isGridLayout;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    _attachSubTabController();
    // 初次进入只触发当前选中 tab 的首屏拉取；其余 tab 的首屏在用户切到时
    // 再按需触发，避免一次性发 4 个并发请求。
    if (state.filterTabs.isNotEmpty) {
      onRefreshTab(state.filterTabIndex);
    } else {
      onRefresh();
    }
  }

  /// 切到目标 tab：
  /// - 已加载过：直接 [update]，由 view 渲染各自的 [tabVideoItems]；
  /// - 未加载过：切到「请求中」让页面级 loading 接管，并触发首次拉取。
  ///
  /// 注意不再每次切 tab 都 [onRefresh]，否则旧 tab 数据会被瞬间清空并出现
  /// 「先看到上一个 tab 的列表 → 突然变空 → 接口回来再填充」的闪烁。
  void setFilterTab(int index) {
    if (index < 0 || index >= state.filterTabs.length) return;
    if (state.filterTabIndex == index) return;
    state.filterTabIndex = index;
    state.sortType = homeTabVideoSortTypeFromIndex(index);
    if (state.tabLoaded[index]) {
      update();
    } else {
      state.tabPullRefreshControllers[index].requesting();
      update();
      onRefreshTab(index);
    }
  }

  /// 下拉刷新**指定 tab**：把该 tab 页码归 1 后请求第一页。
  ///
  /// view 的每个 [PullRefreshView] 都用自己的 tabIndex 闭包捕获本回调，
  /// 这样左右切 tab 时各自的下拉/上拉触发不会互相串数据；不依赖
  /// [state.filterTabIndex]，避免「await 期间切 tab」时回写错位。
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

  /// 拉取**指定 tab** 当前页码下的数据。
  ///
  /// 全程以入参 [tabIndex] 驱动（sortType / pageNumber / pullController /
  /// 回写位置都来自该 tab），与 [state.filterTabIndex] 解耦。
  Future<void> _getDataForTab(int tabIndex) async {
    final int sortType = homeTabVideoSortTypeFromIndex(tabIndex);
    final int pageNumber = state.tabPageNumbers[tabIndex];
    final PullRefreshController controller =
        state.tabPullRefreshControllers[tabIndex];
    try {
      final List<MediaVideoModel> list = await HomeApis.getHomeMediaList(
        // groupId: module?.id,
        sortType: sortType,
        pageNumber: pageNumber,
        pageSize: state.pageSize,
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

  /// 「无 sub tabs」回退分支的数据拉取；正常分支请走 [_getDataForTab]。
  Future<void> getData() async {
    try {
      final List<MediaVideoModel> list = await HomeApis.getHomeMediaList(
        // groupId: module?.id,
        sortType: state.sortType,
        pageNumber: state.pageNumber,
        pageSize: state.pageSize,
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
