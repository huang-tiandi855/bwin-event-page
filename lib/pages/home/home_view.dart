import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/services/scroll_metrics_manager.dart';
import 'package:comics_app/common/utils/event_bus/event_bus_util.dart';
import 'package:comics_app/common/utils/screen.dart';
import 'package:comics_app/common/utils/utils.dart';
import 'package:comics_app/common/utils/widget_utils.dart';
import 'package:comics_app/common/values/config.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/common/widgets/loading_widget.dart';
import 'package:comics_app/common/widgets/space_widget.dart';
import 'package:comics_app/common/widgets/tab_widgets/tabbar_listener_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../common/widgets/draggable_floating_action_button.dart';
import '../../common/widgets/tab_widgets/yj_video_tabbar.dart';
import '../../generated/assets.dart';
import 'home_logic.dart';
import 'home_menu_tab.dart';
import 'home_state.dart';
import 'package:comics_app/common/utils/ads_manage/ads_info_list_extension.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.initialJumpEevent,
  }) : super(key: key);

  final HomeJumpModuleEvent? initialJumpEevent;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeLogic logic;
  HomeState get state => Get.find<HomeLogic>().state;

  @override
  void initState() {
    logic = Get.put(HomeLogic(initialJumpEevent: widget.initialJumpEevent));
    // Get.put(FeaturedLogic());
    // state.scrollController?.addListener(() {
    //   // print(state.scrollController?.offset); //打印滚动位置
    //   if (state.scrollController!.offset - 202.w < 50.w) {
    //     state.navBgOpacity = 0.0;
    //   } else if (state.scrollController!.offset - 202.w > 50.w) {
    //     state.navBgOpacity = 1.0;
    //   } else {
    //     state.navBgOpacity = (state.scrollController!.offset - 202.w) / 50.w;
    //   }
    //   setState(() {});
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return state.banner == null
        ? const LoadingWidget()
        : Scaffold(
            body: createContent(),
          );
  }

  Widget createOtherBody() {
    return NestedScrollView(
        headerSliverBuilder: (context, bool innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                    pinned: false,
                    snap: true,
                    backgroundColor: Colors.transparent,
                    floating: true,
                    expandedHeight: 40,
                    title: Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: Row(children: [
                          getWidth(7.w),
                          HomeMenuTab(
                            tabController: state.tabControllerTop,
                          ),
                          const Spacer(),
                          GestureDetector(
                              onTap: () {
                                Get.toNamed(AppRoutes.SEARCH_PAGE);
                              },
                              child: SvgPicture.asset(
                                Assets.acgHomeSearchIcon,
                                width: 20.w,
                                height: 20.w,
                                color: Colors.white,
                              )),
                          getWidth(16.w),
                          GestureDetector(
                              onTap: () {
                                // Get.toNamed(AppRoutes.);
                              },
                              child: SvgPicture.asset(
                                Assets.acgHistoryIcon,
                                width: 20.w,
                                height: 20.w,
                                color: Colors.white,
                              )),
                          getWidth(16.w),
                          GestureDetector(
                              onTap: () {
                                Get.toNamed(AppRoutes.CATEGORIES_PAGE);
                              },
                              child: SvgPicture.asset(
                                Assets.acgAllCategoryIcon,
                                width: 20.w,
                                height: 20.w,
                                color: Colors.white,
                              )),
                        ])))),
          ];
        },
        body: Container(
            color: Colors.transparent,
            child: Column(children: [
              Container(
                  height: 45.w,
                  alignment: Alignment.bottomCenter,
                  child: Column(children: [
                    Container(
                        margin: const EdgeInsets.only(left: 16, right: 6),
                        height: 45.w,
                        child: TabBarView(
                            controller: state.tabControllerTop,
                            children: [
                              YJCustomeTabBar(
                                controller: state.comicTabController,
                                labelStyle: TextStyle(
                                    fontSize: 20.w,
                                    fontWeight: FontWeight.w600),
                                unselectedLabelStyle: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400),
                                isScrollable: true,
                                labelColor:
                                    const Color.fromRGBO(255, 231, 189, 1),
                                unselectedLabelColor:
                                    const Color.fromRGBO(245, 245, 245, 1),
                                tabs: state.comicTabs,
                              ),
                              YJCustomeTabBar(
                                controller: state.tabController,
                                labelStyle: TextStyle(
                                    fontSize: 20.w,
                                    fontWeight: FontWeight.w600),
                                unselectedLabelStyle: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400),
                                isScrollable: true,
                                labelColor:
                                    const Color.fromRGBO(255, 231, 189, 1),
                                unselectedLabelColor:
                                    const Color.fromRGBO(245, 245, 245, 1),
                                tabs: state.tabs,
                              ),
                              YJCustomeTabBar(
                                  controller: state.xsTabController,
                                  labelStyle: TextStyle(
                                      fontSize: 20.w,
                                      fontWeight: FontWeight.w600),
                                  unselectedLabelStyle: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400),
                                  isScrollable: true,
                                  labelColor:
                                      const Color.fromRGBO(255, 231, 189, 1),
                                  unselectedLabelColor:
                                      const Color.fromRGBO(245, 245, 245, 1),
                                  tabs: state.xsTabs),
                            ])),
                  ])),
              Expanded(
                  child: GetBuilder(
                      init: logic,
                      builder: (_) {
                        return TabBarView(
                            controller: state.tabControllerTop,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              TabBarViewListenWrapper(
                                  group: ScrollMetricsGroup.home,
                                  controller: state.comicTabController,
                                  children: state.comicTabsViewWidget.map((e) {
                                    return TabBarViewItem(
                                        uniqueKey: ScrollKey(key: e.hashCode),
                                        child: e);
                                  }).toList()),
                              TabBarViewListenWrapper(
                                  group: ScrollMetricsGroup.home,
                                  controller: state.tabController,
                                  children:
                                      state.cartoonTabsViewWidget.map((e) {
                                    return TabBarViewItem(
                                        uniqueKey: ScrollKey(key: e.hashCode),
                                        child: e);
                                  }).toList()),
                              TabBarViewListenWrapper(
                                  group: ScrollMetricsGroup.home,
                                  controller: state.xsTabController,
                                  children: state.xsTabsViewWidget.map((e) {
                                    return TabBarViewItem(
                                        uniqueKey: ScrollKey(key: e.hashCode),
                                        child: e);
                                  }).toList()),
                            ]);
                      })),
            ])));
  }

  Widget createContent() {
    return Stack(
      key: state.parentKey,
      children: [
        if (Config.isNewYearTheme()) ...[
          newYearContainer(fit: BoxFit.fitWidth)
        ] else ...[
          Container(
            height: 141.w,
            alignment: Alignment.bottomCenter,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(Assets.acgHomeTitleBg),
                    fit: BoxFit.cover)),
          ),
        ],
        SafeArea(child: createOtherBody()),
        GetBuilder<HomeLogic>(builder: (_) {
          return state.floatingAds.isEmpty || !state.shoFloatAds
              ? const SizedBox()
              : DraggableFloatingActionButton(
                  initialOffset: Offset(0.8.sw,
                      Screen.height - 82.r - Screen.bottomNavigationBarHeight),
                  parentKey: state.parentKey,
                  onPressed: () {
                    state.floatingAds.first.jumpAdvByType(AdsType.banner);
                  },
                  child: Container(
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(color: Colors.grey, blurRadius: 10)
                        ],
                      ),
                      width: 60.r,
                      height: 60.r,
                      child: Stack(
                        children: [
                          CustomImage(
                            url: state.floatingAds.first.resourceUrl,
                            width: 60.r,
                            height: 60.r,
                            borderRadius: BorderRadius.circular(10),
                            fit: BoxFit.contain,
                          ),
                          Positioned(
                              right: 4,
                              top: 4,
                              child: GestureDetector(
                                onTap: () {
                                  state.shoFloatAds = false;
                                  logic.update();
                                },
                                child: Image.asset(
                                  Assets.pngAdsClose,
                                  width: 12,
                                  height: 12,
                                ),
                              ))
                        ],
                      )),
                );
        }),
      ],
    );
  }
}
