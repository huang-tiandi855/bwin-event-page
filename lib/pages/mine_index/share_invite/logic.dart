import 'dart:io';
import 'dart:ui';

import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/utils/utils.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'state.dart';

class ShareInviteLogic extends GetxController {
  final ShareInviteState state = ShareInviteState();

  void copyLink(String url) {
    if (url.isEmpty) {
      showToast(msg: '暂无推广链接');
      return;
    }
    Clipboard.setData(ClipboardData(text: url));
    showToast(msg: '复制成功');
  }

  void savePoster(String shareUrl) {
    const bool kIsWeb = identical(0, 0.0);
    if (shareUrl.isEmpty) {
      showToast(msg: '暂无推广链接');
      return;
    }
    if (kIsWeb) {
      showToast(msg: '请手动截图保存');
      return;
    }
    if (Platform.isAndroid) {
      Future.delayed(const Duration(milliseconds: 20), () async {
        final boundary = state.boundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
        final image = await boundary?.toImage(pixelRatio: 3.0);
        final byteData = await image?.toByteData(format: ImageByteFormat.png);
        final pngBytes = byteData?.buffer.asUint8List();
        if (pngBytes != null) {
          final suc = await savePngDataToAblumn(pngBytes);
          if (suc) showToast(msg: '保存成功');
        }
      });
    } else {
      showToast(msg: '请使用手机截图保存');
    }
  }
}
