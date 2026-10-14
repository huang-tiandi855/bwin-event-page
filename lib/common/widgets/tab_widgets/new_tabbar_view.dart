import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef OnTap = Function(int index);

// ignore: must_be_immutable — 历史写法：允许 `tabController == null` 时在 State 内创建并写回, must_be_immutable
class FantasticTabBarView extends StatefulWidget {
  final List<String>? tabValues;
  final double? containerHeight;
  TabController? tabController;
  final OnTap? onTap;

  final double? borderPaddingTop;
  final double? borderPaddingBottom;
  final Color? bgColor;
  final TabAlignment? tabAlignment;
  final bool isScrollable;

  FantasticTabBarView({
    super.key,
    @required this.tabValues,
    @required this.tabController,
    this.tabAlignment,
    this.isScrollable = false,
    this.containerHeight = 33,
    this.borderPaddingTop = 3.6,
    this.borderPaddingBottom = 3.6,
    this.onTap,
    this.bgColor,
  });

  @override
  State<StatefulWidget> createState() {
    return _FantasticTabBarViewState();
  }
}

class _FantasticTabBarViewState extends State<FantasticTabBarView>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.tabController ??=
        TabController(length: widget.tabValues?.length ?? 0, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.containerHeight?.h,
      padding: EdgeInsets.only(left: 6.5.w, right: 6.5.w),
      decoration: BoxDecoration(
        color: widget.bgColor ?? Colors.transparent,
        image: const DecorationImage(
            filterQuality: FilterQuality.high,
            fit: BoxFit.fill,
            image: AssetImage("assets/images/png/tabbar_bg_large.png")),
      ),
      alignment: Alignment.center,
      child: TabBar(
        isScrollable: widget.isScrollable,
        tabAlignment: widget.tabAlignment,
        labelColor: const Color.fromRGBO(85, 85, 85, 1),
        controller: widget.tabController,
        onTap: (index) {
          widget.onTap?.call(index);
        },
        labelStyle: TextStyle(
            fontSize: 12.sp, fontWeight: FontWeight.w900, height: 1.6),
        unselectedLabelColor: const Color.fromRGBO(153, 153, 153, 1),
        unselectedLabelStyle: TextStyle(
            fontSize: 12.sp, fontWeight: FontWeight.w900, height: 1.6),
        indicatorPadding: EdgeInsets.only(
          top: widget.borderPaddingTop!.w,
          bottom: widget.borderPaddingTop!.w,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: EdgeInsets.zero,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            width: 2.w,
            color: const Color.fromRGBO(229, 229, 232, 1),
          ),
        ),
        tabs: widget.tabValues!.map((e) {
          return Container(
            alignment: Alignment.center,
            height: widget.containerHeight?.h,
            child: Text(
              e,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
      ),
    );
  }
}
