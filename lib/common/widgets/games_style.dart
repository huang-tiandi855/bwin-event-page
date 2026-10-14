import 'package:comics_app/common/entities/circle/game_data_model.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/widgets/game_card/game_card.dart';
import 'package:comics_app/common/widgets/game_card/game_detail_card.dart';
import 'package:comics_app/common/widgets/selection_check_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 游戏详情统一跳转：[AppRoutes.GAME_DETAILS]。
void jumpGameDetail(String gameId) {
  if (gameId.isEmpty) return;
  Get.toNamed(
    AppRoutes.GAME_DETAILS,
    arguments: {'gameId': gameId},
  );
}

/// 黄游纵向列表（[GameCard] / [GameDataModel]）。
///
/// [isSliver] 为 `true` 时返回 [SliverPadding] + [SliverList]；
/// 为 `false` 时返回 [Padding] + [ListView.builder]。
Widget getGameListStyle({
  required List<GameDataModel> items,
  bool isSliver = true,
  EdgeInsetsGeometry? padding,
  bool shrinkWrap = true,
  ScrollPhysics? physics,
  void Function(int index, GameDataModel item)? onItemTap,
}) {
  final effectivePadding = padding ?? EdgeInsets.symmetric(horizontal: 16.w);

  Widget tile(BuildContext context, int index) {
    final item = items[index];
    final card = GameCard(game: item);
    return Padding(
      padding: EdgeInsets.only(bottom: 10.w),
      child: GestureDetector(
        onTap: () => onItemTap != null
            ? onItemTap(index, item)
            : jumpGameDetail('${item.id}'),
        behavior: HitTestBehavior.opaque,
        child: card,
      ),
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

/// 游戏区四宫格（双列、设计稿约 166×200、[GameDetailCard]）。
Widget getGameFourGridStyle({
  required List<GameDataModel> items,
  bool isSliver = true,
  EdgeInsetsGeometry? padding,
  bool shrinkWrap = true,
  ScrollPhysics? physics,
  void Function(int index, GameDataModel item)? onItemTap,
}) {
  final effectivePadding = padding ?? EdgeInsets.symmetric(horizontal: 16.w);
  final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 11.w,
    crossAxisSpacing: 11.w,
    childAspectRatio: 166 / 205,
  );

  Widget tile(BuildContext context, int index) {
    final item = items[index];
    final card = GameDetailCard(game: item);
    final tap = onItemTap;
    if (tap == null) {
      return GestureDetector(
        onTap: () => jumpGameDetail('${item.id}'),
        behavior: HitTestBehavior.opaque,
        child: card,
      );
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

/// 在 [getGameFourGridStyle] 相同版式上增加多选角标。
Widget getGameFourGridStyleWithSelection({
  required List<GameDataModel> items,
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
    mainAxisSpacing: 11.w,
    crossAxisSpacing: 11.w,
    childAspectRatio: 166 / 200,
  );

  Widget tile(BuildContext context, int index) {
    final item = items[index];
    final card = GameDetailCard(game: item);
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
