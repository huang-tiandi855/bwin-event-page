import 'package:comics_app/common/services/scroll_metrics_manager.dart';
import 'package:comics_app/pages/circle/circle_logic.dart';
import 'package:comics_app/pages/circle/games/games_category_feed_body.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 圈子「黄游」主 Tab。
///
/// 筛选字典（分类/平台/语言）由 [GamesDictCache] 全局缓存；本页不再挂假二级 Tab，
/// 避免 KeepAlive 多列表同时打 `gaming/list`。
class GamesTabView extends StatefulWidget {
  const GamesTabView({super.key});

  @override
  State<GamesTabView> createState() => _GamesTabViewState();
}

class _GamesTabViewState extends State<GamesTabView> {
  late final ScrollController _scrollController;
  Worker? _outerCircleTabWorker;

  void _syncInnerScrollBinding() {
    if (!mounted) return;
    // 顶栏（当前启用）：社区(0) · 黄游(1)
    final int outerIndex =
        Get.find<CircleLogic>().state.tabSelectIndex.value;
    if (outerIndex != 1) return;
    ScrollMetricsManager.sharedInstance.bindCircleCommunityInnerScroll(
      _scrollController,
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GamesCategoryFeedBody(
      pageStorageKey: 'circle_games_feed',
      scrollController: _scrollController,
    );
  }
}
