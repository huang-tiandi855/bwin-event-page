import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/pages/home_index/topic_more_detail/topic_more_detail_route.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/ads_manage/ads_banner_widget.dart';
import 'package:comics_app/common/utils/ads_manage/ads_grid_view_widget.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/common/widgets/general_widget/sliver_fixed_height_pinned_header.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/common/widgets/marquee_widget/marquee_widget.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/common/widgets/item/home_video_list_widgets.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'logic.dart';
import 'state.dart';

class RecommendColumnBannerIconTopicPage extends StatefulWidget {
  const RecommendColumnBannerIconTopicPage({
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
  State<RecommendColumnBannerIconTopicPage> createState() =>
      _RecommendColumnBannerIconTopicPageState();
}

class _RecommendColumnBannerIconTopicPageState
    extends State<RecommendColumnBannerIconTopicPage> {
  RecommendColumnBannerIconTopicLogic get _logic =>
      Get.find<RecommendColumnBannerIconTopicLogic>(tag: widget.uniqueTag);

  RecommendColumnBannerIconTopicState get _st => _logic.state;

  @override
  void initState() {
    super.initState();
    Get.put(
      RecommendColumnBannerIconTopicLogic(
        module: widget.module,
        videoType: widget.videoType,
      ),
      tag: widget.uniqueTag,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RecommendColumnBannerIconTopicLogic>(
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
                              '${widget.uniqueTag}_icontopic_$i'),
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
      padding: EdgeInsets.fromLTRB(12.w, 5.w, 12.w, 8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (module.isShowBanner) ...[
            _buildBanner(),
          ],
          if (module.isShowNotice) ...[
            _buildMarquee(),
          ],
          if (module.isShowIcon) _buildIconGrid(),
          _buildAvatarRowAligned(),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return const AdsBannerWidget(
        padding: EdgeInsets.only(bottom: 16), adsType: AdsType.banner);
  }

  Widget _buildMarquee() {
    return const NoticeMarqueeBar(
      margin: EdgeInsets.only(bottom: 16),
      showType: NoticeShowType.home,
      showCloseButton: true,
    );
  }

  Widget _buildIconGrid() {
    return const AdsGridViewWidget(
      adsType: AdsType.dbLineHead,
      isBigStyle: true,
      padding: EdgeInsets.only(bottom: 16),
    );
  }

  Widget _buildAvatarRowAligned() {
    return Obx(() {
      final items = _st.avatarTopicItems;
      if (items.isEmpty) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 76.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(width: 18.w),
            itemBuilder: (context, index) {
              return _buildAvatarCell(items[index], index);
            },
          ),
        ),
      );
    });
  }

  Widget _buildAvatarCell(ModuleModel item, int index) {
    final Widget avatarChild = CustomImage(
      url: item.imageUrl,
      fit: BoxFit.cover,
      width: 54.w,
      height: 54.h,
    );

    return clickButton(
      // 走 [TopicMoreDetailRoute.push] 让每次点击都拿到独立 logic 实例
      // （tag 由 helper 内部生成，栈上叠多份 TopicMoreDetail 时 state 不互相覆盖）。
      onTap: () => TopicMoreDetailRoute.push(
        topicId: item.id,
        topicName: item.groupName ?? '',
        videoType: item.videoType,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 54.w,
            height: 54.h,
            child: ClipOval(child: avatarChild),
          ),
          SizedBox(height: 6.w),
          Text(
            item.groupName ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColor.primaryText,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubFilters(
    RecommendColumnBannerIconTopicState st,
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
              tabAlignment: TabAlignment.fill,
              labelPadding: EdgeInsets.zero,
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
    RecommendColumnBannerIconTopicState st,
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
