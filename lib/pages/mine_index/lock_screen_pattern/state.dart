/// 与历史 `whetherVerify` 对齐：0 解锁验证，1 设置（两次绘制），2 关闭锁屏前验证
enum PasswordFlow {
  verify,
  setNew,
  cancel,
}

class PasswordState {
  PasswordFlow flow = PasswordFlow.setNew;

  /// 设置流程：0 首次，1 确认
  int setPhase = 0;

  /// 首次绘制成功后的编码，用于二次确认比对
  String tempEncoded = '';

  /// 顶部提示（正常为浅灰，错误时由 view 改红色）
  String hint = '请绘制锁屏图形';

  /// 为 true 时连线与选中点为红色（密码错误）
  bool errorVisual = false;

  /// 重建图案板内部状态
  int patternRevision = 0;
}
