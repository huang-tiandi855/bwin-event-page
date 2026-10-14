import 'package:get/get.dart';

/// 收益提现页展示数据（后续可对接 [WalletStore] / 接口）
class WithDrawalState {
  /// 可提现余额（元）
  double availableBalance = 0.0;

  /// 快捷金额档位（元），最后一项为「全部」由逻辑特殊处理
  static const List<int> quickAmounts = [100, 500, 1000];

  /// 当前选中的快捷档位下标，0~2 对应 100/500/1000，3 表示「全部」；-1 表示用户自填
  int selectedQuickIndex = 0;
  WithDrawalState() {
    availableBalance = Get.arguments?['num'] ?? 0.0;
  }
}
