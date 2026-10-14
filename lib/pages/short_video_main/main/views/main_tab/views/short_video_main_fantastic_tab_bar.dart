import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShortVideoMainFantasticTabBar extends StatelessWidget {
  const ShortVideoMainFantasticTabBar({
    super.key,
    required this.controller,
    required this.tabs,
  });

  final TabController controller;
  final List<String> tabs;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: TabBar(
        isScrollable: true,
        controller: controller,
        labelColor: Colors.white,
        padding: EdgeInsets.zero,
        tabAlignment: TabAlignment.start,
        labelPadding: EdgeInsets.only(left: 34.w, right: 10.w),
        unselectedLabelColor: Colors.white.withOpacity(.5),
        labelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 0,
        dividerColor: Colors.transparent,
        indicator: const BoxDecoration(),
        tabs: tabs.map((e) => Text(e)).toList(),
      ),
    );
  }
}
