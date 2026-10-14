/// 冷启动以 [AppRoutes.LOCK_SCREEN_PATTERN] 为首屏时，由 [main] 置位；
/// 首个 [PasswordLogic] onInit 读取后清零。
class PatternLockColdStart {
  PatternLockColdStart._();

  /// 验证成功后应 `Get.offAllNamed(SPLASH)`（仅消费一次）
  static bool pendingVerifyThenSplash = false;
}
