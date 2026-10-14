import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/widgets/selection_check_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'novel_card/novel_card.dart';

/// 小说详情统一跳转：[AppRoutes.NOVEL_DETAILS_PAGE]，与 [jumpMediaPlay] 命名风格一致。
///
/// 使用示例：
/// ```dart
/// getNovelSixGridStyle(
///   items: novels,
///   onItemTap: (i, _) => jumpNovelDetail('${pageStorageKey}_$i'),
/// );
/// ```
void jumpNovelDetail(String novelId) {
  if (novelId.isEmpty) return;
  Get.toNamed(
    AppRoutes.NOVEL_DETAILS_PAGE,
    arguments: {'novelId': novelId},
  );
}

/// 小说区六宫格（三列、设计稿约 108×195、[NovelCard]）。
///
/// [isSliver] 为 `true` 时返回 [SliverPadding] + [SliverGrid]；
/// 为 `false` 时返回 [Padding] + [GridView.builder]。
Widget getNovelSixGridStyle({
  required List<NovelCardData> items,
  bool isSliver = true,
  EdgeInsetsGeometry? padding,
  bool shrinkWrap = true,
  ScrollPhysics? physics,
  void Function(int index, NovelCardData item)? onItemTap,
}) {
  final effectivePadding = padding ?? EdgeInsets.symmetric(horizontal: 16.w);
  final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    mainAxisSpacing: 12.w,
    crossAxisSpacing: 10.w,
    childAspectRatio: 108 / 196,
  );

  Widget tile(BuildContext context, int index) {
    final item = items[index];
    final card = NovelCard(item: item);
    final tap = onItemTap;
    if (tap == null) {
      return card;
    }
    return GestureDetector(
      onTap: () => tap(index, item),
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }

  final count = items.length;

  if (isSliver) {
    return SliverPadding(
      padding: effectivePadding,
      sliver: SliverGrid(
        gridDelegate: gridDelegate,
        delegate: SliverChildBuilderDelegate(
          tile,
          childCount: count,
        ),
      ),
    );
  }

  return Padding(
    padding: effectivePadding,
    child: GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      gridDelegate: gridDelegate,
      itemCount: count,
      itemBuilder: tile,
    ),
  );
}

/// 在 [getNovelSixGridStyle] 相同版式上增加多选角标（不修改原方法实现）。
Widget getNovelSixGridStyleWithSelection({
  required List<NovelCardData> items,
  bool isSliver = true,
  EdgeInsetsGeometry? padding,
  bool shrinkWrap = true,
  ScrollPhysics? physics,
  required bool selectionMode,
  required Set<int> selectedIndices,
  required void Function(int index) onCellTap,
}) {
  final effectivePadding = padding ?? EdgeInsets.symmetric(horizontal: 16.w);
  final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    mainAxisSpacing: 12.w,
    crossAxisSpacing: 10.w,
    childAspectRatio: 108 / 196,
  );

  Widget tile(BuildContext context, int index) {
    final item = items[index];
    final card = NovelCard(item: item);
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
      onTap: () => onCellTap(index),
      behavior: HitTestBehavior.opaque,
      child: body,
    );
  }

  final count = items.length;

  if (isSliver) {
    return SliverPadding(
      padding: effectivePadding,
      sliver: SliverGrid(
        gridDelegate: gridDelegate,
        delegate: SliverChildBuilderDelegate(
          tile,
          childCount: count,
        ),
      ),
    );
  }

  return Padding(
    padding: effectivePadding,
    child: GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      gridDelegate: gridDelegate,
      itemCount: count,
      itemBuilder: tile,
    ),
  );
}
