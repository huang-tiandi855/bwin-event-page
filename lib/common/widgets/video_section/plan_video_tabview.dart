import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PlanVideoTabView extends StatelessWidget {
  const PlanVideoTabView({
    super.key,
    required this.itemBuilder,
    required this.itemTitleBuilder,
    required this.itemCount,
  });
  final Widget Function(BuildContext, int) itemBuilder;
  final String Function(int) itemTitleBuilder;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: itemCount,
      child: LayoutBuilder(builder: (ctx, constraints) {
        return Column(
          children: [
            SizedBox(
              height: 98 / 173 * (constraints.maxWidth - 20.w),
              child: TabBarView(
                children: List.generate(itemCount, (index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: itemBuilder.call(ctx, index),
                  );
                }).toList(),
              ),
            ),
            16.verticalSpaceFromWidth,
            Container(
              height: 26.w,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: TabBar(
                isScrollable: true,
                unselectedLabelStyle: TextStyle(
                  fontSize: 14.sp,
                ),
                unselectedLabelColor: const Color(0xFF777777),
                labelStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                labelColor: const Color(0xFFFFFFFF),
                indicator: BoxDecoration(
                  color: const Color(0xFFB09FD9),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                indicatorWeight: 0,
                labelPadding: EdgeInsets.symmetric(
                  horizontal: 0.w,
                ).copyWith(right: 10.w),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.symmetric(
                  horizontal: 0.w,
                ).copyWith(right: 10.w),
                tabs: List.generate(itemCount, (index) {
                  return Container(
                    height: 26.w,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      itemTitleBuilder.call(index),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      }),
    );
  }
}
