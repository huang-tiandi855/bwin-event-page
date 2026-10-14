import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/common/widgets/community_style.dart';
import 'package:comics_app/common/widgets/item/home_video_list_widgets.dart';
import 'package:comics_app/common/widgets/item/meida_cover_item.dart';
import 'package:comics_app/common/widgets/novel_style.dart';
import 'package:comics_app/common/widgets/photos_style.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:comics_app/common/values/widgetAttibutes/RoundUnderlineTablndicator.dart';

import '../widgets/dating_style.dart';
import '../widgets/games_style.dart';
import 'mine_media_list_base_logic.dart';

/// 顶栏 + 横向 Tab + 各类型列表（带编辑多选与底部操作条）。
class MineMediaListShell extends StatefulWidget {
  const MineMediaListShell({super.key, required this.logic});

  final MineMediaListBaseLogic logic;

  @override
  State<MineMediaListShell> createState() => _MineMediaListShellState();
}

class _MineMediaListShellState extends State<MineMediaListShell>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// 已经构建过 body 的 Tab 索引集合；未在其中的 Tab 在 [TabBarView] 里只占位、
  /// 不实例化 `PullRefreshView` / `CustomScrollView` / `SmartRefresher` 等重对象。
  /// 用户点选或滑动经过哪一个 Tab，就懒挂载哪一个，挂载后保留不再销毁。
  final Set<int> _visitedTabs = <int>{};

  void _tick() {
    if (mounted) setState(() {});
  }

  void _onTabControllerTick() {
    if (_tabController.indexIsChanging) return;
    widget.logic.setTabIndex(_tabController.index);
    // 切到新 Tab 时仅在首次访问触发数据拉取；已加载过的 Tab 走缓存，
    // 避免来回切 Tab 反复请求。
    widget.logic.ensureTabLoaded(_tabController.index);
  }

  /// 监听 [TabController.animation]，按 floor/ceil 把滑动过程中两侧 Tab 都标记
  /// 为已访问，避免在滑动中段才挂载导致出现「空白闪」。仅当集合发生增量变化
  /// 时触发 `setState`，常态下 listener 走一次 `Set.add` 直接 no-op，开销极低。
  void _onTabAnimationTick() {
    final double? v = _tabController.animation?.value;
    if (v == null) return;
    final bool addedFrom = _visitedTabs.add(v.floor());
    final bool addedTo = _visitedTabs.add(v.ceil());
    if ((addedFrom || addedTo) && mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.logic.tabs.length,
      vsync: this,
    );
    _visitedTabs.add(_tabController.index);
    _tabController.addListener(_onTabControllerTick);
    _tabController.animation?.addListener(_onTabAnimationTick);
    widget.logic.attachShell(_tick);
  }

  @override
  void dispose() {
    widget.logic.detachShell();
    _tabController.animation?.removeListener(_onTabAnimationTick);
    _tabController.removeListener(_onTabControllerTick);
    _tabController.dispose();
    super.dispose();
  }

  Widget _wrapPullRefresh(int tabIndex, Widget scroll) {
    final logic = widget.logic;
    if (!logic.supportsPullRefresh) return scroll;
    final controller = logic.pullRefreshForTab(tabIndex);
    if (controller == null) return scroll;
    return PullRefreshView(
      controller: controller,
      onRefresh: () => logic.onMineListRefresh(tabIndex),
      onLoading: () => logic.onMineListLoadMore(tabIndex),
      retryOnTap: () => logic.onMineListRefresh(tabIndex),
      child: scroll,
    );
  }

  Widget _tabBody(int i) {
    final logic = widget.logic;
    final spec = logic.tabs[i];
    final editing = logic.editing;
    final sel = logic.selectedPerTab[i];
    final pad = EdgeInsets.symmetric(horizontal: 16.w);
    final bottomPad = editing ? 88.w : 22.w;

    switch (spec.kind) {
      case MineMediaPaneKind.longVideo:
        return _wrapPullRefresh(
          i,
          CustomScrollView(
            key: PageStorageKey<String>('mine_mv_long_$i'),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              getFourGridWithSelection(
                logic.longVideoItems,
                sliver: true,
                displayType: MediaCoverDisplayType.landscape,
                sliverPadding: pad,
                selectionMode: editing,
                selectedIndices: sel,
                onToggleSelection:
                    editing ? (idx) => logic.toggleItemSelection(i, idx) : null,
                onItemClickWhenInactive:
                    editing ? null : (idx) => logic.onLongVideoItemTap(i, idx),
              ),
              SliverToBoxAdapter(child: SizedBox(height: bottomPad)),
            ],
          ),
        );
      case MineMediaPaneKind.shortVideo:
        return _wrapPullRefresh(
          i,
          CustomScrollView(
            key: PageStorageKey<String>('mine_mv_short_$i'),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              getFourGridWithSelection(
                logic.shortVideoItems,
                sliver: true,
                displayType: MediaCoverDisplayType.shortvideo,
                sliverPadding: pad,
                selectionMode: editing,
                selectedIndices: sel,
                onToggleSelection:
                    editing ? (idx) => logic.toggleItemSelection(i, idx) : null,
                onItemClickWhenInactive:
                    editing ? null : (idx) => logic.onShortVideoItemTap(i, idx),
              ),
              SliverToBoxAdapter(child: SizedBox(height: bottomPad)),
            ],
          ),
        );
      case MineMediaPaneKind.anime:
        return _wrapPullRefresh(
          i,
          CustomScrollView(
            key: PageStorageKey<String>('mine_mv_anime_$i'),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              getFourGridWithSelection(
                logic.animeItems,
                sliver: true,
                displayType: MediaCoverDisplayType.landscape,
                sliverPadding: pad,
                selectionMode: editing,
                selectedIndices: sel,
                onToggleSelection:
                    editing ? (idx) => logic.toggleItemSelection(i, idx) : null,
                onItemClickWhenInactive: editing
                    ? null
                    : (_) {
                        // TODO: 跳转动漫详情
                      },
              ),
              SliverToBoxAdapter(child: SizedBox(height: bottomPad)),
            ],
          ),
        );
      case MineMediaPaneKind.post:
        return _wrapPullRefresh(
          i,
          CustomScrollView(
            key: PageStorageKey<String>('mine_post_$i'),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              getPostListStyleWithSelection(
                items: logic.postItems,
                selectionMode: editing,
                selectedIndices: sel,
                onCellTap: (idx, item) {
                  if (editing) {
                    logic.toggleItemSelection(i, idx);
                  } else {
                    jumpPostDetail(item.id.toString());
                  }
                },
              ),
              SliverToBoxAdapter(child: SizedBox(height: bottomPad)),
            ],
          ),
        );
      case MineMediaPaneKind.comic:
        return _wrapPullRefresh(
          i,
          CustomScrollView(
            key: PageStorageKey<String>('mine_comic_$i'),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              getNovelSixGridStyleWithSelection(
                items: logic.comicItems,
                selectionMode: editing,
                selectedIndices: sel,
                onCellTap: (idx) {
                  if (editing) {
                    logic.toggleItemSelection(i, idx);
                  } else {
                    // TODO: 跳转漫画详情
                  }
                },
              ),
              SliverToBoxAdapter(child: SizedBox(height: bottomPad)),
            ],
          ),
        );
      case MineMediaPaneKind.gallery:
        return _wrapPullRefresh(
          i,
          CustomScrollView(
            key: PageStorageKey<String>('mine_gallery_$i'),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              getPhotosFourGridStyleWithSelection(
                items: logic.photoItems,
                selectionMode: editing,
                selectedIndices: sel,
                onCellTap: (idx) {
                  if (editing) {
                    logic.toggleItemSelection(i, idx);
                  } else {
                    // TODO: 跳转图集详情
                  }
                },
              ),
              SliverToBoxAdapter(child: SizedBox(height: bottomPad)),
            ],
          ),
        );
      case MineMediaPaneKind.game:
        return _wrapPullRefresh(
          i,
          CustomScrollView(
            key: PageStorageKey<String>('mine_game_$i'),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              getGameFourGridStyleWithSelection(
                items: logic.gameItems,
                selectionMode: editing,
                selectedIndices: sel,
                onCellTap: (idx) {
                  if (editing) {
                    logic.toggleItemSelection(i, idx);
                  } else {
                    final item = logic.gameItems[idx];
                    jumpGameDetail('${item.id}');
                  }
                },
              ),
              SliverToBoxAdapter(child: SizedBox(height: bottomPad)),
            ],
          ),
        );
      case MineMediaPaneKind.dating:
        return _wrapPullRefresh(
          i,
          CustomScrollView(
            key: PageStorageKey<String>('mine_dating_$i'),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              getDatingListStyleWithSelection(
                items: logic.datingItems,
                selectionMode: editing,
                selectedIndices: sel,
                onCellTap: (idx) {
                  if (editing) {
                    logic.toggleItemSelection(i, idx);
                  } else {
                    jumpDatingDetail(logic.datingItems[idx].id);
                  }
                },
              ),
              SliverToBoxAdapter(child: SizedBox(height: bottomPad)),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final logic = widget.logic;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColor.scaffoldBackground,
      appBar: commonAppBar(
        logic.pageTitle,
        isShowLine: false,
        actions: logic.showEditAction
            ? [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: logic.toggleEditing,
                  child: Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: Center(
                      child: Text(
                        logic.editing ? '取消编辑' : '编辑',
                        style: TextStyle(
                          color: const Color(0x80FFFFFF),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ]
            : null,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              // tabAlignment: TabAlignment.start,
              padding: EdgeInsets.only(left: 8.w),
              labelColor: const Color(0xffFAFAFA),
              unselectedLabelColor: Colors.white.withOpacity(0.5),
              labelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              indicator: RoundUnderlineTabIndicator(
                borderSide:
                    BorderSide(width: 4.w, color: const Color(0xFFFF0808)),
                width: 20.w,
                insets: EdgeInsets.zero,
                gradient: const LinearGradient(
                  colors: [
                    Color(0x00990404),
                    Color(0xFFFF0808),
                  ],
                ),
              ),
              indicatorPadding: EdgeInsets.only(bottom: 6.w),
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              tabs: [for (final t in logic.tabs) Tab(text: t.label)],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 16.w),
          Expanded(
            child: Stack(
              children: [
                TabBarView(
                  controller: _tabController,
                  children: [
                    for (var i = 0; i < logic.tabs.length; i++)
                      _visitedTabs.contains(i)
                          ? _tabBody(i)
                          : const SizedBox.shrink(),
                  ],
                ),
                if (logic.editing)
                  Positioned(
                    bottom: 22.w,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: double.infinity,
                      height: 54.w,
                      margin: EdgeInsets.fromLTRB(
                          22.w, 10.w, 22.w, 10.w + bottomInset),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.5),
                          borderRadius: BorderRadius.circular(27)),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 54.w,
                              child: GestureDetector(
                                onTap: logic.selectAllCurrentTab,
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '全选',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                              width: 1.w,
                              height: 27.w,
                              color: Colors.white.withOpacity(0.3)),
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: () =>
                                    logic.deleteSelectedForCurrentTab(),
                                child: Container(
                                  width: 85.w,
                                  height: 34.w,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColor.primaryButtonColor,
                                    borderRadius: BorderRadius.circular(17),
                                  ),
                                  child: Text(
                                    '删除 (${logic.currentSelectionCount})',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
