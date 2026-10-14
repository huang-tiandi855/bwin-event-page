import 'package:comics_app/common/apis/circle_api.dart';
import 'package:comics_app/common/entities/circle/posting_list_models.dart';
import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/utils/ads_manage/ads_banner_icon_group.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';
import 'package:comics_app/common/widgets/community_style.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/pages/circle/common/circle_category_feed_header_slivers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 社区二级分类下某一 Tab 对应的纵向滚动页（快捷入口 / 推荐 / 筛选 / 帖子）。
///
/// 布局用 [NestedScrollView] 拆成两层：
///   - [headerSliverBuilder]：广告 / 二级分类条 / 排序条，作为外层 sliver
///   - body：[PullRefreshView] 只包帖子列表
///
/// 这样下拉刷新动画、`REQUESTING` 全屏遮罩、空 / 失败占位都只落在 body 区，
/// header 永远在屏；切排序 / 切二级分类时也不会盖住顶部信息。
class CommunityCategoryFeedBody extends StatefulWidget {
  const CommunityCategoryFeedBody({
    super.key,
    required this.module,
    required this.pageStorageKey,
    this.scrollController,
  });

  /// 当前分类对应的后台模块配置；用 [ModuleModel.isShowIcon] 控制顶部
  /// banner + 双头像广告组件是否展示。
  final ModuleModel module;

  final String pageStorageKey;

  /// 供 [ScrollMetricsManager] 绑定「返回顶部」；与 [pageStorageKey] 分工保存滚动位置。
  final ScrollController? scrollController;

  @override
  State<CommunityCategoryFeedBody> createState() =>
      _CommunityCategoryFeedBodyState();
}

class _CommunityCategoryFeedBodyState extends State<CommunityCategoryFeedBody> {
  static const List<String> _feedFilters = ['推荐', '最新', '最热', '精华'];

  /// 排序条标签 → 后端 [PostSortType] 映射（与 [_feedFilters] 一一对应）。
  static const List<PostSortType> _feedSortTypes = <PostSortType>[
    PostSortType.recommend, // 推荐
    PostSortType.newest, // 最新
    PostSortType.view, // 最热（按观看数）
    PostSortType.like, // 精华（按点赞数）
  ];

  static const int _pageSize = 10;

  /// 默认 `isRequest = true`，进入页面就处于「请求中」遮罩态，待首屏接口完成。
  final PullRefreshController _pullController = PullRefreshController();

  int _feedFilterIndex = 0;
  int _currentPage = 1;
  bool _hasMore = true;

  /// 二级分类 id：`null` 表示「全部」，命中即作为 `childCategoryId` 透传。
  int? _selectedChildId;

  List<PostCardData> _posts = const [];

  @override
  void initState() {
    super.initState();
    _fetchPage(refresh: true);
  }

  @override
  void didUpdateWidget(covariant CommunityCategoryFeedBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外层切换到不同分类（同一个 Tab body 复用的极端情况），重置筛选并重拉。
    if (oldWidget.module.id != widget.module.id) {
      _selectedChildId = null;
      _pullController.requesting();
      _fetchPage(refresh: true);
    }
  }

  @override
  void dispose() {
    _pullController.dispose();
    super.dispose();
  }

  PostingListQuery _buildQuery(int page) {
    return PostingListQuery(
      page: page,
      pageSize: _pageSize,
      categoryId: widget.module.id,
      childCategoryId: _selectedChildId,
      sortType: _feedSortTypes[_feedFilterIndex],
    );
  }

  /// 拉取一页帖子。
  ///
  /// - [refresh] = `true`：首屏 / 下拉刷新 / 切筛选，page=1，结果替换旧列表。
  /// - [refresh] = `false`：上拉加载下一页，结果追加到旧列表。
  Future<void> _fetchPage({required bool refresh}) async {
    final int page = refresh ? 1 : _currentPage + 1;
    final PostingListPage? result =
        await CircleApi.getPostingList(_buildQuery(page));
    if (!mounted) return;

    if (result == null) {
      _pullController.requestFail(isFirstPageNum: refresh);
      return;
    }

    setState(() {
      _posts = refresh
          ? List<PostCardData>.from(result.list)
          : (List<PostCardData>.from(_posts)..addAll(result.list));
      _currentPage = page;
      _hasMore = result.hasNextPage;
    });

    _pullController.requestSuccess(
      isFirstPageNum: refresh,
      hasMore: _hasMore,
      isEmpty: _posts.isEmpty,
    );
  }

  /// 切换二级分类：再点一次当前项 = 取消选中（回到全部）。
  void _onChildTap(ModuleModel item) {
    final int? tappedId = item.id;
    setState(() {
      _selectedChildId = (_selectedChildId == tappedId) ? null : tappedId;
    });
    _pullController.requesting();
    _fetchPage(refresh: true);
  }

  /// 切换排序：相同索引不重复请求，命中即刷新（走 body 的 REQUESTING 遮罩 → 拉一页）。
  void _onSortTap(int index) {
    if (index == _feedFilterIndex) return;
    setState(() => _feedFilterIndex = index);
    _pullController.requesting();
    _fetchPage(refresh: true);
    widget.scrollController?.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      controller: widget.scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return CircleCategoryFeedHeaderSlivers.build(
          // 后端配置该分类不展示 icon 区时（showIcon != 1），不渲染顶部广告组件。
          topAdsWidget: widget.module.isShowIcon
              ? const AdsBannerIconGroup(
                  iconType: AdsType.dbLineHeadPosting,
                )
              : null,
          featuredCards: widget.module.childGroups,
          featuredSelectedId: _selectedChildId,
          onFeaturedTap: _onChildTap,
          sortLabels: _feedFilters,
          selectedSortIndex: _feedFilterIndex,
          onSortSelected: _onSortTap,
        );
      },
      body: PullRefreshView(
        controller: _pullController,
        onRefresh: () => _fetchPage(refresh: true),
        onLoading: () => _fetchPage(refresh: false),
        retryOnTap: () => _fetchPage(refresh: true),
        child: CustomScrollView(
          key: PageStorageKey<String>(widget.pageStorageKey),
          // NestedScrollView body 内的 scrollable 用 Clamping，避免和外层
          // 的弹性回弹叠加产生抖动。
          physics: const ClampingScrollPhysics(),
          slivers: [
            getPostListStyle(
              items: _posts,
              onItemTap: (_, item) => jumpPostDetail(item.id.toString()),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 16.w)),
          ],
        ),
      ),
    );
  }
}
