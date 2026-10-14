import 'dart:ui' as ui;

import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'scan_area_corner_images_overlay.dart';
import 'scan_voucher_logic.dart';

/// 扫描凭证
class ScanVoucherPage extends StatefulWidget {
  const ScanVoucherPage({Key? key}) : super(key: key);

  @override
  State<ScanVoucherPage> createState() => _ScanVoucherPageState();
}

class _ScanVoucherPageState extends State<ScanVoucherPage>
    with SingleTickerProviderStateMixin {
  static const _overlayColor = Color(0xCC000000);
  static const _scanLineDuration = Duration(milliseconds: 2400);

  final GlobalKey _qrViewKey = GlobalKey(debugLabel: 'scan_voucher_qr');

  ScanVoucherLogic get _logic => Get.find<ScanVoucherLogic>();

  late final AnimationController _scanLineController;
  late final Animation<double> _scanLineAnimation;

  /// 与 [ScanAreaCornerImagesShape] 中绘制的四角资源顺序一致
  final List<ui.Image?> _cornerImages = <ui.Image?>[null, null, null, null];

  bool get _cameraSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  double get _cutOutBottomOffset => 36 + 50.w;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: _scanLineDuration,
    )..repeat();
    _scanLineAnimation = CurvedAnimation(
      parent: _scanLineController,
      curve: Curves.linear,
    );
    _loadCornerImages();
  }

  Future<void> _loadCornerImages() async {
    final paths = <String>[
      AssetsGen.images.mine.scanTopLeft.path,
      AssetsGen.images.mine.scanTopRight.path,
      AssetsGen.images.mine.scanBottomLeft.path,
      AssetsGen.images.mine.scanBottomRight.path,
    ];
    for (var i = 0; i < paths.length; i++) {
      if (!mounted) return;
      try {
        final data = await rootBundle.load(paths[i]);
        final codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(),
        );
        final frame = await codec.getNextFrame();
        codec.dispose();
        if (!mounted) return;
        _cornerImages[i] = frame.image;
      } catch (_) {
        if (!mounted) return;
        _cornerImages[i] = null;
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    for (final im in _cornerImages) {
      im?.dispose();
    }
    super.dispose();
  }

  ScanAreaCornerImagesShape _buildQrOverlay(double cut) {
    return ScanAreaCornerImagesShape(
      overlayColor: _overlayColor,
      borderWidth: 3,
      borderLength: 22,
      borderRadius: 0,
      cutOutWidth: cut,
      cutOutHeight: cut,
      cutOutBottomOffset: _cutOutBottomOffset,
      cutoutBlendColor: Colors.white,
      cornerDrawSize: 27,
      cornerBleed: 2.w,
      topLeft: _cornerImages[0],
      topRight: _cornerImages[1],
      bottomLeft: _cornerImages[2],
      bottomRight: _cornerImages[3],
    );
  }

  Widget _buildScanLineLayer(Rect scanRect) {
    return Positioned(
      left: scanRect.left,
      top: scanRect.top,
      width: scanRect.width,
      height: scanRect.height,
      child: IgnorePointer(
        child: ClipRect(
          child: AnimatedBuilder(
            animation: _scanLineAnimation,
            builder: (context, child) {
              final barH = 4.w;
              final maxY = (scanRect.height - barH).clamp(0.0, double.infinity);
              final top = _scanLineAnimation.value * maxY;
              return Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: top,
                    height: barH,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHint(Rect scanRect) {
    return Positioned(
      left: 24.w,
      right: 24.w,
      top: scanRect.bottom + 16.w,
      child: Text(
        '对准二维码即可自动识别',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildActionBar(Rect scanRect, double bottomInset) {
    return Positioned(
      left: 0,
      right: 0,
      top: scanRect.bottom + 16.w + 14.w + 25.w,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, bottomInset + 20.w),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40.w,
                child: FilledButton(
                  onPressed: () => _logic.pickFromAlbum(),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    '相册',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: SizedBox(
                height: 40.w,
                child: FilledButton(
                  onPressed: () => _logic.openMyCredentials(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColor.primaryButtonColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    '我的凭证',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraStack({
    required Rect scanRect,
    required double cut,
    required double bottomInset,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        QRView(
          key: _qrViewKey,
          onQRViewCreated: _logic.attachController,
          overlay: _buildQrOverlay(cut),
        ),
        _buildScanLineLayer(scanRect),
        _buildHint(scanRect),
        _buildActionBar(scanRect, bottomInset),
      ],
    );
  }

  Widget _unsupportedCamera() {
    return Center(
      child: Text(
        '当前环境不支持相机扫码',
        style: TextStyle(color: Colors.white70, fontSize: 14.sp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColor.scaffoldBackground,
      appBar: commonAppBar('扫描凭证'),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxW = constraints.maxWidth;
                final maxH = constraints.maxHeight;
                final cut = (maxW * 0.68).clamp(200.0, 288.0);
                final scanRect = ScanAreaCutOutRect.compute(
                  Offset.zero & Size(maxW, maxH),
                  cutOutWidth: cut,
                  cutOutHeight: cut,
                  cutOutBottomOffset: _cutOutBottomOffset,
                  borderWidth: 3,
                );

                if (!_cameraSupported) {
                  return _unsupportedCamera();
                }

                return _buildCameraStack(
                  scanRect: scanRect,
                  cut: cut,
                  bottomInset: bottomInset,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
