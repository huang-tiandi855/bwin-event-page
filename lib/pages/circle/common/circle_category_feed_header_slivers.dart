import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/widgets/MySliverDelegate.dart';
import 'package:comics_app/pages/circle/common/circle_featured_strip.dart';
import 'package:comics_app/pages/circle/common/circle_sort_filter_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common/widgets/marquee_widget/notice_marquee_bar.dart';

/// 二级页向下滚动区「公共头」：顶部装饰（快捷宫格 / 广告组件） → 可选推荐条 → 排序条。
///
/// 顶部装饰二选一：
///   - 传入 [topAdsWidget]（真实广告区，如 `AdsBannerIconGroup`），将渲染该组件；
///   - 否则传入 [shortcuts]（占位快捷宫格），渲染 [CircleShortcutGrid]；
///   - 两者都不提供时顶部不渲染装饰区域。
///
/// 主列表（瀑布流 / 帖子卡片等）由各页面自行追加 [Widget] sliver。
class CircleCategoryFeedHeaderSlivers {
  CircleCategoryFeedHeaderSlivers._();

  static List<Widget> build({
    Widget? topAdsWidget,
    List<ModuleModel>? featuredCards,
    int? featuredSelectedId,
    ValueChanged<ModuleModel>? onFeaturedTap,
    required List<String> sortLabels,
    required int selectedSortIndex,
    required ValueChanged<int> onSortSelected,
    double? topSpacing,
    int shortcutCrossAxisCount = 5,
  }) {
    // final top = topSpacing ?? 16.w;
    return [
      // SliverToBoxAdapter(child: SizedBox(height: top)),
      if (topAdsWidget != null)
        SliverPadding(
          padding: EdgeInsets.only(top: 16.w, left: 16.w, right: 16.w),
          sliver: SliverToBoxAdapter(child: topAdsWidget),
        ),
      SliverToBoxAdapter(
        child: NoticeMarqueeBar(
          margin: EdgeInsets.only(top: 16.w),
          showType: NoticeShowType.community,
          showCloseButton: true,
        ),
      ),
      if (featuredCards != null && featuredCards.isNotEmpty) ...[
        SliverToBoxAdapter(child: SizedBox(height: 16.w)),
        SliverToBoxAdapter(
          child: CircleFeaturedStrip(
            cards: featuredCards,
            selectedId: featuredSelectedId,
            onTap: onFeaturedTap,
          ),
        ),
      ],
      SliverToBoxAdapter(child: SizedBox(height: 16.w)),
      // SliverToBoxAdapter(
      //   child: CircleSortFilterRow(
      //     labels: sortLabels,
      //     selectedIndex: selectedSortIndex,
      //     onSelected: onSortSelected,
      //   ),
      // ),
      SliverPersistentHeader(
          pinned: true,
          delegate: MySliverDelegate(
              maxHeight: 30.w,
              minHeight: 30.w,
              child: CircleSortFilterRow(
                labels: sortLabels,
                selectedIndex: selectedSortIndex,
                onSelected: onSortSelected,
              ))),
      SliverToBoxAdapter(child: SizedBox(height: 8.w)),
    ];
  }
}
