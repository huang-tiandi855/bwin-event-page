import 'dart:async';

import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/utils/tab_controller_dispose.dart';
import 'package:comics_app/common/utils/event_bus/event_bus_util.dart';
import 'package:comics_app/pages/home_index/recommend_column_banner_icon_topic/view.dart';
import 'package:comics_app/pages/home_index/recommend_column_banner_kingkong_tag/view.dart';
import 'package:comics_app/pages/home_index/recommend_new/view.dart';
import 'package:comics_app/pages/home_index/recommend_topic/view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/apis/module_api.dart';
import 'state.dart';

class DarkLogic extends GetxController with GetTickerProviderStateMixin {
  final state = DarkState();

  late StreamSubscription subscription;
  final DarkJumpModuleEvent? initialJumpEevent;
  TabController? categoryTabController;

  DarkLogic({
    required this.initialJumpEevent,
  });

  @override
  void onInit() {
    super.onInit();
    if (state.categoryModules.isNotEmpty) {
      categoryTabController = TabController(
        length: state.categoryModules.length,
        vsync: this,
        initialIndex: state.primaryTabIndex.clamp(
          0,
          state.categoryModules.isNotEmpty
              ? state.categoryModules.length - 1
              : 0,
        ),
      );
      categoryTabController?.addListener(_onCategoryTabChanged);
    }

    subscription = eventBus.on<DarkJumpModuleEvent>(eventBusCallback);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      eventBusCallback(initialJumpEevent);
    });
  }

  void _onCategoryTabChanged() {
    final idx = categoryTabController?.index ?? 0;
    if (state.primaryTabIndex != idx) {
      state.primaryTabIndex = idx;
      update();
    }
  }

  void eventBusCallback(DarkJumpModuleEvent? event) {
    if (event == null) {
      return;
    }
    final targetId = event.id;
    if (targetId != null && targetId.isNotEmpty) {
      final idx =
          state.categoryModules.indexWhere((m) => m.id?.toString() == targetId);
      if (idx >= 0) {
        setPrimaryTab(idx);
        return;
      }
    }
    update();
  }

  void setPrimaryTab(int index) {
    if (index < 0 || index >= state.categoryModules.length) return;
    if (categoryTabController?.index == index) return;
    categoryTabController?.animateTo(index);
  }

  void onSearchTap() {
    Get.toNamed(AppRoutes.SEARCH_PAGE);
  }

  void onSignInTap() {
    Get.toNamed(AppRoutes.SIGNIN_WELFARE);
  }

  String primaryTabUniqueTag(ModuleModel module, int index) =>
      'dark_primary_${module.id ?? index}';

  /// 暗网入口共用首页 Recommend* 组件，但所有数据接口需要带 `videoType: 2`
  /// 才能拿到暗网池子。逐 case 显式传，避免后续新增 showType 时漏传退化成
  /// 普通视频（[HomeApis.getHomeMediaList] / [HomeApis.getRankList] 的
  /// `videoType` 默认为 0）。
  ///
  /// 注意：`RecommendTopicPage`（showType==3）走的是 `cms/vod/groups/search`，
  /// 该接口当前**没有** `videoType` 参数；如果后端后续在该接口加上区分，
  /// 这里也需要把 `videoType` 透传过去。
  Widget primaryTabPage(ModuleModel module, int index) {
    final tag = primaryTabUniqueTag(module, index);
    const int darkVideoType = 2;
    switch (module.showType) {
      case 0:
        return RecommendNewPage(
          uniqueTag: tag,
          module: module,
          videoType: darkVideoType,
        );
      case 1:
        return RecommendColumnBannerKingKongTagPage(
          uniqueTag: tag,
          module: module,
          videoType: darkVideoType,
        );
      case 2:
        return RecommendColumnBannerIconTopicPage(
          uniqueTag: tag,
          module: module,
          videoType: darkVideoType,
        );
      case 3:
        return RecommendTopicPage(
          uniqueTag: tag,
          module: module,
        );
      default:
        return RecommendNewPage(
          uniqueTag: tag,
          module: module,
          videoType: darkVideoType,
        );
    }
  }

  Future<void> retryGetDarkCategory() async {
    state.categoryModules = (await ModuleApi.getHomeModuleList(2)).darkModules;
    if (state.categoryModules.isNotEmpty) {
      categoryTabController = TabController(
        length: state.categoryModules.length,
        vsync: this,
        initialIndex: state.primaryTabIndex.clamp(
          0,
          state.categoryModules.length - 1,
        ),
      );
    }
    update();
  }

  @override
  void onClose() {
    categoryTabController?.removeListener(_onCategoryTabChanged);
    disposeTabControllerAfterRouteExit(categoryTabController);
    eventBus.off(subscription);
    super.onClose();
  }
}
