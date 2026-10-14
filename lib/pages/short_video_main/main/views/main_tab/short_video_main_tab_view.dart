import 'package:comics_app/common/services/module_config_service.dart';
import 'package:comics_app/common/widgets/keep_alive_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../video_tab/short_video_tab_view.dart';
import 'views/short_video_main_fantastic_tab_bar.dart';

class ShortVideoMainTabView extends StatelessWidget {
  const ShortVideoMainTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = ModuleConfigService.sharedInstance.discoverSecondTabs;

    return DefaultTabController(
      length: tabs.length,
      child: Builder(builder: (ctx) {
        final tabController = DefaultTabController.of(ctx);
        return Column(
          children: [
            ShortVideoMainFantasticTabBar(
              tabs: tabs.map((e) => e.moduleName ?? '').toList(),
              controller: tabController,
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: tabs.map((module) {
                  return KeepAliveWidget(
                    ShortVideoTabView(
                      module: module,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        );
      }),
    );
  }
}

class SliverCustomHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  SliverCustomHeaderDelegate({
    required this.child,
    required this.height,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
