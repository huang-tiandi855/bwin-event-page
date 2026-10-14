import 'package:comics_app/common/services/scroll_metrics_manager.dart';
import 'package:comics_app/pages/circle/circle_logic.dart';
import 'package:comics_app/pages/circle/common/circle_secondary_category_shell.dart';
import 'package:comics_app/pages/circle/photos/photos_category_feed_body.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 圈子「图集」主 Tab：二级分类 + 与稿一致的列表壳。
class PhotosTabView extends StatefulWidget {
  const PhotosTabView({super.key});

  @override
  State<PhotosTabView> createState() => _PhotosTabViewState();
}

class _PhotosTabViewState extends State<PhotosTabView>
    with SingleTickerProviderStateMixin {
  late final TabController _categoryTabController;
  late final List<ScrollController> _scrollControllers;

  Worker? _outerCircleTabWorker;

  static const List<String> _categories = [
    '热搜图集',
    '新晋佳作',
    '专题合集',
  ];

  void _syncInnerScrollBinding() {
    if (!mounted) return;
    final outerIndex = Get.find<CircleLogic>().state.tabSelectIndex.value;
    if (outerIndex != 1) return;
    if (_categoryTabController.indexIsChanging) return;
    ScrollMetricsManager.sharedInstance.bindCircleCommunityInnerScroll(
      _scrollControllers[_categoryTabController.index],
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollControllers = List.generate(
      _categories.length,
      (_) => ScrollController(),
    );
    _categoryTabController =
        TabController(length: _categories.length, vsync: this);
    _categoryTabController.addListener(_syncInnerScrollBinding);

    _outerCircleTabWorker =
        ever(Get.find<CircleLogic>().state.tabSelectIndex, (_) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _syncInnerScrollBinding());
    });

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _syncInnerScrollBinding());
  }

  @override
  void dispose() {
    _outerCircleTabWorker?.dispose();
    ScrollMetricsManager.sharedInstance.bindCircleCommunityInnerScroll(null);
    _categoryTabController.removeListener(_syncInnerScrollBinding);
    _categoryTabController.dispose();
    for (final c in _scrollControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CircleSecondaryCategoryShell(
      tabController: _categoryTabController,
      categoryLabels: _categories,
      tabBodyBuilder: (context, i) => PhotosCategoryFeedBody(
        pageStorageKey: 'circle_photos_category_$i',
        scrollController: _scrollControllers[i],
      ),
    );
  }
}
