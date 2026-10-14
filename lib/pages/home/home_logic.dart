import 'dart:async';

import 'package:comics_app/common/apis/user.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/entities/modules_config/notice_model.dart';
import 'package:comics_app/common/store/config.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/event_bus/event_bus_util.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';
import 'package:comics_app/common/utils/tab_controller_dispose.dart';
import 'package:comics_app/common/utils/utils.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/common/widgets/common_dialog/image_dialog.dart';
import 'package:comics_app/pages/home/comic2/comic_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/entities/config.dart';
import '../../common/entities/sign_entity.dart';
import '../../common/widgets/common_dialog/announcement_dialog.dart';
import '../../common/widgets/common_ui/common_ui.dart';
import 'comic/comic_view.dart';
import 'home_state.dart';

class HomeLogic extends GetxController with GetTickerProviderStateMixin {
  final HomeState state = HomeState();

  late StreamSubscription subscription;

  final HomeJumpModuleEvent? initialJumpEevent;

  HomeLogic({
    required this.initialJumpEevent,
  });

  @override
  void onInit() {
    super.onInit();

    initComicData();

    initCartoonData();
    initXsData();

    state.tabController = TabController(
        length: state.cartoonLists.length, vsync: this, initialIndex: 0);

    state.comicTabController = TabController(
        length: state.comicLists.length, vsync: this, initialIndex: 0);

    state.xsTabController = TabController(
        length: state.xsLists.length, vsync: this, initialIndex: 0);

    state.tabControllerTop =
        TabController(length: 3, vsync: this, initialIndex: 0);

    state.banner = getAdsByType(AdsType.banner);

    state.bannerImage = getAdsByType(AdsType.banner);

    state.homePageSpecialAds = getAdsByType(AdsType.banner);

    state.floatingAds = getAdsByType(AdsType.banner);

    state.nineAdsTopBanner = getAdsByType(AdsType.banner);

    state.tabController.addListener(() {
      //state.scrollController?.jumpTo(0);
      update();
    });

    subscription = eventBus.on<HomeJumpModuleEvent>(eventBusCallback);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      eventBusCallback(initialJumpEevent);
    });
  }

  @override
  void onClose() {
    eventBus.off(subscription);
    disposeTabControllerAfterRouteExit(state.tabController);
    disposeTabControllerAfterRouteExit(state.tabControllerTop);
    disposeTabControllerAfterRouteExit(state.comicTabController);
    disposeTabControllerAfterRouteExit(state.xsTabController);
    super.onClose();
  }

  void eventBusCallback(HomeJumpModuleEvent? event) {
    if (event == null) {
      return;
    }
    final topIndex = event.subModuleType! - 1;

    int subModuleIndex = -1;

    TabController? tabController;

    if (event.subModuleType == 1) {
      subModuleIndex = state.comicLists
          .indexWhere((element) => element.id.toString() == event.id);
      tabController = state.comicTabController;
    } else if (event.subModuleType == 2) {
      subModuleIndex = state.cartoonLists
          .indexWhere((element) => element.id.toString() == event.id);
      tabController = state.tabController;
    } else if (event.subModuleType == 3) {
      subModuleIndex = state.xsLists
          .indexWhere((element) => element.id.toString() == event.id);
      tabController = state.xsTabController;
    }
    state.tabControllerTop.animateTo(topIndex);
    if (subModuleIndex != -1 && tabController != null) {
      tabController.animateTo(subModuleIndex);
    }
  }

  /*
    1 组合样式
    2 列表 所有帖子列表
    3 图集 图集列表
    4 单个专题  单个专题模块展示
    5 专题合集  总专题+ 所有帖子列表
    6 所有专题
    7 社区样式
    8 二竖屏列表
    9 三竖屏列表
    10 三竖屏三排序列表
    11 三竖屏二排序列表
    12 瀑布流列表
   */

  void initComicData() {
    state.comicTabs.clear();
    state.comicTabsViewWidget.clear();
    for (int i = 0; i < state.comicLists.length; i++) {
      state.comicTabs.add(state.comicLists[i].moduleName ?? "");
      var s = state.comicLists[i];
      fillData(state.comicTabsViewWidget, s.showType, (s.id ?? "").toString(),
          i == 0);
    }
  }

  void initCartoonData() {
    state.tabs.clear();
    state.cartoonTabsViewWidget.clear();
    for (int i = 0; i < state.cartoonLists.length; i++) {
      state.tabs.add(state.cartoonLists[i].moduleName ?? "");
      var s = state.cartoonLists[i];
      fillData(state.cartoonTabsViewWidget, s.showType, (s.id ?? "").toString(),
          i == 0);
    }
  }

  void initXsData() {
    state.xsTabs.clear();
    state.xsTabsViewWidget.clear();
    for (int i = 0; i < state.xsLists.length; i++) {
      var s = state.xsLists[i];
      fillData(
          state.xsTabsViewWidget, s.showType, (s.id ?? "").toString(), i == 0);
      state.xsTabs.add(s.moduleName ?? "");
    }
    update();
  }

  void fillData(List<Widget> widgets, int? showType, String id,
      [bool showJingangqu = false, bool showAd = true]) {
    switch (showType) {
      case 1:
        widgets.add(ComicPage(
            key: Key(id),
            moduleId: id,
            showJingangqu: showJingangqu,
            showAd: showAd));
        break;
      case 8:
        widgets.add(ComicPage2(
            crossCount: 2,
            aspectRatio: 173 / 304,
            key: Key(id.toString()),
            moduleId: id,
            showAd: showAd));
        break;

      case 10:
        widgets.add(ComicPage2(
            crossCount: 3,
            showTabNum: 3,
            key: Key(id.toString()),
            moduleId: id,
            showAd: showAd));
        break;
      case 11:
        widgets.add(ComicPage2(
            crossCount: 3,
            showTabNum: 2,
            key: Key(id.toString()),
            moduleId: id,
            showAd: showAd));
        break;
      case 12:
        widgets.add(ComicPage2(
          key: Key(id.toString()),
          moduleId: id,
          showAd: showAd,
          isFlow: true,
        ));
        break;
      case 9:
      case 4:
      case 2:
        widgets.add(
            ComicPage2(key: Key(id.toString()), moduleId: id, showAd: showAd));
        break;
      default:
        widgets.add(ComicPage(key: Key(id), moduleId: id, showAd: showAd));
        break;
    }
  }

  @override
  void onReady() async {
    super.onReady();

    if (ConfigStore.to.configBean.officialConfigApps!.isNotEmpty) {
      _officialListReq();
    } else {
      getAnnouncement();
      await getAnnounce();
    }
  }

  List<AdsInfoList> loadAds() {
    AdSubResult result =
        AdsManager.subList(state.homePageSpecialAds, state.adCurrentIndex, 5);
    state.adCurrentIndex = result.index;
    debugPrint('===========${result.ads.toString()}==============');
    return result.ads;
  }

  ///1:下载  2:社区
  void _officialListReq() async {
    await showDialog(
        context: Get.context!, //BuildContext对象
        barrierDismissible: false,
        useSafeArea: false,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) {
          return Material(
            color: Colors.transparent,
            child: Container(
              alignment: Alignment.center,
              width: ScreenUtil().screenWidth,
              height: ScreenUtil().screenHeight,
              color: AppColor.black.withOpacity(0.9),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // state.nineAdsTopBanner != null &&
                  //         state.nineAdsTopBanner!.isNotEmpty
                  //     ? Container(
                  //         margin: EdgeInsets.only(
                  //             left: 23.w, right: 23.w, bottom: 26.w),
                  //         height: 90.w,
                  //         child: Swiper(
                  //           itemBuilder: (BuildContext context, int index) {
                  //             return GestureDetector(
                  //               onTap: () {
                  //                 AppNavigator.to.jumpAdv(
                  //                     id: state.nineAdsTopBanner![index].id!,
                  //                     title:
                  //                         state.nineAdsTopBanner![index].title!,
                  //                     url:
                  //                         state.nineAdsTopBanner![index].externalLink!);
                  //               },
                  //               child: ClipRRect(
                  //                 borderRadius: const BorderRadius.all(
                  //                     Radius.circular(4)),
                  //                 child: CustomImage(
                  //                   url: state.nineAdsTopBanner![index].resourceUrl!,
                  //                   //height: 262.w,
                  //                   aspectRatio: 3.73,
                  //                   fit: BoxFit.fill,
                  //                 ),
                  //               ),
                  //             );
                  //           },
                  //           autoplayDelay: 5000,
                  //           itemCount: state.nineAdsTopBanner!.length,
                  //           autoplay: true,
                  //           loop: state.nineAdsTopBanner?.length == 1
                  //               ? false
                  //               : true,
                  //           pagination: (state.nineAdsTopBanner?.length ?? 0) >
                  //                   1
                  //               ? const SwiperPagination(
                  //                   alignment: Alignment.bottomRight,
                  //                   builder: DotSwiperPaginationBuilder(
                  //                     activeColor:
                  //                         Color.fromRGBO(254, 205, 85, 1),
                  //                     space: 6,
                  //                     size: 6,
                  //                     activeSize: 9,
                  //                     color:
                  //                         Color.fromRGBO(255, 255, 255, 0.45),
                  //                   ),
                  //                 )
                  //               : null,
                  //         ),
                  //       )
                  //     : Container(),
                  LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    const ratio = 76 / 100;
                    final oneHeight =
                        ((constraints.maxWidth - 3 * 10 - 80) / 4) / ratio;
                    final height = 4.5 * oneHeight + 4 * 10;
                    return Container(
                      width: double.infinity,
                      height: height,
                      margin: const EdgeInsets.only(left: 40, right: 40),
                      child: MediaQuery.removePadding(
                        context: Get.context!,
                        removeTop: true,
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: ratio),
                          itemCount: ConfigStore
                                  .to.configBean.officialConfigApps?.length ??
                              0,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () async {
                                AppNavigator.to.launchWebUrl(ConfigStore
                                        .to
                                        .configBean
                                        .officialConfigApps?[index]
                                        .officialUrl ??
                                    "");
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(8)),
                                      child: CustomImage(
                                        width: double.infinity,
                                        height: double.infinity,
                                        url: ConfigStore
                                                .to
                                                .configBean
                                                .officialConfigApps?[index]
                                                .officialImg ??
                                            "",
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  // SizedBox(height: 8.),
                                  Text(
                                    ConfigStore
                                            .to
                                            .configBean
                                            .officialConfigApps?[index]
                                            .officialName ??
                                        "",
                                    style: const TextStyle(
                                        color: AppColor.white, fontSize: 12),
                                  ),
                                  // SizedBox(
                                  //   height: 3.w,
                                  // ),
                                  // Text(
                                  //   ConfigStore
                                  //           .to
                                  //           .configBean
                                  //           .officialConfigApps?[index]
                                  //           .officialDesc ??
                                  //       "",
                                  //   style: TextStyle(
                                  //       color: AppColor.white, fontSize: 12.sp),
                                  // ),
                                  /*SizedBox(
                                  height: 8.w,
                                ),*/
                                  /*GestureDetector(
                                  onTap: () {
                                    AppNavigator.to.launchWebUrl(ConfigStore
                                        .to
                                        .configBean
                                        .officialConfigApps?[index]
                                        .officialUrl ??
                                        "");
                                  },
                                  child: Container(
                                    width: 56.w,
                                    height: 20.w,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color:
                                      const Color.fromRGBO(251, 207, 23, 1),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.w)),
                                    ),
                                    child: Text(
                                      "立即下载",
                                      style: TextStyle(
                                          fontSize: 8.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),*/
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 20),
                    child: GestureDetector(
                        onTap: () async {
                          Get.back();

                          getAnnouncement();
                          await getAnnounce();
                        },
                        child: Image.asset(
                          "assets/images/png/ads_close.png",
                          width: 31.w,
                          height: 31.w,
                        )),
                  ),
                ],
              ),
            ),
          );
        });

    /*await showDialog(
        context: Get.context!, //BuildContext对象
        barrierDismissible: false,
        useSafeArea: false,
        builder: (BuildContext context) {
          return Material(
            child: Container(
              width: ScreenUtil().screenWidth,
              height: ScreenUtil().screenHeight,
              color: AppColor.scaffoldBackground,
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.only(right: 32),
                    child: GestureDetector(
                        onTap: () async {
                          Get.back();

                          getAnnouncement();
                          await getAnnounce();
                        },
                        child: Text(
                          "跳过",
                          style: TextStyle(
                              fontSize: 18.w,
                              color: const Color.fromRGBO(255, 129, 13, 1)),
                        )),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 14, right: 14),
                      child: MediaQuery.removePadding(
                        context: Get.context!,
                        removeTop: true,
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 30,
                                  childAspectRatio: 110 / 190),
                          itemCount: ConfigStore
                              .to.configBean.officialConfigApps!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () async {},
                              child: Column(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomImage(
                                        url: ConfigStore
                                                .to
                                                .configBean
                                                .officialConfigApps?[index]
                                                .officialImg ??
                                            "",
                                        borderRadius:
                                            BorderRadius.circular(12.w),
                                        width: 76.w,
                                        height: 76.w,
                                      ),
                                      SizedBox(height: 9.w),
                                      Text(
                                          ConfigStore
                                                  .to
                                                  .configBean
                                                  .officialConfigApps?[index]
                                                  .officialName ??
                                              "",
                                          style: TextStyle(
                                              fontSize: 15.sp,
                                              color: Colors.white)),
                                      SizedBox(height: 2.w),
                                      Text(
                                        ConfigStore
                                                .to
                                                .configBean
                                                .officialConfigApps?[index]
                                                .officialDesc ??
                                            "",
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize: 13.sp,
                                            color: const Color(0xff45e7de)),
                                      ),
                                      //width, double? height, double? fontSize
                                      SizedBox(height: 12.w),
                                      commonSubSubmitButton("立即下载",
                                          width: 76.w,
                                          height: 26.w,
                                          fontSize: 12.sp,
                                          onSubmitTap: () => AppNavigator.to.launchWebUrl(
                                              ConfigStore
                                                      .to
                                                      .configBean
                                                      .officialConfigApps?[
                                                          index]
                                                      .officialUrl ??
                                                  "")),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });*/

    update();
  }

  //获取公告
  void getAnnouncement() async {
    if (state.bannerImage!.isNotEmpty) {
      for (int i = 0; i < state.bannerImage!.length; i++) {
        await openImageAnnouncementDialog(ads: state.bannerImage![i]);
      }
    }

    // 数据源已迁移到 ads/notice/list（[ConfigStore.noticeList]）；
    // 新模型 [NoticeModel] 只有 title 字段，不再区分独立的 content。
    List<NoticeModel> list = ConfigStore.to.noticeList.toList();
    list = list.reversed.toList();
    while (list.isNotEmpty) {
      final NoticeModel notice = list.removeLast();

      await openAnnouncementDialog(notice: notice);
      ///文字弹窗
    }
  }

  sign() async {
    BaseRespBean baseRespBean = await UserApi.taskSign();
    SignEntity signEntity = SignEntity.fromJson(baseRespBean.data);
    if (baseRespBean.isSuccess) {
      customSign(signEntity);
      return;
    }
  }

  Future getAnnounce() async {
    /*BaseRespBean baseRespBean = await UserApi.getAnnouncement();
    state.announcement = AnnounceMent.fromJson(baseRespBean.data);
    ConfigStore.to.homePageAnnounceMent =
        state.announcement?.announcement![0].content.toString();*/
  }
}
