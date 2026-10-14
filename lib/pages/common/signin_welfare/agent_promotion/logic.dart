import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/utils/utils.dart';
import 'package:comics_app/common/values/address.dart';

import '../../../../common/apis/mine_apis.dart';
import 'state.dart';

class AgentPromotionLogic extends GetxController {
  final state = AgentPromotionState();

  @override
  void onInit() {
    super.onInit();
    _syncUserFromStore();
    _syncInviteUserCount();
    _syncWalletBalance();
  }

  void _syncInviteUserCount() {
    MineApis.getInviteUserCount().then((value) {
      state.inviteCount = value;
      update();
    });
  }

  void _syncWalletBalance() {
    MineApis.getWalletBalance().then((value) {
      state.walletBalanceModel = value;
      state.withdrawableReward = value?.invitation ?? 0.0;
      update();
    });
  }

  void _syncUserFromStore() {
    final u = UserStore.to.getUserInfoModel;
    if (u == null) {
      return;
    }
    state.userName =
        (u.name?.trim().isNotEmpty == true) ? u.name!.trim() : '用户';
    state.userPortrait =
        u.avatarUrl?.trim().isNotEmpty == true ? u.avatarUrl : null;
    state.inviteCode = u.invitationCode?.trim().isNotEmpty == true
        ? u.invitationCode!.trim()
        : state.inviteCode;
  }

  void onTapWithdraw() {
    Get.toNamed(AppRoutes.WITH_DRAWAL,
        arguments: {'num': state.withdrawableReward});
  }

  void onTapPromotionData() {
    Get.toNamed(AppRoutes.AGENT_PROMOTION_DATA,
        arguments: {"model": state.walletBalanceModel});
  }

  void onTapJoinAgent() {
    Get.toNamed(AppRoutes.SHARE_INVITE);
  }

  /// 推广链接 = `Address.shareUrlLink` 拼当前 [state.inviteCode]。
  ///
  /// 不直接读 [AgentPromotionState.shareLink] —— 那个字段是 state 构造时
  /// 拿 [UserStore] 里的邀请码一次性算好的，[_syncUserFromStore] 之后会被
  /// state 里的 [inviteCode] 覆盖，复用旧字段容易拷成旧值。
  String get _resolvedShareLink =>
      ('${Address.shareUrlLink ?? ''}${state.inviteCode}').trim();

  /// 「复制链接」入口。空链接给文案，不要让用户复制到一个空串。
  void onTapCopyLink() {
    final url = _resolvedShareLink;
    if (url.isEmpty) {
      showToast(msg: '暂无推广链接');
      return;
    }
    Clipboard.setData(ClipboardData(text: url));
    showToast(msg: '复制成功');
  }

  /// 「请截图保存」入口：把 [AgentPromotionState.boundaryKey] 包住的二维码
  /// 海报渲染成 PNG 写进相册。
  ///
  /// 平台策略与隔壁 [ShareInviteLogic.savePoster] 对齐：
  /// - Web：相册接口不可用，提示手动截图；
  /// - Android：走 `image_gallery_saver` + 权限申请（[savePngDataToAblumn]）；
  /// - iOS（含其他平台）：当前 [savePngDataToAblumn] 内部只跑 Android 分支，
  ///   暂提示用户手动截图，留待统一相册保存接入后再覆盖。
  ///
  /// 微延迟一帧再 [RenderRepaintBoundary.toImage]：保证按钮按下后的水波纹 /
  /// `setState` 已经绘制完毕，避免截图截到瞬态的 highlight。
  Future<void> onTapSavePoster() async {
    if (_resolvedShareLink.isEmpty && state.inviteCode.trim().isEmpty) {
      showToast(msg: '暂无推广信息');
      return;
    }
    if (kIsWeb) {
      showToast(msg: '请手动截图保存');
      return;
    }
    if (!Platform.isAndroid) {
      showToast(msg: '请使用手机截图保存');
      return;
    }
    await Future.delayed(const Duration(milliseconds: 20));
    try {
      final boundary = state.boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        showToast(msg: '保存失败，请手动截图');
        return;
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();
      if (pngBytes == null) {
        showToast(msg: '保存失败，请手动截图');
        return;
      }
      // [savePngDataToAblumn] 内部会自带成功 / 失败 toast，这里不再重复。
      await savePngDataToAblumn(pngBytes);
    } catch (_) {
      showToast(msg: '保存失败，请手动截图');
    }
  }
}
