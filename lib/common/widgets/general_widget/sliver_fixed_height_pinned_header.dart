import 'package:flutter/material.dart';

/// 固定高度、不随 overscroll 伸缩的 [SliverPersistentHeaderDelegate]，
/// 常用于二级 Tab、筛选条等吸顶区域。
class FixedHeightSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  FixedHeightSliverPersistentHeaderDelegate({
    required this.height,
    required this.child,
  });

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(
    covariant FixedHeightSliverPersistentHeaderDelegate oldDelegate,
  ) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

/// [SliverPersistentHeader] + [FixedHeightSliverPersistentHeaderDelegate] 的便捷封装。
class SliverFixedHeightPinnedHeader extends StatelessWidget {
  const SliverFixedHeightPinnedHeader({
    Key? key,
    required this.height,
    required this.child,
    this.pinned = true,
    this.floating = false,
  }) : super(key: key);

  final double height;
  final Widget child;
  final bool pinned;
  final bool floating;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: pinned,
      floating: floating,
      delegate: FixedHeightSliverPersistentHeaderDelegate(
        height: height,
        child: child,
      ),
    );
  }
}
