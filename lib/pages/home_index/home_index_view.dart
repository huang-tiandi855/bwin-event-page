import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/services/scroll_metrics_manager.dart';
import 'package:comics_app/common/store/config.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';
import 'package:comics_app/common/widgets/tab_widgets/tabbar_listener_wrapper.dart';
import 'package:comics_app/common/utils/event_bus/event_bus_util.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/pages/home_index/home_index_category_tab_bar.dart';
import 'package:comics_app/pages/home_index/home_index_logic.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../common/widgets/index_page_top_bar.dart';
import 'package:comics_app/common/utils/ads_manage/ads_info_list_extension.dart';

class HomeIndexPage extends StatefulWidget {
  const HomeIndexPage({
    Key? key,
    required this.initialJumpEevent,
  }) : super(key: key);

  final HomeJumpModuleEvent? initialJumpEevent;

  @override
  State<HomeIndexPage> createState() => _HomeIndexPageState();
}

class _HomeIndexPageState extends State<HomeIndexPage> {
  late HomeIndexLogic logic;

  /// 当前展示的悬浮广告（`AdsType.indexFix`）下标；
  /// 点击右上角关闭按钮后自增，越界即整个悬浮区不再展示。
  int _floatAdIndex = 0;

  @override
  void initState() {
    logic = Get.put(
      HomeIndexLogic(initialJumpEevent: widget.initialJumpEevent),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeIndexLogic>(
      builder: (_) {
        final state = logic.state;
        return Scaffold(
          backgroundColor: AppColor.scaffoldBackground,
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    IndexPageTopBar(
                      horizontalPadding: state.topBarHorizontalPadding,
                      onSearchTap: logic.onSearchTap,
                      onSignInTap: logic.onSignInTap,
                      onMenuTap: () => logic.onMenuTap(context),
                    ),
                    HomeIndexCategoryTabBar(
                      controller: logic.categoryTabController,
                      modules: state.categoryModules,
                    ),
                    Expanded(
                      // 用 [TabBarViewListenWrapper] 接管一级 Tab：每个分类对应一个
                      // [ScrollKey]，配合 [VisibilityDetector] 让 [ScrollMetricsManager]
                      // 始终知道「当前可见的页面」是哪一项，从而把任一一级 Tab 内
                      // 列表（视频 / 专题）滚动后的 offset 同步到底部「主页」图标，
                      // 触发返顶。
                      child: TabBarViewListenWrapper(
                        group: ScrollMetricsGroup.home,
                        controller: logic.categoryTabController,
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
                _buildFloatAdView(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatAdView() {
    return Positioned(
      right: 16.w,
      bottom: 70.h,
      child: GetBuilder<ConfigStore>(
        builder: (_) {
          final List<AdsInfoList> ads = getAdsByType(AdsType.indexFix);
          if (ads.isEmpty || _floatAdIndex >= ads.length) {
            return const SizedBox.shrink();
          }
          final AdsInfoList ad = ads[_floatAdIndex];
          return Stack(
            alignment: Alignment.topRight,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => ad.jumpAdvByType(AdsType.indexFix),
                child: CustomImage(
                  url: ad.resourceUrl,
                  width: 70.w,
                  height: 70.h,
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _floatAdIndex += 1),
                child: AssetsGen.images.alertWhiteClose
                    .image(width: 16.w, height: 16.h),
              ),
            ],
          );
        },
      ),
    );
  }
}
