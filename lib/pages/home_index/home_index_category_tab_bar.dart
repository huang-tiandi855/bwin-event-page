import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/widgets/indicators/filled_rounded_rect_tab_indicator.dart';

/// 首页一级分类 TabBar（与 [TabBarView] 共用同一 [TabController]）。
class HomeIndexCategoryTabBar extends StatelessWidget {
  const HomeIndexCategoryTabBar({
    Key? key,
    required this.controller,
    required this.modules,
  }) : super(key: key);

  final TabController controller;
  final List<ModuleModel> modules;

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 50.h,
      padding: EdgeInsets.fromLTRB(0, 14.h, 0, 4.h),
      child: ColoredBox(
        color: AppColor.scaffoldBackground,
        child: Align(
          alignment: Alignment.centerLeft,
          child: TabBar(
            controller: controller,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: EdgeInsets.only(left: 4.w),
            labelPadding: EdgeInsets.symmetric(horizontal: 12.w),
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 5.h,
            indicatorPadding: EdgeInsets.zero,
            // 实心指示条：仅上侧圆角，底边平直贴齐 Tab 区域底（参见 tab_indicator.dart）
            indicator: FilledRoundedRectTabIndicator(
              color: AppColor.tabIndicatorColor,
              width: 10.w,
              height: 3.w,
              borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
            ),
            labelColor: AppColor.primaryText,
            unselectedLabelColor: AppColor.tabUnselLabelColor,
            labelStyle: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
            ),
            dividerColor: Colors.transparent,
            tabs: modules.map((e) => Tab(text: e.moduleName ?? '')).toList(),
          ),
        ),
      ),
    );
  }
}
