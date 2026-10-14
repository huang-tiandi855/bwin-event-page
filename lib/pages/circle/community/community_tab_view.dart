import 'package:comics_app/common/services/scroll_metrics_manager.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/common/widgets/loading_widget.dart';
import 'package:comics_app/pages/circle/circle_logic.dart';
import 'package:comics_app/pages/circle/circle_state.dart';
import 'package:comics_app/pages/circle/community/community_category_feed_body.dart';
import 'package:comics_app/pages/circle/common/circle_secondary_category_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/entities/modules_config/module_model.dart';

/// 「社区」Tab：二级分类 + 帖子流。
///
/// - 加载中：展示 [LoadingWidget]
/// - 加载失败：展示「加载失败，点击重试」，点击后回调 [onRetry]
/// - 加载成功但空：展示「暂无分类」
/// - 加载成功且非空：展示二级 TabBar + 各分类的帖子流
class CommunityTabView extends StatefulWidget {
  const CommunityTabView({
    super.key,
    required this.postingCategory,
    required this.tabPostingIndex,
    this.status = CircleCategoryLoadStatus.success,
    this.onRetry,
  });

  final List<ModuleModel> postingCategory;
  final int tabPostingIndex;
  final CircleCategoryLoadStatus status;
  final VoidCallback? onRetry;

  @override
  State<CommunityTabView> createState() => _CommunityTabViewState();
}

class _CommunityTabViewState extends State<CommunityTabView>
    with TickerProviderStateMixin {
  /// 分类异步加载完成前可能是空的，所以这两个都允许 `null` / 空。
  TabController? _categoryTabController;
  List<ScrollController> _categoryScrollControllers = const [];

  Worker? _outerCircleTabWorker;

  void _syncCircleInnerScrollBinding() {
    if (!mounted) return;
    final outerIndex = Get.find<CircleLogic>().state.tabSelectIndex.value;
    // 非当前圈子顶栏 Tab 时不要 bind(null)，否则会与其它 Tab 的 bind 抢顺序，
    // 导致 ScrollMetricsManager 拿不到内层 ScrollController，返回顶部失效。
    if (outerIndex != 0) return;
    final controller = _categoryTabController;
    if (controller == null) return;
    if (controller.indexIsChanging) return;
    if (_categoryScrollControllers.isEmpty) return;
    if (controller.index >= _categoryScrollControllers.length) return;
    ScrollMetricsManager.sharedInstance.bindCircleCommunityInnerScroll(
      _categoryScrollControllers[controller.index],
    );
  }

  /// 根据当前 [widget.postingCategory] 长度（重新）创建 tab/scroll controller。
  /// 接口异步返回数据时长度会从 0 → N 变化，需要在 [didUpdateWidget] 里调用。
  void _rebuildControllers() {
    _categoryTabController?.removeListener(_syncCircleInnerScrollBinding);
    _categoryTabController?.dispose();
    for (final c in _categoryScrollControllers) {
      c.dispose();
    }

    final length = widget.postingCategory.length;
    _categoryScrollControllers =
        List.generate(length, (_) => ScrollController());

    if (length == 0) {
      _categoryTabController = null;
      return;
    }
    final controller = TabController(
        length: length, vsync: this, initialIndex: widget.tabPostingIndex);
    controller.addListener(_syncCircleInnerScrollBinding);
    _categoryTabController = controller;
  }

  @override
  void initState() {
    super.initState();
    _rebuildControllers();

    _outerCircleTabWorker =
        ever(Get.find<CircleLogic>().state.tabSelectIndex, (_) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _syncCircleInnerScrollBinding());
    });

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _syncCircleInnerScrollBinding());
  }

  @override
  void didUpdateWidget(covariant CommunityTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.postingCategory.length != widget.postingCategory.length) {
      _rebuildControllers();
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _syncCircleInnerScrollBinding());
    }
    if (oldWidget.tabPostingIndex != _categoryTabController?.index && _categoryTabController != null) {
      _categoryTabController?.animateTo(widget.tabPostingIndex);
    }
  }

  @override
  void dispose() {
    _outerCircleTabWorker?.dispose();
    ScrollMetricsManager.sharedInstance.bindCircleCommunityInnerScroll(null);
    _categoryTabController?.removeListener(_syncCircleInnerScrollBinding);
    _categoryTabController?.dispose();
    for (final c in _categoryScrollControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 优先按加载状态决定渲染分支：失败 / 加载中先短路，避免去渲染 TabBar。
    switch (widget.status) {
      case CircleCategoryLoadStatus.loading:
        return getBgColorsView(
          child: const Center(child: LoadingWidget()),
        );
      case CircleCategoryLoadStatus.failed:
        return getBgColorsView(
          child: _CategoryRetryPlaceholder(
            message: '加载失败，点击重试',
            onRetry: widget.onRetry,
          ),
        );
      case CircleCategoryLoadStatus.success:
        break;
    }

    final controller = _categoryTabController;
    if (controller == null || widget.postingCategory.isEmpty) {
      return getBgColorsView(
        child: _CategoryRetryPlaceholder(
          message: '暂无分类',
          onRetry: widget.onRetry,
          retryText: '重新加载',
        ),
      );
    }
    return CircleSecondaryCategoryShell(
      tabController: controller,
      categoryLabels: widget.postingCategory.map((e) => e.name ?? '').toList(),
      tabBodyBuilder: (context, i) => CommunityCategoryFeedBody(
        module: widget.postingCategory[i],
        pageStorageKey: 'community_category_$i',
        scrollController: _categoryScrollControllers[i],
      ),
    );
  }
}

/// 失败 / 空态共用的占位（白色提示 + 可选的重试按钮）。
class _CategoryRetryPlaceholder extends StatelessWidget {
  const _CategoryRetryPlaceholder({
    required this.message,
    this.onRetry,
    this.retryText = '点击重试',
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(.6),
              fontSize: 14.sp,
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(height: 12.h),
            InkWell(
              onTap: onRetry,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(.3)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  retryText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
