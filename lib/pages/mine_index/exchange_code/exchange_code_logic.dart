import 'package:comics_app/common/apis/user.dart';
import 'package:comics_app/common/entities/user_redemption_model.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/utils/toast_util.dart';
import 'exchange_code_state.dart';

class ExchangeCodeLogic extends GetxController {
  final ExchangeCodeState state = ExchangeCodeState();

  @override
  void onInit() {
    super.onInit();
    onRefresh();
  }

  // editingController / pullRefreshController 的 dispose 交给 view 的 State.dispose 处理，
  // 避免 GetX 自动清理 binding 的时机早于 widget 真正离开 tree，
  // 触发 "controller used after disposed" 异常。

  ///更新提交按钮状态
  void updateSubmitButtonState(bool isNotEmpty) {
    state.canSubmit = isNotEmpty;
    update(["canSubmit"]);
  }

  /// 下拉刷新
  Future<void> onRefresh() async {
    state.pageNumber = 1;
    await _fetchExchangeRecords();
  }

  /// 上拉加载更多
  Future<void> onLoad() async {
    state.pageNumber++;
    await _fetchExchangeRecords();
  }

  /// 请求兑换码列表（支持分页）
  Future<void> _fetchExchangeRecords() async {
    final isFirstPage = state.pageNumber == 1;
    try {
      final result = await UserApi.getExchangeRecordList(
        state.pageNumber,
        pageSize: state.pageSize,
      );
      final newList = result?.list ?? const <ExchangeRecordItemModel>[];

      if (isFirstPage) {
        state.list = [...newList];
      } else {
        state.list = [...state.list, ...newList];
      }

      // 接口未返回 total / hasMore，按 "当页返回数 < pageSize 即到底" 判定
      final hasMore = newList.length >= state.pageSize;
      // 始终上报 isEmpty=false：空态由列表内部占位行渲染，保留下拉刷新能力
      state.pullRefreshController.requestSuccess(
        isFirstPageNum: isFirstPage,
        hasMore: hasMore,
        isEmpty: false,
      );
      update();
    } catch (e) {
      l.d('fetchExchangeRecords error: $e', tag: 'error');
      state.pullRefreshController.requestFail(isFirstPageNum: isFirstPage);
    }
  }

  ///请求兑换码
  void redemptionCodeReq() async {
    String code = state.editingController.text.trim();
    if (code.isEmpty) {
      showToast(msg: "请输入兑换码");
      return;
    }
    try {
      String? key = await UserApi.getExchangeCodeKeyReq();
      if (key == null) {
        showToast(msg: "获取兑换码失败");
        return;
      }
      bool success = await UserApi.exchangeCodeReq(code, key);
      if (success) {
        state.editingController.text = "";
        update(["EditCode"]);
        showToast(msg: "兑换成功");
        onRefresh();
        UserStore.to.refreshUser();
      } else {
        showToast(msg: "兑换失败");
      }
    } catch (e) {
      l.d("兑换失败:$e");
      showToast(msg: "兑换失败");
    }
  }

  ///转换小写为大写字母
  void updateValue(String value) {
    updateSubmitButtonState(value.isNotEmpty);
    state.editingController.text = value.toUpperCase();
    state.editingController.selection = TextSelection.fromPosition(
      TextPosition(
          affinity: TextAffinity.downstream,
          offset: state.editingController.text.length),
    );
  }
}
