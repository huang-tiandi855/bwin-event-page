import 'package:comics_app/common/apis/circle_api.dart';
import 'package:comics_app/common/store/event_tracking_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/circle/posting_list_models.dart';
import '../search_result_logic.dart';
import 'post_search_result_state.dart';

/// 搜索结果页「帖子」Tab 的逻辑层。
///
/// 数据源：[CircleApi.getPostingList]（`posting/list`，扁平数组返回，由
/// [PostingListPage.fromData] 用「条数 ≥ 请求 pageSize」启发式判定还有没有下一页）。
///
/// 关键字来源：组件挂载时去 [SearchResultLogic] 取一次当前输入框文案；之后
/// 外层切换关键字调 [updateKeyword]。空关键字直接清空列表，不会发起请求。
class PostSearchResultLogic extends GetxController {
  PostSearchResultLogic({this.index = 0});

  final PostSearchResultState state = PostSearchResultState();

  /// 由外层 Tab 索引透传过来，目前并未直接影响请求；保留参数兼容旧调用点。
  final int index;

  /// 单页条数。`posting/list` 是扁平数组，`hasNextPage` 依赖
  /// 「条数 ≥ pageSize」启发式判断；调小会导致最后一页可能被误判为「还有下一页」。
  static const int _pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    _syncKeywordFromSearchPage();
    onRefresh();
  }

  @override
  void onClose() {
    // 必须显式 dispose，否则下次进页面时 `SmartRefresher` 复用旧 controller
    // 会触发 `Don't use one refreshController to multiple SmartRefresher` 断言。
    state.pullRefreshController.dispose();
    super.onClose();
  }

  /// 取一次外层搜索页当前关键字。组件 init 时调用一次，之后由
  /// [updateKeyword] 驱动后续更新。
  void _syncKeywordFromSearchPage() {
    if (!Get.isRegistered<SearchResultLogic>()) return;
    final text =
        Get.find<SearchResultLogic>().state.textEditingController.text.trim();
    if (text.isNotEmpty) state.keyWord = text;
  }

  /// 外层关键字变更后调用：keyword 实际变化才重置列表并重新请求；空关键字会
  /// 清空当前列表，避免残留上一次搜索的结果。
  void updateKeyword(String? keyword) {
    final next = keyword?.trim() ?? '';
    if (next == (state.keyWord ?? '')) return;
    state.keyWord = next.isEmpty ? null : next;
    onRefresh();
  }

  /// 下拉刷新 / 首屏入口：页码重置为 1，整段替换列表。
  Future<void> onRefresh() async {
    state.pageNum = 1;
    state.hasMore = true;
    await _fetch(replace: true);
  }

  /// 上拉加载下一页；若上一次已知没有下一页，直接短路告诉 footer。
  Future<void> onLoadMore() async {
    if (!state.hasMore) {
      state.pullRefreshController.requestSuccess(
        isFirstPageNum: false,
        hasMore: false,
      );
      return;
    }
    state.pageNum += 1;
    await _fetch(replace: false);
  }

  /// 真正下发请求；按 [replace] 决定整段替换还是追加，统一通过
  /// [PullRefreshController] 同步 header / footer 状态。
  ///
  /// 失败处理：网络 / 解析异常一律走 `requestFail`，并把刚加上的页码回滚，
  /// 避免下一次「加载更多」直接跳页。
  Future<void> _fetch({required bool replace}) async {
    final int page = state.pageNum;
    final bool isFirstPage = page == 1;
    final String keyword = state.keyWord?.trim() ?? '';

    // 空关键字：清空列表 + 走 success(empty) 收尾，不发请求；避免后端按
    // 「无关键字」语义返回全量列表把搜索结果污染掉。
    if (keyword.isEmpty) {
      state.postCardList = <PostCardData>[];
      state.hasMore = false;
      state.pullRefreshController.requestSuccess(
        isFirstPageNum: true,
        hasMore: false,
        isEmpty: true,
      );
      update();
      return;
    }

    EventTrackingManager().addTagsDatas(keyword);

    // 注意：这里不再调用 `pullRefreshController.requesting()`。
    // `PullRefreshView` 用 `Visibility` 在 REQUESTING 时把 `SmartRefresher` 整个
    // 卸载（默认 maintainState=false），下次切回 REQUEST_SUCCESS 时滚动位置会
    // 重置到顶部，导致「上拉加载下一页」看起来像「刷新回到第一页」。
    // 首屏菊花走 controller 的初始状态；下拉刷新 / 上拉加载分别由 header /
    // footer 自己的指示器展示，无需在这里强切到 REQUESTING。
    try {
      final PostingListPage? data = await CircleApi.getPostingList(
        PostingListQuery(
          page: page,
          pageSize: _pageSize,
          keyword: keyword,
          sortType: PostSortType.newest,
        ),
      );

      if (data == null) {
        if (!isFirstPage && state.pageNum > 1) state.pageNum -= 1;
        state.pullRefreshController.requestFail(isFirstPageNum: isFirstPage);
        update();
        return;
      }

      state.postCardList = replace
          ? List<PostCardData>.from(data.list)
          : <PostCardData>[...state.postCardList, ...data.list];
      state.hasMore = data.hasNextPage;

      state.pullRefreshController.requestSuccess(
        isFirstPageNum: isFirstPage,
        hasMore: state.hasMore,
        isEmpty: state.postCardList.isEmpty,
      );
      update();
    } catch (e, st) {
      debugPrint('post search page=$page error: $e\n$st');
      if (!isFirstPage && state.pageNum > 1) state.pageNum -= 1;
      state.pullRefreshController.requestFail(isFirstPageNum: isFirstPage);
      update();
    }
  }
}
