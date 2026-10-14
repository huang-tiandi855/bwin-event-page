import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

/// 与 [QrScannerOverlayShape] `paint` 中取景框 [Rect] 计算保持一致。
class ScanAreaCutOutRect {
  ScanAreaCutOutRect._();

  static Rect compute(
    Rect rect, {
    required double cutOutWidth,
    required double cutOutHeight,
    double cutOutBottomOffset = 0,
    double borderWidth = 3,
  }) {
    final width = rect.width;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final cutW =
        cutOutWidth < width ? cutOutWidth : width - borderOffset;
    final cutH =
        cutOutHeight < height ? cutOutHeight : height - borderOffset;
    return Rect.fromLTWH(
      rect.left + width / 2 - cutW / 2 + borderOffset,
      -cutOutBottomOffset +
          rect.top +
          height / 2 -
          cutH / 2 +
          borderOffset,
      cutW - borderOffset * 2,
      cutH - borderOffset * 2,
    );
  }
}

/// 继承 [QrScannerOverlayShape]（[QRView.overlay] 类型要求），重写 [paint]：
/// 与包内相同的 saveLayer 遮罩 + `dstOut` 镂空，不画四段描边；再在四角 [drawImageRect]。
class ScanAreaCornerImagesShape extends QrScannerOverlayShape {
  ScanAreaCornerImagesShape({
    Color borderColorForCutout = Colors.white,
    double borderWidth = 3.0,
    Color overlayColor = const Color(0xCC000000),
    double borderRadius = 0,
    double borderLength = 22,
    double? cutOutSize,
    double? cutOutWidth,
    double? cutOutHeight,
    double cutOutBottomOffset = 0,
    this.cutoutBlendColor = Colors.white,
    this.cornerDrawSize = 27,
    this.cornerBleed = 0,
    this.topLeft,
    this.topRight,
    this.bottomLeft,
    this.bottomRight,
  }) : super(
          borderColor: borderColorForCutout,
          borderWidth: borderWidth,
          overlayColor: overlayColor,
          borderRadius: borderRadius,
          borderLength: borderLength,
          cutOutSize: cutOutSize,
          cutOutWidth: cutOutWidth,
          cutOutHeight: cutOutHeight,
          cutOutBottomOffset: cutOutBottomOffset,
        );

  /// 抠洞用色（须不透明），可与传给父类构造的 [borderColorForCutout] 相同。
  final Color cutoutBlendColor;

  final double cornerDrawSize;
  final double cornerBleed;

  final ui.Image? topLeft;
  final ui.Image? topRight;
  final ui.Image? bottomLeft;
  final ui.Image? bottomRight;

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final boxPaint = Paint()
      ..color = cutoutBlendColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final cutOutRect = ScanAreaCutOutRect.compute(
      rect,
      cutOutWidth: cutOutWidth,
      cutOutHeight: cutOutHeight,
      cutOutBottomOffset: cutOutBottomOffset,
      borderWidth: borderWidth,
    );

    canvas
      ..saveLayer(rect, backgroundPaint)
      ..drawRect(rect, backgroundPaint)
      ..drawRRect(
        RRect.fromRectAndRadius(
          cutOutRect,
          Radius.circular(borderRadius),
        ),
        boxPaint,
      )
      ..restore();

    final sz = cornerDrawSize;
    final b = cornerBleed;
    final imgPaint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.medium;

    void drawCorner(ui.Image? img, Rect dest) {
      if (img == null) return;
      final src = Rect.fromLTWH(
        0,
        0,
        img.width.toDouble(),
        img.height.toDouble(),
      );
      canvas.drawImageRect(img, src, dest, imgPaint);
    }

    drawCorner(
      topLeft,
      Rect.fromLTWH(cutOutRect.left - b, cutOutRect.top - b, sz, sz),
    );
    drawCorner(
      topRight,
      Rect.fromLTWH(cutOutRect.right - sz + b, cutOutRect.top - b, sz, sz),
    );
    drawCorner(
      bottomLeft,
      Rect.fromLTWH(
        cutOutRect.left - b,
        cutOutRect.bottom - sz + b,
        sz,
        sz,
      ),
    );
    drawCorner(
      bottomRight,
      Rect.fromLTWH(
        cutOutRect.right - sz + b,
        cutOutRect.bottom - sz + b,
        sz,
        sz,
      ),
    );
  }

  @override
  ShapeBorder scale(double t) {
    return ScanAreaCornerImagesShape(
      borderColorForCutout: borderColor,
      borderWidth: borderWidth * t,
      overlayColor: overlayColor,
      borderRadius: borderRadius * t,
      borderLength: borderLength * t,
      cutOutWidth: cutOutWidth * t,
      cutOutHeight: cutOutHeight * t,
      cutOutBottomOffset: cutOutBottomOffset * t,
      cutoutBlendColor: cutoutBlendColor,
      cornerDrawSize: cornerDrawSize * t,
      cornerBleed: cornerBleed * t,
      topLeft: topLeft,
      topRight: topRight,
      bottomLeft: bottomLeft,
      bottomRight: bottomRight,
    );
  }
}
