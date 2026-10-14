import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/ads_manage/ads_banner_widget.dart';
import 'package:comics_app/common/utils/ads_manage/ads_grid_view_widget.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/common/widgets/general_widget/sliver_fixed_height_pinned_header.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/common/widgets/marquee_widget/marquee_widget.dart';
import 'package:comics_app/common/widgets/item/home_video_list_widgets.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'logic.dart';
import 'state.dart';

/// 一级 Tab「最新」：二级筛选 + Feed（各自模块内实现详细 UI）。
class RecommendNewPage extends StatefulWidget {
  const RecommendNewPage({
    Key? key,
    required this.module,
    required this.uniqueTag,
    this.videoType = 0,
  }) : super(key: key);

  /// 每个 Tab 独立 Logic，避免多 Tab 共用同一控制器
  final String uniqueTag;
  final ModuleModel module;

  /// 透传到 logic 的 `videoType`：首页默认 0、暗网入口传 2。
  final int videoType;

  @override
  State<RecommendNewPage> createState() => _RecommendNewPageState();
}

class _RecommendNewPageState extends State<RecommendNewPage> {
  RecommendNewLogic get _logic =>
      Get.find<RecommendNewLogic>(tag: widget.uniqueTag);

  @override
  void initState() {
    super.initState();
    Get.put(
      RecommendNewLogic(
        module: widget.module,
        videoType: widget.videoType,
      ),
      tag: widget.uniqueTag,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RecommendNewLogic>(
      tag: widget.uniqueTag,
      builder: (_) {
        final st = _logic.state;
        final c = _logic.subTabController;
        return getBgColorsView(
          child: ExtendedNestedScrollView(
            onlyOneScrollInBody: true,
            headerSliverBuilder: (context, inner) {
              return [
                SliverToBoxAdapter(child: _buildTopHeader(st)),
                if (c != null && st.filterTabs.isNotEmpty)
                  SliverFixedHeightPinnedHeader(
                    height: 40.h,
                    child: Material(
                      color: AppColor.scaffoldBackground,
                      child: _buildSubFilters(st, c),
                    ),
                  ),
              ];
            },
            body: c == null || st.filterTabs.isEmpty
                ? PullRefreshView(
                    controller: st.pullRefreshController,
                    onRefresh: _logic.onRefresh,
                    onLoading: _logic.onLoad,
                    retryOnTap: _logic.onRefresh,
                    child: CustomScrollView(
                      slivers: [
                        _buildVideoSliver(st, 0),
                        SliverToBoxAdapter(child: SizedBox(height: 12.w)),
                      ],
                    ),
                  )
                : TabBarView(
                    controller: c,
                    children: List.generate(
                      st.filterTabs.length,
                      (i) => PullRefreshView(
                        controller: st.tabPullRefreshControllers[i],
                        // 每个 tab 各自捕获 i：下拉/上拉只触发自己这一份
                        // [tabPageNumbers]/[tabVideoItems]，与 filterTabIndex 解耦。
                        onRefresh: () => _logic.onRefreshTab(i),
                        onLoading: () => _logic.onLoadTab(i),
                        retryOnTap: () => _logic.onRefreshTab(i),
                        child: CustomScrollView(
                          key: PageStorageKey<String>(
                              '${widget.uniqueTag}_new_$i'),
                          slivers: [
                            _buildVideoSliver(st, i),
                            SliverToBoxAdapter(child: SizedBox(height: 12.w)),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildTopHeader(RecommendNewState st) {
    final module = widget.module;
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 5.w),
      child: Column(
        children: [
          if (module.isShowBanner) ...[
            const AdsBannerWidget(
                padding: EdgeInsets.only(bottom: 16), adsType: AdsType.banner),
            // 16.h.verticalSpace,
          ],
          if (module.isShowNotice) ...[
            const NoticeMarqueeBar(
              margin: EdgeInsets.only(bottom: 16),
              showType: NoticeShowType.home,
              showCloseButton: true,
            ),
            // 16.h.verticalSpace,
          ],
          if (module.isShowIcon) _buildIconGrid(),
        ],
      ),
    );
  }

  Widget _buildIconGrid() {
    return const AdsGridViewWidget(
      adsType: AdsType.dbLineHead,
      isBigStyle: true,
    );
  }

  Widget _buildSubFilters(RecommendNewState st, TabController tabController) {
    final filters = st.filterTabs;
    return SizedBox(
      height: 40.h,
      child: TabBar(
        controller: tabController,
        isScrollable: false,
        tabAlignment: TabAlignment.fill,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        labelPadding: EdgeInsets.zero,
        labelColor: Colors.white,
        unselectedLabelColor: AppColor.hintTextColor,
        labelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 0,
        dividerColor: Colors.transparent,
        indicator: const BoxDecoration(),
        tabs: [
          for (int i = 0; i < filters.length; i++)
            Tab(
              child: Align(
                alignment: i == 0
                    ? Alignment.centerLeft
                    : (i == filters.length - 1
                        ? Alignment.centerRight
                        : Alignment.center),
                child: Text(filters[i]),
              ),
            ),
        ],
      ),
    );
  }

  /// 渲染**指定 tab** 的视频列表。
  ///
  /// 直接读 `st.tabVideoItems[tabIndex]`，不再走 [state.videoItems] 这种
  /// 依赖 [filterTabIndex] 的 getter；切 tab 时旁边那一页始终展示自己的
  /// 数据，不会闪到当前 tab 的列表上。
  Widget _buildVideoSliver(RecommendNewState st, int tabIndex) {
    final pad = EdgeInsets.fromLTRB(12.w, 0, 12.w, 0);
    final list = st.tabVideoItems[tabIndex];
    if (list.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    if (st.isGridLayout) {
      return getFourGrid(list, sliver: true, sliverPadding: pad);
    }
    return getBigColumn(list, sliver: true, sliverPadding: pad);
  }
}
