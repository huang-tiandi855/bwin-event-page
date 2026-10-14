import 'package:comics_app/common/apis/circle_api.dart';
import 'package:comics_app/common/apis/home_apis.dart';
import 'package:comics_app/common/entities/circle/posting_list_models.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/entities/home/home_media_list_models_extension.dart';
import 'package:comics_app/common/entities/pagination_model.dart';
import 'package:comics_app/common/entities/video_model/video_model.dart';
import 'package:comics_app/pages/short_video_main/play/short_video_play_view.dart';
import 'package:get/get.dart';

import 'state.dart';

class SearchVideoLibraryLogic extends GetxController {
  final SearchVideoLibraryState state = SearchVideoLibraryState();

  /// 「帖子」分类对应的 typeIndex（与 [SearchVideoLibraryState.types] 顺序一致）。
  static const int _postTypeIndex = 2;

  @override
  void onInit() {
    super.onInit();
    loadHotTags();
  }

  Future<void> loadHotTags() async {
    final page = await HomeApis.getVodTagsList();
    state.tagOptions = page.list;
    update();
    onRefresh();
  }

  void selectType(int index) {
    if (state.typeIndex == index) return;
    state.typeIndex = index;
    // 切换大类时清空两份列表，避免上一种类型的内容残留出现在新分类下。
    state.videoItems = <MediaVideoModel>[];
    state.postItems = <PostCardData>[];
    onRefresh();
    update();
  }

  void selectTag(int index) {
    if (state.tagIndex == index) return;
    state.tagIndex = index;
    onRefresh();
    update();
  }

  void selectPayType(int index) {
    if (state.payIndex == index) return;
    state.payIndex = index;
    onRefresh();
    update();
  }

  void selectSort(int index) {
    if (state.sortIndex == index) return;
    state.sortIndex = index;
    onRefresh();
    update();
  }

  void onRefresh() {
    state.pageNumber = 1;
    getData();
  }

  void onLoad() {
    state.pageNumber++;
    getData();
  }

  int get _videoType => state.types[state.typeIndex].id ?? 0;

  /// 当前是否为「帖子」分类。
  bool get isPostType => state.typeIndex == _postTypeIndex;

  int? get _sortType => state.sorts[state.sortIndex].id;

  bool? get _isVip => state.payIndex == 1 ? true : null;

  int? get _gold => state.payIndex == 2 ? 1 : null;

  String? _buildTags() {
    final index = state.tagIndex;
    if (index < 0 || index >= state.tagOptions.length) return null;
    final tag = state.tagOptions[index].tag;
    if (tag == null) return null;
    return tag;
  }

  /// 「排序」筛选 → 帖子 `sortType`：现有三档（最多收藏 / 最新上架 / 最多观看）
  /// 与帖子接口枚举不完全一致，按最贴近的语义映射；最多收藏目前后端无对应项，
  /// 暂用 [PostSortType.like]（精华/点赞）兜底。
  PostSortType get _postSortType {
    switch (state.sortIndex) {
      case 0:
        return PostSortType.like;
      case 2:
        return PostSortType.view;
      case 1:
      default:
        return PostSortType.newest;
    }
  }

  Future<void> getData() async {
    if (isPostType) {
      await _getPostData();
      return;
    }
    await _getVideoData();
  }

  Future<void> _getVideoData() async {
    try {
      final tagKeyword = _buildTags();
      final List<MediaVideoModel> list = await HomeApis.getHomeMediaList(
        sortType: _sortType,
        videoType: _videoType,
        isVip: _isVip,
        gold: _gold,
        keyword: tagKeyword,
        keywordType: tagKeyword != null ? 1 : 0,
        pageNumber: state.pageNumber,
        pageSize: state.pageSize,
      );
      if (state.pageNumber == 1) {
        state.videoItems = list;
      } else {
        state.videoItems = <MediaVideoModel>[
          ...state.videoItems,
          ...list,
        ];
      }
      final bool hasMore = list.length >= state.pageSize;
      final bool isEmpty = state.videoItems.isEmpty;
      state.pullRefreshController.requestSuccess(
        isFirstPageNum: state.pageNumber == 1,
        hasMore: hasMore,
        isEmpty: isEmpty,
      );
      update();
    } catch (_) {
      state.pullRefreshController.requestFail(
        isFirstPageNum: state.pageNumber == 1,
      );
      update();
    }
  }

  /// 拉取「帖子」分类下的列表，走 [CircleApi.getPostingList]。
  ///
  /// 标签筛选透传到 `keyword`（产品规则：帖子页只保留分类 / 标签 / 排序，
  /// 「类型」筛选行在视图层针对帖子整行隐藏，所以这里也不再带 `costType`，
  /// 防止用户在视频 tab 选过的 VIP / 金币残留值反向影响帖子接口）。
  Future<void> _getPostData() async {
    final int page = state.pageNumber;
    final bool isFirstPage = page == 1;
    try {
      final tagKeyword = _buildTags();
      final PostingListPage? data = await CircleApi.getPostingList(
        PostingListQuery(
          page: page,
          hasVideo: true,
          pageSize: state.pageSize,
          sortType: _postSortType,
          keyword:
              (tagKeyword != null && tagKeyword.isNotEmpty) ? tagKeyword : null,
        ),
      );

      if (data == null) {
        state.pullRefreshController.requestFail(isFirstPageNum: isFirstPage);
        update();
        return;
      }

      if (isFirstPage) {
        state.postItems = List<PostCardData>.from(data.list);
      } else {
        state.postItems = <PostCardData>[
          ...state.postItems,
          ...data.list,
        ];
      }
      state.pullRefreshController.requestSuccess(
        isFirstPageNum: isFirstPage,
        hasMore: data.hasNextPage,
        isEmpty: state.postItems.isEmpty,
      );
      update();
    } catch (_) {
      state.pullRefreshController.requestFail(isFirstPageNum: isFirstPage);
      update();
    }
  }

  /// 「抖音」分类（`videoType == 1`）下点击单项的跳转。
  ///
  /// 进入沉浸式 [ShortVideoPlayPage]，带入当前列表与索引，并提供
  /// [_shortPlayVideoProvider] 用于继续向后翻页加载更多视频。
  void navigateToShortPlay(int index) {
    if (index < 0 || index >= state.videoItems.length) return;
    Get.to(
      () => ShortVideoPlayPage(
        videoProvider: _shortPlayVideoProvider,
        initialIndex: index,
        initialList:
            state.videoItems.map((e) => e.toShortPlayVideoModel()).toList(),
      ),
    );
  }

  /// 沉浸式播放页继续翻页的回调：复用当前筛选条件加载下一页。
  Future<PaginationModel<VideoModel>> _shortPlayVideoProvider() async {
    state.pageNumber++;
    try {
      final tagKeyword = _buildTags();
      final List<MediaVideoModel> list = await HomeApis.getHomeMediaList(
        sortType: _sortType,
        videoType: _videoType,
        isVip: _isVip,
        gold: _gold,
        keyword: tagKeyword,
        keywordType: tagKeyword != null ? 1 : 0,
        pageNumber: state.pageNumber,
        pageSize: state.pageSize,
      );
      state.videoItems = <MediaVideoModel>[
        ...state.videoItems,
        ...list,
      ];
      final bool hasMore = list.length >= state.pageSize;
      update();
      return PaginationModel<VideoModel>(
        list: list.map((e) => e.toShortPlayVideoModel()).toList(),
        hasNext: hasMore,
      );
    } catch (_) {
      rethrow;
    }
  }
}
