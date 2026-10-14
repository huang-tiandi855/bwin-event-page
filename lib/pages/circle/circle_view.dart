import 'package:comics_app/common/utils/system_ui_util.dart';
import 'package:comics_app/common/services/scroll_metrics_manager.dart';
import 'package:comics_app/common/utils/event_bus/event_bus_util.dart';
import 'package:comics_app/common/utils/screen.dart';
import 'package:comics_app/common/widgets/tab_widgets/tabbar_listener_wrapper.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/pages/circle/community/community_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../common/routers/app_routes.dart';
import 'circle_logic.dart';
import 'dating/dating_tab_view.dart';
import 'games/games_tab_view.dart';

class CirclePage extends StatelessWidget {
  const CirclePage({
    Key? key,
    required this.initialJumpEevent,
  }) : super(key: key);

  final CommunityJumpModuleEvent? initialJumpEevent;

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(CircleLogic(initialJumpEevent: initialJumpEevent));
    return buildScaffold(logic, context);
  }

  Scaffold buildScaffold(CircleLogic logic, BuildContext context) {
    const pageBg = Colors.black;
    final contentBottomInset = Screen.bottomSafeHeight + 52.w;
    final fabBottom = Screen.bottomSafeHeight + 52.w + 24.w;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        toolbarHeight: kAppBarToolbarHeight,
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 8.w,
        title: _buildTopBar(logic),
        actions: _buildAppBarActions(),
      ),
      body: Stack(
        children: [
          ColoredBox(
            color: pageBg,
            child: Padding(
              padding: EdgeInsets.only(bottom: contentBottomInset),
              child: TabBarViewListenWrapper(
                group: ScrollMetricsGroup.circle,
                controller: logic.state.tabController,
                scrollCallback: (value) {
                  debugPrint('scrollCallback => $value');
                  logic.updateShowOrHide(value);
                },
                children: [
                  TabBarViewItem(
                    uniqueKey: const ScrollKey<int>(
                      key: 7100,
                      isNestedScroll: true,
                    ),
                    child: GetBuilder<CircleLogic>(
                      id: 'community_tab_view',
                      builder: (_) {
                        return CommunityTabView(
                          postingCategory: logic.state.postingCategory,
                          tabPostingIndex: logic.state.tabPostingIndex.value,
                          status: logic.state.postingCategoryStatus,
                          onRetry: logic.retryGetPostingCategory,
                        );
                      },
                    ),
                  ),
                  const TabBarViewItem(
                    uniqueKey: ScrollKey<int>(
                      key: 7102,
                      isNestedScroll: true,
                    ),
                    child: GamesTabView(),
                  ),
                  const TabBarViewItem(
                    uniqueKey: ScrollKey<int>(
                      key: 7103,
                      isNestedScroll: true,
                    ),
                    child: DatingTabView(),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: fabBottom,
            right: 26.w,
            child: Obx(() {
              if (logic.state.tabSelectIndex.value != 0) {
                return const SizedBox.shrink();
              }
              return _placeholderFab(logic);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(CircleLogic logic) {
    final tabH = 23.h;
    final unselectedStyle = TextStyle(
      color: Colors.white.withOpacity(0.5),
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
    );

    return Obx(() {
      final idx = logic.state.tabSelectIndex.value;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _circleMainTab(
            logic: logic,
            index: 0,
            selected: idx == 0,
            label: '社区',
            selectedAsset: AssetsGen.images.circle.circleCommunitySel,
            height: tabH,
            unselectedStyle: unselectedStyle,
          ),
          SizedBox(width: 10.w),
          _circleMainTab(
            logic: logic,
            index: 1,
            selected: idx == 1,
            label: '黄游',
            selectedAsset: AssetsGen.images.circle.circleCommunityGame,
            height: tabH,
            unselectedStyle: unselectedStyle,
          ),
          SizedBox(width: 10.w),
          _circleMainTab(
            logic: logic,
            index: 2,
            selected: idx == 2,
            label: '约会',
            selectedAsset: AssetsGen.images.circle.circleCommunityDating,
            height: tabH,
            unselectedStyle: unselectedStyle,
          ),
          // Expanded(
          //   child: _circleMainTab(
          //     logic: logic,
          //     index: 1,
          //     selected: idx == 1,
          //     label: '图集',
          //     selectedAsset: AssetsGen.images.circle.circleCommunityPhoto,
          //     height: tabH,
          //     unselectedStyle: unselectedStyle,
          //   ),
          // ),
          // Expanded(
          //   child: _circleMainTab(
          //     logic: logic,
          //     index: 2,
          //     selected: idx == 2,
          //     label: '黄游',
          //     selectedAsset: AssetsGen.images.circle.circleCommunityGame,
          //     height: tabH,
          //     unselectedStyle: unselectedStyle,
          //   ),
          // ),
          // Expanded(
          //   child: _circleMainTab(
          //     logic: logic,
          //     index: 3,
          //     selected: idx == 3,
          //     label: '小说',
          //     selectedAsset: AssetsGen.images.circle.circleCommunityNovel,
          //     height: tabH,
          //     unselectedStyle: unselectedStyle,
          //   ),
          // ),
        ],
      );
    });
  }

  Widget _circleMainTab({
    required CircleLogic logic,
    required int index,
    required bool selected,
    required String label,
    required AssetGenImage selectedAsset,
    required double height,
    required TextStyle unselectedStyle,
  }) {
    return InkWell(
      onTap: () => logic.state.tabController.animateTo(index),
      child: SizedBox(
        height: height,
        child: selected
            ? selectedAsset.image(
                height: height,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              )
            : Text(label, style: unselectedStyle),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      IconButton(
        splashRadius: 25.w,
        icon: AssetsGen.images.circle.search.image(
          width: 25.w,
          height: 25.w,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        onPressed: () => Get.toNamed(AppRoutes.SEARCH_PAGE),
      ),
      IconButton(
        splashRadius: 25.w,
        icon: AssetsGen.images.circle.signIn.image(
          width: 25.w,
          height: 25.w,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        onPressed: () => Get.toNamed(AppRoutes.SIGNIN_WELFARE),
      ),
      SizedBox(width: 4.w),
    ];
  }

  /// 占位发布按钮（交互后续再接）。
  Widget _placeholderFab(CircleLogic logic) {
    return InkWell(
      onTap: () => logic.showPostAlert(),
      child:
          AssetsGen.images.circle.postPublish.image(width: 40.w, height: 40.w),
    );
  }
}
