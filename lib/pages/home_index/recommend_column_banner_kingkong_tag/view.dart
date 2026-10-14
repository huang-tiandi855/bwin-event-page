import 'dart:math' as math;

import 'package:comics_app/common/entities/modules_config/king_kong_model.dart';
import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/pages/home_index/topic_more_detail/topic_more_detail_route.dart';
import 'package:comics_app/common/store/config.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/ads_manage/ads_banner_widget.dart';
import 'package:comics_app/common/utils/ads_manage/ads_grid_view_widget.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';
import 'package:comics_app/common/utils/utils.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/common/widgets/general_widget/sliver_fixed_height_pinned_header.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/common/widgets/marquee_widget/marquee_widget.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/common/widgets/item/home_video_list_widgets.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'logic.dart';
import 'state.dart';

class RecommendColumnBannerKingKongTagPage extends StatefulWidget {
  const RecommendColumnBannerKingKongTagPage({
    Key? key,
    required this.module,
    required this.uniqueTag,
    this.videoType = 0,
  }) : super(key: key);

  final ModuleModel module;
  final String uniqueTag;

  /// 透传到 logic 的 `videoType`：首页默认 0、暗网入口传 2。
  final int videoType;

  @override
  State<RecommendColumnBannerKingKongTagPage> createState() =>
      _RecommendColumnBannerKingKongTagPageState();
}

class _RecommendColumnBannerKingKongTagPageState
    extends State<RecommendColumnBannerKingKongTagPage> {
  RecommendColumnBannerKingKongTagLogic get _logic =>
      Get.find<RecommendColumnBannerKingKongTagLogic>(tag: widget.uniqueTag);

  RecommendColumnBannerKingKongTagState get _st => _logic.state;

  @override
  void initState() {
    super.initState();
    Get.put(
      RecommendColumnBannerKingKongTagLogic(
        module: widget.module,
        videoType: widget.videoType,
      ),
      tag: widget.uniqueTag,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RecommendColumnBannerKingKongTagLogic>(
      tag: widget.uniqueTag,
      builder: (_) {
        final st = _st;
        final c = _logic.secondaryTabController;
        return getBgColorsView(
          child: ExtendedNestedScrollView(
            onlyOneScrollInBody: true,
            headerSliverBuilder: (context, inner) {
              return [
                SliverToBoxAdapter(child: _buildHeader()),
                if (c != null && st.secondaryTabs.isNotEmpty)
                  SliverFixedHeightPinnedHeader(
                    height: 40.h,
                    child: Material(
                      color: AppColor.scaffoldBackground,
                      child: _buildSubFilters(st, c),
                    ),
                  ),
              ];
            },
            body: c == null || st.secondaryTabs.isEmpty
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
                      st.secondaryTabs.length,
                      (i) => PullRefreshView(
                        controller: st.tabPullRefreshControllers[i],
                        // 每个 tab 各自捕获 i：下拉/上拉只触发自己这一份
                        // [tabPageNumbers]/[tabVideoItems]，与 secondaryTabIndex 解耦。
                        onRefresh: () => _logic.onRefreshTab(i),
                        onLoading: () => _logic.onLoadTab(i),
                        retryOnTap: () => _logic.onRefreshTab(i),
                        child: CustomScrollView(
                          key: PageStorageKey<String>(
                              '${widget.uniqueTag}_kingkong_$i'),
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

  Widget _buildHeader() {
    final module = widget.module;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w).copyWith(top: 5.h),
      child: Column(
        children: [
          if (module.isShowBanner) ...[
            _buildBanner(),
            // 16.h.verticalSpace,
          ],
          if (module.isShowNotice) ...[
            _buildMarquee(),
            // 16.h.verticalSpace,
          ],
          if (module.isShowIcon) _buildIconGrid(),
          _buildKingKong(),
          _buildHotTags(),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return const AdsBannerWidget(
        padding: EdgeInsets.only(bottom: 16), adsType: AdsType.banner);
  }

  Widget _buildIconGrid() {
    return const AdsGridViewWidget(
      adsType: AdsType.dbLineHead,
      isBigStyle: true,
      padding: EdgeInsets.only(bottom: 10),
    );
  }

  /// 金刚区展示规则：
  /// - 数量 ≤ 5：保持原有"按 [Row] 等距铺平自适应"展示，不可滚动；
  /// - 数量 > 5：改为水平 [ListView] 横滑列表，可左右滑动，
  ///   单屏最少露出 [_kingKongMinItemsPerView] 个，最后那 0.5 暗示"还能左滑"。
  Widget _buildKingKong() {
    return GetBuilder<ConfigStore>(
      builder: (_) {
        final List<KingKongModel> items = ConfigStore.to.kingKongList;
        if (items.isEmpty) return const SizedBox.shrink();

        if (items.length <= _kingKongScrollThreshold) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SizedBox(
              height: 63.h,
              child: Row(
                mainAxisAlignment: items.length < 5
                    ? MainAxisAlignment.spaceEvenly
                    : MainAxisAlignment.spaceBetween,
                children: items.map(_buildKingKongItem).toList(),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SizedBox(
            height: 63.h,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 用容器实际可用宽度均分成 5.5 份，确保最后半格被裁出来作为
                // "可左滑"的视觉提示；不依赖屏幕宽度，避免 padding 变化时算错。
                final double itemWidth =
                    constraints.maxWidth / _kingKongMinItemsPerView;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    return SizedBox(
                      width: itemWidth,
                      child: _buildKingKongItem(items[index]),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// 数量阈值：超过该值改为横滑列表。
  static const int _kingKongScrollThreshold = 5;

  /// 横滑模式下单屏最少展示的金刚位数量（含尾部半格暗示）。
  static const double _kingKongMinItemsPerView = 5.5;

  Widget _buildKingKongItem(KingKongModel item) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onKingKongTap(item),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomImage(
            url: item.icon,
            width: 42.w,
            height: 42.w,
          ),
          SizedBox(height: 3.w),
          Text(
            item.title ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }

  /// 金刚区点击：
  /// - 其余条目按通用广告跳转走 [AppNavigator.jumpAdv]。
  void _onKingKongTap(KingKongModel item) {
    AppNavigator.to.jumpAdv(
      id: item.id?.toString() ?? '',
      title: item.title ?? '',
      url: item.url ?? '',
      planId: '',
      slotCode: '',
    );
  }

  Widget _buildMarquee() {
    return const NoticeMarqueeBar(
      margin: EdgeInsets.only(bottom: 16),
      showType: NoticeShowType.home,
      showCloseButton: true,
    );
  }

  Widget _buildHotTags() {
    return Obx(() {
      final tags = _st.hotTags;
      if (tags.isEmpty) return const SizedBox.shrink();

      final expanded = _st.hotTagsExpanded.value;
      final canToggle =
          tags.length > RecommendColumnBannerKingKongTagState.collapsedTagSlots;

      final int itemCount;
      if (expanded) {
        itemCount = tags.length + 1;
      } else {
        itemCount = RecommendColumnBannerKingKongTagState.collapsedGridSlots;
      }

      return GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12.w,
          crossAxisSpacing: 5.w,
          childAspectRatio: 82 / 30,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (expanded) {
            if (index == tags.length) {
              return _buildHotTagsToggleCell(
                label: _st.hotTagCollapseLabel,
                icon: AssetsGen.images.home.icExpand,
                flipIcon: false,
                onTap: () => _logic.setHotTagsExpanded(false),
              );
            }
            final item = tags[index];
            return _buildHotTagChip(
              label: item.groupName ?? '',
              isHot: item.hot == 1,
              // 走 [TopicMoreDetailRoute.push] 让每次点击都拿到独立 logic 实例。
              onTap: () => TopicMoreDetailRoute.push(
                topicId: item.id,
                topicName: item.groupName ?? '',
              ),
            );
          }

          const lastIndex =
              RecommendColumnBannerKingKongTagState.collapsedGridSlots - 1;
          if (index == lastIndex) {
            if (!canToggle) {
              return const SizedBox.shrink();
            }
            return _buildHotTagsToggleCell(
              label: _st.hotTagExpandLabel,
              icon: AssetsGen.images.home.icExpand,
              flipIcon: true,
              onTap: () => _logic.setHotTagsExpanded(true),
            );
          }
          if (index < tags.length &&
              index < RecommendColumnBannerKingKongTagState.collapsedTagSlots) {
            final item = tags[index];
            return _buildHotTagChip(
              label: item.groupName ?? '',
              isHot: item.hot == 1,
              onTap: () => TopicMoreDetailRoute.push(
                topicId: item.id,
                topicName: item.groupName ?? '',
              ),
            );
          }
          return const SizedBox.shrink();
        },
      );
    });
  }

  Widget _buildHotTagChip({
    required String label,
    required bool isHot,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.w),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _st.hotTagCellBg,
                borderRadius: BorderRadius.circular(4.w),
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),
            ),
            if (isHot)
              Positioned(
                top: -10.w,
                right: 0,
                child: AssetsGen.images.home.icHotTag
                    .image(width: 24.w, height: 17.h),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotTagsToggleCell({
    required String label,
    required AssetGenImage icon,
    required VoidCallback onTap,
    bool flipIcon = false,
  }) {
    Widget iconWidget = icon.image(width: 16.w, height: 16.h);
    if (flipIcon) {
      iconWidget = Transform.rotate(
        angle: math.pi,
        child: iconWidget,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.w),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _st.hotTagCellBg,
            borderRadius: BorderRadius.circular(4.w),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              4.w.horizontalSpace,
              iconWidget,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubFilters(
    RecommendColumnBannerKingKongTagState st,
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
              isScrollable: false,
              padding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              tabAlignment: TabAlignment.fill,
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
                for (final t in st.secondaryTabs) Tab(text: t),
              ],
            ),
          ),
          GestureDetector(
            onTap: _logic.toggleSecondaryVideoLayout,
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
                (st.secondaryVideoGridLayout
                        ? AssetsGen.images.home.icSwitchList
                        : AssetsGen.images.home.icSwitchGrid)
                    .image(width: 14.w, height: 14.h)
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 渲染**指定 tab** 的视频列表。
  ///
  /// 直接读 `st.tabVideoItems[tabIndex]`，不再走 [state.secondaryVideoItems]
  /// 这种依赖 [secondaryTabIndex] 的 getter；切 tab 时旁边那一页始终展示
  /// 自己的数据，不会闪到当前 tab 的列表上。
  Widget _buildVideoSliver(
    RecommendColumnBannerKingKongTagState st,
    int tabIndex,
  ) {
    final pad = EdgeInsets.fromLTRB(12.w, 0, 12.w, 0);
    final list = st.tabVideoItems[tabIndex];
    if (list.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    if (st.secondaryVideoGridLayout) {
      return getFourGrid(list, sliver: true, sliverPadding: pad);
    }
    return getBigColumn(list, sliver: true, sliverPadding: pad);
  }
}
