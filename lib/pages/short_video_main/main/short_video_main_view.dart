import 'package:comics_app/common/values/enum.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/common/widgets/keep_alive_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'short_video_main_logic.dart';
import 'short_video_main_state.dart';
import 'views/main_tab/short_video_main_tab_view.dart';
import 'views/short_video_main_app_bar.dart';
import 'views/skits_follow_tab/short_video_skits_follow_tab_view.dart';
import 'views/video_tab/short_video_vertical_tab_view.dart';

class ShortVideoMainPage extends StatelessWidget {
  const ShortVideoMainPage({super.key});

  ShortVideoMainLogic get logic => Get.find<ShortVideoMainLogic>();

  ShortVideoMainState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ShortVideoMainLogic>()) {
      Get.put(ShortVideoMainLogic());
    }

    return Scaffold(
      appBar: const ShortVideoMainAppBar(),
      body: getBgColorsView(
        child: TabBarView(
          controller: state.tabController,
          children: state.tabs.map((tab) {
            return KeepAliveWidget(
              _buildTabPage(tab),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabPage(ShortVideoPrimaryTab tab) {
    final rootModule = state.moduleConfigService.shortVideoRootModule;
    if (rootModule == null) {
      return const SizedBox.shrink();
    }

    switch (tab.type) {
      case ShortVideoPrimaryTabType.follow:
        // return ShortVideoVerticalTabView(
        //   module: rootModule,
        //   useFollowList: true,
        // );
        return const ShortVideoSkitsFollowTabView();
      case ShortVideoPrimaryTabType.discover:
        return const ShortVideoMainTabView();
      case ShortVideoPrimaryTabType.hot:
        return ShortVideoVerticalTabView(
          module: rootModule,
          moduleSort: VideoSortTypeEnum.random.value,
        );
    }
  }
}
