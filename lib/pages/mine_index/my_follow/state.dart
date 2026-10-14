import 'package:comics_app/common/entities/user/user_account_model.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/material.dart';

/// 我的关注页：双 Tab —— 关注（我关注的人）/ 粉丝（关注我的人）。
class MyFollowState {
  static const List<String> tabs = <String>['关注', '粉丝'];
  static const int pageSize = 10;

  late TabController tabController;

  /// 关注列表（MineApis.getMyFollowList）
  final List<UserAccountModel> followList = <UserAccountModel>[];
  int followPage = 1;
  bool followLoaded = false;
  final PullRefreshController followPullRefresh =
      PullRefreshController(isRequest: true);

  /// 粉丝列表（MineApis.getMyFansList）
  final List<UserAccountModel> fansList = <UserAccountModel>[];
  int fansPage = 1;
  bool fansLoaded = false;
  final PullRefreshController fansPullRefresh =
      PullRefreshController(isRequest: true);

  /// 关注/取关期间禁止重复点击的标记：key = uid。
  final Set<int> pendingFollowUids = <int>{};
}
