import 'package:comics_app/common/entities/circle/dating_models.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/widgets/dating_card/dating_card.dart';
import 'package:comics_app/common/widgets/selection_check_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

void jumpDatingDetail(int cardId) {
  if (cardId <= 0) return;
  Get.toNamed(
    AppRoutes.DATING_DETAILS,
    arguments: <String, dynamic>{'datingId': cardId},
  );
}

/// 约会双列网格（[DatingCard] / [DatingCardModel]）。
///
/// [isSliver] 为 `true` 时返回 [SliverPadding] + [SliverGrid]；
/// 为 `false` 时返回 [Padding] + [GridView.builder]。
Widget getDatingListStyle({
  required List<DatingCardModel> items,
  bool isSliver = true,
  EdgeInsetsGeometry? padding,
  bool shrinkWrap = true,
  ScrollPhysics? physics,
  void Function(int index, DatingCardModel item)? onItemTap,
}) {
  final effectivePadding = padding ?? EdgeInsets.symmetric(horizontal: 16.w);
  final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 12.w,
    crossAxisSpacing: 10.w,
    childAspectRatio: 167 / 310,
  );

  Widget tile(BuildContext context, int index) {
    final item = items[index];
    final card = DatingCard(card: item);
    return GestureDetector(
      onTap: () => onItemTap != null
          ? onItemTap(index, item)
          : jumpDatingDetail(item.id),
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
        delegate: SliverChildBuilderDelegate(tile, childCount: count),
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

/// 我的购买等场景：双列网格 + 多选角标。
Widget getDatingListStyleWithSelection({
  required List<DatingCardModel> items,
  bool isSliver = true,
  EdgeInsetsGeometry? padding,
  required bool selectionMode,
  required Set<int> selectedIndices,
  required void Function(int index) onCellTap,
}) {
  final effectivePadding = padding ?? EdgeInsets.symmetric(horizontal: 16.w);
  final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 12.w,
    crossAxisSpacing: 10.w,
    childAspectRatio: 167 / 310,
  );

  Widget tile(BuildContext context, int index) {
    final item = items[index];
    final selected = selectedIndices.contains(index);
    final body = wrapWithSelectionCheckBadge(
      child: DatingCard(card: item),
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
        delegate: SliverChildBuilderDelegate(tile, childCount: count),
      ),
    );
  }
  return Padding(
    padding: effectivePadding,
    child: GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: gridDelegate,
      itemCount: count,
      itemBuilder: tile,
    ),
  );
}
