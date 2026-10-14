import 'package:comics_app/common/services/scroll_metrics_manager.dart';
import 'package:comics_app/common/utils/event_bus/event_bus_util.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/values/config.dart';

class BottomNavigationBarItemModel {
  final int index;
  final AssetGenImage icon;
  final AssetGenImage selIcon;
  final String? activeIcon;
  final String title;
  final ScrollMetricsGroup? listenerGroup;
  final Color activeColor;

  final double? iconWidth;
  final double? iconHeight;

  BottomNavigationBarItemModel({
    required this.index,
    required this.icon,
    required this.selIcon,
    this.activeIcon,
    required this.title,
    this.listenerGroup,
    required this.activeColor,
    this.iconWidth,
    this.iconHeight,
  });
}

class ApplicationState {
  RxInt curTabIndex = 0.obs; //当前选中tab
  late final PageController pageController; // 页控制器
  final tabColor = [
    const Color(0xff814CFF),
    const Color(0xff1A75F5),
    const Color(0xff814CFF),
    const Color(0xffB84EFF),
    const Color(0xff814CFF),
    const Color(0xffFF888A),
  ];

  ApplicationState() {
    pageController = PageController(initialPage: curTabIndex.value);

    ///Initialize variables
  }

  HomeJumpModuleEvent? homeJumpModuleEvent;
  DouYinJumpModuleEvent? douYinJumpModuleEvent;
  DarkJumpModuleEvent? darkJumpModuleEvent;
  CommunityJumpModuleEvent? communityJumpModuleEvent;
  AiJumpModuleEvent? aiJumpModuleEvent;
  MineJumpModuleEvent? mineJumpModuleEvent;
  bool isNewYear = Config.isNewYearTheme();

  late final tabs = {
    BottomNavigationBarItemModel(
      index: 0,
      selIcon: AssetsGen.images.navigation.icNavigationHomeSel,
      icon: AssetsGen.images.navigation.icNavigationHome,
      title: "主页",
      activeColor: Colors.white,
      listenerGroup: ScrollMetricsGroup.home,
    ),
    BottomNavigationBarItemModel(
      index: 1,
      selIcon: AssetsGen.images.navigation.icNavigationDouyinSel,
      icon: AssetsGen.images.navigation.icNavigationDouyin,
      title: "抖音",
      activeColor: Colors.white,
      listenerGroup: ScrollMetricsGroup.video,
    ),
    BottomNavigationBarItemModel(
      index: 2,
      selIcon: AssetsGen.images.navigation.icNavigationAiSel,
      icon: AssetsGen.images.navigation.icNavigationAi,
      activeColor: Colors.white,
      title: "AI",
    ),
    BottomNavigationBarItemModel(
      index: 3,
      selIcon: AssetsGen.images.navigation.icNavigationDarkSel,
      icon: AssetsGen.images.navigation.icNavigationDark,
      activeColor: Colors.white,
      title: "禁区",
      listenerGroup: ScrollMetricsGroup.dark,
    ),
    BottomNavigationBarItemModel(
      index: 4,
      selIcon: AssetsGen.images.navigation.icNavigationCircleSel,
      icon: AssetsGen.images.navigation.icNavigationCircle,
      activeColor: Colors.white,
      title: "社区",
      listenerGroup: ScrollMetricsGroup.circle,
    ),
    BottomNavigationBarItemModel(
      index: 5,
      selIcon: AssetsGen.images.navigation.icNavigationMineSel,
      icon: AssetsGen.images.navigation.icNavigationMine,
      activeColor: Colors.white,
      title: "我的",
    ),
  };
}
