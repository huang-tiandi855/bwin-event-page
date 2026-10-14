import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/ads_manage/ads_banner_icon_group.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/common/widgets/general_widget/sliver_fixed_height_pinned_header.dart';
import 'package:comics_app/common/widgets/item/home_video_list_widgets.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/pages/common/search_page/search_result/search_result_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../search_page_logic.dart';
import '../widgets/search_input_bar.dart';
import 'logic.dart';

class SearchDiscoveryPage extends StatelessWidget {
  const SearchDiscoveryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchDiscoveryLogic>(
      init: SearchDiscoveryLogic(),
      builder: (logic) {
        return GetBuilder<SearchPageLogic>(
          builder: (parentLogic) {
            // 必须用 if/else 区分挂载，而不能用 Stack+Offstage 同时挂两边：
            // SearchResultPage.embedded 内部用 `GetBuilder<SearchResultLogic>(init: ...)`
            // 注册 logic，`init` 只在首次 mount 时生效。Offstage 不会 dispose 子树，
            // 会导致 logic 永远拿不到后续 initialKeyword 的更新，影片模块也就不会按
            // 新关键字发请求。
            if (logic.state.hasSearched) {
              return _searchResultView(logic, parentLogic);
            }
            return _searchMainView(logic, parentLogic);
          },
        );
      },
    );
  }

  /// 搜索结果页
  Widget _searchResultView(
      SearchDiscoveryLogic logic, SearchPageLogic parentLogic) {
    final parentState = parentLogic.state;
    return SearchResultPage.embedded(
      initialKeyword: logic.state.searchKeyword,
      textEditingController: parentState.textEditingController,
    );
  }

  /// 搜索主页
  Widget _searchMainView(
      SearchDiscoveryLogic logic, SearchPageLogic parentLogic) {
    final hotWords = logic.hotWords();
    final discoveryState = logic.state;
    final parentState = parentLogic.state;
    final rankControllers = discoveryState.rankPullRefreshControllers;
    return getBgColorsView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: SearchInputBar(
              controller: parentState.textEditingController,
              onSearch: logic.onSearch,
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: NestedScrollView(
                physics: const BouncingScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  final List<String> historyWords = parentState.searchList;
                  return [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      sliver: const SliverToBoxAdapter(
                        child: AdsBannerIconGroup(
                          // bannerType: AdsType.bannerSearch,
                          iconType: AdsType.dbLineHeadSearch,
                        ),
                      ),
                    ),
                    if (historyWords.isNotEmpty) ...[
                      SliverToBoxAdapter(child: 24.h.verticalSpace),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        sliver: SliverToBoxAdapter(
                          child: _SearchHistoryPanel(
                            items: historyWords,
                            onTap: logic.onSearch,
                            onClear: parentLogic.deleteSelectSearchRecord,
                          ),
                        ),
                      ),
                    ],
                    if (hotWords.isNotEmpty) ...[
                      SliverToBoxAdapter(child: 16.h.verticalSpace),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        sliver: SliverToBoxAdapter(
                          child: _HotSearchPanel(
                            words: hotWords,
                            onTap: logic.onSearch,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: 16.h.verticalSpace),
                    ],
                    SliverFixedHeightPinnedHeader(
                      height: 40.h,
                      child: Container(
                        color: AppColor.scaffoldBackground,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        alignment: Alignment.center,
                        child: const _HotTabBar(),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  children: [
                    _HotVideoGrid(
                      rankIndex: 0,
                      items: discoveryState.weekHotMediaList,
                      controller: rankControllers[0],
                      onRefresh: () => logic.onRankRefresh(0),
                      onLoad: () => logic.onRankLoad(0),
                    ),
                    _HotVideoGrid(
                      rankIndex: 1,
                      items: discoveryState.monthHotMediaList,
                      controller: rankControllers[1],
                      onRefresh: () => logic.onRankRefresh(1),
                      onLoad: () => logic.onRankLoad(1),
                    ),
                    _HotVideoGrid(
                      rankIndex: 2,
                      items: discoveryState.lastMonthHotMediaList,
                      controller: rankControllers[2],
                      onRefresh: () => logic.onRankRefresh(2),
                      onLoad: () => logic.onRankLoad(2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HotSearchPanel extends StatelessWidget {
  const _HotSearchPanel({
    required this.words,
    required this.onTap,
  });

  final List<String> words;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 17.w, 16.w, 17.w),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetsGen.images.search.icSearchHotBg.provider(),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '热门搜索',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          16.h.verticalSpace,
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: words.length > 10 ? 10 : words.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 0.w,
              childAspectRatio: 155 / 20,
            ),
            itemBuilder: (context, index) {
              final text = words[index];
              return GestureDetector(
                onTap: () => onTap(text),
                child: Row(
                  children: [
                    _RankIcon(index: index),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RankIcon extends StatelessWidget {
  const _RankIcon({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final asset = switch (index) {
      0 => 'assets/images/search/ic_search_hot_one.png',
      1 => 'assets/images/search/ic_search_hot_two.png',
      2 => 'assets/images/search/ic_search_hot_three.png',
      _ => null,
    };
    if (asset != null) {
      return Image.asset(asset, width: 16.w, height: 16.w);
    }
    return SizedBox(
      width: 18.w,
      child: Text(
        '${index + 1}',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryYellowColor,
        ),
      ),
    );
  }
}

/// 历史记录面板：标题 + 清空按钮 + Wrap 排列的关键字标签。
///
/// 关键字由调用方按「最新置顶 / 最多 10 条」处理后传入，不再在这里二次过滤。
class _SearchHistoryPanel extends StatelessWidget {
  const _SearchHistoryPanel({
    required this.items,
    required this.onTap,
    required this.onClear,
  });

  final List<String> items;
  final ValueChanged<String> onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '历史记录',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClear,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
                child: AssetsGen.images.search.icSearchHistoryDel.image(
                  width: 20.w,
                  height: 20.w,
                ),
              ),
            ),
          ],
        ),
        16.h.verticalSpace,
        Wrap(
          spacing: 12.w,
          runSpacing: 12.w,
          children: <Widget>[
            for (final String word in items)
              _HistoryChip(text: word, onTap: () => onTap(word)),
          ],
        ),
      ],
    );
  }
}

class _HistoryChip extends StatelessWidget {
  const _HistoryChip({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.05),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withOpacity(.5),
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _HotTabBar extends StatelessWidget {
  const _HotTabBar();

  @override
  Widget build(BuildContext context) {
    return TabBar(
      indicatorColor: Colors.transparent,
      dividerColor: Colors.transparent,
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
      labelPadding: EdgeInsets.zero,
      indicatorWeight: 0,
      indicator: const BoxDecoration(),
      tabs: const [
        Tab(text: '本周最热'),
        Tab(text: '本月最热'),
        Tab(text: '上月最热'),
      ],
    );
  }
}

class _HotVideoGrid extends StatelessWidget {
  const _HotVideoGrid({
    required this.rankIndex,
    required this.items,
    required this.controller,
    required this.onRefresh,
    required this.onLoad,
  });

  final int rankIndex;
  final List<MediaVideoModel> items;
  final PullRefreshController controller;
  final VoidCallback onRefresh;
  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) {
    return PullRefreshView(
      controller: controller,
      onRefresh: onRefresh,
      onLoading: onLoad,
      retryOnTap: onRefresh,
      emptyText: '暂无数据',
      child: CustomScrollView(
        key: PageStorageKey<String>('search_discovery_rank_$rankIndex'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          getFourGrid(
            items,
            sliver: true,
            sliverPadding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
          ),
        ],
      ),
    );
  }
}
