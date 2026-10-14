import 'package:comics_app/common/widgets/indicators/filled_rounded_rect_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common/style/color.dart';

/// 圈子二级分类 TabBar：横向滚动 + 底部红色圆角指示条
class CircleSecondaryTabBar extends StatelessWidget {
  const CircleSecondaryTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.accentColor = AppColor.primaryButtonColor,
    this.height,
  });

  final TabController controller;
  final List<String> tabs;
  final Color accentColor;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final h = height ?? 40.w;
    return Container(
      color: Colors.black,
      height: h,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TabBar(
          controller: controller,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: EdgeInsets.zero,
          labelPadding: EdgeInsets.symmetric(horizontal: 9.w),
          indicatorSize: TabBarIndicatorSize.label,
          indicator: FilledRoundedRectTabIndicator(
            color: accentColor,
            width: 20.w,
            height: 4.w,
            borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
          ),
          labelColor: const Color(0xFFFAFAFA),
          unselectedLabelColor: const Color(0x80FFFFFF),
          labelStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          dividerColor: Colors.transparent,
          tabs: tabs.map((e) => Tab(text: e)).toList(),
        ),
      ),
    );
  }
}
