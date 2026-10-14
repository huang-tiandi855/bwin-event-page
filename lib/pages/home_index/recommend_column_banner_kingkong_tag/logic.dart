import 'package:comics_app/common/apis/home_apis.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/utils/tab_controller_dispose.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/pages/home_index/home_column_video_feed_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'state.dart';

class RecommendColumnBannerKingKongTagLogic extends GetxController
    with GetTickerProviderStateMixin {
  RecommendColumnBannerKingKongTagLogic({
    this.module,
    this.videoType = 0,
  });

  final RecommendColumnBannerKingKongTagState state =
      RecommendColumnBannerKingKongTagState();

  final ModuleModel? module;

  /// `cms/vod/search-json` 的 `videoType` 入参（0 普通 / 1 短视频 / 2 暗网）。
  ///
  /// 默认 0 兼容首页（[HomeIndexLogic.primaryTabPage] 不显式传），暗网
  /// 入口（[DarkLogic.primaryTabPage]）显式传 2 —— 让本 logic 在 dark / home
  /// 两套页面复用同一份金刚 + 二级 Tab UI，但底层只在数据请求上区隔。
  final int videoType;

  TabController? secondaryTabController;

  int _prevSecondaryTabIndex = -1;

  void _onSecondaryTabTick() {
    final c = secondaryTabController;
    if (c == null || c.indexIsChanging) return;
    if (c.index == _prevSecondaryTabIndex) return;
    _prevSecondaryTabIndex = c.index;
    setSecondaryTab(c.index);
  }

  /// 切到目标二级 tab：
  /// - 已加载过：直接 [update]，view 渲染各自的 [tabVideoItems]；
  /// - 未加载过：切到「请求中」让页面级 loading 接管，并触发首次拉取。
  ///
  /// 不再每次切 tab 都 [onRefresh]，否则旁边那一页会先清空再被接口结果填充，
  /// 产生「切 tab 闪烁」的体感问题。
  void setSecondaryTab(int index) {
    if (index < 0 || index >= state.secondaryTabs.length) return;
    if (state.secondaryTabIndex == index) return;
    state.secondaryTabIndex = index;
    state.sortType = homeTabVideoSortTypeFromIndex(index);
    if (state.tabLoaded[index]) {
      update();
    } else {
      state.tabPullRefreshControllers[index].requesting();
      update();
      onRefreshTab(index);
    }
  }

  void _attachSecondaryTabController() {
    final n = state.secondaryTabs.length;
    if (n <= 0) return;
    secondaryTabController?.removeListener(_onSecondaryTabTick);
    secondaryTabController?.dispose();
    secondaryTabController = TabController(
      length: n,
      vsync: this,
      initialIndex: state.secondaryTabIndex.clamp(0, n - 1),
    )..addListener(_onSecondaryTabTick);
    _prevSecondaryTabIndex = secondaryTabController!.index;
    state.sortType = homeTabVideoSortTypeFromIndex(_prevSecondaryTabIndex);
  }

  void toggleSecondaryVideoLayout() {
    state.secondaryVideoGridLayout = !state.secondaryVideoGridLayout;
    update();
  }

  /// 下拉刷新**指定 tab**：把该 tab 页码归 1 后请求第一页。
  ///
  /// view 的每个 [PullRefreshView] 都用自己的 tabIndex 闭包捕获本回调，与
  /// [state.secondaryTabIndex] 解耦：即便 await 期间用户切了 tab，结果也
  /// 只会落回它自己的 [tabVideoItems][tabIndex]，不会污染其他 tab。
  void onRefreshTab(int tabIndex) {
    if (tabIndex < 0 || tabIndex >= state.secondaryTabs.length) return;
    state.tabPageNumbers[tabIndex] = 1;
    _getDataForTab(tabIndex);
  }

  /// 上拉加载**指定 tab**：把该 tab 页码 +1 后请求下一页。
  void onLoadTab(int tabIndex) {
    if (tabIndex < 0 || tabIndex >= state.secondaryTabs.length) return;
    state.tabPageNumbers[tabIndex] += 1;
    _getDataForTab(tabIndex);
  }

  /// 「无 sub tabs」回退分支的入口；正常分支请走 [onRefreshTab]。
  void onRefresh() {
    state.pageNumber = 1;
    getVideoData();
  }

  /// 「无 sub tabs」回退分支的入口；正常分支请走 [onLoadTab]。
  void onLoad() {
    state.pageNumber++;
    getVideoData();
  }

  /// 拉取**指定 tab** 当前页码下的数据。
  ///
  /// 全程以入参 [tabIndex] 驱动（sortType / pageNumber / pullController /
  /// 回写位置都来自该 tab），与 [state.secondaryTabIndex] 解耦。
  Future<void> _getDataForTab(int tabIndex) async {
    final int sortType = homeTabVideoSortTypeFromIndex(tabIndex);
    final int pageNumber = state.tabPageNumbers[tabIndex];
    final PullRefreshController controller =
        state.tabPullRefreshControllers[tabIndex];
    try {
      final List<MediaVideoModel> list = await HomeApis.getHomeMediaList(
        groupId: module?.id,
        sortType: sortType,
        videoType: videoType,
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
  Future<void> getVideoData() async {
    try {
      final List<MediaVideoModel> list = await HomeApis.getHomeMediaList(
        groupId: module?.id,
        sortType: state.sortType,
        videoType: videoType,
        pageNumber: state.pageNumber,
        pageSize: state.pageSize,
      );
      if (state.pageNumber == 1) {
        state.secondaryVideoItems = list;
      } else {
        state.secondaryVideoItems = <MediaVideoModel>[
          ...state.secondaryVideoItems,
          ...list,
        ];
      }
      final bool hasMore = list.length >= state.pageSize;
      final bool isEmpty = state.secondaryVideoItems.isEmpty;
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
  void onInit() {
    super.onInit();
    _attachSecondaryTabController();
    getTags();
    // 初次进入只触发当前选中 tab 的首屏拉取；其余 tab 的首屏在切到它们时
    // 再按需触发，避免一次性发 4 个并发请求。
    if (state.secondaryTabs.isNotEmpty) {
      onRefreshTab(state.secondaryTabIndex);
    } else {
      onRefresh();
    }
  }

  Future<void> getTags() async {
    final groups = module?.childGroups ?? [];
    final tags = groups.where((e) {
      final label = (e.moduleName ?? e.groupName ?? '').trim();
      return label.isNotEmpty;
    }).toList();
    state.hotTags.assignAll(tags);
  }

  void setHotTagsExpanded(bool expanded) {
    state.hotTagsExpanded.value = expanded;
  }

  @override
  void onClose() {
    final c = secondaryTabController;
    c?.removeListener(_onSecondaryTabTick);
    disposeTabControllerAfterRouteExit(c);
    for (final pc in state.tabPullRefreshControllers) {
      pc.dispose();
    }
    state.pullRefreshController.dispose();
    super.onClose();
  }
}
