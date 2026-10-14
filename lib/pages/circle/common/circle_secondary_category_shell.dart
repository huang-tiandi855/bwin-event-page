import 'package:comics_app/pages/circle/common/circle_secondary_tab_bar.dart';
import 'package:comics_app/common/widgets/keep_alive_widget.dart';
import 'package:flutter/material.dart';

import '../../../common/style/color.dart';

/// 二级 TabBar + [TabBarView] 外壳
///
/// 适用于社区 / 黄游 / 小说等子频道：顶部仅负责本段横向分类切换。
class CircleSecondaryCategoryShell extends StatelessWidget {
  const CircleSecondaryCategoryShell({
    super.key,
    required this.tabController,
    required this.categoryLabels,
    required this.tabBodyBuilder,
    this.accentColor = AppColor.primaryButtonColor,
    this.secondaryTabBarHeight,
  });

  final TabController tabController;
  final List<String> categoryLabels;
  final Widget Function(BuildContext context, int index) tabBodyBuilder;
  final Color accentColor;
  final double? secondaryTabBarHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.scaffoldContentBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CircleSecondaryTabBar(
            controller: tabController,
            tabs: categoryLabels,
            accentColor: accentColor,
            height: secondaryTabBarHeight,
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                categoryLabels.length,
                (i) => KeepAliveWidget(tabBodyBuilder(context, i)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
