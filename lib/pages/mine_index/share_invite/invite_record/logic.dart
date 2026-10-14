import 'package:comics_app/common/apis/mine_apis.dart';
import 'package:comics_app/common/entities/mine/invite_record_model.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'state.dart';

class InviteRecordLogic extends GetxController {
  final InviteRecordState state = InviteRecordState();

  @override
  void onInit() {
    super.onInit();
    _fetch(isRefresh: true);
  }

  @override
  void onClose() {
    state.pullRefreshController.dispose();
    super.onClose();
  }

  /// 下拉刷新：从第一页重新拉取
  Future<void> onRefresh() => _fetch(isRefresh: true);

  /// 上拉加载更多
  Future<void> onLoadMore() => _fetch(isRefresh: false);

  Future<void> _fetch({required bool isRefresh}) async {
    final int targetPage = isRefresh ? 1 : state.page + 1;
    final String code = UserStore.to.getUserInfoModel?.invitationCode ?? '';
    try {
      final InviteRecordPageModel result = await MineApis.getInviteRecord(
        code,
        page: targetPage,
        pageSize: InviteRecordState.pageSize,
      );

      state.page = targetPage;
      state.total = result.total;
      state.records = isRefresh
          ? result.list
          : <InviteUserModel>[...state.records, ...result.list];

      state.pullRefreshController.requestSuccess(
        isFirstPageNum: targetPage == 1,
        hasMore: result.hasNextPage,
        isEmpty: state.records.isEmpty,
      );
    } catch (e, st) {
      debugPrint('invite record fetch error: $e\n$st');
      state.pullRefreshController.requestFail(isFirstPageNum: targetPage == 1);
    } finally {
      update();
    }
  }
}
