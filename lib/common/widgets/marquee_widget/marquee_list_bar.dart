import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 多条公告跑马灯里的一条数据。
class MarqueeItem {
  const MarqueeItem({required this.text, this.onTap});

  /// 单条文案
  final String text;

  /// 单条点击事件
  final VoidCallback? onTap;
}

/// 多条跑马灯（水平无限滚动）：
///
/// - 单条数据：文字水平循环移动，跟 `marquee` 包同款效果；
/// - 多条数据：按顺序首尾相接、无缝水平滚动；
/// - 每条 [MarqueeItem] 独立 hit-test，点击只触发自身的 `onTap`；
/// - 视觉样式（容器高度、底色、内边距、左侧图标、关闭按钮）对齐
///   [MarqueeAnnouncementBar]，可以混用在同一处布局里。
///
/// 用法：
/// ```dart
/// MarqueeListBar(
///   items: [
///     MarqueeItem(text: '系统将于今晚维护', onTap: () => Get.toNamed(...)),
///     MarqueeItem(text: '点击立即领取金币', onTap: () => ...),
///   ],
/// )
/// ```
class MarqueeListBar extends StatefulWidget {
  const MarqueeListBar({
    Key? key,
    required this.items,
    this.velocity = 30,
    this.itemGap,
    this.leading,
    this.barHeight,
    this.horizontalPadding,
    this.padding,
    this.leadingGap,
    this.margin,
    this.decoration,
    this.marqueeLineHeight,
    this.textStyle,

    /// 为 `true` 时展示关闭按钮；关闭后本实例内不再展示。
    this.showCloseButton = true,
    this.onDismiss,
  }) : super(key: key);

  /// 公告条数据；为空时返回 [SizedBox.shrink]，不渲染空条。
  final List<MarqueeItem> items;

  /// 滚动速度，单位 `逻辑像素 / 秒`；与 `Marquee.velocity` 同义。
  final double velocity;

  /// 相邻条目之间（含末尾回到第一条之间）的横向间距，默认 48.w。
  final double? itemGap;

  /// 不传时使用首页金刚区同款喇叭图标。
  final Widget? leading;

  /// 整条固定高度；为 null 时由子组件撑开。
  final double? barHeight;

  /// 与 [padding] 二选一：未传 [padding] 时使用 `symmetric(horizontal: horizontalPadding ?? 17.w)`。
  final double? horizontalPadding;

  final EdgeInsetsGeometry? padding;

  final EdgeInsetsGeometry? margin;

  /// 图标与文案间距。
  final double? leadingGap;

  final Decoration? decoration;

  /// 文案区高度。
  final double? marqueeLineHeight;

  final TextStyle? textStyle;

  final bool showCloseButton;

  /// 用户点击关闭后回调（可选，用于业务埋点等）。
  final VoidCallback? onDismiss;

  @override
  State<MarqueeListBar> createState() => _MarqueeListBarState();
}

class _MarqueeListBarState extends State<MarqueeListBar>
    with SingleTickerProviderStateMixin {
  /// 测量「一组完整数据 + 末尾间距」宽度的探针 key。
  final GlobalKey _cycleKey = GlobalKey();

  AnimationController? _controller;
  double _cycleWidth = 0;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupAnimation());
  }

  @override
  void didUpdateWidget(covariant MarqueeListBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final itemsChanged = !_sameItems(oldWidget.items, widget.items);
    if (itemsChanged ||
        oldWidget.velocity != widget.velocity ||
        oldWidget.itemGap != widget.itemGap ||
        oldWidget.textStyle != widget.textStyle) {
      _cycleWidth = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) => _setupAnimation());
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  bool _sameItems(List<MarqueeItem> a, List<MarqueeItem> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].text != b[i].text) return false;
    }
    return true;
  }

  /// 测量首份「轨道」宽度后，按 `velocity` 计算一轮的时长并循环播放。
  void _setupAnimation() {
    if (!mounted) return;
    final ctx = _cycleKey.currentContext;
    final width = ctx?.size?.width ?? 0;
    if (width <= 0) return;
    if ((width - _cycleWidth).abs() < 0.5 && _controller?.isAnimating == true) {
      return;
    }
    _cycleWidth = width;
    final v = widget.velocity <= 0 ? 30.0 : widget.velocity;
    final ms = (width / v * 1000).round().clamp(800, 3600000);
    _controller?.dispose();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ms),
    )..addListener(_onTick);
    _controller!.repeat();
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty || (widget.showCloseButton && _dismissed)) {
      return const SizedBox.shrink();
    }

    final effectiveLeading = widget.leading ??
        AssetsGen.images.home.icNotice.image(
          width: 23.w,
          height: 23.w,
        );

    final effectivePadding = widget.padding ??
        EdgeInsets.symmetric(horizontal: widget.horizontalPadding ?? 17.w);

    final effectiveTextStyle = widget.textStyle ??
        TextStyle(
          fontSize: 12.sp,
          color: Colors.white.withOpacity(0.9),
        );

    final double gap = widget.itemGap ?? 48.w;

    final Widget marquee = SizedBox(
      height: widget.marqueeLineHeight ?? 22.w,
      width: double.infinity,
      child: ClipRect(
        child: _HorizontalMarqueeTrack(
          offset: (_controller?.value ?? 0) * _cycleWidth,
          cycleKey: _cycleKey,
          buildCycle: (Key? key) => _Cycle(
            key: key,
            items: widget.items,
            gap: gap,
            style: effectiveTextStyle,
          ),
        ),
      ),
    );

    final Widget row = Row(
      children: [
        effectiveLeading,
        SizedBox(width: widget.leadingGap ?? 8.w),
        Expanded(child: marquee),
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
      margin: widget.margin,
      decoration: widget.decoration ??
          BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(29.w),
          ),
      child: row,
    );
  }
}

/// 两份「轨道」首尾相接，按 [offset] 整体左移；offset 走完一轮（cycleWidth）后
/// 由 [AnimationController.repeat] 自动归零，从而形成无缝循环。
class _HorizontalMarqueeTrack extends StatelessWidget {
  const _HorizontalMarqueeTrack({
    required this.offset,
    required this.cycleKey,
    required this.buildCycle,
  });

  final double offset;
  final Key cycleKey;
  final Widget Function(Key? key) buildCycle;

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      alignment: Alignment.centerLeft,
      maxWidth: double.infinity,
      child: Transform.translate(
        offset: Offset(-offset, 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildCycle(cycleKey),
            buildCycle(null),
          ],
        ),
      ),
    );
  }
}

/// 一组完整数据 + 每条后面的间距，作为循环的最小重复单元。
class _Cycle extends StatelessWidget {
  const _Cycle({
    super.key,
    required this.items,
    required this.gap,
    required this.style,
  });

  final List<MarqueeItem> items;
  final double gap;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (final item in items) {
      Widget child = Text(
        item.text,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.visible,
        style: style,
      );
      if (item.onTap != null) {
        child = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: item.onTap,
          child: child,
        );
      }
      children.add(child);
      children.add(SizedBox(width: gap));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}
