import 'dart:async';

import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/values/address.dart';
import 'package:comics_app/common/values/config.dart';
import 'package:comics_app/common/widgets/common_dialog/line_switch_bottom_sheet.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/pages/image/network/network_image_urls.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/routers/app_routes.dart';
import '../../common/values/varibel_config.dart';
import 'state.dart';

class MineIndexLogic extends GetxController {
  final state = MineIndexState();

  Timer? _countdownTimer;

  /// 我的页下拉刷新控制器。
  ///
  /// 初始为 `REQUEST_SUCCESS`（[PullRefreshController.isRequest] = false），
  /// 避免一进入「我的」页就出现整页 loading 转圈 —— 页面本身从 [UserStore]
  /// 取数据，进来时已有可展示内容；首次下拉/手动调 [refreshUserInfo] 时
  /// 才走 SmartRefresher 的刷新 UI。
  final PullRefreshController pullRefreshController =
      PullRefreshController(isRequest: false);

  @override
  void onInit() {
    super.onInit();
    _initLockScreenPassword();
  }

  void _initLockScreenPassword() {
    state.lockScreenPasswordOn =
        SpUtil.getBool(VariableConfig.lockScreen, defValue: false)!;
    update(['lockScreenPassword']);
  }

  /// 真正拉用户资料的内部入口，没有任何 UI 副作用：
  /// - 拉 `/user/profile` 回写 [UserStore]（VIP / 金币 / AI 次数 / 头像 等）；
  /// - 完成后再跑一次 [_tick] 重算 VIP 名称 + 新人 24h 倒计时。
  ///
  /// 不在这里碰 [pullRefreshController] —— 由 [refreshUserInfo] /
  /// [silentRefreshUserInfo] 自己根据触发场景决定是否要操作 SmartRefresher。
  Future<void> _fetchUserProfile() async {
    await UserStore.to.refreshUser();
    _tick();
  }

  /// 下拉刷新「我的」页全部用户数据。
  ///
  /// 通过 [pullRefreshController] 上报成败，让 SmartRefresher 正确结束动画；
  /// 失败时使用 `isFirstPageNum: false` —— 我的页是「单页静态信息」场景，
  /// 不希望失败时整页变成「点击重新加载」的失败态，保持原有数据可见。
  Future<void> refreshUserInfo() async {
    try {
      await _fetchUserProfile();
      pullRefreshController.requestSuccess(
        isFirstPageNum: false,
        hasMore: false,
      );
    } catch (_) {
      pullRefreshController.requestFail(isFirstPageNum: false);
    }
  }

  /// 静默刷新用户资料（不触碰 [pullRefreshController]，没有下拉动画）。
  ///
  /// 给「底部导航切到我的」「会员开通后回到我的」等无下拉手势的场景用 ——
  /// 走 [refreshUserInfo] 会把 SmartRefresher 的 `loadComplete / loadNoData`
  /// 状态搓一遍，调试 / 行为上都不干净。
  ///
  /// 失败时直接吞掉：场景是「页面已有缓存数据」的后台刷新，没必要把异常
  /// 透到 UI。
  Future<void> silentRefreshUserInfo() async {
    try {
      await _fetchUserProfile();
    } catch (_) {
      // 静默失败：UI 仍显示上一次缓存的用户资料，避免后台刷新失败影响体验。
    }
  }

  void _cancelCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  /// 解析新人 24h 截止时间（`newUser24HourExpireAt`，后端约定为毫秒时间戳）。
  DateTime? _parseNewUser24HourExpireAt(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final ms = int.tryParse(trimmed);
    if (ms == null || ms <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  void _tick() {
    if (!Get.isRegistered<UserStore>()) {
      state.vipName = '';
      state.countdownText = '';
      _cancelCountdownTimer();
      update(['timer']);
      return;
    }

    final user = UserStore.to.getUserInfoModel;
    state.isVip = user?.isVip ?? false;
    // 1. VIP：只展示会员卡名称
    if (user?.isVip == true) {
      state.vipName = user?.membershipCardName ?? '';
      final vipValidDate = DateTime.fromMillisecondsSinceEpoch(
          int.parse(user?.vipValidDate ?? '0'));
      //2026-05-30
      state.countdownText =
          '${vipValidDate.year}-${vipValidDate.month.toString().padLeft(2, '0')}-${vipValidDate.day.toString().padLeft(2, '0')}';
      _cancelCountdownTimer();
      update(['timer']);
      return;
    }

    // 2. 非 VIP：清空会员名，再判断新人倒计时
    state.vipName = '';

    final expireAt = _parseNewUser24HourExpireAt(user?.newUser24HourExpireAt);
    if (expireAt == null) {
      state.isNewUser = false;
      state.countdownText = '';
      _cancelCountdownTimer();
      update(['timer']);
      return;
    }

    state.countdownSecond = expireAt.difference(DateTime.now()).inSeconds;
    if (state.countdownSecond <= 0) {
      state.isNewUser = false;
      state.countdownText = '';
      _cancelCountdownTimer();
      update(['timer']);
      return;
    }

    state.isNewUser = true;
    void syncCountdownText() {
      final sec = state.countdownSecond;
      final h = sec ~/ 3600;
      final m = (sec % 3600) ~/ 60;
      final s = sec % 60;
      state.countdownText =
          '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }

    syncCountdownText();
    update(['timer']);

    _cancelCountdownTimer();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state.countdownSecond -= 1;
      if (state.countdownSecond <= 0) {
        state.countdownText = '';
        _cancelCountdownTimer();
        update(['timer']);
        return;
      }
      syncCountdownText();
      update(['timer']);
    });
  }

  void setLockScreenPassword(bool on) {
    state.lockScreenPasswordOn = on;
    SpUtil.putBool(VariableConfig.lockScreen, on);
    update(['lockScreenPassword']);
  }

  /// 从「我的」开关进入：开 → 设置图案；关 → 校验原图案后关闭。
  Future<void> toggleLockScreenFromMine() async {
    if (state.lockScreenPasswordOn) {
      await Get.toNamed(AppRoutes.LOCK_SCREEN_PATTERN, arguments: 2);
    } else {
      await Get.toNamed(AppRoutes.LOCK_SCREEN_PATTERN, arguments: 1);
    }
    _initLockScreenPassword();
    update(['lockScreenPassword', 'timer']);
  }

  void showPictureLineSwitchSheet(BuildContext context) {
    showCombinedLineSwitchBottomSheet(
      context: context,
      sections: [
        LineSwitchSection(
          title: '图片线路',
          lines: lineSwitchItemsFromPlayLines(Address.pictureLines ?? []),
          selectedLine: Address.pictureLine,
          onSelected: (item, _) {
            applyPictureLineSelection(item.line);
            FBroadcast.instance().broadcast(Config.SWITCH_PICTURE_LINE);
            update();
          },
        ),
        LineSwitchSection(
          title: '视频线路',
          lines: lineSwitchItemsFromPlayLines(Address.h5PlayLines ?? []),
          selectedLine: Address.h5PlayLine,
          onSelected: (item, _) {
            Address.h5PlayLine = item.line;
            update();
          },
        ),
      ],
    );
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    pullRefreshController.dispose();
    super.onClose();
  }
}
