import 'package:comics_app/common/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'state.dart';

class WithDrawalLogic extends GetxController {
  final WithDrawalState state = WithDrawalState();
  final TextEditingController amountController = TextEditingController();

  static const int _quickAllIndex = 3;

  /// 与 [WithDrawalPage] 中 GetBuilder 的 id 一致
  static const Object bodyUpdateId = 'body';

  @override
  void onInit() {
    super.onInit();
    amountController.text = '${WithDrawalState.quickAmounts.first}';
    state.selectedQuickIndex = 0;
  }

  void selectQuickAmount(int index) {
    state.selectedQuickIndex = index;
    if (index == _quickAllIndex) {
      fillAllAmount();
    } else {
      amountController.text = '${WithDrawalState.quickAmounts[index]}';
    }
    update([bodyUpdateId]);
  }

  void fillAllAmount() {
    final v = state.availableBalance;
    if (v <= 0) return;
    amountController.text = _formatBalanceForInput(v);
  }

  /// 与输入框展示一致，用于「全部」与 onChanged 比对
  String _formatBalanceForInput(double v) {
    return v.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  void onAmountFieldChanged(String _) {
    if (state.selectedQuickIndex < 0) return;
    final preset = state.selectedQuickIndex == _quickAllIndex
        ? _formatBalanceForInput(state.availableBalance)
        : '${WithDrawalState.quickAmounts[state.selectedQuickIndex]}';
    if (amountController.text.trim() != preset) {
      state.selectedQuickIndex = -1;
      update([bodyUpdateId]);
    }
  }

  void submitWithdraw() {
    final text = amountController.text.trim();
    if (text.isEmpty) {
      showToast(msg: '请输入提现金额');
      return;
    }
    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      showToast(msg: '请输入有效金额');
      return;
    }
    if (amount < 100) {
      showToast(msg: '单笔最低提现金额为100元');
      return;
    }
    if (amount > state.availableBalance) {
      showToast(msg: '提现金额不能超过可提现余额');
      return;
    }
    showToast(msg: '暂无提现通道');
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
}
