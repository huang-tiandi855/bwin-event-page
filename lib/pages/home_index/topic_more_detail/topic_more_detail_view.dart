import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/common/widgets/item/home_video_list_widgets.dart';
import 'package:comics_app/common/widgets/item/meida_cover_item.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'topic_more_detail_logic.dart';
import 'topic_more_detail_route.dart';
import 'topic_more_detail_state.dart';

/// 专题详情：顶部标题 + 二级排序 Tab + 双列视频列表；路由参数 `topicId`、`topicName`。
class TopicMoreDetailPage extends StatefulWidget {
  const TopicMoreDetailPage({Key? key}) : super(key: key);

  @override
  State<TopicMoreDetailPage> createState() => _TopicMoreDetailPageState();
}

class _TopicMoreDetailPageState extends State<TopicMoreDetailPage>
    with SingleTickerProviderStateMixin {
  late final TopicMoreDetailLogic logic;

  /// 由 [TopicMoreDetailRoute.push] 在 `Get.arguments` 注入的页面 tag。
  ///
  /// 同一个 [AppRoutes.TOPIC_MORE_DETAIL] 路由可能在栈上叠多份（专题 A → 短
  /// 视频流 → 专题 B；专题 A → 长视频 → `offNamed` 专题 B；同路由 push 等），
  /// 用 tag 隔离每次的 logic 实例，state 不再互相覆盖。
  ///
  /// 旧入口/外链没传 tag 时为 `null`，[Get.find] 会 fallback 到无 tag 的
  /// 全局实例，行为退化到改造前。
  String? _tag;
  late final TabController _tabController;
  int _prevTabIndex = -1;

  TopicMoreDetailState get state => logic.state;

  @override
  void initState() {
    super.initState();
    _tag = TopicMoreDetailRoute.tagOf(Get.arguments);
    // 同一个路由名可能在栈上叠多份，按 tag 各取各的 logic 实例。
    // logic 内部 `onInit` 已经按 `Get.arguments` 解析参数 + 拉首屏，
    // view 不再额外调用 `applyArguments`，避免重复请求。
    logic = Get.find<TopicMoreDetailLogic>(tag: _tag);
    // initialIndex 必须与 [state.filterTabIndex] 严格一致；之前误把下界写成 1，
    // 导致默认显示 tab 1 但 logic 仍认为在 tab 0：
    // 用户下拉 tab 1 时，[getData] 里 [state.activeBodyPullRefresh] 取的是
    // tab 0 的 [PullRefreshController]，调用的是错对象的 [refreshCompleted]，
    // 实际下拉那个 tab 的 [RefreshController] 永远收不到完成信号 ——
    // WaterDropHeader 因此一直停在加载态不消失。
    _tabController = TabController(
      length: TopicMoreDetailState.filterTabs.length,
      vsync: this,
      initialIndex: state.filterTabIndex.clamp(
        0,
        TopicMoreDetailState.filterTabs.length - 1,
      ),
    )..addListener(_onTabChanged);
    _prevTabIndex = _tabController.index;
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == _prevTabIndex) return;
    _prevTabIndex = _tabController.index;
    logic.setFilterTab(_tabController.index);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TopicMoreDetailLogic>(
      tag: _tag,
      builder: (_) {
        final title = state.topicName.isEmpty ? '专题详情' : state.topicName;
        return Scaffold(
          backgroundColor: AppColor.scaffoldBackground,
          appBar: commonAppBar(
            title,
            bottom: _buildTabBar(),
          ),
          body: TabBarView(
            controller: _tabController,
            children: List.generate(
              TopicMoreDetailState.filterTabs.length,
              (i) => PullRefreshView(
                controller: state.tabPullRefreshControllers[i],
                onRefresh: () => logic.onRefreshTab(i),
                onLoading: () => logic.onLoadTab(i),
                retryOnTap: () => logic.onRefreshTab(i),
                child: CustomScrollView(
                  key: PageStorageKey<String>('topic_more_detail_$i'),
                  slivers: [
                    _buildVideoSliver(i),
                    SliverToBoxAdapter(child: SizedBox(height: 12.w)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSize _buildTabBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(48.h),
      child: SizedBox(
        height: 48.h,
        child: Material(
          color: AppColor.scaffoldBackground,
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            labelColor: AppColor.primaryText,
            unselectedLabelColor: AppColor.hintTextColor,
            labelStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
            indicatorColor: Colors.transparent,
            indicatorWeight: 1,
            indicatorPadding: EdgeInsets.zero,
            dividerColor: Colors.transparent,
            tabs: [
              for (final t in TopicMoreDetailState.filterTabs) Tab(text: t),
            ],
          ),
        ),
      ),
    );
  }

  /// 渲染**指定 tab** 的视频列表。
  ///
  /// 不再从 [state.videoItems]（基于 [filterTabIndex] 的 getter）取数据，
  /// 改用 `state.tabVideoItems[tabIndex]` 各取各的；这样左右滑切 tab 时
  /// 旁边那一页一直显示自己的列表，不会被当前 tab 的数据「短暂替换」。
  Widget _buildVideoSliver(int tabIndex) {
    final pad = EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0);
    final list = state.tabVideoItems[tabIndex];
    if (list.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final bool isShortVideo = state.videoType == 1;
    return getFourGrid(
      list,
      sliver: true,
      sliverPadding: pad,
      displayType: isShortVideo
          ? MediaCoverDisplayType.shortvideo
          : MediaCoverDisplayType.landscape,
      // 短视频流走 [navigateToShortPlay] 接管：用当前 tab 的 list/pageNumber
      // 作为初始队列 + 接力翻页 provider；长视频/其他走 [getFourGrid] 默认的
      // [jumpMediaPlayByModel]，沿用现网行为。
      onItemClick: isShortVideo ? logic.navigateToShortPlay : null,
    );
  }
}
