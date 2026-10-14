import 'dart:async';

import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/services/module_config_service.dart';
import 'package:comics_app/common/services/scroll_metrics_manager.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/event_bus/event_bus_util.dart';
import 'package:comics_app/common/utils/tab_controller_dispose.dart';
import 'package:comics_app/common/values/varibel_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/apis/circle_api.dart';
import '../../common/widgets/select_publish_type_bottom_sheet.dart';
import 'circle_state.dart';

/// 顶栏 Tab 顺序：社区(0) · 图集(1) · 黄游(2) · 小说(3)
class CircleLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  final CircleState state = CircleState();

  /// 占位 Tab 配置（预留 bizId 以便后续深链跳转）。
  late List<TabItem> tabs = [
    TabItem(),
    TabItem(),
    TabItem(),
    // TabItem(),
  ];

  late StreamSubscription subscription;

  final CommunityJumpModuleEvent? initialJumpEevent;

  CircleLogic({
    required this.initialJumpEevent,
  });

  @override
  void onInit() {
    debugPrint("CircleLogic  onInit => ${tabs.length}");
    getPostingCategory();
    eventBusCallback(initialJumpEevent);
    state.tabController = TabController(
      length: tabs.length,
      vsync: this,
      initialIndex: state.tabSelectIndex.value,
    );

    ConfigStore.to.trackData('圈子浏览', {'链路': '圈子'});

    // state.isFabVisible.value = state.tabController.index == 0;

    state.tabController.addListener(() {
      VariableConfig.isClickAppCenter = false;
      state.tabSelectIndex.value = state.tabController.index;
      // state.isFabVisible.value = state.tabController.index == 0;
      if (state.tabController.index != 0) {
        ScrollMetricsManager.sharedInstance
            .bindCircleCommunityInnerScroll(null);
      }
    });

    subscription = eventBus.on<CommunityJumpModuleEvent>(eventBusCallback);
    super.onInit();
  }

  @override
  void onClose() {
    eventBus.off(subscription);
    disposeTabControllerAfterRouteExit(state.tabController);
    super.onClose();
  }

  void jumpToPosting(int? moduleId, bool showPostAlert) {
    if (showPostAlert) {
      this.showPostAlert();
    }

    state.tabSelectIndex.value = 0;

    if (moduleId == null) {
      return;
    }
    state.jumpPostingModuleId = moduleId;

    if (state.postingCategory.isEmpty) {
      return;
    }
    int postingIndex =
        state.postingCategory.indexWhere((m) => m.id == moduleId);
    if (postingIndex == -1) {
      return;
    }

    state.tabPostingIndex.value = postingIndex;
    update(['community_tab_view']);
  }

  void showPostAlert() {
    showSelectPublishTypeBottomSheet();
  }

  void eventBusCallback(CommunityJumpModuleEvent? event) {
    if (event == null) {
      return;
    }
    int index = tabs.indexWhere((element) => element.bizId == event.id);
    if (index != -1) {
      if (!initialized) {
        state.tabSelectIndex.value = index;
      } else {
        state.tabController.animateTo(index);
      }
      return;
    }

    final modules = _allModulesDeep(
      ModuleConfigService.sharedInstance.homeModules.homeModules,
    );
    final photoHit = modules
        .indexWhere((e) => e.id.toString() == event.id && e.showType == 3);
    if (photoHit != -1) {
      if (!initialized) {
        state.tabSelectIndex.value = 1;
      } else {
        state.tabController.animateTo(1);
      }
      return;
    }

    final communityHit = modules
        .indexWhere((e) => e.id.toString() == event.id && e.showType == 7);
    if (communityHit != -1) {
      if (!initialized) {
        state.tabSelectIndex.value = 0;
      } else {
        state.tabController.animateTo(0);
      }
    }
  }

  List<ModuleModel> _allModulesDeep(List<ModuleModel> roots) {
    final out = <ModuleModel>[];
    void walk(ModuleModel m) {
      out.add(m);
      for (final c in m.childGroups) {
        walk(c);
      }
    }

    for (final r in roots) {
      walk(r);
    }
    return out;
  }

  /// 滚动开始 / 结束时调；用于切社区 Tab 上的悬浮按钮显示状态。
  ///
  /// 注意：通知有时由 `RenderShrinkWrappingViewport.performLayout` 内部的
  /// `goBallistic` 在布局阶段派发（如刷数据后内容高度变化触发的弹性回弹），
  /// 此刻同步写 `RxBool.value` 会触发外层 [Obx] 在当前帧调 `setState`，
  /// 抛「Build scheduled during frame」。所以延一帧写入 + 值未变直接 return，
  /// 既避开布局期写 state，也省掉无意义的重建。
  void updateShowOrHide(bool value) {
    // final int tabIndex = state.tabController.index;
    // final bool target = tabIndex == 0 ? !value : false;
    // if (state.isFabVisible.value == target) return;

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (state.isFabVisible.value != target) {
    //     state.isFabVisible.value = target;
    //   }
    // });
  }

  /// 获取「社区」二级帖子分类。
  ///
  /// 同一份 GetBuilder id 在加载 / 成功 / 失败时都会刷新一次，方便 UI 展示
  /// loading / 失败重试 / 空态。
  Future<void> getPostingCategory() async {
    state.postingCategoryStatus = CircleCategoryLoadStatus.loading;
    update(['community_tab_view']);

    final List<ModuleModel>? resp = await CircleApi.getPostingCategory();
    if (resp == null) {
      state.postingCategoryStatus = CircleCategoryLoadStatus.failed;
    } else {
      state.postingCategory = resp;
      state.postingCategoryStatus = CircleCategoryLoadStatus.success;
    }
    if (state.jumpPostingModuleId != null) {
      int postingIndex = state.postingCategory
          .indexWhere((m) => m.id == state.jumpPostingModuleId);
      if (postingIndex != -1) {
        state.tabPostingIndex.value = postingIndex;
      }
    }
    update(['community_tab_view']);
  }

  /// 失败态点击「重试」时调用。
  Future<void> retryGetPostingCategory() => getPostingCategory();
}
