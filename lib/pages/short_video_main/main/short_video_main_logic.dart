import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:comics_app/common/utils/tab_controller_dispose.dart';

import '../play/short_video_play_logic.dart';
import 'short_video_main_state.dart';

class ShortVideoMainLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  final state = ShortVideoMainState();
  int _lastTabIndex = 1;

  final String? initialId;

  ShortVideoMainLogic({this.initialId});

  @override
  void onInit() {
    state.tabController = TabController(
      length: state.tabs.length,
      vsync: this,
      initialIndex: 2,
    )..addListener(_handlePrimaryTabChanged);
    _lastTabIndex = state.tabController.index;
    // 把「当前 Douyin sub-tab 是否命中带视频播放器的 tab」同步给
    // [ShortVideoPlayLogic.resumeAllActive]：跨底部 tab 切回抖音时，
    // 只有命中 [ShortVideoPrimaryTabType.hot] 才允许自动恢复 —— 否则用户
    // 上次切到关注/发现，回到抖音也会让背后还活着的热门播放器误起播。
    ShortVideoPlayLogic.setShouldAutoResumeOnReturn(
      _isAutoPlayingSubTabSelected,
    );
    super.onInit();
  }

  void _handlePrimaryTabChanged() {
    final index = state.tabController.index;
    if (index == _lastTabIndex) return;
    _lastTabIndex = index;
    ShortVideoPlayLogic.pauseAllActive();
  }

  /// 当前 sub-tab 是否「带视频播放器的 tab」（即对应一份 [ShortVideoPlayLogic]
  /// 的 sub-tab）。目前只有 [ShortVideoPrimaryTabType.hot] 走 [ShortVideoPlayLogic]，
  /// 关注 / 发现都没有自动播放的视频。
  bool _isAutoPlayingSubTabSelected() {
    final tabs = state.tabs;
    final i = state.tabController.index;
    if (i < 0 || i >= tabs.length) return false;
    return tabs[i].type == ShortVideoPrimaryTabType.hot;
  }

  @override
  void onClose() {
    state.tabController.removeListener(_handlePrimaryTabChanged);
    ShortVideoPlayLogic.setShouldAutoResumeOnReturn(null);
    ShortVideoPlayLogic.pauseAllActive();
    disposeTabControllerAfterRouteExit(state.tabController);
    super.onClose();
  }
}
