import 'package:comics_app/common/widgets/item/home_video_list_widgets.dart';
import 'package:comics_app/common/widgets/item/meida_cover_item.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'film_search_result_logic.dart';
import 'film_search_result_state.dart';

class FilmSearchResultPage extends StatefulWidget {
  const FilmSearchResultPage({
    super.key,
    this.videoType = 0,
    this.keyWord,
  });

  final int videoType;
  final String? keyWord;

  @override
  State<FilmSearchResultPage> createState() => _FilmSearchResultPageState();
}

class _FilmSearchResultPageState extends State<FilmSearchResultPage> {
  late final FilmSearchResultLogic logic;
  late final String _logicTag;

  @override
  void initState() {
    super.initState();
    _logicTag = 'film_search_${widget.videoType}';
    // 防御性清理：当用户从搜索结果页清空文本框→回到发现页→再次搜索时，
    // 上一次的 `FilmSearchResultLogic` 可能因为没有及时 `Get.delete` 而残留。
    // `Get.put` 对同 tag 已存在的实例会丢弃新对象、复用旧的，导致新关键字搜不出来。
    // 所以这里先强制删除旧实例，再注册一份带新 initialKeyword 的全新实例。
    if (Get.isRegistered<FilmSearchResultLogic>(tag: _logicTag)) {
      Get.delete<FilmSearchResultLogic>(tag: _logicTag, force: true);
    }
    logic = Get.put(
      FilmSearchResultLogic(
        videoType: widget.videoType,
        initialKeyword: widget.keyWord,
      ),
      tag: _logicTag,
    );
  }

  @override
  void didUpdateWidget(covariant FilmSearchResultPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.keyWord != widget.keyWord) {
      logic.updateKeyword(widget.keyWord);
    }
  }

  @override
  void dispose() {
    // 页面销毁时连带回收 logic，避免下次再次进入时 `Get.put` 复用旧实例。
    Get.delete<FilmSearchResultLogic>(tag: _logicTag, force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FilmSearchResultLogic>(
      tag: _logicTag,
      builder: (_) {
        final tabController = logic.sortTabController;
        if (tabController == null) {
          return const SizedBox.shrink();
        }
        return Column(
          children: [
            _SortTabBar(
              controller: tabController,
              tabs: FilmSearchResultState.sortTabs,
              onSelected: logic.setSortTab,
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  for (var tabIndex = 0;
                      tabIndex < FilmSearchResultState.sortTabs.length;
                      tabIndex++)
                    _FilmSortResultTab(
                      logic: logic,
                      tabIndex: tabIndex,
                      videoType: widget.videoType,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FilmSortResultTab extends StatelessWidget {
  const _FilmSortResultTab({
    required this.logic,
    required this.tabIndex,
    required this.videoType,
  });

  final FilmSearchResultLogic logic;
  final int tabIndex;
  final int videoType;

  @override
  Widget build(BuildContext context) {
    final state = logic.state;
    final items = state.tabVideoItems[tabIndex];
    final pullRefresh = state.tabPullRefreshControllers[tabIndex];

    return PullRefreshView(
      controller: pullRefresh,
      onRefresh: () {
        if (state.filterTabIndex != tabIndex) {
          logic.setSortTab(tabIndex);
          return;
        }
        logic.onRefresh(tabIndex: tabIndex);
      },
      onLoading: () {
        if (state.filterTabIndex != tabIndex) {
          logic.setSortTab(tabIndex);
          return;
        }
        logic.onLoad(tabIndex: tabIndex);
      },
      retryOnTap: logic.onRefresh,
      child: CustomScrollView(
        key: PageStorageKey<String>('film_search_${videoType}_$tabIndex'),
        physics: const BouncingScrollPhysics(),
        slivers: [
          if (items.isEmpty &&
              pullRefresh.requestCode != PULL_REQUEST_CODE.REQUESTING)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 180.w,
                child: Center(
                  child: Text(
                    '暂无相关结果',
                    style: TextStyle(
                      color: Colors.white.withOpacity(.45),
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            )
          else if (items.isNotEmpty)
            getFourGrid(
              items,
              sliver: true,
              sliverPadding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
              displayType: videoType == 1
                  ? MediaCoverDisplayType.shortvideo
                  : MediaCoverDisplayType.landscape,
            ),
          SliverToBoxAdapter(child: SizedBox(height: 12.w)),
        ],
      ),
    );
  }
}

class _SortTabBar extends StatelessWidget {
  const _SortTabBar({
    required this.controller,
    required this.tabs,
    required this.onSelected,
  });

  final TabController controller;
  final List<String> tabs;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.w,
      child: TabBar(
        controller: controller,
        isScrollable: true,
        padding: EdgeInsets.zero,
        tabAlignment: TabAlignment.center,
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
        onTap: onSelected,
        tabs: [for (final tab in tabs) Tab(text: tab)],
      ),
    );
  }
}
