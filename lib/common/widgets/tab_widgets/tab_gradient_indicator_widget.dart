import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/values/widgetAttibutes/RoundUnderlineTablndicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 带渐变圆角下划线的 [TabBar] 封装，默认样式对齐签到福利顶栏 Tab。
///
/// 尺寸类默认值在 [build] 内使用 [ScreenUtil]，请在已 `ScreenUtilInit` 的树下使用。
class TabGradientIndicatorTabBar extends StatelessWidget {
  const TabGradientIndicatorTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.isScrollable = false,
    this.tabAlignment = TabAlignment.center,
    this.padding,
    this.labelColor,
    this.labelPadding,
    this.unselectedLabelColor,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.indicatorSize,
    this.indicatorWeight,
    this.indicatorPadding,
    this.indicatorBorderSide,
    this.indicatorUnderlineWidth,
    this.indicatorInsets,
    this.indicatorGradient,
    this.enableIndicatorGradient = true,
    this.useSigninWelfareDefaults = true,
    this.dividerColor = Colors.transparent,
    this.onTap,
  });

  final TabController controller;
  final List<Widget> tabs;

  final bool isScrollable;
  final TabAlignment tabAlignment;

  /// 传给 [TabBar.padding]；默认 null（使用 [TabBar] 自身默认）。
  final EdgeInsetsGeometry? padding;

  /// 默认 [AppColor.primaryText]
  final Color? labelColor;

  /// [useSigninWelfareDefaults] 为 true 且本参数为 null 时，默认水平 `23.w`；否则为 null 表示不覆盖。
  final EdgeInsetsGeometry? labelPadding;

  /// 默认 [AppColor.hintTextColor]
  final Color? unselectedLabelColor;

  /// 默认 `15.sp` / `FontWeight.w600`
  final TextStyle? labelStyle;

  /// 默认 `15.sp` / `FontWeight.w400`
  final TextStyle? unselectedLabelStyle;

  /// 传给 [TabBar.indicatorSize]；默认 null。
  final TabBarIndicatorSize? indicatorSize;

  /// [useSigninWelfareDefaults] 为 true 且本参数为 null 时默认 `8.h`，否则为 null 时使用 [TabBar] 默认 `2.0`。
  final double? indicatorWeight;

  /// [useSigninWelfareDefaults] 为 true 且本参数为 null 时默认 `bottom: 7.h`；否则仅使用传入值。
  final EdgeInsetsGeometry? indicatorPadding;

  /// 传给 [RoundUnderlineTabIndicator.borderSide]；默认宽度 `4.w`、颜色 `#FF0808`
  final BorderSide? indicatorBorderSide;

  /// 传给 [RoundUnderlineTabIndicator.width]；默认 `20.w`
  final double? indicatorUnderlineWidth;

  /// 传给 [RoundUnderlineTabIndicator.insets]；默认 [EdgeInsets.zero]
  final EdgeInsetsGeometry? indicatorInsets;

  /// 传给 [RoundUnderlineTabIndicator.gradient]；默认左透明 `#990404`、右 `#FF0808`。
  /// [enableIndicatorGradient] 为 false 时不绘制渐变（使用 [borderSide] 颜色）。
  final LinearGradient? indicatorGradient;

  final bool enableIndicatorGradient;

  /// 为 true 时套用签到福利顶栏 Tab 的默认间距与指示条高度（见各字段说明）。
  final bool useSigninWelfareDefaults;

  final Color? dividerColor;
  final ValueChanged<int>? onTap;

  static LinearGradient _defaultGradient() {
    return LinearGradient(
      colors: [
        const Color(0xFFFFAD08).withOpacity(0),
        const Color(0xFFFFAD08),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color resolvedLabel = labelColor ?? AppColor.primaryText;
    final Color resolvedUnselected =
        unselectedLabelColor ?? Colors.white.withOpacity(.5);
    final TextStyle resolvedLabelStyle = labelStyle ??
        TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        );
    final TextStyle resolvedUnselectedStyle = unselectedLabelStyle ??
        TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        );

    final EdgeInsetsGeometry? effectiveLabelPadding = useSigninWelfareDefaults
        ? (labelPadding ?? EdgeInsets.symmetric(horizontal: 23.w))
        : labelPadding;

    final double effectiveIndicatorWeight =
        indicatorWeight ?? (useSigninWelfareDefaults ? 8.h : 2.0);

    final EdgeInsetsGeometry effectiveIndicatorPadding =
        useSigninWelfareDefaults
            ? (indicatorPadding ?? EdgeInsets.only(bottom: 7.h))
            : (indicatorPadding ?? EdgeInsets.zero);

    final LinearGradient? effectiveGradient = !enableIndicatorGradient
        ? null
        : (indicatorGradient ?? _defaultGradient());

    return TabBar(
      controller: controller,
      isScrollable: isScrollable,
      tabAlignment: tabAlignment,
      padding: padding,
      labelColor: resolvedLabel,
      labelPadding: effectiveLabelPadding,
      unselectedLabelColor: resolvedUnselected,
      labelStyle: resolvedLabelStyle,
      unselectedLabelStyle: resolvedUnselectedStyle,
      indicatorSize: indicatorSize,
      indicatorWeight: effectiveIndicatorWeight,
      indicatorPadding: effectiveIndicatorPadding,
      indicator: RoundUnderlineTabIndicator(
        borderSide: indicatorBorderSide ??
            BorderSide(width: 4.w, color: const Color(0xFFFF0808)),
        width: indicatorUnderlineWidth ?? 20.w,
        insets: indicatorInsets ?? EdgeInsets.zero,
        gradient: effectiveGradient,
      ),
      dividerColor: dividerColor,
      onTap: onTap,
      tabs: tabs,
    );
  }
}
