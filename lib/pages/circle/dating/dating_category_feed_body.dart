import 'package:comics_app/common/apis/dating_api.dart';
import 'package:comics_app/common/entities/circle/dating_models.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/ads_manage/ads_banner_widget.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';
import 'package:comics_app/common/widgets/dating_style.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/pages/circle/circle_logic.dart';
import 'package:comics_app/pages/circle/dating/dating_dict_cache.dart';
import 'package:comics_app/pages/circle/dating/widgets/dating_feed_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 约会 Feed：分类 + 地区 + 排序 + 双列列表。
class DatingCategoryFeedBody extends StatefulWidget {
  const DatingCategoryFeedBody({
    super.key,
    required this.pageStorageKey,
    this.scrollController,
  });

  final String pageStorageKey;
  final ScrollController? scrollController;

  @override
  State<DatingCategoryFeedBody> createState() => _DatingCategoryFeedBodyState();
}

class _DatingCategoryFeedBodyState extends State<DatingCategoryFeedBody> {
  static const int _pageSize = 20;

  final PullRefreshController _pullController = PullRefreshController();

  DatingDictBundle _dicts = DatingDictBundle.empty;
  List<DatingCardModel> _items = const <DatingCardModel>[];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _bootstrapped = false;
  // bool _provinceListExpanded = false;
  bool _cityPanelOpen = false;
  int? _panelProvinceId;

  int? _selectedType;
  int? _provinceId;
  int? _cityId;
  DatingSortType _sortType = DatingSortType.latest;

  Worker? _outerCircleTabWorker;

  @override
  void initState() {
    super.initState();
    _bootstrap();
    _outerCircleTabWorker =
        ever(Get.find<CircleLogic>().state.tabSelectIndex, (idx) {
      if (idx == 2) _refreshDicts();
    });
  }

  @override
  void dispose() {
    _outerCircleTabWorker?.dispose();
    _pullController.dispose();
    super.dispose();
  }

  Future<void> _refreshDicts() async {
    final dicts = await DatingDictCache.instance.ensureLoaded();
    if (!mounted) return;
    setState(() => _dicts = dicts);
  }

  DatingListQuery _buildQuery(int page) {
    return DatingListQuery(
      page: page,
      pageSize: _pageSize,
      type: _selectedType,
      provinceId: _provinceId,
      cityId: _cityId,
      sortType: _sortType,
    );
  }

  Future<void> _bootstrap() async {
    final dicts = await DatingDictCache.instance.ensureLoaded();
    if (!mounted) return;

    if (dicts.types.isNotEmpty && _selectedType == null) {
      _selectedType = dicts.types.first.value;
    }

    final page = await DatingApi.getList(_buildQuery(1));
    if (!mounted) return;

    setState(() {
      _dicts = dicts;
      _bootstrapped = true;
      if (page != null) {
        _items = List<DatingCardModel>.from(page.list);
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
    final pageNum = refresh ? 1 : _currentPage + 1;
    final result = await DatingApi.getList(_buildQuery(pageNum));
    if (!mounted) return;

    if (result == null) {
      _pullController.requestFail(isFirstPageNum: refresh);
      return;
    }

    setState(() {
      _items = refresh
          ? List<DatingCardModel>.from(result.list)
          : (List<DatingCardModel>.from(_items)..addAll(result.list));
      _currentPage = pageNum;
      _hasMore = result.hasNextPage;
    });

    _pullController.requestSuccess(
      isFirstPageNum: refresh,
      hasMore: _hasMore,
      isEmpty: _items.isEmpty,
    );
  }

  void _reloadFromFilters() {
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
            if (_bootstrapped && _dicts.types.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 8.w, bottom: 16.w),
                  child: DatingTypeSelector(
                    types: _dicts.types,
                    selectedType: _selectedType,
                    onChanged: (v) {
                      if (_selectedType == v) return;
                      setState(() => _selectedType = v);
                      _reloadFromFilters();
                    },
                  ),
                ),
              ),
            if (_bootstrapped && _dicts.regions.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12.w),
                  child: DatingRegionFilter(
                    regions: _dicts.regions,
                    selectedProvinceId: _provinceId,
                    selectedCityId: _cityId,
                    // provinceListExpanded: _provinceListExpanded,
                    cityPanelOpen: _cityPanelOpen,
                    panelProvinceId: _panelProvinceId,
                    // onToggleProvinceList: () => setState(
                    //   () => _provinceListExpanded = !_provinceListExpanded,
                    // ),
                    onSelectAll: () {
                      if (_provinceId == null &&
                          _cityId == null &&
                          !_cityPanelOpen &&
                          _panelProvinceId == null) {
                        return;
                      }
                      setState(() {
                        _provinceId = null;
                        _cityId = null;
                        _cityPanelOpen = false;
                        _panelProvinceId = null;
                      });
                      _reloadFromFilters();
                    },
                    onSelectProvince: (node) {
                      if (node.children.isEmpty) {
                        setState(() {
                          _provinceId = node.id;
                          _cityId = null;
                          _cityPanelOpen = false;
                          _panelProvinceId = null;
                        });
                        _reloadFromFilters();
                        return;
                      }
                      var shouldReload = true;
                      setState(() {
                        if (_panelProvinceId == node.id) {
                          _cityPanelOpen = !_cityPanelOpen;
                          if (_cityPanelOpen) {
                            _provinceId = node.id;
                            _cityId = null;
                          } else {
                            shouldReload = false;
                          }
                        } else {
                          _panelProvinceId = node.id;
                          _cityPanelOpen = true;
                          _provinceId = node.id;
                          _cityId = null;
                        }
                      });
                      if (shouldReload) _reloadFromFilters();
                    },
                    onSelectAllCitiesInPanel: () {
                      if (_panelProvinceId == null) return;
                      setState(() => _cityId = null);
                      if (_provinceId != _panelProvinceId) {
                        setState(() => _provinceId = _panelProvinceId);
                      }
                      _reloadFromFilters();
                    },
                    onSelectCityInPanel: (node) {
                      if (_panelProvinceId == null) return;
                      setState(() {
                        _provinceId = _panelProvinceId;
                        _cityId = node.id;
                      });
                      _reloadFromFilters();
                    },
                    onCollapseCityPanel: () {
                      if (!_cityPanelOpen) return;
                      setState(() => _cityPanelOpen = false);
                    },
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.w),
                child: DatingSortTabs(
                  selected: _sortType,
                  onChanged: (v) {
                    if (_sortType == v) return;
                    setState(() => _sortType = v);
                    _reloadFromFilters();
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
                child: AdsBannerWidget(
              adsType: AdsType.datingBanner,
              height: 60.w,
              padding: EdgeInsets.only(bottom: 16.w, left: 16.w, right: 16.w),
            )),
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
              getDatingListStyle(items: _items),
              SliverToBoxAdapter(child: SizedBox(height: 16.w)),
            ],
          ),
        ),
      ),
    );
  }
}
