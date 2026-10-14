import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/entities/pagination_model.dart';
import 'package:comics_app/common/entities/video_model/video_model.dart';
import 'package:comics_app/common/widgets/item/home_topic_widget.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/foundation.dart';

import 'mine_media_list_base_logic.dart';

export 'mine_media_list_base_logic.dart';

/// 「单页拉到的数据 + 是否还有下一页」 的统一返回结构。
///
/// 子类在 [MineMediaPagedListBaseLogic.fetchPageChunk] 内部把数据 append/replace
/// 到对应数组后，用这个结构告知基类：
/// - [appendedCount]：本次接口实际拉到 / 写入列表的条数；
/// - [hasMore]：是否还有下一页（默认推荐 `appendedCount >= pageSize`，
///   特殊场景如「帖子 Tab 占位调用」可显式传 false 短路）。
@immutable
class MineMediaPageResult {
  const MineMediaPageResult({
    required this.appendedCount,
    required this.hasMore,
  });

  final int appendedCount;
  final bool hasMore;
}

/// 「我的收藏 / 我的购买 / 我的喜欢」共用的分页 + 视频点击模板。
///
/// 与 [MineMediaListBaseLogic] 的区别：
/// - **统一管理每个 Tab 的 [PullRefreshController] / 页码 / hasMore 游标**
///   ——子类不再自己维护 `pullRefreshControllers / _pagePerTab / _hasMorePerTab`，
///   也不再各写一份相似度极高的 `loadTab / onMineListRefresh / onMineListLoadMore`。
/// - **统一管理 [onClose] 时 [PullRefreshController.dispose]** —— 修了之前三个
///   子类都漏 dispose、下次进页 SmartRefresher 复用旧 controller 会触发断言的
///   潜在隐患。
/// - **统一实现视频点击**：长视频走 [jumpMediaPlayByModel]、抖音走
///   [jumpShortMediaPlay] 并把 [_shortVideoProvider] 接到播放页底部翻页 ——
///   播放页翻出来的新数据会**自动 append 回 [shortVideoItems]**，回到列表
///   直接可见，与 user_center / topic_more_detail 行为一致。
/// - **统一以模板方法委托 [fetchPageChunk]** —— 子类只需实现一个方法：
///   描述「指定 tab + page 调哪个接口、把 chunk append/replace 进哪个数组、
///   这一页是否还有下一页」，列表分页与播放页接力分页共用同一份实现。
///
/// 历史记录页（[MineHistoryRecordLogic]）走本地数据 + 单 id 跳转的另一种范式，
/// 仍直接继承 [MineMediaListBaseLogic]，不走本模板。
abstract class MineMediaPagedListBaseLogic extends MineMediaListBaseLogic {
  /// 每页大小，子类可覆写。
  int get pageSize => 10;

  /// 与 [tabs] 等长，每个 tab 一份分页控制器。
  late final List<PullRefreshController> pullRefreshControllers;

  late final List<int> _pagePerTab;
  late final List<bool> _hasMorePerTab;

  // -------------------- 模板方法（子类必须实现） --------------------

  /// 拉取指定 tab 的第 [page] 页数据并写入对应数组。
  ///
  /// 实现要点：
  /// - 按 `tabs[tabIndex].kind` 决定调哪个接口；
  /// - `replace == true` 时整段替换该 tab 的数据数组，否则 append；
  /// - **必须**把结果写入基类的 `longVideoItems / shortVideoItems / postItems`
  ///   等数组（基类不做这件事）；
  /// - 返回 [MineMediaPageResult]：`appendedCount` 通常为接口返回的 chunk 长度，
  ///   `hasMore` 通常为 `chunk.length >= pageSize`，但允许子类按业务自定义
  ///   （如帖子 Tab 占位调用时可直接返回 `hasMore: false`）；
  /// - **不需要**触发 [update] 或调 [PullRefreshController]，模板方法会接管；
  /// - 抛异常会被模板方法捕获 → [PullRefreshController.requestFail]。
  Future<MineMediaPageResult> fetchPageChunk(
    int tabIndex,
    int page, {
    required bool replace,
  });

  // -------------------- 基类钩子覆写 --------------------

  @override
  bool get supportsPullRefresh => true;

  @override
  PullRefreshController? pullRefreshForTab(int tabIndex) =>
      pullRefreshControllers[tabIndex];

  @override
  void onInit() {
    pullRefreshControllers = List<PullRefreshController>.generate(
      tabs.length,
      (_) => PullRefreshController(),
    );
    _pagePerTab = List<int>.filled(tabs.length, 1, growable: false);
    _hasMorePerTab = List<bool>.filled(tabs.length, true, growable: false);
    super.onInit();
  }

  @override
  void onClose() {
    for (final c in pullRefreshControllers) {
      c.dispose();
    }
    super.onClose();
  }

  @override
  Future<void> loadTab(int i) async {
    pullRefreshControllers[i].requesting();
    await _requestTab(i, replace: true);
  }

  @override
  Future<void> fetchTabData(int tabIndex) async {
    await _requestTab(tabIndex, replace: true);
  }

  @override
  Future<void> onMineListRefresh(int tabIndex) async {
    _pagePerTab[tabIndex] = 1;
    _hasMorePerTab[tabIndex] = true;
    pullRefreshControllers[tabIndex].requesting();
    await _requestTab(tabIndex, replace: true);
  }

  @override
  Future<void> onMineListLoadMore(int tabIndex) async {
    if (!_hasMorePerTab[tabIndex]) {
      pullRefreshControllers[tabIndex].requestSuccess(
        isFirstPageNum: false,
        hasMore: false,
      );
      return;
    }
    _pagePerTab[tabIndex]++;
    await _requestTab(tabIndex, replace: false);
  }

  Future<void> _requestTab(
    int tabIndex, {
    required bool replace,
  }) async {
    final int page = _pagePerTab[tabIndex];
    final bool isFirstPage = page == 1;
    final PullRefreshController pr = pullRefreshControllers[tabIndex];
    try {
      final MineMediaPageResult result =
          await fetchPageChunk(tabIndex, page, replace: replace);
      _hasMorePerTab[tabIndex] = result.hasMore;
      pr.requestSuccess(
        isFirstPageNum: isFirstPage,
        hasMore: result.hasMore,
        isEmpty: itemCountForTab(tabIndex) == 0,
      );
    } catch (e, st) {
      debugPrint('mine paged tab=$tabIndex page=$page error: $e\n$st');
      pr.requestFail(isFirstPageNum: isFirstPage);
    }
    update();
  }

  // -------------------- 视频点击（默认按 Tab 类型分发） --------------------

  /// 影片 Tab 点击 → 走 [jumpMediaPlayByModel] 自动落到长视频详情页。
  @override
  void onLongVideoItemTap(int tabIndex, int itemIndex) {
    if (itemIndex < 0 || itemIndex >= longVideoItems.length) return;
    jumpMediaPlayByModel(longVideoItems[itemIndex]);
  }

  /// 抖音 Tab 点击 → 走垂直滑动播放页 [jumpShortMediaPlay]。
  ///
  /// 传入整份 [shortVideoItems] + 命中 [itemIndex] 为起播位置，
  /// `videoProvider` 接到 [_shortVideoProvider] 让播放页底部接力翻页继续走
  /// 子类对应接口；翻出来的新数据会 append 回 [shortVideoItems]，
  /// 回到列表后直接可见。
  @override
  void onShortVideoItemTap(int tabIndex, int itemIndex) {
    if (itemIndex < 0 || itemIndex >= shortVideoItems.length) return;
    jumpShortMediaPlay(
      mediaList: shortVideoItems,
      index: itemIndex,
      videoProvider: () => _shortVideoProvider(tabIndex),
    );
  }

  /// 抖音播放页底部翻页 provider。
  ///
  /// 与列表分页**共用同一份** [_pagePerTab] / [_hasMorePerTab] 游标，从而：
  /// - 播放页翻出来的新数据写到 [shortVideoItems]，列表与播放页共享一份数据；
  /// - 列表上拉时不会跳页 / 漏页（页码连续）；
  /// - **不**直接触发 [pullRefreshControllers] 状态：列表 footer 状态由用户
  ///   实际上拉时 [_requestTab] 内 `requestSuccess(hasMore: ...)` 接管，
  ///   两条路径互不污染；
  /// - 失败时回滚 `_pagePerTab[tabIndex]`，避免下次列表上拉时跳页。
  Future<PaginationModel<VideoModel>> _shortVideoProvider(int tabIndex) async {
    if (!_hasMorePerTab[tabIndex]) {
      return PaginationModel<VideoModel>(
        list: <VideoModel>[],
        hasNext: false,
      );
    }
    final int priorLen = shortVideoItems.length;
    _pagePerTab[tabIndex]++;
    try {
      final MineMediaPageResult result = await fetchPageChunk(
        tabIndex,
        _pagePerTab[tabIndex],
        replace: false,
      );
      _hasMorePerTab[tabIndex] = result.hasMore;
      // 取出本次新 append 的尾段（子类已把 chunk 写入 shortVideoItems）；
      // 不直接用 `result.appendedCount` 截取，而以列表长度 diff 兜底，
      // 避免子类把多余数据写到别处时这里崩。
      final List<MediaVideoModel> newSlice = shortVideoItems.length > priorLen
          ? shortVideoItems.sublist(priorLen)
          : const <MediaVideoModel>[];
      update();
      return PaginationModel<VideoModel>(
        list: newSlice.map(videoModelFromHomeMedia).toList(),
        hasNext: result.hasMore,
      );
    } catch (e, st) {
      debugPrint('mine paged short provider tab=$tabIndex error: $e\n$st');
      if (_pagePerTab[tabIndex] > 1) {
        _pagePerTab[tabIndex]--;
      }
      rethrow;
    }
  }
}
