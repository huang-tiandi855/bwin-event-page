import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class YJCustomeTabBar extends StatelessWidget {
  const YJCustomeTabBar({
    super.key,
    required this.tabs,
    required this.controller,
    this.isScrollable,
    this.labelColor,
    this.labelStyle,
    this.unselectedLabelColor,
    this.unselectedLabelStyle,
    this.padding,
    this.callback,
  });

  final List<String> tabs;
  final TabController controller;
  final bool? isScrollable;
  final Color? labelColor;
  final TextStyle? labelStyle;
  final Color? unselectedLabelColor;
  final TextStyle? unselectedLabelStyle;
  final void Function(int index)? callback;
  final EdgeInsets? padding;

  Color get _labelColor => labelColor ?? const Color(0xFFFFE7BD);
  Color get _unselectedLabelColor =>
      unselectedLabelColor ?? const Color(0xFFF5F5F5);

  TextStyle get _labelStyle => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        height: 1.44,
      ).merge(labelStyle);

  TextStyle get _unselectedLabelStyle => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        height: 1.44,
      ).merge(unselectedLabelStyle);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.w,
      child: TabBar(
        controller: controller,
        tabAlignment: TabAlignment.start,
        isScrollable: isScrollable ?? true,
        unselectedLabelStyle: _unselectedLabelStyle,
        unselectedLabelColor: _unselectedLabelColor,
        labelStyle: _unselectedLabelStyle,
        labelColor: _labelColor,
        indicator: const BoxDecoration(),
        indicatorWeight: 0,
        labelPadding: EdgeInsets.zero,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.zero,
        padding: padding ??
            EdgeInsets.symmetric(
              horizontal: 15.w,
            ),
        onTap: callback,
        tabs: List.generate(
          tabs.length,
          (index) {
            final TextPainter textPainter = TextPainter(
              text: TextSpan(
                text: tabs[index],
                style: _labelStyle,
              ),
              textDirection: TextDirection.ltr,
            )..layout();
            final padding =
                10.w * _unselectedLabelStyle.fontSize! / _labelStyle.fontSize!;
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: padding,
              ).copyWith(
                left: index == 0 ? 0 : padding,
                right: index == tabs.length - 1 ? 0 : padding,
              ),
              child: ValueListenableBuilder<double>(
                valueListenable: controller.animation!,
                builder: (context, value, child) {
                  final double progress =
                      1 - (value - index).abs().clamp(0, 1.0);
                  final double endScale =
                      _labelStyle.fontSize! / _unselectedLabelStyle.fontSize!;
                  final double scaleValue =
                      1.0 + (endScale - 1.0) * progress;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      5.verticalSpaceFromWidth,
                      Container(
                        height: textPainter.height,
                        constraints: BoxConstraints(
                          minWidth: textPainter.width,
                        ),
                        alignment: Alignment.center,
                        child: ScaleTransition(
                          scale: AlwaysStoppedAnimation(scaleValue),
                          child: Text(
                            tabs[index],
                          ),
                        ),
                      ),
                      CustomPaint(
                        size: Size(10.w, 5.w),
                        painter: BottomArcPainter(
                          progress: progress,
                        ), // 控制进度
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class BottomArcPainter extends CustomPainter {
  final double progress;

  BottomArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) {
      return;
    }
    final paint = Paint()
      ..color = const Color(0xFFFFE7BD)
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.0;
    final rect = Rect.fromLTWH(
        0, -size.height - size.height * 3 / 5, size.width, size.height * 2);
    final path = Path();
    path.arcTo(rect, 90 * (pi / 180.0), 70 * (pi / 180.0) * progress, true);
    path.arcTo(rect, 90 * (pi / 180.0), -70 * (pi / 180.0) * progress, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
