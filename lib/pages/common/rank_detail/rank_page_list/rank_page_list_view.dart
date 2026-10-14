import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/item/anime_ranking_item.dart';
import 'package:comics_app/common/widgets/item/home_topic_widget.dart';
import 'package:comics_app/common/widgets/item/movie_ranking_item.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../rank_detail_logic.dart';
import '../rank_detail_state.dart';

/// 二级周期 Tab 视觉（设计稿：选中渐变底 + 主色字，未选中深底 + 半透明白字，圆角胶囊）。
abstract final class _RankPeriodTabStyle {
  static const List<Color> selectedGradientColors = [
    Color(0xFF312217),
    Color(0xFF312B1D),
  ];
  static const Color selectedText = AppColor.primaryButtonColor;
  static final Color idleBg = Colors.white.withOpacity(.05);
  static final Color idleText = Colors.white.withOpacity(0.5);
}

/// 单个一级 Tab 下的内容：二级 Tab（日/周/月/总）+ [TabBarView] 列表。
class RankPageList extends StatefulWidget {
  const RankPageList({
    super.key,
    required this.primaryTabIndex,
  });

  final int primaryTabIndex;

  @override
  State<RankPageList> createState() => _RankPageListState();
}

class _RankPageListState extends State<RankPageList>
    with SingleTickerProviderStateMixin {
  late final TabController _periodTabController;

  RankDetailLogic get _logic => Get.find<RankDetailLogic>();

  @override
  void initState() {
    super.initState();
    _periodTabController = TabController(
      length: RankDetailState.periodLabels.length,
      vsync: this,
    );
    _periodTabController.addListener(_onPeriodChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.primaryTabIndex != 0 && widget.primaryTabIndex != 1) return;
      if (!_logic.isPrimaryRankVisible(widget.primaryTabIndex)) return;
      _logic.ensureRankPeriodLoaded(
        primaryTabIndex: widget.primaryTabIndex,
        periodIndex: _periodTabController.index,
      );
    });
  }

  void _onPeriodChanged() {
    if (!mounted) return;
    if (_periodTabController.indexIsChanging) return;
    if (widget.primaryTabIndex != 0 && widget.primaryTabIndex != 1) return;
    if (!_logic.isPrimaryRankVisible(widget.primaryTabIndex)) return;
    _logic.ensureRankPeriodLoaded(
      primaryTabIndex: widget.primaryTabIndex,
      periodIndex: _periodTabController.index,
    );
  }

  @override
  void dispose() {
    _periodTabController.removeListener(_onPeriodChanged);
    _periodTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTabView(),
        Expanded(
          child: TabBarView(
            controller: _periodTabController,
            children: widget.primaryTabIndex == 0
                ? _filmRank()
                : widget.primaryTabIndex == 1
                    ? _animeRank()
                    : List.generate(
                        RankDetailState.periodLabels.length,
                        (_) => const SizedBox.shrink(),
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabView() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: _RankPeriodTabStyle.selectedText.withOpacity(0.12),
          highlightColor: Colors.white.withOpacity(0.04),
        ),
        child: AnimatedBuilder(
          animation: _periodTabController,
          builder: (BuildContext context, Widget? child) {
            final int cur = _periodTabController.index;
            return TabBar(
              controller: _periodTabController,
              isScrollable: false,
              padding: EdgeInsets.zero,
              tabAlignment: TabAlignment.fill,
              splashFactory: NoSplash.splashFactory,
              overlayColor:
                  MaterialStateProperty.all<Color>(Colors.transparent),
              dividerColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              indicatorWeight: 0,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: const BoxDecoration(color: Colors.transparent),
              labelColor: _RankPeriodTabStyle.selectedText,
              unselectedLabelColor: _RankPeriodTabStyle.idleText,
              labelStyle: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
              ),
              tabs: [
                for (int i = 0; i < RankDetailState.periodLabels.length; i++)
                  SizedBox(
                    width: 48.w,
                    height: 30.h,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 50),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        gradient: cur == i
                            ? const LinearGradient(
                                colors:
                                    _RankPeriodTabStyle.selectedGradientColors,
                              )
                            : null,
                        color: cur == i ? null : _RankPeriodTabStyle.idleBg,
                      ),
                      child: Text(
                        RankDetailState.periodLabels[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight:
                              cur == i ? FontWeight.w600 : FontWeight.w400,
                          color: cur == i
                              ? _RankPeriodTabStyle.selectedText
                              : _RankPeriodTabStyle.idleText,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 影片：日 / 周 / 月 / 总，各绑定 [RankDetailState.rankPeriodPullRefreshControllers] 之一。
  List<Widget> _filmRank() {
    return List.generate(
      RankDetailState.periodLabels.length,
      (int periodIndex) => _buildFilmPeriodPage(periodIndex),
    );
  }

  /// 动漫：日 / 周 / 月 / 总。
  List<Widget> _animeRank() {
    return List.generate(
      RankDetailState.periodLabels.length,
      (int periodIndex) => _buildAnimePeriodPage(periodIndex),
    );
  }

  Widget _buildFilmPeriodPage(int periodIndex) {
    return GetBuilder<RankDetailLogic>(
      builder: (RankDetailLogic logic) {
        final bool bindPull = logic.isPrimaryRankVisible(0);
        final list = logic.state.filmRankLists[periodIndex];
        final Widget scroll = ListView.separated(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (_, __) => 16.h.verticalSpace,
          itemBuilder: (BuildContext context, int index) {
            return MovieRankingItem(
              model: list[index],
              rank: index + 1,
              onTap: () => jumpMediaPlay(list[index].id ?? ''),
            );
          },
        );
        if (!bindPull) return scroll;
        return PullRefreshView(
          controller: logic.state.rankPeriodPullRefreshControllers[periodIndex],
          onRefresh: () => logic.onRankRefresh(
            primaryTabIndex: 0,
            periodIndex: periodIndex,
          ),
          onLoading: () => logic.onRankLoad(
            primaryTabIndex: 0,
            periodIndex: periodIndex,
          ),
          retryOnTap: () => logic.onRankRefresh(
            primaryTabIndex: 0,
            periodIndex: periodIndex,
          ),
          child: scroll,
        );
      },
    );
  }

  Widget _buildAnimePeriodPage(int periodIndex) {
    return GetBuilder<RankDetailLogic>(
      builder: (RankDetailLogic logic) {
        final bool bindPull = logic.isPrimaryRankVisible(1);
        final list = logic.state.animeRankLists[periodIndex];
        final Widget scroll = ListView.separated(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (_, __) => 16.h.verticalSpace,
          itemBuilder: (BuildContext context, int index) {
            return AnimeRankingItem(
              model: list[index],
              rank: index + 1,
            );
          },
        );
        if (!bindPull) return scroll;
        return PullRefreshView(
          controller: logic.state.rankPeriodPullRefreshControllers[periodIndex],
          onRefresh: () => logic.onRankRefresh(
            primaryTabIndex: 1,
            periodIndex: periodIndex,
          ),
          onLoading: () => logic.onRankLoad(
            primaryTabIndex: 1,
            periodIndex: periodIndex,
          ),
          retryOnTap: () => logic.onRankRefresh(
            primaryTabIndex: 1,
            periodIndex: periodIndex,
          ),
          child: scroll,
        );
      },
    );
  }
}
