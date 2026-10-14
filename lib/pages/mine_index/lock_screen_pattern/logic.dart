import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/values/varibel_config.dart';
import 'package:comics_app/pages/mine_index/logic.dart';
import 'package:flustars/flustars.dart';
import 'package:get/get.dart';

import 'cold_start.dart';
import 'state.dart';

class PasswordLogic extends GetxController {
  PasswordLogic({this.initialMode});

  /// 与 `Get.arguments` 一致：0 验证，1 设置，2 取消前验证；不传参时默认 0（图案解锁）
  final int? initialMode;

  late final bool _replaceRootOnVerifySuccess;

  final PasswordState state = PasswordState();

  @override
  void onInit() {
    super.onInit();
    _replaceRootOnVerifySuccess = PatternLockColdStart.pendingVerifyThenSplash;
    PatternLockColdStart.pendingVerifyThenSplash = false;

    final fromArg = Get.arguments;
    final mode = initialMode ??
        (fromArg is int ? fromArg : null) ??
        0;
    switch (mode) {
      case 0:
        state.flow = PasswordFlow.verify;
        state.hint = '请绘制锁屏图形';
        break;
      case 2:
        state.flow = PasswordFlow.cancel;
        state.hint = '请确认锁屏图形';
        break;
      default:
        state.flow = PasswordFlow.setNew;
        state.setPhase = 0;
        state.hint = '请绘制锁屏图形';
    }
    update();
  }

  bool get canPop => state.flow != PasswordFlow.verify;

  String get appBarTitle {
    switch (state.flow) {
      case PasswordFlow.verify:
        return '';
      case PasswordFlow.setNew:
        return '密码锁';
      case PasswordFlow.cancel:
        return '取消密码锁';
    }
  }

  String _encode(List<int> path) => path.join(',');

  bool _listEq(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  List<int>? _decodeSaved(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      return raw
          .split(',')
          .map((e) => int.parse(e.trim()))
          .where((e) => e >= 0 && e <= 8)
          .toList();
    } catch (_) {
      return null;
    }
  }

  void onPatternStart() {
    if (state.errorVisual) {
      state.errorVisual = false;
      if (state.flow != PasswordFlow.setNew || state.setPhase == 0) {
        state.hint = state.flow == PasswordFlow.cancel
            ? '请确认锁屏图形'
            : '请绘制锁屏图形';
      } else {
        state.hint = '请确认锁屏图形';
      }
      update();
    }
  }

  void onPatternTooShort(int count) {
    showToast(msg: '至少连接4个点');
  }

  void onPatternSubmit(List<int> path) {
    switch (state.flow) {
      case PasswordFlow.setNew:
        _onSet(path);
        break;
      case PasswordFlow.verify:
        _onVerify(path);
        break;
      case PasswordFlow.cancel:
        _onCancel(path);
        break;
    }
  }

  void _syncMineSwitch() {
    if (Get.isRegistered<MineIndexLogic>()) {
      final on = SpUtil.getBool(VariableConfig.lockScreen, defValue: false)!;
      Get.find<MineIndexLogic>().setLockScreenPassword(on);
    }
  }

  void _onSet(List<int> path) {
    final enc = _encode(path);
    if (state.setPhase == 0) {
      state.tempEncoded = enc;
      state.setPhase = 1;
      state.hint = '请确认锁屏图形';
      state.patternRevision++;
      update();
      return;
    }
    if (enc == state.tempEncoded) {
      SpUtil.putString(VariableConfig.lockScreenPassword, enc);
      SpUtil.putBool(VariableConfig.lockScreen, true);
      showToast(msg: '密码设置成功');
      _syncMineSwitch();
      Get.back(result: true);
    } else {
      state.errorVisual = true;
      state.hint = '设置失败,重新绘制';
      state.setPhase = 0;
      state.tempEncoded = '';
      state.patternRevision++;
      update();
    }
  }

  void _onVerify(List<int> path) {
    final saved =
        _decodeSaved(SpUtil.getString(VariableConfig.lockScreenPassword));
    if (saved == null || saved.isEmpty) {
      showToast(msg: '尚未设置锁屏图案');
      if (_replaceRootOnVerifySuccess) {
        Get.offAllNamed(AppRoutes.SPLASH);
      } else {
        Get.back();
      }
      return;
    }
    if (_listEq(path, saved)) {
      if (_replaceRootOnVerifySuccess) {
        Get.offAllNamed(AppRoutes.SPLASH);
      } else {
        Get.back(result: true);
      }
    } else {
      state.errorVisual = true;
      state.hint = '密码错误，请重新绘制';
      state.patternRevision++;
      update();
    }
  }

  void _onCancel(List<int> path) {
    final saved =
        _decodeSaved(SpUtil.getString(VariableConfig.lockScreenPassword));
    if (saved == null || saved.isEmpty) {
      showToast(msg: '尚未设置锁屏图案');
      Get.back();
      return;
    }
    if (_listEq(path, saved)) {
      SpUtil.putString(VariableConfig.lockScreenPassword, '');
      SpUtil.putBool(VariableConfig.lockScreen, false);
      showToast(msg: '已关闭锁屏密码');
      _syncMineSwitch();
      Get.back(result: true);
    } else {
      state.errorVisual = true;
      state.hint = '密码错误，请重新绘制';
      state.patternRevision++;
      update();
    }
  }
}
