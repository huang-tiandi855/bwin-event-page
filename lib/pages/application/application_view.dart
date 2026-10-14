import 'package:comics_app/common/utils/screen.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/common/widgets/space_widget.dart';
import 'package:comics_app/common/widgets/tab_widgets/tabbar_listener_wrapper.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/pages/ai_index/view.dart';
import 'package:comics_app/pages/circle/circle_view.dart';
import 'package:comics_app/pages/dark/view.dart';
import 'package:comics_app/pages/home_index/home_index_view.dart';
import 'package:comics_app/pages/mine_index/view.dart';
import 'package:comics_app/pages/short_video_main/main/short_video_main_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/widgets/keep_alive_widget.dart';
import 'application_logic.dart';

class ApplicationPage extends StatelessWidget {
  ApplicationPage({Key? key}) : super(key: key);

  final logic = Get.find<ApplicationLogic>();
  final state = Get.find<ApplicationLogic>().state;

  ///内容页
  Widget _buildPageView() {
    return Stack(children: [
      PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: state.pageController,
          children: [
            KeepAliveWidget(GetBuilder<ApplicationLogic>(
                id: 'home',
                builder: (logic) {
                  return HomeIndexPage(
                    initialJumpEevent: state.homeJumpModuleEvent,
                  );
                })),
            KeepAliveWidget(GetBuilder<ApplicationLogic>(
                id: 'douyin',
                builder: (logic) {
                  return const ShortVideoMainPage();
                })),
            KeepAliveWidget(GetBuilder<ApplicationLogic>(
                id: 'ai',
                builder: (logic) {
                  return AiIndexPage();
                })),
            KeepAliveWidget(GetBuilder<ApplicationLogic>(
                id: 'dark',
                builder: (logic) {
                  return DarkPage(
                    initialJumpEevent: state.darkJumpModuleEvent,
                  );
                })),
            KeepAliveWidget(GetBuilder<ApplicationLogic>(
                id: 'community',
                builder: (logic) {
                  return CirclePage(
                    initialJumpEevent: state.communityJumpModuleEvent,
                  );
                })),
            KeepAliveWidget(GetBuilder<ApplicationLogic>(
                id: 'mine',
                builder: (logic) {
                  return const MineIndexPage();
                })),
          ]),
      // Positioned(
      //     right: 10.w,
      //     bottom: 145.w,
      //     child: Visibility(
      //         visible: PreSaleGlobalInfo().hasOpenPreSale(),
      //         child: const ShakeAnimationView()))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    DateTime? lastPressedAt; //上次点击时间
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        // Web 端没有「退出应用」概念，让浏览器走默认 history 回退。
        if (kIsWeb) {
          Navigator.of(context).pop();
          return;
        }
        final now = DateTime.now();
        if (lastPressedAt == null ||
            now.difference(lastPressedAt!) > const Duration(seconds: 3)) {
          lastPressedAt = now;
          showToast(msg: "再次点击退出应用哟～");
          return;
        }
        // 注意：当前 [PopScope] 把 `canPop` 锁成 false，Navigator.pop 会被
        // 框架拦下来再次回调到这里，根本走不出去；要真正退出 Android 必须
        // 调系统 API。iOS 不允许应用主动退出，这条 channel 会被 OS 忽略，
        // 行为等同于无操作（不会崩溃），所以可以一视同仁地调用。
        SystemNavigator.pop();
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.black,
        body: _buildPageView(),
        bottomNavigationBar: Obx(() {
          final bottomNavigationBarHeight = Screen.bottomSafeHeight + 58.w;
          return Container(
            width: 1.sw,
            height: bottomNavigationBarHeight,
            alignment: Alignment.topCenter,
            decoration: const BoxDecoration(color: Colors.black),
            padding: EdgeInsets.only(top: 10.w),
            child: Row(
              children: state.tabs.map((e) {
                final bool isSelected = state.curTabIndex.value == e.index;
                AssetGenImage icon = isSelected ? e.selIcon : e.icon;

                late Widget child;

                final text = Text(
                  e.title,
                  style: textStyle(
                      11,
                      !isSelected
                          ? Colors.white.withOpacity(0.3)
                          : Colors.white,
                      FontWeight.w500),
                );
                Widget iconWidget = icon.image(
                    width: e.iconWidth ?? 24.w, height: e.iconHeight ?? 24.w);

                if (e.listenerGroup != null) {
                  child = ScrollMetricsListenableBuilder(
                    group: e.listenerGroup!,
                    builder: (context, value, child) {
                      if (value > 0 && isSelected) {
                        return AssetsGen.images.circle.backTop.image(
                          width: e.iconWidth ?? 24.w,
                          height: e.iconHeight ?? 24.w,
                          fit: BoxFit.fitHeight,
                        );
                      }
                      return iconWidget;
                    },
                  );
                } else {
                  child = iconWidget;
                }

                child = Container(
                  height: bottomNavigationBarHeight,
                  alignment: Alignment.center,
                  child: Column(
                    children: [child, getHeight(3), text],
                  ),
                );

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      logic.handleNavBarTap(e.index);
                    },
                    child: child,
                  ),
                );
              }).toList(),
            ),

            // BottomNavigationBar(
            //   type: BottomNavigationBarType.fixed,
            //   currentIndex: state.curTabIndex.value,
            //   onTap: logic.handleNavBarTap,
            //   selectedFontSize: 0.sp,
            //   showSelectedLabels: false,
            //   elevation: 0.0,
            //   showUnselectedLabels: false,
            //   unselectedFontSize: 0.sp,
            //   backgroundColor: Colors.transparent,
            //   iconSize: 0,
            //   fixedColor: Colors.white,
            //   unselectedItemColor: Colors.white,
            //   useLegacyColorScheme: false,
            //   selectedLabelStyle: const TextStyle(fontSize: 1),
            //   unselectedLabelStyle: const TextStyle(fontSize: 1),
            //   items: const [],
            // ),
          );
        }),
      ),
    );
  }
}
