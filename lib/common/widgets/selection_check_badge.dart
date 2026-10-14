import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 在 [child] 上叠加 [SelectionCheckBadge]；[selectionMode] 为 false 时原样返回 [child]。
///
/// [top]、[right] 为逻辑像素，内部会再 `.w` 适配（与 ScreenUtil 用法一致）。
Widget wrapWithSelectionCheckBadge({
  required Widget child,
  required bool selectionMode,
  required bool selected,
  double top = 6,
  double right = 6,
  bool ignorePointerOnBadge = true,
}) {
  if (!selectionMode) return child;
  final badge = selected
      ? AssetsGen.images.mine.vipCenterSel.image(
          width: 30.w,
          height: 30.w,
        )
      : const SizedBox.shrink();
  return Stack(
    clipBehavior: Clip.none,
    children: [
      child,
      Positioned(
        top: top.w,
        right: right.w,
        child: ignorePointerOnBadge ? IgnorePointer(child: badge) : badge,
      ),
    ],
  );
}
