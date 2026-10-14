import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/widgets/selection_check_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'post_card/post_card.dart';

/// 帖子详情统一跳转：[AppRoutes.POST_DETAILS]，与 [jumpMediaPlay] 命名风格一致。
///
/// 使用示例：
/// ```dart
/// getPostListStyle(
///   items: posts,
///   onItemTap: (i, _) => jumpPostDetail('community_feed_$i'),
/// );
/// ```
void jumpPostDetail(String postId) {
  if (postId.isEmpty) return;
  Get.toNamed(
    AppRoutes.POST_DETAILS,
    arguments: {'postId': postId},
  );
}

/// 帖子列表：纵向 [PostCard]（社区等 Tab 信息流）。
///
/// [isSliver] 为 `true` 时返回 [SliverPadding] + [SliverList]，用于 [CustomScrollView]；
/// 为 `false` 时返回 [Padding] + [ListView.builder]，适合嵌在 [Column] 等布局里。
Widget getPostListStyle({
  required List<PostCardData> items,
  bool isSliver = true,
  EdgeInsetsGeometry? padding,
  bool shrinkWrap = true,
  ScrollPhysics? physics,
  void Function(int index, PostCardData item)? onItemTap,
}) {
  final effectivePadding = padding ?? EdgeInsets.symmetric(horizontal: 16.w);

  Widget tile(BuildContext context, int index) {
    final item = items[index];
    final card = PostCard(post: item);

    return GestureDetector(
      onTap: () => onItemTap != null
          ? onItemTap.call(index, item)
          : jumpPostDetail(item.id.toString()),
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }

  final count = items.length;

  if (isSliver) {
    return SliverPadding(
      padding: effectivePadding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          tile,
          childCount: count,
        ),
      ),
    );
  }

  return Padding(
    padding: effectivePadding,
    child: ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: tile,
    ),
  );
}

/// 在 [getPostListStyle] 相同版式上增加多选角标（不修改原方法实现）。
Widget getPostListStyleWithSelection({
  required List<PostCardData> items,
  bool isSliver = true,
  EdgeInsetsGeometry? padding,
  bool shrinkWrap = true,
  ScrollPhysics? physics,
  required bool selectionMode,
  required Set<int> selectedIndices,
  required void Function(int index, PostCardData item) onCellTap,
}) {
  final effectivePadding = padding ?? EdgeInsets.symmetric(horizontal: 16.w);

  Widget tile(BuildContext context, int index) {
    final item = items[index];
    final card = PostCard(post: item);
    final selected = selectedIndices.contains(index);
    final body = wrapWithSelectionCheckBadge(
      child: card,
      selectionMode: selectionMode,
      selected: selected,
      top: 4,
      right: 4,
      ignorePointerOnBadge: false,
    );
    return GestureDetector(
      onTap: () => onCellTap(index, item),
      behavior: HitTestBehavior.opaque,
      child: body,
    );
  }

  final count = items.length;

  if (isSliver) {
    return SliverPadding(
      padding: effectivePadding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          tile,
          childCount: count,
        ),
      ),
    );
  }

  return Padding(
    padding: effectivePadding,
    child: ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: tile,
    ),
  );
}
