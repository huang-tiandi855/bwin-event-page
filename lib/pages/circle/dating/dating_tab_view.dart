import 'package:comics_app/common/services/scroll_metrics_manager.dart';
import 'package:comics_app/pages/circle/circle_logic.dart';
import 'package:comics_app/pages/circle/dating/dating_category_feed_body.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 圈子「约会」主 Tab。
class DatingTabView extends StatefulWidget {
  const DatingTabView({super.key});

  @override
  State<DatingTabView> createState() => _DatingTabViewState();
}

class _DatingTabViewState extends State<DatingTabView> {
  late final ScrollController _scrollController;
  Worker? _outerCircleTabWorker;

  void _syncInnerScrollBinding() {
    if (!mounted) return;
    final outerIndex = Get.find<CircleLogic>().state.tabSelectIndex.value;
    if (outerIndex != 2) return;
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
    return DatingCategoryFeedBody(
      pageStorageKey: 'circle_dating_feed',
      scrollController: _scrollController,
    );
  }
}
