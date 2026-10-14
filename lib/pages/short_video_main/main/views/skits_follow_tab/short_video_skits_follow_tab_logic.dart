import 'package:comics_app/common/apis/media_api.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/entities/pagination_model.dart';
import 'package:comics_app/common/entities/video_model/short_recommend_follow_model.dart';
import 'package:comics_app/common/entities/video_model/video_model.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/widgets/item/home_topic_widget.dart';
import 'package:get/get.dart';

import 'short_video_skits_follow_tab_state.dart';

/// 短剧/短视频「我的关注」Tab。
///
/// 双数据源：
/// - [MediaApi.getShortFollowsList]：我关注的作者聚合短视频流（主数据，命中即展示
///   四宫格，支持分页）；
/// - [MediaApi.getShortRecommendFollowsList]：推荐作者列表（兜底，首屏关注为空
///   时展示，**不分页**，下拉刷新即拿全量；点关注成功后回去刷主数据）。
///
/// 两个接口共用同一份 [ShortVideoSkitsFollowTabState.pullRefreshController]：
/// - `onRefresh` 永远先拉关注，空了再回落推荐；
/// - `onLoad` 只在关注模式下翻页；推荐模式视为「不可加载更多」。
class ShortVideoSkitsFollowTabLogic extends GetxController {
  ShortVideoSkitsFollowTabLogic({this.module, this.moduleSort});

  final ModuleModel? module;

  final int? moduleSort;

  final state = ShortVideoSkitsFollowTabState();

  @override
  void onInit() {
    super.onInit();
    onRefresh();
  }

  void onRefresh() {
    state.pageNumber = 1;
    _refreshFollow();
  }

  void onLoad() {
    // 推荐模式下不分页；这里直接给 PullRefreshView 一个「无更多」的回调，
    // 让上拉动效自然回弹，而不是去打第二次请求。
    if (state.isShowRecommend) {
      state.pullRefreshController.requestSuccess(
        isFirstPageNum: false,
        hasMore: false,
      );
      return;
    }
    state.pageNumber += 1;
    _loadMoreFollow();
  }

  // ---------------------------------------------------------------------------
  // 关注列表
  // ---------------------------------------------------------------------------

  /// 拉关注列表第一页。空 → 自动回落推荐；非空 → 切回关注模式并清空推荐。
  Future<void> _refreshFollow() async {
    try {
      final list = await MediaApi.getShortFollowsList(
        page: 1,
        pageSize: ShortVideoSkitsFollowTabState.pageSize,
      );
      state.mediaList = list;
      if (list.isNotEmpty) {
        state.isShowRecommend = false;
        state.recommendList = const [];
        state.pullRefreshController.requestSuccess(
          isFirstPageNum: true,
          hasMore: list.length >= ShortVideoSkitsFollowTabState.pageSize,
          isEmpty: false,
        );
        update(['list']);
      } else {
        // 关注为空 → 拉推荐
        await _refreshRecommend();
      }
    } catch (_) {
      state.pullRefreshController.requestFail(isFirstPageNum: true);
    }
  }

  Future<void> _loadMoreFollow() async {
    try {
      final list = await MediaApi.getShortFollowsList(
        page: state.pageNumber,
        pageSize: ShortVideoSkitsFollowTabState.pageSize,
      );
      state.mediaList = <MediaVideoModel>[
        ...?state.mediaList,
        ...list,
      ];
      state.pullRefreshController.requestSuccess(
        isFirstPageNum: false,
        hasMore: list.length >= ShortVideoSkitsFollowTabState.pageSize,
      );
      update(['list']);
    } catch (_) {
      if (state.pageNumber > 1) state.pageNumber -= 1;
      state.pullRefreshController.requestFail(isFirstPageNum: false);
    }
  }

  // ---------------------------------------------------------------------------
  // 推荐列表
  // ---------------------------------------------------------------------------

  /// 推荐作者列表不分页：每次都是全量结果，没有 loadMore。
  Future<void> _refreshRecommend() async {
    try {
      final list = await MediaApi.getShortRecommendFollowsList();
      state.recommendList = list;
      state.isShowRecommend = true;
      state.pullRefreshController.requestSuccess(
        isFirstPageNum: true,
        hasMore: false,
        // 推荐也为空 → 让 PullRefreshView 走「真正空」态。
        isEmpty: list.isEmpty,
      );
      update(['list']);
    } catch (_) {
      state.pullRefreshController.requestFail(isFirstPageNum: true);
    }
  }

  // ---------------------------------------------------------------------------
  // 关注 / 取关切换（推荐作者卡的按钮）
  // ---------------------------------------------------------------------------

  bool isFollowPending(int uid) => state.pendingFollowUids.contains(uid);

  /// 关注接口成功后，等待后端关注关系入库的延迟时长。
  ///
  /// 后端关注 / 取关接口返回成功后，关注关系到主列表（`getShortFollowsList`）
  /// 落库可能存在轻微延迟；如果立刻拉主列表，新关注的作者短视频往往还没来。
  /// 这里固定等待 2 秒再刷新，期间按钮文案显示「加载中」给用户即时反馈。
  static const Duration _followRefreshDelay = Duration(seconds: 2);

  bool _isClosed = false;

  @override
  void onClose() {
    _isClosed = true;
    super.onClose();
  }

  /// 点推荐作者卡上的「+关注 / 已关注」按钮。
  ///
  /// 关注 / 取关成功后会等待 [_followRefreshDelay] 再触发 [onRefresh]：
  /// - 等待期间 `pendingFollowUids` 仍包含 uid，按钮显示「加载中」并禁用点击；
  /// - 若关注列表后端已经能拉到这位作者的视频聚合 → 视图自动切到四宫格关注流；
  /// - 否则继续展示推荐列表，但当前作者按钮已就地翻成「已关注」。
  Future<void> toggleFollow(ShortRecommendFollowItemModel item) async {
    final RecommendFollowAuthorModel? author = item.author;
    final int uid = author?.id ?? item.uid ?? 0;
    if (uid <= 0) {
      showToast(msg: '用户信息错误');
      return;
    }
    if (state.pendingFollowUids.contains(uid)) return;
    state.pendingFollowUids.add(uid);
    update(['follow_$uid']);

    final bool prev = author?.follow ?? false;
    try {
      final BaseRespBean resp = prev
          ? await MediaApi.onCancleFocus(uid)
          : await MediaApi.onFocus(uid);
      if (resp.isSuccess) {
        author?.follow = !prev;
        showToast(msg: !prev ? '关注成功' : '取消关注');
        // 接口成功 → 等 2s 让后端关注关系生效再刷新主列表；
        // 期间 pendingFollowUids 仍含 uid，按钮显示「加载中」并保持禁用。
        await Future.delayed(_followRefreshDelay);
        if (_isClosed) return;
        // 关注 / 取关都触发主列表刷新：
        // - 关注成功 → 关注列表可能立即有数据，切到四宫格；
        // - 取关 → 同样可能影响列表（兼容服务端语义）。
        onRefresh();
      } else {
        showToast(msg: resp.tip ?? (prev ? '取消关注失败' : '关注失败'));
      }
    } catch (_) {
      showToast(msg: '网络异常，请稍后重试');
    } finally {
      state.pendingFollowUids.remove(uid);
      if (!_isClosed) update(['follow_$uid']);
    }
  }

  // ---------------------------------------------------------------------------
  // 跳转
  // ---------------------------------------------------------------------------

  /// 短视频流播放页底部接力翻页回调（仅用于关注列表模式，推荐卡片各自跳转）。
  Future<PaginationModel<VideoModel>> _shortVideoProvider() async {
    state.pageNumber += 1;
    try {
      final list = await MediaApi.getShortFollowsList(
        page: state.pageNumber,
        pageSize: ShortVideoSkitsFollowTabState.pageSize,
      );
      final bool hasNext =
          list.length >= ShortVideoSkitsFollowTabState.pageSize;
      state.mediaList = <MediaVideoModel>[
        ...?state.mediaList,
        ...list,
      ];
      update(['list']);
      return PaginationModel<VideoModel>(
        list: list.map(videoModelFromHomeMedia).toList(),
        hasNext: hasNext,
      );
    } catch (_) {
      if (state.pageNumber > 1) state.pageNumber -= 1;
      rethrow;
    }
  }

  /// 点关注列表四宫格里的某一项。
  void navigateToPlayPage(int index) {
    final list = state.mediaList;
    if (list == null || list.isEmpty) return;
    jumpShortMediaPlay(
      mediaList: list,
      index: index,
      videoProvider: _shortVideoProvider,
    );
  }

  /// 点推荐卡里某位作者的某条视频：把这位作者的代表作整组送进短视频流。
  void navigateToRecommendPlay(
    ShortRecommendFollowItemModel item,
    int videoIndex,
  ) {
    if (item.videos.isEmpty) return;
    final int idx = videoIndex.clamp(0, item.videos.length - 1);
    jumpShortMediaPlay(
      mediaList: item.videos,
      index: idx,
    );
  }
}
