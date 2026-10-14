import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/common/widgets/general_widget/sliver_fixed_height_pinned_header.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/common/widgets/item/home_video_list_widgets.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'logic.dart';
import 'state.dart';

class RecommendColumnTabVideoPage extends StatefulWidget {
  const RecommendColumnTabVideoPage({
    Key? key,
    required this.module,
    required this.uniqueTag,
  }) : super(key: key);

  final String uniqueTag;
  final ModuleModel module;

  @override
  State<RecommendColumnTabVideoPage> createState() =>
      _RecommendColumnTabVideoPageState();
}

class _RecommendColumnTabVideoPageState
    extends State<RecommendColumnTabVideoPage> {
  RecommendColumnTabVideoLogic get _logic =>
      Get.find<RecommendColumnTabVideoLogic>(tag: widget.uniqueTag);

  @override
  void initState() {
    super.initState();
    Get.put(
      RecommendColumnTabVideoLogic(
        module: widget.module,
        uniqueTag: widget.uniqueTag,
      ),
      tag: widget.uniqueTag,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RecommendColumnTabVideoLogic>(
      tag: widget.uniqueTag,
      builder: (_) {
        final st = _logic.state;
        final c = _logic.subTabController;
        return getBgColorsView(
          child: ExtendedNestedScrollView(
            onlyOneScrollInBody: true,
            headerSliverBuilder: (context, inner) {
              return [
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
                        // 每个 tab 各自捕获 i，下拉/上拉只触发自己这一份
                        // [tabPageNumbers]/[tabVideoItems]，与 filterTabIndex 解耦。
                        onRefresh: () => _logic.onRefreshTab(i),
                        onLoading: () => _logic.onLoadTab(i),
                        retryOnTap: () => _logic.onRefreshTab(i),
                        child: CustomScrollView(
                          key: PageStorageKey<String>(
                              '${widget.uniqueTag}_tabv_$i'),
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

  Widget _buildSubFilters(
    RecommendColumnTabVideoState st,
    TabController tabController,
  ) {
    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              controller: tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: EdgeInsets.only(right: 16.w),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(.5),
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
              indicator: const BoxDecoration(),
              indicatorColor: Colors.white,
              dividerColor: Colors.transparent,
              tabs: [
                for (final t in st.filterTabs) Tab(text: t),
              ],
            ),
          ),
          GestureDetector(
            onTap: _logic.toggleLayoutMode,
            child: Row(
              children: [
                Text(
                  '切换',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(.5),
                  ),
                ),
                3.w.horizontalSpace,
                (st.isGridLayout
                        ? AssetsGen.images.home.icSwitchList
                        : AssetsGen.images.home.icSwitchGrid)
                    .image(width: 14.w, height: 14.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 渲染**指定 tab** 的视频列表。
  ///
  /// 不从 [state.videoItems]（基于 [filterTabIndex] 的 getter）取数据，
  /// 改用 `st.tabVideoItems[tabIndex]` 各取各的；这样左右切 tab 时旁边
  /// 那一页一直渲染自己的列表，不会被当前 tab 的数据「短暂替换」造成闪烁。
  Widget _buildVideoSliver(RecommendColumnTabVideoState st, int tabIndex) {
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
