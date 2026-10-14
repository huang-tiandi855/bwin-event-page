class MineIndexState {
  /// 锁屏密码开关（仅 UI 状态，可与设置页持久化对接）
  bool lockScreenPasswordOn = false;

  /// VIP 横幅倒计时文案
  String countdownText = '';

  /// 新人 24h 等活动的剩余秒数（由 logic 的定时器维护）
  int countdownSecond = 0;

  String vipName = "";

  bool isVip = false;

  bool isNewUser = false;
}
