import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marquee/marquee.dart';

/// 横向公告条：左侧图标 + `marquee` 文案；可选右侧关闭（关闭后本实例内不再展示，父级刷新亦不恢复）。
///
/// 默认样式对齐首页金刚区深色条；频道白底样式请用 [LightChannelMarqueeBar] / [ThemedChannelMarqueeBar]。
class MarqueeAnnouncementBar extends StatefulWidget {
  const MarqueeAnnouncementBar({
    Key? key,
    required this.text,
    this.leading,
    this.barHeight,
    this.horizontalPadding,
    this.padding,
    this.leadingGap,
    this.decoration,
    this.marqueeLineHeight,
    this.textStyle,
    this.blankSpace,
    this.velocity,
    this.pauseAfterRound,
    this.startPadding,
    this.accelerationDuration,
    this.decelerationDuration,
    this.accelerationCurve,
    this.decelerationCurve,
    this.onTap,

    /// 为 `true` 时展示关闭按钮；关闭后本条公告隐藏直至路由重建或 [Key] 变化。
    this.showCloseButton = false,

    /// 用户点击关闭后回调（可选，用于业务埋点等）。
    this.onDismiss,
  }) : super(key: key);

  final String text;

  /// 不传时使用首页金刚区同款喇叭图标。
  final Widget? leading;

  /// 整条固定高度；为 null 时由子组件撑开（推荐频道白底条使用）。
  final double? barHeight;

  /// 与 [padding] 二选一：未传 [padding] 时使用 `symmetric(horizontal: horizontalPadding ?? 10.w)`。
  final double? horizontalPadding;

  final EdgeInsetsGeometry? padding;

  /// 图标与文案间距。
  final double? leadingGap;

  final Decoration? decoration;

  /// Marquee 区域高度。
  final double? marqueeLineHeight;

  final TextStyle? textStyle;

  final double? blankSpace;

  final double? velocity;

  final Duration? pauseAfterRound;

  final double? startPadding;

  final Duration? accelerationDuration;

  final Duration? decelerationDuration;

  final Curve? accelerationCurve;

  final Curve? decelerationCurve;

  final VoidCallback? onTap;

  final bool showCloseButton;

  final VoidCallback? onDismiss;

  @override
  State<MarqueeAnnouncementBar> createState() => _MarqueeAnnouncementBarState();
}

class _MarqueeAnnouncementBarState extends State<MarqueeAnnouncementBar> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.showCloseButton && _dismissed) {
      return const SizedBox.shrink();
    }

    final effectiveLeading = widget.leading ??
        AssetsGen.images.home.icNotice.image(
          width: 23.w,
          height: 23.w,
        );

    final effectivePadding = widget.padding ??
        EdgeInsets.symmetric(horizontal: widget.horizontalPadding ?? 17.w);

    final Widget marquee = SizedBox(
      height: widget.marqueeLineHeight ?? 22.w,
      child: Marquee(
        text: widget.text,
        style: widget.textStyle ??
            TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withOpacity(0.9),
            ),
        scrollAxis: Axis.horizontal,
        blankSpace: widget.blankSpace ?? 48.w,
        pauseAfterRound: widget.pauseAfterRound ?? Duration.zero,
        startPadding: widget.startPadding ?? 0,
        velocity: widget.velocity ?? 30,
        accelerationDuration: widget.accelerationDuration ?? Duration.zero,
        accelerationCurve: widget.accelerationCurve ?? Curves.linear,
        decelerationDuration: widget.decelerationDuration ?? Duration.zero,
        decelerationCurve: widget.decelerationCurve ?? Curves.easeOut,
      ),
    );

    Widget marqueeArea = Expanded(child: marquee);
    if (widget.onTap != null) {
      marqueeArea = Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: marquee,
        ),
      );
    }

    final Widget row = Row(
      children: [
        effectiveLeading,
        SizedBox(width: widget.leadingGap ?? 8.w),
        marqueeArea,
        if (widget.showCloseButton)
          GestureDetector(
            onTap: () {
              setState(() => _dismissed = true);
              widget.onDismiss?.call();
            },
            child: AssetsGen.images.home.icMarqueeClose.image(
              width: 18.7.w,
              height: 18.7.h,
            ),
          ),
      ],
    );

    return Container(
      width: double.infinity,
      height: widget.barHeight ?? 36.h,
      padding: effectivePadding,
      decoration: widget.decoration ??
          BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(29.w),
          ),
      child: row,
    );
  }
}
