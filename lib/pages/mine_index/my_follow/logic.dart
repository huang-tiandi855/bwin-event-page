import 'package:comics_app/common/apis/media_api.dart';
import 'package:comics_app/common/apis/mine_apis.dart';
import 'package:comics_app/common/entities/user/user_account_model.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/tab_controller_dispose.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'state.dart';

/// 我的关注 / 我的粉丝（合页双 Tab）。
///
/// - 关注 Tab：`MineApis.getMyFollowList`（POST `/fans/stars`）。
/// - 粉丝 Tab：`MineApis.getMyFansList`（POST `/fans/fans`）。
/// - 关注 / 取关：复用详情 / 用户中心同一对外接口
///   [MediaApi.onFocus] / [MediaApi.onCancleFocus]，避免出现两份不一致的关注逻辑。
class MyFollowLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  final MyFollowState state = MyFollowState();

  int get myUid => UserStore.to.getUserInfoModel?.uid ?? 0;

  @override
  void onInit() {
    super.onInit();
    state.tabController =
        TabController(length: MyFollowState.tabs.length, vsync: this);
    state.tabController.addListener(_onTabChanged);
    // 默认进入「关注」Tab，「粉丝」Tab 首次切到再请求，避免不必要的接口压力。
    onRefreshFollow();
  }

  void _onTabChanged() {
    if (state.tabController.indexIsChanging) return;
    if (state.tabController.index == 1 && !state.fansLoaded) {
      onRefreshFans();
    }
  }

  // ----- 关注 -----

  Future<void> onRefreshFollow() async {
    state.followPage = 1;
    state.followLoaded = true;
    await _loadList(isFans: false, replace: true);
  }

  Future<void> onLoadMoreFollow() async {
    state.followPage++;
    await _loadList(isFans: false, replace: false);
  }

  // ----- 粉丝 -----

  Future<void> onRefreshFans() async {
    state.fansPage = 1;
    state.fansLoaded = true;
    await _loadList(isFans: true, replace: true);
  }

  Future<void> onLoadMoreFans() async {
    state.fansPage++;
    await _loadList(isFans: true, replace: false);
  }

  Future<void> _loadList({
    required bool isFans,
    required bool replace,
  }) async {
    final int page = isFans ? state.fansPage : state.followPage;
    final PullRefreshController pr =
        isFans ? state.fansPullRefresh : state.followPullRefresh;
    final List<UserAccountModel> target =
        isFans ? state.fansList : state.followList;

    try {
      final List<UserAccountModel> chunk = isFans
          ? await MineApis.getMyFansList(
              uid: myUid,
              page: page,
              pageSize: MyFollowState.pageSize,
            )
          : await MineApis.getMyFollowList(
              uid: myUid,
              page: page,
              pageSize: MyFollowState.pageSize,
            );
      if (replace) target.clear();
      target.addAll(chunk);
      final bool hasMore = chunk.length >= MyFollowState.pageSize;
      pr.requestSuccess(
        isFirstPageNum: replace,
        hasMore: hasMore,
        isEmpty: target.isEmpty,
      );
    } catch (_) {
      // 分页失败时回滚页码，避免下次再加载漏掉这一页。
      if (!replace) {
        if (isFans && state.fansPage > 1) state.fansPage--;
        if (!isFans && state.followPage > 1) state.followPage--;
      }
      pr.requestFail(isFirstPageNum: replace);
    }
    update();
  }

  /// 点击「+ 关注」/「已关注」按钮。
  ///
  /// - 关注 Tab：取关成功后从列表里移除该项（关注 Tab 的语义就是"我关注的人"，
  ///   不再关注后该项不应继续出现在列表里）。
  /// - 粉丝 Tab：仅切换按钮态，不移除条目（取关粉丝不会让对方不再是我的粉丝）。
  Future<void> toggleFollow(UserAccountModel item,
      {required bool isFans}) async {
    final int uid = item.id ?? 0;
    if (uid <= 0) {
      showToast(msg: '用户信息错误');
      return;
    }
    if (state.pendingFollowUids.contains(uid)) return;
    state.pendingFollowUids.add(uid);
    update(['focus_$uid']);

    final bool prev = item.follow ?? false;
    final BaseRespBean resp =
        prev ? await MediaApi.onCancleFocus(uid) : await MediaApi.onFocus(uid);
    if (resp.isSuccess) {
      item.follow = !prev;
      showToast(msg: !prev ? '关注成功' : '取消关注');
      if (!isFans && prev) {
        // 「关注」Tab 取关：把这一条移除。
        state.followList.removeWhere((e) => e.id == uid);
      }
      update();
    } else {
      showToast(msg: resp.tip ?? (prev ? '取消关注失败' : '关注失败'));
    }
    state.pendingFollowUids.remove(uid);
    update(['focus_$uid']);
  }

  bool isPendingFor(int uid) => state.pendingFollowUids.contains(uid);

  @override
  void onClose() {
    state.tabController.removeListener(_onTabChanged);
    disposeTabControllerAfterRouteExit(state.tabController);
    state.followPullRefresh.dispose();
    state.fansPullRefresh.dispose();
    super.onClose();
  }
}
