import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:comics_app/common/apis/user.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/utils/utils.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import 'account_credentials_state.dart';

class AccountCredentialsLogic extends GetxController {
  final AccountCredentialsState state = AccountCredentialsState();

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!isClosed) _certificationReq();
    });
  }

  Future<void> _certificationReq() async {
    final model = await UserApi.getCertification();
    if (!isClosed && model != null) {
      state.cardModel = model;
      update(['QrContent']);
    }
  }

  ///保存账号凭证
  void saveAccountCredentials() {
    const bool kIsWeb = identical(0, 0.0);

    ///web
    if (kIsWeb) {
      showToast(msg: "请手动截图保存账号凭证");
      return;
    }

    ///安卓
    if (Platform.isAndroid) {
      if (state.cardModel != null) {
        Future.delayed(const Duration(milliseconds: 20), () async {
          RenderRepaintBoundary? boundary = state.boundaryKey.currentContext
              ?.findRenderObject() as RenderRepaintBoundary?;
          Image? image = await boundary?.toImage(pixelRatio: 3.0);
          ByteData? byteData =
              await image?.toByteData(format: ImageByteFormat.png);
          Uint8List? pngBytes = byteData?.buffer.asUint8List();
          bool suc = await savePngDataToAblumn(pngBytes!);
          if (suc) Get.back();
        });
      }
    }
  }
}
