import 'package:comics_app/common/apis/game_api.dart';
import 'package:comics_app/common/entities/circle/gaming_models.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/games_style.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/pages/circle/games/games_dict_cache.dart';
import 'package:comics_app/pages/circle/games/widgets/games_filter_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common/utils/ads_manage/ads_banner_icon_group.dart';
import '../../../common/utils/ads_manage/getAdv.dart';

/// 黄游 Feed：公告 + 筛选 + 纵向 [GameCard] 列表。
///
/// 首屏 [Future.wait] 并行拉字典缓存 + 第一页列表；之后只改筛选时只重拉 list。
class GamesCategoryFeedBody extends StatefulWidget {
  const GamesCategoryFeedBody({
    super.key,
    required this.pageStorageKey,
    this.scrollController,
  });

  final String pageStorageKey;
  final ScrollController? scrollController;

  @override
  State<GamesCategoryFeedBody> createState() => _GamesCategoryFeedBodyState();
}

class _GamesCategoryFeedBodyState extends State<GamesCategoryFeedBody> {
  static const int _pageSize = 20;

  /// 排序文案 → [GamingSortType]（产品主排序）。
  static const List<({String label, GamingSortType type})> _sortOptions =
      <({String label, GamingSortType type})>[
    (label: '发布时间', type: GamingSortType.publishTime),
    (label: '浏览量', type: GamingSortType.watch),
    (label: '点赞数', type: GamingSortType.perfect),
    (label: '收藏数', type: GamingSortType.collect),
    (label: '销售量', type: GamingSortType.unlockCount),
  ];

  final PullRefreshController _pullController = PullRefreshController();

  GamesDictBundle _dicts = GamesDictBundle.empty;
  List<GamesFilterRowData> _filterRows = const <GamesFilterRowData>[];
  late final List<int> _selectedFilters = <int>[0, 0, 0, 0];

  List<GameDataModel> _items = const <GameDataModel>[];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _pullController.dispose();
    super.dispose();
  }

  void _applyDicts(GamesDictBundle dicts) {
    _dicts = dicts;
    _filterRows = <GamesFilterRowData>[
      GamesFilterRowData(
        label: '分类',
        options: <String>[
          '全部',
          ...dicts.categories.map((e) => e.name),
        ],
      ),
      // GamesFilterRowData(
      //   label: '平台',
      //   options: <String>[
      //     '全部',
      //     ...dicts.platforms.map((e) => e.name),
      //   ],
      // ),
      // GamesFilterRowData(
      //   label: '语言',
      //   options: <String>[
      //     '全部语言',
      //     ...dicts.languages.map((e) => e.name),
      //   ],
      // ),
      // GamesFilterRowData(
      //   label: '排序',
      //   options: _sortOptions.map((e) => e.label).toList(),
      // ),
    ];
  }

  GamingListQuery _buildQuery(int page) {
    int? categoryId;
    int? platformId;
    int? languageId;

    final int catIdx = _selectedFilters[0];
    if (catIdx > 0 && catIdx - 1 < _dicts.categories.length) {
      categoryId = _dicts.categories[catIdx - 1].id;
    }
    final int platIdx = _selectedFilters[1];
    if (platIdx > 0 && platIdx - 1 < _dicts.platforms.length) {
      platformId = _dicts.platforms[platIdx - 1].id;
    }
    final int langIdx = _selectedFilters[2];
    if (langIdx > 0 && langIdx - 1 < _dicts.languages.length) {
      languageId = _dicts.languages[langIdx - 1].id;
    }

    final int sortIdx = _selectedFilters[3].clamp(0, _sortOptions.length - 1);

    return GamingListQuery(
      page: page,
      pageSize: _pageSize,
      categoryId: categoryId,
      platformId: platformId,
      languageId: languageId,
      sortType: _sortOptions[sortIdx].type,
      sortAsc: false,
    );
  }

  /// 首屏：字典 + 列表并行；字典命中缓存时几乎零成本。
  Future<void> _bootstrap() async {
    final List<Object?> results = await Future.wait<Object?>([
      GamesDictCache.instance.ensureLoaded(),
      GameApi.getList(_buildQuery(1)),
    ]);
    if (!mounted) return;

    final GamesDictBundle dicts =
        (results[0] as GamesDictBundle?) ?? GamesDictBundle.empty;
    final GamingListPage? page = results[1] as GamingListPage?;

    setState(() {
      _applyDicts(dicts);
      _bootstrapped = true;
      if (page != null) {
        _items = List<GameDataModel>.from(page.list);
        _currentPage = 1;
        _hasMore = page.hasNextPage;
      }
    });

    if (page == null) {
      _pullController.requestFail(isFirstPageNum: true);
      return;
    }
    _pullController.requestSuccess(
      isFirstPageNum: true,
      hasMore: _hasMore,
      isEmpty: _items.isEmpty,
    );
  }

  Future<void> _fetchPage({required bool refresh}) async {
    final int page = refresh ? 1 : _currentPage + 1;
    final GamingListPage? result = await GameApi.getList(_buildQuery(page));
    if (!mounted) return;

    if (result == null) {
      _pullController.requestFail(isFirstPageNum: refresh);
      return;
    }

    setState(() {
      _items = refresh
          ? List<GameDataModel>.from(result.list)
          : (List<GameDataModel>.from(_items)..addAll(result.list));
      _currentPage = page;
      _hasMore = result.hasNextPage;
    });

    _pullController.requestSuccess(
      isFirstPageNum: refresh,
      hasMore: _hasMore,
      isEmpty: _items.isEmpty,
    );
  }

  void _onFilterSelected(int row, int opt) {
    if (_selectedFilters[row] == opt) return;
    setState(() => _selectedFilters[row] = opt);
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
    return ColoredBox(
      color: AppColor.scaffoldBackground,
      child: NestedScrollView(
        controller: widget.scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverToBoxAdapter(
              child: AdsBannerIconGroup(
                iconType: AdsType.gameAppIcon,
                iconPadding: EdgeInsets.all(16.w),
              ),
            ),
            // SliverToBoxAdapter(
            //     child: Container(
            //   margin: EdgeInsets.only(
            //     left: 16.w,
            //     right: 16.w,
            //   ),
            //   color: const Color(0x80808080),
            //   height: 1.w,
            // )),
            if (_bootstrapped && _filterRows.isNotEmpty)
              SliverToBoxAdapter(
                child: GamesFilterBlock(
                  rows: _filterRows,
                  selectedIndices: _selectedFilters,
                  onSelected: _onFilterSelected,
                ),
              ),
            // SliverToBoxAdapter(child: SizedBox(height: 16.w)),
            // SliverToBoxAdapter(
            //     child: Container(
            //   margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.w),
            //   color: const Color(0x80808080),
            //   height: 1.w,
            // )),
          ];
        },
        body: PullRefreshView(
          controller: _pullController,
          onRefresh: () => _fetchPage(refresh: true),
          onLoading: () => _fetchPage(refresh: false),
          retryOnTap: () {
            if (!_bootstrapped) {
              _pullController.requesting();
              _bootstrap();
            } else {
              _fetchPage(refresh: true);
            }
          },
          child: CustomScrollView(
            key: PageStorageKey<String>(widget.pageStorageKey),
            physics: const ClampingScrollPhysics(),
            slivers: [
              getGameListStyle(
                items: _items,
              ),
              SliverToBoxAdapter(child: SizedBox(height: 16.w)),
            ],
          ),
        ),
      ),
    );
  }
}
