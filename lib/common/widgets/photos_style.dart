import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/widgets/selection_check_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'photo_card/photo_card.dart';

/// 图集详情统一跳转：[AppRoutes.PICTURE_GROUP_PREVIEW]，与 [jumpMediaPlay] 命名风格一致。
///
/// 使用示例：
/// ```dart
/// getPhotosFourGridStyle(
///   items: photos,
///   onItemTap: (i, _) => jumpPhotoDetail('${pageStorageKey}_$i'),
/// );
/// ```
void jumpPhotoDetail(String photoId) {
  if (photoId.isEmpty) return;
  Get.toNamed(
    AppRoutes.PICTURE_GROUP_PREVIEW,
    arguments: {'photoId': photoId},
  );
}

/// 图集区四宫格（双列、设计稿约 166×285、[PhotoCard]）。
///
/// [isSliver] 为 `true` 时返回 [SliverPadding] + [SliverGrid]；
/// 为 `false` 时返回 [Padding] + [GridView.builder]。
Widget getPhotosFourGridStyle({
  required List<PhotoCardData> items,
  bool isSliver = true,
  EdgeInsetsGeometry? padding,
  bool shrinkWrap = true,
  ScrollPhysics? physics,
  void Function(int index, PhotoCardData item)? onItemTap,
}) {
  final effectivePadding = padding ?? EdgeInsets.symmetric(horizontal: 16.w);
  final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 12.w,
    crossAxisSpacing: 10.w,
    childAspectRatio: 166 / 285,
  );

  Widget tile(BuildContext context, int index) {
    final item = items[index];
    final card = PhotoCard(item: item);
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

/// 在 [getPhotosFourGridStyle] 相同版式上增加多选角标（不修改原方法实现）。
Widget getPhotosFourGridStyleWithSelection({
  required List<PhotoCardData> items,
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
    crossAxisCount: 2,
    mainAxisSpacing: 12.w,
    crossAxisSpacing: 10.w,
    childAspectRatio: 166 / 285,
  );

  Widget tile(BuildContext context, int index) {
    final item = items[index];
    final card = PhotoCard(item: item);
    final selected = selectedIndices.contains(index);
    final body = wrapWithSelectionCheckBadge(
      child: card,
      selectionMode: selectionMode,
      selected: selected,
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
