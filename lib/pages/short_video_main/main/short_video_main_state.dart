import 'package:comics_app/common/services/module_config_service.dart';
import 'package:flutter/material.dart';

enum ShortVideoPrimaryTabType {
  follow,
  discover,
  hot,
}

class ShortVideoPrimaryTab {
  const ShortVideoPrimaryTab({
    required this.title,
    required this.type,
  });

  final String title;
  final ShortVideoPrimaryTabType type;
}

class ShortVideoMainState {
  ShortVideoMainState();
  final ModuleConfigService moduleConfigService = ModuleConfigService();

  final List<ShortVideoPrimaryTab> tabs = const [
    ShortVideoPrimaryTab(
      title: '关注',
      type: ShortVideoPrimaryTabType.follow,
    ),
    ShortVideoPrimaryTab(
      title: '发现',
      type: ShortVideoPrimaryTabType.discover,
    ),
    ShortVideoPrimaryTab(
      title: '热门',
      type: ShortVideoPrimaryTabType.hot,
    ),
  ];

  List<String> get tabTitles => [
        for (final tab in tabs) tab.title,
      ];

  late TabController tabController;
}
