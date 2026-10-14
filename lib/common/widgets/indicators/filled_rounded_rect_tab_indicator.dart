import 'package:flutter/material.dart';

Rect _filledRoundedRectTabIndicatorRect(
  Rect tabRect,
  double width,
  double height,
) {
  final cx = tabRect.center.dx;
  return Rect.fromLTWH(cx - width / 2, tabRect.bottom - height, width, height);
}

/// [TabBar] 指示器：贴底、固定宽高，绘制为填充的圆角矩形（[borderRadius] 逐角可配）。
///
/// 示例：
/// - 仅顶部左右圆角：`BorderRadius.vertical(top: Radius.circular(r))`
/// - 仅单侧竖边圆角：`BorderRadius.only(topLeft: Radius.circular(r), bottomLeft: Radius.circular(r))`
/// - 单角：`BorderRadius.only(topLeft: Radius.circular(r))`
class FilledRoundedRectTabIndicator extends Decoration {
  const FilledRoundedRectTabIndicator({
    required this.color,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final Color color;
  final double width;
  final double height;
  final BorderRadius borderRadius;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _FilledRoundedRectTabIndicatorPainter(this, onChanged);
  }

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) {
    final indicatorRect =
        _filledRoundedRectTabIndicatorRect(rect, width, height);
    return Path()..addRRect(borderRadius.toRRect(indicatorRect));
  }
}

class _FilledRoundedRectTabIndicatorPainter extends BoxPainter {
  _FilledRoundedRectTabIndicatorPainter(
      this.decoration, VoidCallback? onChanged)
      : super(onChanged);

  final FilledRoundedRectTabIndicator decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final tabRect = offset & configuration.size!;
    final rect = _filledRoundedRectTabIndicatorRect(
      tabRect,
      decoration.width,
      decoration.height,
    );
    final rrect = decoration.borderRadius.toRRect(rect);
    canvas.drawRRect(rrect, Paint()..color = decoration.color);
  }
}
