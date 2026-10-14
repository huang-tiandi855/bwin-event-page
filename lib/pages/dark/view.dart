import 'package:comics_app/common/services/scroll_metrics_manager.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/utils/event_bus/event_bus_util.dart';
import 'package:comics_app/common/widgets/tab_widgets/tabbar_listener_wrapper.dart';
import 'package:comics_app/pages/dark/widgets/dark_navigation_drawer.dart';
import 'package:comics_app/pages/dark/widgets/dark_overlay_page.dart';
import 'package:comics_app/pages/home_index/home_index_category_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../common/widgets/index_page_top_bar.dart';
import 'logic.dart';
import 'state.dart';

class DarkPage extends StatefulWidget {
  const DarkPage({
    Key? key,
    required this.initialJumpEevent,
  }) : super(key: key);

  final DarkJumpModuleEvent? initialJumpEevent;

  @override
  State<DarkPage> createState() => _DarkPageState();
}

class _DarkPageState extends State<DarkPage> {
  late DarkLogic logic;

  @override
  void initState() {
    logic = Get.put(
      DarkLogic(initialJumpEevent: widget.initialJumpEevent),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DarkLogic>(
      builder: (_) {
        final DarkState state = logic.state;
        return Scaffold(
          backgroundColor: AppColor.scaffoldBackground,
          body: Stack(
            children: [
              SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    IndexPageTopBar(
                      horizontalPadding: state.topBarHorizontalPadding,
                      searchHint: state.topBarSearchHint,
                      onSearchTap: logic.onSearchTap,
                      onSignInTap: logic.onSignInTap,
                      onMenuTap: () => showDarkNavigationDrawer(context, logic),
                    ),
                    if (state.categoryModules.isNotEmpty)
                      HomeIndexCategoryTabBar(
                        controller: logic.categoryTabController!,
                        modules: state.categoryModules,
                      ),
                    Expanded(
                      // 与首页保持一致：用 [TabBarViewListenWrapper] 把每个一级 Tab
                      // 内的滚动 offset 同步到 [ScrollMetricsGroup.dark]，让底部
                      // 「暗网」图标在视频 / 专题列表被滑下去后切成返顶图标，
                      // 再次点击则把当前 Tab 的列表滚回顶部。
                      child: state.categoryModules.isEmpty
                          ? _DarkEmptyView(onRetry: logic.retryGetDarkCategory)
                          : TabBarViewListenWrapper(
                              group: ScrollMetricsGroup.dark,
                              controller: logic.categoryTabController!,
                              children: List.generate(
                                state.categoryModules.length,
                                (i) {
                                  final m = state.categoryModules[i];
                                  return TabBarViewItem(
                                    uniqueKey: ScrollKey<String>(
                                      key: logic.primaryTabUniqueTag(m, i),
                                    ),
                                    child: logic.primaryTabPage(m, i),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const DarkOverlayPage(),
            ],
          ),
        );
      },
    );
  }
}

class _DarkEmptyView extends StatelessWidget {
  const _DarkEmptyView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onRetry,
        child: Text(
          '暂无禁区内容\n点击重试',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(.5),
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}
