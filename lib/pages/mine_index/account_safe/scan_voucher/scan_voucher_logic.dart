import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/logger.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:recognition_qrcode/recognition_qrcode.dart';

import '../../../../common/entities/card_model.dart';
import '../../../../common/store/user.dart';
import 'scan_voucher_state.dart';

class ScanVoucherLogic extends GetxController {
  ScanVoucherLogic();

  final ScanVoucherState state = ScanVoucherState();

  QRViewController? qrController;
  StreamSubscription<Barcode>? _scanSub;
  bool _handling = false;

  void attachController(QRViewController controller) {
    _scanSub?.cancel();
    qrController = controller;
    _scanSub = controller.scannedDataStream.listen(_onBarcode);
  }

  Future<void> _onBarcode(Barcode scan) async {
    if (_handling) return;
    final code = scan.code; //{"idCard":"34M","idCardPwd":"3XVHU"}
    if (code == null || code.isEmpty) return;
    final json = jsonDecode(code);
    final cardModel = CardModel.fromJson(json);
    if (cardModel.idCard == null || cardModel.idCardPwd == null) return;
    _handling = true;
    try {
      await qrController?.pauseCamera();
      final ok = await submitQrContent(cardModel);
      if (!ok && qrController != null) {
        await qrController!.resumeCamera();
      }
    } catch (e) {
      l.d('扫码处理异常: $e');
      await qrController?.resumeCamera();
    } finally {
      _handling = false;
    }
  }

  /// 与 [AccountRecoveryLogic.qrLoginReq] 一致：凭证内容走 devLogin
  Future<bool> submitQrContent(CardModel? cardModel) async {
    try {
      final ok = await UserStore.to
          .loginByAccount(cardModel?.idCard ?? '', cardModel?.idCardPwd ?? '');
      if (ok) {
        showToast(msg: '登录成功');
        Get.until((routes) {
          if (routes is GetPageRoute) {
            GetPageRoute getRoute = routes;
            if (getRoute.settings.name == AppRoutes.APPLICATION_PAGE) {
              return true;
            }
          }
          return false;
        });
        return true;
      } else {
        showToast(msg: '登录失败');
      }
      return false;
    } catch (e) {
      l.d('执行扫码登录失败：$e');
      showToast(msg: '识别失败，请重试');
      return false;
    }
  }

  /// 相册选图识别二维码（参考 `account_recovery_view` / 原 `scan_camera_dialog`）
  Future<void> pickFromAlbum() async {
    try {
      if (!await _canReadStorage()) {
        showToast(msg: '需要相册权限');
        return;
      }
      final image = await ImagePickers.pickerPaths(
        uiConfig: UIConfig(uiThemeColor: AppColor.bottomNavigationBg),
        selectCount: 1,
        showCamera: false,
        cropConfig: CropConfig(enableCrop: true),
      );
      if (image.isEmpty) return;
      final result = await RecognitionManager.recognition(image[0].path ?? '');
      final value = result.value; //{"idCard":"34M","idCardPwd":"3XVHU"}
      final json = jsonDecode(value);
      final cardModel = CardModel.fromJson(json);
      if (cardModel.idCard == null || cardModel.idCardPwd == null) return;
      await qrController?.pauseCamera();
      final ok = await submitQrContent(cardModel);
      if (!ok) await qrController?.resumeCamera();
    } catch (e) {
      l.d('相册扫码失败：$e');
      showToast(msg: '相册识别失败');
    }
  }

  void openMyCredentials() {
    Get.toNamed(AppRoutes.ACCOUNT_CREDENTIALS);
  }

  Future<bool> _canReadStorage() async {
    if (!Platform.isAndroid) return true;
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final androidVersion = androidInfo.version.release;
    final PermissionStatus status;
    if (int.parse(androidVersion) <= 12) {
      status = await Permission.storage.request();
    } else {
      status = await Permission.mediaLibrary.request();
    }
    return status.isGranted;
  }

  @override
  void onClose() {
    _scanSub?.cancel();
    qrController?.dispose();
    qrController = null;
    super.onClose();
  }
}
