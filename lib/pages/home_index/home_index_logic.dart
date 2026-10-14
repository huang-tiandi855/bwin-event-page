import 'dart:async';

import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';
import 'package:comics_app/common/utils/tab_controller_dispose.dart';
import 'package:comics_app/common/utils/event_bus/event_bus_util.dart';
import 'package:comics_app/common/widgets/common_dialog/image_dialog.dart';
import 'package:comics_app/common/widgets/common_dialog/open_app_nine_grid_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/entities/modules_config/notice_model.dart';
import '../../common/store/config.dart';
import '../../common/widgets/common_dialog/announcement_dialog.dart';
import 'home_index_state.dart';
import 'widgets/home_navigation_drawer.dart';
import 'recommend_column_banner_icon_topic/view.dart';
import 'recommend_column_banner_kingkong_tag/view.dart';
import 'recommend_new/view.dart';
import 'recommend_topic/view.dart';

class HomeIndexLogic extends GetxController with GetTickerProviderStateMixin {
  final HomeIndexState state = HomeIndexState();

  late StreamSubscription subscription;
  final HomeJumpModuleEvent? initialJumpEevent;

  late TabController categoryTabController;

  HomeIndexLogic({
    required this.initialJumpEevent,
  });

  @override
  void onInit() {
    super.onInit();
    categoryTabController = TabController(
      length: state.categoryModules.length,
      vsync: this,
      initialIndex: state.primaryTabIndex.clamp(
          0,
          state.categoryModules.isNotEmpty
              ? state.categoryModules.length - 1
              : 0),
    );
    categoryTabController.addListener(_onCategoryTabChanged);

    subscription = eventBus.on<HomeJumpModuleEvent>(eventBusCallback);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      eventBusCallback(initialJumpEevent);
    });
  }

  @override
  void onReady() {
    super.onReady();
    // 必须等到首帧渲染完成（widget tree + 路由 overlay 都已就位）再弹窗，
    // 否则 Get.dialog 拿不到正确的 overlayContext，await 会被立即吞掉，
    // 多条 indexTip 广告会全部静默丢失。
    showPopupAds();
  }

  /// 弹窗广告
  Future<void> showPopupAds() async {
    final List<AdsInfoList> gridAds = getAdsByType(AdsType.indexTipGuild);
    if (gridAds.isNotEmpty) {
      await openAppNineGridDialog(ads: gridAds);
    }

    final List<AdsInfoList> adsIndex = getAdsByType(AdsType.indexTip);
    // if (adsIndex.isEmpty) return;
    for (final AdsInfoList ads in adsIndex) {
      await openImageAnnouncementDialog(ads: ads);
    }

    // 数据源已迁移到 ads/notice/list（[ConfigStore.noticeList]）；
    // 新模型 [NoticeModel] 只有 title 字段，不再区分独立的 content。
    List<NoticeModel> list = ConfigStore.to.noticeList
        .where((element) => element.showType == NoticeShowType.notice.value)
        .toList();
    for (final NoticeModel notice in list) {
      ///公告弹窗
      await openAnnouncementDialog(notice: notice);
    }
  }

  void _onCategoryTabChanged() {
    final idx = categoryTabController.index;
    if (state.primaryTabIndex != idx) {
      state.primaryTabIndex = idx;
      update();
    }
  }

  void eventBusCallback(HomeJumpModuleEvent? event) {
    if (event == null) {
      return;
    }
    final String? targetId = event.id;
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

  /// 外部跳转指定一级 Tab（与 TabBar / TabBarView 同步）
  void setPrimaryTab(int index) {
    if (index < 0 || index >= state.categoryModules.length) return;
    if (categoryTabController.index == index) return;
    categoryTabController.animateTo(index);
  }

  void onSearchTap() {
    Get.toNamed(AppRoutes.SEARCH_PAGE);
  }

  void onSignInTap() {
    Get.toNamed(AppRoutes.SIGNIN_WELFARE);
  }

  void onMenuTap(BuildContext context) {
    showHomeNavigationDrawer(context);
  }

  String primaryTabUniqueTag(ModuleModel module, int index) =>
      'home_primary_${module.id ?? index}';

  /// 一级 Tab 对应子页（展示由 View 拼装，路由由 Logic 决定）
  Widget primaryTabPage(ModuleModel module, int index) {
    final tag = primaryTabUniqueTag(module, index);
    switch (module.showType) {
      case 0:
        return RecommendNewPage(
          uniqueTag: tag,
          module: module,
        );
      case 1:
        return RecommendColumnBannerKingKongTagPage(
          uniqueTag: tag,
          module: module,
        );
      case 2:
        return RecommendColumnBannerIconTopicPage(
          uniqueTag: tag,
          module: module,
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
        );
    }
  }

  @override
  void onClose() {
    categoryTabController.removeListener(_onCategoryTabChanged);
    disposeTabControllerAfterRouteExit(categoryTabController);
    eventBus.off(subscription);
    super.onClose();
  }
}
