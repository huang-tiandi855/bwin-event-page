import 'package:flutter/material.dart';

class RoundUnderlineTabIndicator extends Decoration {
  const RoundUnderlineTabIndicator({
    this.borderSide = const BorderSide(width: 5.0, color: Colors.white),
    this.insets = EdgeInsets.zero,
    this.width = 21,
    this.widthEqualTitle = false,
    this.gradient,
  });

  final BorderSide borderSide;
  final EdgeInsetsGeometry insets;
  final double width;
  final bool widthEqualTitle;

  /// 非空时用水平渐变绘制下划线（忽略 [borderSide] 的颜色，仍使用其 [BorderSide.width] 作为线宽）。
  final LinearGradient? gradient;

  @override
  Decoration lerpFrom(Decoration? a, double t) {
    if (a is UnderlineTabIndicator) {
      return UnderlineTabIndicator(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
        insets: EdgeInsetsGeometry.lerp(a.insets, insets, t)!,
      );
    }
    return super.lerpFrom(a, t)!;
  }

  @override
  Decoration lerpTo(Decoration? b, double t) {
    if (b is UnderlineTabIndicator) {
      return UnderlineTabIndicator(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        insets: EdgeInsetsGeometry.lerp(insets, b.insets, t)!,
      );
    }
    return super.lerpTo(b, t)!;
  }

  @override
  _UnderlinePainter createBoxPainter([VoidCallback? onChanged]) {
    return _UnderlinePainter(this, onChanged);
  }

  Rect _indicatorRectFor(Rect rect, TextDirection textDirection) {
    final Rect indicator = insets.resolve(textDirection).deflateRect(rect);

    if (widthEqualTitle) {
      return Rect.fromLTWH(
        indicator.left,
        indicator.bottom - borderSide.width,
        indicator.width,
        borderSide.width,
      );
    } else {
      double w = (indicator.left + indicator.right) / 2;
      return Rect.fromLTWH(w - width / 2, indicator.bottom - borderSide.width,
          width, borderSide.width);
    }
  }

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) {
    return Path()..addRect(_indicatorRectFor(rect, textDirection));
  }
}

class _UnderlinePainter extends BoxPainter {
  _UnderlinePainter(this.decoration, VoidCallback? onChanged)
      : super(onChanged);

  final RoundUnderlineTabIndicator decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Size? size = configuration.size;
    if (size == null) return;

    final Rect rect = offset & size;
    final TextDirection textDirection =
        configuration.textDirection ?? TextDirection.ltr;
    final Rect indicator = decoration
        ._indicatorRectFor(rect, textDirection)
        .deflate(decoration.borderSide.width / 2.0);
    final Paint paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = decoration.borderSide.width;
    final g = decoration.gradient;
    if (g != null) {
      final shaderRect = Rect.fromLTRB(
        indicator.left,
        indicator.top - decoration.borderSide.width,
        indicator.right,
        indicator.bottom + decoration.borderSide.width,
      );
      paint.shader = g.createShader(shaderRect);
    } else {
      paint.color = decoration.borderSide.color;
    }
    canvas.drawLine(indicator.bottomLeft, indicator.bottomRight, paint);
  }
}
