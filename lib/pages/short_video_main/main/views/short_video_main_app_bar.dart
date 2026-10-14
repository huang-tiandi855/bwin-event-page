import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/widgets/tab_widgets/tab_gradient_indicator_widget.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../short_video_main_logic.dart';
import '../short_video_main_state.dart';

class ShortVideoMainAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ShortVideoMainAppBar({super.key});

  ShortVideoMainLogic get logic => Get.find<ShortVideoMainLogic>();

  ShortVideoMainState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.darkBackground,
      child: SafeArea(
        top: true,
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: _buildTabBar(),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Get.toNamed(AppRoutes.SEARCH_PAGE),
              child: Padding(
                padding: EdgeInsets.only(right: 16.h),
                child: AssetsGen.images.circle.search
                    .image(width: 25.w, height: 25.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabGradientIndicatorTabBar(
      isScrollable: true,
      controller: state.tabController,
      indicatorSize: TabBarIndicatorSize.tab,
      useSigninWelfareDefaults: false,
      tabAlignment: TabAlignment.center,
      labelPadding: EdgeInsets.symmetric(horizontal: 24.w),
      indicatorPadding: EdgeInsets.only(bottom: 5.h),
      indicatorWeight: 6.h,
      indicatorUnderlineWidth: 20.w,
      indicatorInsets: EdgeInsets.zero,
      tabs: state.tabTitles.map((title) => Tab(text: title)).toList(),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(40.w);
}
