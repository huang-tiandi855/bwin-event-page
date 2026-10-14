import 'package:comics_app/common/entities/user_redemption_model.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/material.dart';

class ExchangeCodeState {
  final TextEditingController editingController = TextEditingController();

  /// 是否可以提交
  bool canSubmit = false;

  /// 分页 + 下拉刷新控制器
  final PullRefreshController pullRefreshController = PullRefreshController();
  int pageNumber = 1;
  final int pageSize = 10;

  /// 兑换记录列表
  List<ExchangeRecordItemModel> list = <ExchangeRecordItemModel>[];

  ExchangeCodeState();
}
