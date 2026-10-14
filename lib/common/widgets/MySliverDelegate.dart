import 'dart:math';

import 'package:flutter/widgets.dart';

class MySliverDelegate extends SliverPersistentHeaderDelegate {
  double maxHeight;
  double minHeight;
  Widget child;

  MySliverDelegate({
    required this.maxHeight,
    required this.minHeight,
    required this.child,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TODO: implement build
    return SizedBox.expand(child: child,);
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => max(maxHeight, minHeight);

  @override
  // TODO: implement minExtent
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    // 仅比较高度会漏掉 child 内部状态（如选中索引）变化，
    // 导致 SliverPersistentHeader 不重建 child，UI 看上去「点了没反应」。
    if (oldDelegate is MySliverDelegate) {
      return maxHeight != oldDelegate.maxHeight ||
          minHeight != oldDelegate.minHeight ||
          child != oldDelegate.child;
    }
    return true;
  }
}
