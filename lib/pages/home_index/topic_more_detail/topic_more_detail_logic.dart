import 'package:comics_app/common/apis/home_apis.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/entities/pagination_model.dart';
import 'package:comics_app/common/entities/video_model/video_model.dart';
import 'package:comics_app/common/widgets/item/home_topic_widget.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:get/get.dart';

import 'topic_more_detail_state.dart';

class TopicMoreDetailLogic extends GetxController {
  final TopicMoreDetailState state = TopicMoreDetailState();

  @override
  void onInit() {
    super.onInit();
    _parseArguments();
    // 初次进入只触发默认 tab（[state.filterTabIndex] = 0）的首屏拉取；
    // 其余 tab 的首屏在 [setFilterTab] 切到它们时再按需触发。
    //
    // 注：[TopicMoreDetailBinding] 会按 [TopicMoreDetailRoute] 注入的 tag
    // 给每次 push 注册一份**独立**的 logic 实例，因此本方法只需做单纯的
    // 「初始化」，不再需要兼容「同实例 + 新参数」的复用场景。
    onRefreshTab(state.filterTabIndex);
  }

  void _parseArguments() {
    final raw = Get.arguments;
    if (raw is Map) {
      final id = raw['topicId'];
      if (id is int) {
        state.topicId = id;
      } else if (id != null) {
        state.topicId = int.tryParse(id.toString()) ?? 0;
      }
      final name = raw['topicName'];
      if (name != null) {
        state.topicName = name.toString();
      }
      if (raw['keywordType'] is int) {
        state.keywordType = raw['keywordType'] as int;
      }
      if (raw['videoType'] is int) {
        state.videoType = raw['videoType'] as int;
      }
    }
  }

  /// 下拉刷新**指定 tab**：把该 tab 页码归 1 后请求第一页。
  ///
  /// view 层每个 [PullRefreshView] 都会用自己的 tabIndex 绑定一份回调，
  /// 这样左右切 tab 时各自的下拉/上拉触发不会互相串数据；不再依赖
  /// [state.filterTabIndex]，避免「切 tab 瞬间 filterTabIndex 还未更新」
  /// 导致错位写回。
  void onRefreshTab(int tabIndex) {
    if (tabIndex < 0 || tabIndex >= TopicMoreDetailState.filterTabs.length) {
      return;
    }
    state.tabPageNumbers[tabIndex] = 1;
    _getDataForTab(tabIndex);
  }

  /// 上拉加载**指定 tab**：把该 tab 页码 +1 后请求下一页。
  void onLoadTab(int tabIndex) {
    if (tabIndex < 0 || tabIndex >= TopicMoreDetailState.filterTabs.length) {
      return;
    }
    state.tabPageNumbers[tabIndex] += 1;
    _getDataForTab(tabIndex);
  }

  void setFilterTab(int index) {
    if (index < 0 || index >= TopicMoreDetailState.filterTabs.length) return;
    if (state.filterTabIndex == index) return;
    state.filterTabIndex = index;
    // 切 tab 不再清空列表 —— 每个 tab 各自管理 [tabVideoItems] / [tabPageNumbers]：
    // - 已加载过的 tab：直接展示原有数据 + 滚动位置（[PageStorageKey] 维持），
    //   不发请求；
    // - 没加载过的 tab：把它的状态切到「请求中」，让页面级 loading 接管，并触发
    //   首次拉取。
    if (state.tabLoaded[index]) {
      update();
    } else {
      state.tabPullRefreshControllers[index].requesting();
      update();
      onRefreshTab(index);
    }
  }

  @override
  void onClose() {
    // [PullRefreshController] 内部持有 `RefreshController` + `ValueNotifier`，
    // 必须在 logic 销毁时主动释放；否则下次进入页面新建的 SmartRefresher 复用
    // 旧实例会触发 `Don't use one refreshController to multiple SmartRefresher`
    // 断言，并造成持续的内存 / 监听泄漏。
    for (final c in state.tabPullRefreshControllers) {
      c.dispose();
    }
    state.pullRefreshController.dispose();
    super.onClose();
  }

  /// 拉取**指定 tab** 当前页码下的数据。
  ///
  /// 全程以入参 [tabIndex] 驱动（sortType / pageNumber / pullController /
  /// 回写位置都来自该 tab），与 [state.filterTabIndex] 解耦：即便 await
  /// 期间用户切了 tab，结果也只会落回它自己的 [tabVideoItems][tabIndex]，
  /// 不会污染其他 tab。
  Future<void> _getDataForTab(int tabIndex) async {
    final int sortType = TopicMoreDetailState.sortTypes[tabIndex];
    final int pageNumber = state.tabPageNumbers[tabIndex];
    final PullRefreshController controller =
        state.tabPullRefreshControllers[tabIndex];

    if (state.topicId <= 0 && state.keywordType != 1) {
      controller.requestFail(isFirstPageNum: true);
      update();
      return;
    }
    try {
      final List<MediaVideoModel> list = await _fetchMediaList(
        sortType: sortType,
        pageNumber: pageNumber,
      );
      final bool isFirstPage = pageNumber == 1;
      if (isFirstPage) {
        state.tabVideoItems[tabIndex] = list;
      } else {
        state.tabVideoItems[tabIndex] = <MediaVideoModel>[
          ...state.tabVideoItems[tabIndex],
          ...list,
        ];
      }
      state.tabLoaded[tabIndex] = true;
      final bool hasMore = list.length >= state.pageSize;
      final bool isEmpty = state.tabVideoItems[tabIndex].isEmpty;
      controller.requestSuccess(
        isFirstPageNum: isFirstPage,
        hasMore: hasMore,
        isEmpty: isEmpty,
      );
      update();
    } catch (_) {
      controller.requestFail(isFirstPageNum: pageNumber == 1);
      update();
    }
  }

  /// 列表/翻页统一的 [HomeApis.getHomeMediaList] 调用，封装 [_parseArguments]
  /// 解析出的 `topicId / keyword / videoType / keywordType` 入参组合，避免
  /// [getData] 与 [_shortVideoProvider] 各写一份导致后续维护错位。
  Future<List<MediaVideoModel>> _fetchMediaList({
    required int sortType,
    required int pageNumber,
  }) {
    return HomeApis.getHomeMediaList(
      groupIds: state.keywordType == 1 ? null : state.topicId,
      sortType: sortType,
      pageNumber: pageNumber,
      pageSize: state.pageSize,
      keyword: state.keywordType == 1 ? state.topicName : null,
      videoType: state.videoType,
      keywordType: state.keywordType,
    );
  }

  /// 短视频流播放页（[ShortVideoPlayPage]）底部接力翻页时回调。
  ///
  /// 与列表 [getData] 共用同一份 `tabVideoItems[tabIndex] / tabPageNumbers[tabIndex]`：
  /// - 翻出来的新数据**回写**到对应 tab，关闭播放页回到列表可以直接看到新增项；
  /// - [tabIndex] 在 [navigateToShortPlay] 调用时锁定，避免播放期间用户在列表
  ///   切了 tab 导致翻页错位；
  /// - 接口失败时回滚 `pageNumber`，与 [user_center] 短视频 provider 行为一致。
  Future<PaginationModel<VideoModel>> _shortVideoProvider(int tabIndex) async {
    final int sortType = TopicMoreDetailState.sortTypes[tabIndex];
    state.tabPageNumbers[tabIndex] += 1;
    try {
      final List<MediaVideoModel> list = await _fetchMediaList(
        sortType: sortType,
        pageNumber: state.tabPageNumbers[tabIndex],
      );
      final bool hasNext = list.length >= state.pageSize;
      state.tabVideoItems[tabIndex] = <MediaVideoModel>[
        ...state.tabVideoItems[tabIndex],
        ...list,
      ];
      update();
      return PaginationModel<VideoModel>(
        list: list.map(videoModelFromHomeMedia).toList(),
        hasNext: hasNext,
      );
    } catch (e) {
      if (state.tabPageNumbers[tabIndex] > 1) {
        state.tabPageNumbers[tabIndex] -= 1;
      }
      rethrow;
    }
  }

  /// 点击列表项跳入短视频流播放页（仅 `videoType == 1` 调用）。
  ///
  /// 使用当前 tab 的 list 作为初始队列、当前 tab 的 sortType 作为后续翻页
  /// 规则；非短视频（`videoType == 0/2`）路径仍由
  /// [home_video_list_widgets.getFourGrid] 默认的 [jumpMediaPlayByModel]
  /// 处理，本方法不接管。
  void navigateToShortPlay(int index) {
    final int tabIndex = state.filterTabIndex;
    jumpShortMediaPlay(
      mediaList: state.tabVideoItems[tabIndex],
      index: index,
      videoProvider: () => _shortVideoProvider(tabIndex),
    );
  }
}
