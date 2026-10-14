import 'package:comics_app/common/apis/circle_api.dart';
import 'package:comics_app/common/apis/home_apis.dart';
import 'package:comics_app/common/apis/media_api.dart';
import 'package:comics_app/common/entities/circle/posting_list_models.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/entities/media_info.dart';
import 'package:comics_app/common/entities/pagination_model.dart';
import 'package:comics_app/common/entities/user_info_model_entity.dart';
import 'package:comics_app/common/entities/video_model/video_model.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/tab_controller_dispose.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/widgets/item/home_topic_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'state.dart';

class UserCenterLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  final UserCenterState state = UserCenterState();

  UserInfoModelEntity? get myInfo => UserStore.to.getUserInfoModel;

  bool get isMe => myInfo?.uid == state.uid;

  bool get isFollow => state.userInfo?.follow ?? false;

  @override
  void onInit() {
    super.onInit();
    final dynamic arg = Get.arguments;
    Map<String, dynamic>? map;
    if (arg is Map) {
      map = Map<String, dynamic>.from(arg);
    }
    state.uid = _toInt(map?['uid']) ?? _toInt(arg) ?? myInfo?.uid ?? 0;

    _applyAuthor(map?['author']);

    state.tabController = TabController(length: state.tabs.length, vsync: this);
    state.tabController.addListener(_onTabChanged);

    // 首屏默认展示「影片」Tab，先拉影片，「抖音」延迟到 Tab 切换时再请求。
    onRefreshMovies();
  }

  void _onTabChanged() {
    if (state.tabController.indexIsChanging) return;
    final int index = state.tabController.index;
    if (index == 1 && !state.shortsLoaded) {
      state.shortsLoaded = true;
      onRefreshShorts();
    } else if (index == 2 && !state.postsLoaded) {
      state.postsLoaded = true;
      // 进入帖子 Tab 时切到「请求中」遮罩，避免先短暂闪过空态。
      state.postPullRefresh.requesting();
      onRefreshPosts();
    }
  }

  /// 入口（长 / 短视频）跳转时携带的 `author`：直接当作详情数据使用，
  /// 用户中心不再额外请求 `/user/profile`，关注 / 取关后原地更新该对象。
  ///
  /// 与详情接口 `result.author` 字段一致，因此直接交给 [MediaInfoAuthor.fromJson]
  /// 反序列化；缺 `id` 时回填外层 `uid` 做兜底，避免后续关注接口拿不到 star 参数。
  void _applyAuthor(dynamic raw) {
    final Map<String, dynamic> m =
        raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    if (m['id'] == null) m['id'] = state.uid;
    final MediaInfoAuthor author = MediaInfoAuthor.fromJson(m);
    state.userInfo = author;
    state.initialFollow = author.follow ?? false;
  }

  // ----- 影片 -----

  Future<void> onRefreshMovies() async {
    state.moviePage = 1;
    await _loadVideos(videoType: 0, isRefresh: true);
  }

  Future<void> onLoadMoreMovies() async {
    state.moviePage++;
    await _loadVideos(videoType: 0, isRefresh: false);
  }

  // ----- 抖音 -----

  Future<void> onRefreshShorts() async {
    state.shortPage = 1;
    await _loadVideos(videoType: 1, isRefresh: true);
  }

  Future<void> onLoadMoreShorts() async {
    state.shortPage++;
    await _loadVideos(videoType: 1, isRefresh: false);
  }

  /// 抖音流的「上滑加载更多」provider：传给 [jumpShortMediaPlay] 让
  /// [ShortVideoPlayPage] 触底时按本用户作品继续翻页。
  ///
  /// 与 [_loadVideos] 同源（[HomeApis.getHomeMediaList] + uid + videoType=1），
  /// 新增数据会回写 [UserCenterState.shortList]，保持本页 Tab 列表与播放页
  /// 的可见数据同步；失败时回滚 [UserCenterState.shortPage] 并继续抛出，由
  /// 播放页自行处理失败 toast。
  Future<PaginationModel<VideoModel>> _shortVideoProvider() async {
    state.shortPage++;
    try {
      final List<MediaVideoModel> list = await HomeApis.getHomeMediaList(
        uid: state.uid,
        videoType: 1,
        pageNumber: state.shortPage,
        pageSize: state.pageSize,
      );
      final bool hasNext = list.length >= state.pageSize;
      state.shortList = <MediaVideoModel>[...state.shortList, ...list];
      update();
      return PaginationModel<VideoModel>(
        list: list.map(videoModelFromHomeMedia).toList(),
        hasNext: hasNext,
      );
    } catch (e) {
      if (state.shortPage > 1) state.shortPage--;
      rethrow;
    }
  }

  /// 抖音 Tab item 点击：走通用封装 [jumpShortMediaPlay]，把当前列表 +
  /// index + 分页 provider 一起传进去，进 [ShortVideoPlayPage] 后即可上下
  /// 滑切集，并按需懒加载下一页。
  void navigateToShortPlay(int index) {
    jumpShortMediaPlay(
      mediaList: state.shortList,
      index: index,
      videoProvider: _shortVideoProvider,
    );
  }

  Future<void> _loadVideos({
    required int videoType,
    required bool isRefresh,
  }) async {
    final controller =
        videoType == 1 ? state.shortPullRefresh : state.moviePullRefresh;
    final page = videoType == 1 ? state.shortPage : state.moviePage;
    try {
      final List<MediaVideoModel> list = await HomeApis.getHomeMediaList(
        uid: state.uid,
        videoType: videoType,
        pageNumber: page,
        pageSize: state.pageSize,
      );
      if (videoType == 1) {
        state.shortList =
            isRefresh ? list : <MediaVideoModel>[...state.shortList, ...list];
      } else {
        state.movieList =
            isRefresh ? list : <MediaVideoModel>[...state.movieList, ...list];
      }
      final bool hasMore = list.length >= state.pageSize;
      final bool isEmpty =
          videoType == 1 ? state.shortList.isEmpty : state.movieList.isEmpty;
      controller.requestSuccess(
        isFirstPageNum: page == 1,
        hasMore: hasMore,
        isEmpty: isEmpty,
      );
      update();
    } catch (_) {
      // 加载更多失败时回滚页码，避免下次再加载漏掉这一页。
      if (!isRefresh) {
        if (videoType == 1 && state.shortPage > 1) {
          state.shortPage--;
        } else if (videoType == 0 && state.moviePage > 1) {
          state.moviePage--;
        }
      }
      controller.requestFail(isFirstPageNum: page == 1);
      update();
    }
  }

  // ----- 帖子 -----

  Future<void> onRefreshPosts() async {
    state.postPage = 1;
    await _loadPosts(isRefresh: true);
  }

  Future<void> onLoadMorePosts() async {
    state.postPage++;
    await _loadPosts(isRefresh: false);
  }

  /// 拉取当前用户（[UserCenterState.uid]）的帖子列表。
  ///
  /// 与 [_loadVideos] 的分页/回滚策略保持一致：加载更多失败时回滚 [state.postPage]
  /// 避免下次再加载漏页；列表为空时下沉到 PullRefreshView 的空态占位。
  Future<void> _loadPosts({required bool isRefresh}) async {
    final controller = state.postPullRefresh;
    final int page = state.postPage;
    final PostingListQuery query = PostingListQuery(
        page: page,
        pageSize: state.pageSize,
        uid: state.uid,
        // uid: 941,
        sortType: PostSortType.newest);
    final PostingListPage? result = await CircleApi.getPostingList(query);
    if (result == null) {
      if (!isRefresh && state.postPage > 1) state.postPage--;
      controller.requestFail(isFirstPageNum: page == 1);
      update();
      return;
    }
    state.postList = isRefresh
        ? List<PostCardData>.from(result.list)
        : <PostCardData>[...state.postList, ...result.list];
    controller.requestSuccess(
      isFirstPageNum: page == 1,
      hasMore: result.hasNextPage,
      isEmpty: state.postList.isEmpty,
    );
    update();
  }

  Future<void> toggleFollow() async {
    final user = state.userInfo;
    final int? star = user?.id;
    if (user == null ||
        star == null ||
        star <= 0 ||
        isMe ||
        state.isFollowLoading) {
      return;
    }
    state.isFollowLoading = true;
    update();
    try {
      final bool next = !isFollow;
      final BaseRespBean resp = next
          ? await MediaApi.onFocus(star)
          : await MediaApi.onCancleFocus(star);
      if (resp.isSuccess) {
        user.follow = next;
        final int prevFans = user.fansNum ?? 0;
        user.fansNum = next ? prevFans + 1 : (prevFans > 0 ? prevFans - 1 : 0);
        showToast(msg: next ? '关注成功' : '取消关注');
      } else {
        showToast(msg: resp.tip ?? (next ? '关注失败' : '取消关注失败'));
      }
    } catch (e) {
      showToast(msg: e.toString());
    }
    state.isFollowLoading = false;
    update();
  }

  /// 构造返回上一页的回调 payload：仅当本次进入产生过变化时才携带 `isFollow`，
  /// 保证入口侧可以判定「是否要刷新关注按钮 / 粉丝数」。
  Map<String, dynamic> buildPopResult() {
    final user = state.userInfo;
    return <String, dynamic>{
      'uid': state.uid,
      if (user?.follow != null) 'isFollow': user!.follow,
      if (user?.fansNum != null) 'fansNum': user!.fansNum,
      'changed': state.initialFollow != (user?.follow ?? false),
    };
  }

  void popWithResult() {
    Get.back(result: buildPopResult());
  }

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  @override
  void onClose() {
    state.tabController.removeListener(_onTabChanged);
    disposeTabControllerAfterRouteExit(state.tabController);
    // 释放三个 Tab 的 RefreshController，避免下次进入相同 logic 时复用导致
    // SmartRefresher 的 _refresherState != null 断言。
    state.moviePullRefresh.dispose();
    state.shortPullRefresh.dispose();
    state.postPullRefresh.dispose();
    super.onClose();
  }
}
