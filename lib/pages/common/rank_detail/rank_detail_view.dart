import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'rank_detail_logic.dart';
import 'rank_page_list/rank_page_list_view.dart';

/// 排行榜二级页：一级 Tab + 各 Tab 内 [RankPageList]（二级 Tab 日/周/月/总 + 列表）。
class RankDetailPage extends StatelessWidget {
  const RankDetailPage({Key? key}) : super(key: key);

  RankDetailLogic get logic => Get.find<RankDetailLogic>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RankDetailLogic>(
      builder: (_) {
        final TabController? c = logic.primaryTabController;
        if (c == null) {
          return const Scaffold(
            backgroundColor: AppColor.scaffoldBackground,
            body: SizedBox.shrink(),
          );
        }
        return Scaffold(
          backgroundColor: AppColor.scaffoldBackground,
          appBar: commonAppBar(
            '排行榜',
            // bgColor: AppColor.scaffoldBackground,
            // bottom: PreferredSize(
            //   preferredSize: Size.fromHeight(40.h),
            //   child: TabGradientIndicatorTabBar(
            //     controller: c,
            //     useSigninWelfareDefaults: false,
            //     tabAlignment: TabAlignment.fill,
            //     labelPadding: EdgeInsets.zero,
            //     indicatorWeight: 0,
            //     indicatorPadding: EdgeInsets.only(bottom: 5.h),
            //     indicatorUnderlineWidth: 20.w,
            //     indicatorInsets: EdgeInsets.zero,
            //     tabs: [
            //       for (final String t in RankDetailState.primaryTabs)
            //         Tab(text: t),
            //     ],
            //   ),
            // ),
          ),
          // body: getBgColorsView(
          //   child: TabBarView(
          //     controller: c,
          //     children: List.generate(
          //       RankDetailState.primaryTabs.length,
          //       (int tabIndex) => RankPageList(
          //         key: PageStorageKey<String>('rank_detail_primary_$tabIndex'),
          //         primaryTabIndex: tabIndex,
          //       ),
          //     ),
          //   ),
          // ),
          body: const RankPageList(
            primaryTabIndex: 0,
          ),
        );
      },
    );
  }
}
