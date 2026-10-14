import 'package:comics_app/common/services/scroll_metrics_manager.dart';
import 'package:comics_app/pages/circle/circle_logic.dart';
import 'package:comics_app/pages/circle/common/circle_secondary_category_shell.dart';
import 'package:comics_app/pages/circle/novel/novel_category_feed_body.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 圈子「小说」主 Tab。
class NovelTabView extends StatefulWidget {
  const NovelTabView({super.key});

  @override
  State<NovelTabView> createState() => _NovelTabViewState();
}

class _NovelTabViewState extends State<NovelTabView>
    with SingleTickerProviderStateMixin {
  late final TabController _categoryTabController;
  late final List<ScrollController> _scrollControllers;

  Worker? _outerCircleTabWorker;

  static const List<String> _categories = [
    '文字小说',
    '有声小说',
  ];

  void _syncInnerScrollBinding() {
    if (!mounted) return;
    final outerIndex = Get.find<CircleLogic>().state.tabSelectIndex.value;
    if (outerIndex != 3) return;
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
      tabBodyBuilder: (context, i) => NovelCategoryFeedBody(
        pageStorageKey: 'circle_novel_category_$i',
        scrollController: _scrollControllers[i],
      ),
    );
  }
}
