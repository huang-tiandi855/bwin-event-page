import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/apis/circle_api.dart';
import '../../../common/apis/mine_apis.dart';
import '../../../common/entities/circle/posting_list_models.dart';
import 'state.dart';

class CreateCenterLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  final CreateCenterState state = CreateCenterState();
  late TabController tabController;

  /// 触发某个 Tab 的列表重建：`update(['post_list_$tabIndex'])`。
  static String tabBuilderId(int tabIndex) => 'post_list_$tabIndex';

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(
      length: CreateCenterState.tabCount,
      vsync: this,
      initialIndex: state.index,
    );
    tabController.addListener(_onTabChange);
  }

  @override
  void onReady() {
    super.onReady();
    _loadIfNeeded(state.index);
    _syncWalletBalance();
  }

  @override
  void onClose() {
    tabController.removeListener(_onTabChange);
    tabController.dispose();
    state.dispose();
    super.onClose();
  }

  void _syncWalletBalance() {
    MineApis.getWalletBalance().then((value) {
      state.posting = value?.posting ?? 0.0;
      state.postingSum = value?.postingSum ?? 0.0;
      update(['balance']);
    });
  }

  void _onTabChange() {
    if (tabController.indexIsChanging) return;
    state.index = tabController.index;
    _loadIfNeeded(state.index);
  }

  /// 仅在该 Tab 还没拉过首屏时触发，避免来回切换 Tab 反复请求。
  void _loadIfNeeded(int tab) {
    if (state.loaded[tab]) return;
    state.loaded[tab] = true;
    loadFirstPage(tab);
  }

  /// 下拉刷新 / 首屏 / 错误重试通用入口。
  Future<void> loadFirstPage(int tab) async {
    await _fetch(tab, refresh: true);
  }

  /// 上拉加载下一页。
  Future<void> loadMore(int tab) async {
    await _fetch(tab, refresh: false);
  }

  Future<void> _fetch(int tab, {required bool refresh}) async {
    final int status = CreateCenterState.tabStatusValues[tab];
    final int targetPage = refresh ? 1 : state.pages[tab] + 1;

    final PostingListPage? result = await CircleApi.getMyPostingList(
      status: status,
      page: targetPage,
    );

    if (result == null) {
      state.pullControllers[tab].requestFail(isFirstPageNum: refresh);
      return;
    }

    if (refresh) {
      state.posts[tab]
        ..clear()
        ..addAll(result.list);
    } else {
      state.posts[tab].addAll(result.list);
    }
    state.pages[tab] = targetPage;
    state.hasMore[tab] = result.hasNextPage;

    state.pullControllers[tab].requestSuccess(
      isFirstPageNum: refresh,
      hasMore: state.hasMore[tab],
      isEmpty: state.posts[tab].isEmpty,
    );
    update([tabBuilderId(tab)]);
  }
}
