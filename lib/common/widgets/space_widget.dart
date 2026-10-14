import 'package:comics_app/common/apis/media_api.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/entities/MediaListInfo.dart';
import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/entities/media_info.dart';
import 'package:comics_app/common/entities/video_model/tags_model.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/utils.dart';
import 'package:comics_app/common/values/enum.dart';
import 'package:comics_app/common/widgets/golden_beans_buying.dart';
import 'package:comics_app/common/widgets/memberPaying.dart';
import 'package:comics_app/pages/home/categories/categories_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../pages/home/home_logic.dart';
import '../../pages/home/tag_detail/tag_detail_logic.dart';

// import '../entities/feature_info.dart' hide MediaList;
import '../entities/module_detail_model/all_section_model.dart';
import '../routers/app_routes.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/common/utils/ads_manage/ads_info_list_extension.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';

final state = Get.find<HomeLogic>().state;
final homeLogic = Get.find<HomeLogic>();

final categoriesState = Get.find<CategoriesLogic>().state;

Widget getSliverHeight(double height) {
  return SliverToBoxAdapter(
    child: SizedBox(
      height: height.w,
    ),
  );
}

Widget getSliverWidth(double width) {
  return SliverToBoxAdapter(
    child: SizedBox(
      width: width.w,
    ),
  );
}

Widget getHeight(double height) {
  return SizedBox(
    height: height.w,
  );
}

Widget getWidth(double width) {
  return SizedBox(
    width: width.w,
  );
}

/// 获取个性化数量显示
String getShowCountStr(int number, {int count = 1}) {
  String numStr = "";
  if (number > 100000000) {
    // ignore: no_leading_underscores_for_local_identifiers
    num _num = number / 100000000;
    _num = num.parse(_num.toStringAsFixed(count));

    numStr = "$_num亿";
  } else if (number > 10000) {
    // ignore: no_leading_underscores_for_local_identifiers
    num _num = number / 10000;
    _num = num.parse(_num.toStringAsFixed(1));
    numStr = "${_num}w";
  } else {
    numStr = number.toString();
  }
  return numStr;
}

Widget commonTabBar(Widget tabBar) {
  return Theme(
      data: ThemeData(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: tabBar);
}

Widget getThreeCover(int indexs, AllSectionModel? listElement,
    {bool? isFreeZone, List<AdsInfoList>? banner, String? linkName}) {
  return Column(
    children: [
      Column(
        children: [
          getTitle(listElement),
        ],
      ),
      getHeight(9),
      listElement!.allVideoInfo.isEmpty
          ? Container()
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: listElement.allVideoInfo.length > 3
                  ? listElement.allVideoInfo
                      .sublist(0, 3)
                      .asMap()
                      .entries
                      .map((e) {
                      return Container(
                        padding: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                ConfigStore.to.trackData(
                                    '作品点击',
                                    ConfigStore.to.getClickProductInfoMap(
                                        MediaList.fromJson(e.value.toJson()),
                                        linkName!));

                                if (isVideo(
                                    listElement.allVideoInfo[e.key].kind)) {
                                  Get.toNamed(AppRoutes.VIDEO_PAGE, arguments: {
                                    "id": listElement.allVideoInfo[e.key].id,
                                    "isFreeZoneArgs": isFreeZone,
                                  });
                                } else {
                                  if (listElement.allVideoInfo[e.key].kind ==
                                      5) {
                                    // Map<String, dynamic> data = {
                                    //   "mediaID": listElement. allVideoInfo![e.key].id,
                                    // };
                                    //
                                    // Map<String, dynamic> mediaInfo;
                                    // mediaInfo = await MediaApi.getMediaInfo(...);
                                    // MediaInfo mediainfo = MediaInfo.fromJson(mediaInfo);
                                    //
                                    // ///vip
                                    // if (mediainfo.data!.permission == 0 &&
                                    //     !UserStore.to.isVip() &&
                                    //     !mediainfo.data!.hasPaid!) {
                                    //   openMemberPaying(
                                    //           isShowCoupon: true,
                                    //           productType: 24,
                                    //           id: mediainfo.data!. sectionId.toString(),
                                    //           title: mediainfo.data!.title)
                                    //       .then((value) {
                                    //     if (value == PaySuccess.exchangeSuccessFullly) {
                                    //       Get.toNamed(AppRoutes.PORTRAY, arguments: {
                                    //         "id": listElement. allVideoInfo?[e.key].id,
                                    //         "imageList": listElement. allVideoInfo,
                                    //         "index": e.key,
                                    //       });
                                    //     }
                                    //   });
                                    //
                                    //   return;
                                    // }
                                    //
                                    // ///金豆
                                    // if (mediainfo.data!.permission == 1 &&
                                    //     mediainfo.data!. coins != 0 &&
                                    //     !mediainfo.data!.hasPaid!) {
                                    //   openGoldenBeansBuying(
                                    //     id: mediainfo.data!. sectionId.toString(),
                                    //     title: mediainfo.data!.title.toString(),
                                    //     price: mediainfo.data!. coins ?? 0,
                                    //     productType: 24,
                                    //     isShowCoupon: true,
                                    //   ).then((value) {
                                    //     if (value == PaySuccess.exchangeSuccessFullly ||
                                    //         value == PaySuccess.successfulPurchase) {
                                    //       Get.toNamed(AppRoutes.PORTRAY, arguments: {
                                    //         "id": listElement. allVideoInfo?[e.key].id,
                                    //         "imageList": listElement. allVideoInfo,
                                    //         "index": e.key,
                                    //       });
                                    //     }
                                    //   });
                                    //
                                    //   return;
                                    // }

                                    Get.toNamed(AppRoutes.PORTRAY, arguments: {
                                      "id": listElement.allVideoInfo[e.key].id,
                                      "imageList": listElement.allVideoInfo,
                                      "index": e.key,
                                    });
                                  }

                                  if (listElement.allVideoInfo[e.key].kind ==
                                      4) {
                                    Get.toNamed(AppRoutes.NOVEL_DETAILS_PAGE,
                                        arguments: {
                                          "id": listElement
                                              .allVideoInfo[e.key].id,
                                          "type":
                                              MediaKind.mediaKindRealFiction,
                                        });
                                  }
                                  if (listElement.allVideoInfo[e.key].kind ==
                                      1) {
                                    Get.toNamed(AppRoutes.NOVEL_DETAILS_PAGE,
                                        arguments: {
                                          "id": listElement
                                              .allVideoInfo[e.key].id,
                                          "type": MediaKind.mediaKindComics
                                        });
                                  }
                                }
                              },
                              child: Stack(
                                children: [
                                  CustomImage(
                                    url: e.value.verticalCover,
                                    fit: BoxFit.cover,
                                    width: 113.w,
                                    height: 166.w,
                                    borderRadius: BorderRadius.circular(8),
                                    // borderRadius:
                                    //     const BorderRadius.all(Radius.circular(6)),
                                  ),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    child: getMarkIcon(
                                        listElement
                                            .allVideoInfo[e.key].permission,
                                        listElement.allVideoInfo[e.key].coins),
                                  ),
                                  getBottomGridentShadow(
                                      111.w,
                                      listElement.allVideoInfo[e.key].status,
                                      listElement.allVideoInfo[e.key].title),
                                ],
                              ),
                            ),
                            getHeight(6),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              width: 110.w,
                              child: Text(
                                e.value.title.toString(),
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12.sp),
                              ),
                            ),
                            getHeight(2),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: getTagWidgetM(e.value.tags, e.value.kind,
                                  isVertical: true),
                            ),
                            getHeight(12),
                          ],
                        ),
                      );
                    }).toList()
                  : listElement.allVideoInfo.asMap().entries.map((e) {
                      return Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  ConfigStore.to.trackData(
                                      '作品点击',
                                      ConfigStore.to.getClickProductInfoMap(
                                          MediaList.fromJson(e.value.toJson()),
                                          linkName!));

                                  if (isVideo(
                                      listElement.allVideoInfo[e.key].kind)) {
                                    Get.toNamed(AppRoutes.VIDEO_PAGE,
                                        arguments: {
                                          "id": listElement
                                              .allVideoInfo[e.key].id,
                                          "isFreeZoneArgs": isFreeZone,
                                        });
                                  } else {
                                    if (listElement.allVideoInfo[e.key].kind ==
                                        5) {
                                      // Map<String, dynamic> data = {
                                      //   "mediaID": listElement. allVideoInfo![e.key].id,
                                      // };
                                      //
                                      // Map<String, dynamic> mediaInfo;
                                      // mediaInfo = await MediaApi.getMediaInfo(...);
                                      // MediaInfo mediainfo = MediaInfo.fromJson(mediaInfo);
                                      //
                                      // ///vip
                                      // if (mediainfo.data!.permission == 0 &&
                                      //     !UserStore.to.isVip() &&
                                      //     !mediainfo.data!.hasPaid!) {
                                      //   openMemberPaying(
                                      //           isShowCoupon: true,
                                      //           productType: 24,
                                      //           id: mediainfo.data!. sectionId.toString(),
                                      //           title: mediainfo.data!.title)
                                      //       .then((value) {
                                      //     if (value == PaySuccess.exchangeSuccessFullly) {
                                      //       Get.toNamed(AppRoutes.PORTRAY, arguments: {
                                      //         "id": listElement. allVideoInfo?[e.key].id,
                                      //         "imageList": listElement. allVideoInfo,
                                      //         "index": e.key,
                                      //       });
                                      //     }
                                      //   });
                                      //
                                      //   return;
                                      // }
                                      //
                                      // ///金豆
                                      // if (mediainfo.data!.permission == 1 &&
                                      //     mediainfo.data!. coins != 0 &&
                                      //     !mediainfo.data!.hasPaid!) {
                                      //   openGoldenBeansBuying(
                                      //     id: mediainfo.data!. sectionId.toString(),
                                      //     title: mediainfo.data!.title.toString(),
                                      //     price: mediainfo.data!. coins ?? 0,
                                      //     productType: 24,
                                      //     isShowCoupon: true,
                                      //   ).then((value) {
                                      //     if (value == PaySuccess.exchangeSuccessFullly ||
                                      //         value == PaySuccess.successfulPurchase) {
                                      //       Get.toNamed(AppRoutes.PORTRAY, arguments: {
                                      //         "id": listElement. allVideoInfo?[e.key].id,
                                      //         "imageList": listElement. allVideoInfo,
                                      //         "index": e.key,
                                      //       });
                                      //     }
                                      //   });
                                      //
                                      //   return;
                                      // }

                                      Get.toNamed(AppRoutes.PORTRAY,
                                          arguments: {
                                            "id": listElement
                                                .allVideoInfo[e.key].id,
                                            "imageList":
                                                listElement.allVideoInfo,
                                            "index": e.key,
                                          });
                                    }

                                    if (listElement.allVideoInfo[e.key].kind ==
                                        4) {
                                      Get.toNamed(AppRoutes.NOVEL_DETAILS_PAGE,
                                          arguments: {
                                            "id": listElement
                                                .allVideoInfo[e.key].id,
                                            "type":
                                                MediaKind.mediaKindRealFiction,
                                          });
                                    }
                                    if (listElement.allVideoInfo[e.key].kind ==
                                        1) {
                                      Get.toNamed(AppRoutes.NOVEL_DETAILS_PAGE,
                                          arguments: {
                                            "id": listElement
                                                .allVideoInfo[e.key].id,
                                            "type": MediaKind.mediaKindComics
                                          });
                                    }
                                  }
                                },
                                child: Stack(
                                  children: [
                                    CustomImage(
                                      url: e.value.verticalCover,
                                      fit: BoxFit.cover,
                                      width: 113.w,
                                      height: 166.w,
                                      borderRadius: BorderRadius.circular(8),
                                      // borderRadius:
                                      //     const BorderRadius.all(Radius.circular(6)),
                                    ),
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      child: getMarkIcon(
                                          listElement
                                              .allVideoInfo[e.key].permission,
                                          listElement
                                              .allVideoInfo[e.key].coins),
                                    ),
                                    getBottomGridentShadow(
                                        111.w,
                                        listElement.allVideoInfo[e.key].status,
                                        listElement.allVideoInfo[e.key].title),
                                  ],
                                ),
                              ),
                              getHeight(6),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: 110.w,
                                child: Text(
                                  e.value.title.toString(),
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12.sp),
                                ),
                              ),
                              getHeight(2),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: getTagWidgetM(e.value.tags, e.value.kind,
                                    isVertical: true),
                              ),
                              getHeight(12),
                            ],
                          ));
                    }).toList(),
            ),
      getHeight(12),
      /*Visibility(
        visible: state.tabController.index == 1 ? true : false,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 140.w,
            child: Swiper(
              itemBuilder: (BuildContext context, int bannerIndex) {
                return GestureDetector(
                  onTap: () {
                    AppNavigator.to.jumpAdv(
                        id: banner![bannerIndex].id!,
                        title: banner[bannerIndex].title!,
                        url: banner[bannerIndex].externalLink!);
                  },
                  child: CustomImage(
                    url: banner![bannerIndex].resourceUrl!,
                    height: 140.w,
                    fit: BoxFit.cover,
                  ),
                );
              },
              itemCount: banner!.length,
              autoplay: true,
              loop: banner.length == 1 ? false : true,
              pagination: banner.length > 1
                  ? const SwiperPagination(
                      alignment: Alignment.bottomRight,
                      builder: DotSwiperPaginationBuilder(
                        activeColor: Color.fromRGBO(254, 205, 85, 1),
                        space: 6,
                        size: 6,
                        activeSize: 9,
                        color: Color.fromRGBO(255, 255, 255, 0.45),
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ),*/
      getHeight(12),
      Container(
        color: AppColor.lineColor,
        height: 1.w,
      ),
      getHeight(18),
    ],
  );
}

Widget getTitle(AllSectionModel? listElement,
    {double? hPadding, GestureTapCallback? onTap, bool showMore = true}) {
  return GestureDetector(
    // onTap: onTap ??() {
    //   //漫画title点击容错处理
    //   if (listElement?.allVideoInfo.isEmpty ?? true) return;
    //   Get.toNamed(AppRoutes.TOPIC_PAGE, arguments: {
    //     "title": listElement?.sectionName.toString(),
    //     "id": listElement?.sectionId.toString(),
    //     "kind": listElement?.allVideoInfo[0].kind,
    //     "isJinGangZone": false,
    //   });
    // },
    child: Container(
      constraints: BoxConstraints(maxHeight: 60.w),
      padding: EdgeInsets.symmetric(horizontal: hPadding ?? 0),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // 确保 Column 内部的元素居中对齐
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listElement?.sectionName.toString() ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
                if (listElement?.sectionDesc?.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  SizedBox(
                    width: ScreenUtil().screenWidth - 100.w,
                    child: Text(
                      listElement?.sectionDesc.toString() ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 12.sp, color: AppColor.warmGrey),
                    ),
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          if (showMore)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap ??
                  () {
                    if (listElement?.linkUrl?.isNotEmpty == true) {
                      AppNavigator.to.jumpAdv(url: listElement?.linkUrl!, planId: '', slotCode: '');
                      return;
                    }
                    final showType = listElement?.showType ?? -1;
                    // print('AppRoutes.TOPIC_PAGE,' + listElement!.showType.toString());
                    final forceVerticalCover = showType == 21 ||
                        showType == 20 ||
                        showType == 22 ||
                        showType == 23 ||
                        showType == 26 ||
                        showType == 27 ||
                        showType == 28 ||
                        showType == 2 ||
                        showType == 4 ||
                        showType == 6 ||
                        showType == 9 ||
                        showType == 10 ||
                        showType == 13;
                    Get.toNamed(AppRoutes.TOPIC_PAGE, arguments: {
                      "title": listElement?.sectionName.toString(),
                      "id": listElement?.sectionId.toString(),
                      "kind": listElement?.type,
                      "isJinGangZone": false,
                      'isVerticalCover': forceVerticalCover
                    });
                  },
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(right: 5.w),
                child: Row(
                  children: [
                    Text(
                      "更多",
                      style:
                          TextStyle(fontSize: 12.sp, color: AppColor.warmGrey),
                    ),
                    Image.asset(
                      "assets/images/png/right_arrow.png",
                      width: 16.w,
                      height: 16.w,
                    ),
                  ],
                ),
              ),
            ),

          //getWidth(8),
        ],
      ),
    ),
  );
}

Widget getVerticalGridView(BuildContext context, int? itemCount,
    {List<MediaList>? mediaList,
    int? kind,
    bool? isFreeZone = false,
    List<AdsInfoList>? homePageSpecialMoreAds,
    String? linkName}) {
  List<Widget> lists = [];

  for (var element in mediaList!) {
    lists.add(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                ConfigStore.to.trackData(
                    '作品点击',
                    ConfigStore.to.getClickProductInfoMap(
                        MediaList.fromJson(element.toJson()), linkName!));

                jumpPage(element.kind, element.id,
                    index: mediaList.indexOf(element),
                    mediaList: mediaList,
                    isFreeZone: isFreeZone);
              },
              child: CustomImage(
                url: element.verticalCover.toString(),
                fit: BoxFit.cover,
                width: 111.w,
                height: 162.w,
                borderRadius: BorderRadius.circular(8),
                // borderRadius: const BorderRadius.all(Radius.circular(3)),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: getMarkIcon(element.permission, element.price),
            ),
            getBottomGridentShadow(
                111.w, element.updateStatus, element.updatedDesc)
          ],
        ),
        getHeight(6),
        SizedBox(
          width: 110.w,
          child: Text(
            element.title ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontSize: 12.sp),
          ),
        ),
        getHeight(2),
        getTagWidget(element.tagNames, element.tags, element.kind,
            isVertical: true),
      ],
    ));
  }

  if ((homePageSpecialMoreAds ?? []).isNotEmpty) {
    for (int i = 0; i < lists.length; i++) {
      if ((i + 1) % 5 == 0) {
        lists.insert(i, getVerticalCoverListAds(i, homePageSpecialMoreAds!));
      }
    }
  }

  return GridView.builder(
    itemCount: lists.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3, //横向数量
      crossAxisSpacing: 0, //间距
      mainAxisSpacing: 0, //行距
      childAspectRatio: 111.w / 200.w,
    ),
    itemBuilder: (context, index) {
      return lists[index];
    },
  );
}

Widget getVerticalCoverListAds(
    int index, List<AdsInfoList> homePageSpecialMoreAds) {
  int j = ((index) / 4).round();
  int i;
  if (j % homePageSpecialMoreAds.length == 0) {
    i = homePageSpecialMoreAds.length - 1;
  } else {
    i = (j % homePageSpecialMoreAds.length - 1);
  }

  return homePageSpecialMoreAds.isEmpty
      ? Container()
      : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                homePageSpecialMoreAds[i].jumpAdvByType(AdsType.banner);
              },
              child: CustomImage(
                url: homePageSpecialMoreAds[i].resourceUrl!,
                height: 162.w,
                width: 111.w,
                fit: BoxFit.cover,
              ),
            ),
            getHeight(6),
            SizedBox(
              width: 110.w,
              child: Text(
                homePageSpecialMoreAds[i].title ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.black, fontSize: 12.sp),
              ),
            ),
            getHeight(2),
          ],
        );
}

Widget getCategoriesVerticalCoverListAds(int index) {
  int j = ((index) / 4).round();
  int i;
  if (j % categoriesState.categoriesAds.length == 0) {
    i = categoriesState.categoriesAds.length - 1;
  } else {
    i = (j % categoriesState.categoriesAds.length - 1);
  }

  return categoriesState.categoriesAds.isEmpty
      ? Container()
      : Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  categoriesState.categoriesAds[i].jumpAdvByType(AdsType.banner);
                },
                child: CustomImage(
                  url: categoriesState.categoriesAds[i].resourceUrl!,
                  height: 166.w,
                  width: 113.w,
                  fit: BoxFit.cover,
                ),
              ),
              getHeight(6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  categoriesState.categoriesAds[i].title ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black, fontSize: 12.sp),
                ),
              ),
              getHeight(2),
            ],
          ),
        );
}

Widget getHorizontalCoverListAds(
    int index, List<AdsInfoList> homePageSpecialMoreAdsHorizontal) {
  int j = ((index) / 4).round();
  int i;
  if (j % homePageSpecialMoreAdsHorizontal.length == 0) {
    i = homePageSpecialMoreAdsHorizontal.length - 1;
  } else {
    i = (j % homePageSpecialMoreAdsHorizontal.length - 1);
  }

  return homePageSpecialMoreAdsHorizontal.isEmpty
      ? Container()
      : Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 96.w,
                child: GestureDetector(
                  onTap: () {
                    homePageSpecialMoreAdsHorizontal[i].jumpAdvByType(AdsType.banner);
                  },
                  child: CustomImage(
                    url: homePageSpecialMoreAdsHorizontal[i].resourceUrl!,
                    width: 173.w,
                    height: 98.w,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              getHeight(6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  homePageSpecialMoreAdsHorizontal[i].title.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black, fontSize: 12.sp),
                ),
              ),
              getHeight(2),
            ],
          ),
        );
}

Widget getCategoriesHorizontalCoverListAds(int index) {
  int j = ((index) / 4).round();
  int i;
  if (j % categoriesState.categoriesAdsHorizonal.length == 0) {
    i = categoriesState.categoriesAdsHorizonal.length - 1;
  } else {
    i = (j % categoriesState.categoriesAdsHorizonal.length - 1);
  }

  return categoriesState.categoriesAdsHorizonal.isEmpty
      ? Container()
      : SizedBox(
          height: 126.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  categoriesState.categoriesAdsHorizonal[i].jumpAdvByType(AdsType.banner);
                },
                child: CustomImage(
                  url: categoriesState.categoriesAdsHorizonal[i].resourceUrl!,
                  height: 96.w,
                  fit: BoxFit.cover,
                ),
              ),
              getHeight(6),
              Text(
                categoriesState.categoriesAdsHorizonal[i].title ?? "",
                maxLines: 1,
                style: TextStyle(color: Colors.black, fontSize: 12.sp),
              ),
              getHeight(2),
            ],
          ),
        );
}

Widget getHorizontalGridView(BuildContext context, int? itemCount,
    {List<MediaList>? mediaList,
    int? kind,
    List<AdsInfoList>? homePageSpecialMoreAdsHorizontal,
    String? linkName}) {
  List<Widget> lists = [];

  for (var element in mediaList!) {
    lists.add(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: AlignmentDirectional.center,
          children: [
            GestureDetector(
              onTap: () {
                ConfigStore.to.trackData(
                    '作品点击',
                    ConfigStore.to.getClickProductInfoMap(
                        MediaList.fromJson(element.toJson()), linkName!));

                jumpPage(kind, element.id,
                    index: mediaList.indexOf(element), mediaList: mediaList);
              },
              child: CustomImage(
                url: element.horizontalCover.toString(),
                fit: BoxFit.cover,
                width: 171.w,
                height: 96.w,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: getMarkIcon(element.permission, element.price),
            ),
            getBottomGridentShadow(
                171.w, element.updateStatus, element.updatedDesc)
          ],
        ),
        getHeight(6),
        SizedBox(
          width: 180.w,
          child: Text(
            element.title.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontSize: 12.sp),
          ),
        ),
        getHeight(2),
        getTagWidget(element.tagNames, element.tags, element.kind,
            isVertical: false),
      ],
    ));
  }

  if ((homePageSpecialMoreAdsHorizontal ?? []).isNotEmpty) {
    for (int i = 0; i < lists.length; i++) {
      if ((i + 1) % 5 == 0) {
        lists.insert(
            i, getHorizontalCoverListAds(i, homePageSpecialMoreAdsHorizontal!));
      }
    }
  }

  return GridView.builder(
    itemCount: lists.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2, //横向数量
      crossAxisSpacing: 1, //间距
      mainAxisSpacing: 1, //行距
      childAspectRatio: 171.w / 138.w,
    ),
    itemBuilder: (context, index) {
      return lists[index];
    },
  );
}

Widget getSixCover(
    int index, BuildContext context, AllSectionModel? listElement,
    {bool? isHideTitle = false, List<AdsInfoList>? banner, String? linkName}) {
  return Column(
    children: [
      Visibility(
        visible: isHideTitle! ? false : true,
        child: Column(
          children: [
            getTitle(listElement),
          ],
        ),
      ),
      getHeight(9),
      listElement!.allVideoInfo.isEmpty
          ? Container()
          : SizedBox(
              height: listElement.allVideoInfo.length > 4 ? 442.w : 212.w,
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: GridView.builder(
                  itemCount: listElement.allVideoInfo.length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, //横向数量
                    crossAxisSpacing: 8, //间距
                    mainAxisSpacing: 8, //行距
                    childAspectRatio: 113.w / 216.w,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  ConfigStore.to.trackData(
                                      '作品点击',
                                      ConfigStore.to.getClickProductInfoMap(
                                          MediaList.fromJson(listElement
                                              .allVideoInfo[index]
                                              .toJson()),
                                          linkName!));

                                  if (isVideo(
                                      listElement.allVideoInfo[index].kind)) {
                                    Get.toNamed(AppRoutes.VIDEO_PAGE,
                                        arguments: {
                                          "id":
                                              listElement.allVideoInfo[index].id
                                        });
                                  } else {
                                    if (listElement.allVideoInfo[index].kind ==
                                        5) {
                                      Get.toNamed(AppRoutes.PORTRAY,
                                          arguments: {
                                            "id": listElement
                                                .allVideoInfo[index].id,
                                            "imageList":
                                                listElement.allVideoInfo,
                                            "index": index,
                                          });
                                    }

                                    if (listElement.allVideoInfo[index].kind ==
                                        4) {
                                      Get.toNamed(AppRoutes.NOVEL_DETAILS_PAGE,
                                          arguments: {
                                            "id": listElement
                                                .allVideoInfo[index].id,
                                            "type":
                                                MediaKind.mediaKindRealFiction,
                                          });
                                    }
                                    if (listElement.allVideoInfo[index].kind ==
                                        1) {
                                      Get.toNamed(AppRoutes.NOVEL_DETAILS_PAGE,
                                          arguments: {
                                            "id": listElement
                                                .allVideoInfo[index].id,
                                            "type": MediaKind.mediaKindComics
                                          });
                                    }
                                  }
                                },
                                child: Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: [
                                    CustomImage(
                                      url: listElement
                                          .allVideoInfo[index].verticalCover
                                          .toString(),
                                      fit: BoxFit.cover,
                                      width: 113.w,
                                      height: 166.w,
                                      borderRadius: BorderRadius.circular(8),
                                      // borderRadius: const BorderRadius.all(
                                      //     Radius.circular(6)),
                                    ),
                                    getBottomGridentShadow(
                                        111.w,
                                        listElement.allVideoInfo[index].status,
                                        listElement.allVideoInfo[index].title),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                child: getMarkIcon(
                                    listElement.allVideoInfo[index].permission,
                                    listElement.allVideoInfo[index].coins),
                              ),
                            ],
                          ),
                          getHeight(6),
                          Container(
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            width: 111.w,
                            child: Text(
                              listElement.allVideoInfo[index].title.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.black, fontSize: 12.sp),
                            ),
                          ),
                          getHeight(2),
                          Container(
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            width: 111.w,
                            child: getTagWidgetM(
                                listElement.allVideoInfo[index].tags,
                                listElement.allVideoInfo[index].kind,
                                isVertical: true),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
      getHeight(12),

      //getHeight(1),
      Container(
        color: AppColor.lineColor,
        height: 1.r,
      ),
      getHeight(18),
    ],
  );
}

Widget getFourCover(int index, List<AdsInfoList> banner, BuildContext context,
    AllSectionModel? listElement) {
  return Column(
    children: [
      Column(
        children: [
          getTitle(listElement),
        ],
      ),
      getHeight(9),
      listElement!.allVideoInfo.isEmpty
          ? Container()
          : SizedBox(
              height: 430.w,
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: GridView.builder(
                  itemCount: 4,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, //横向数量
                    crossAxisSpacing: 1, //间距
                    mainAxisSpacing: 1, //行距
                    childAspectRatio: 111.w / 198.w,
                  ),
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (isVideo(
                                    listElement.allVideoInfo[index].kind)) {
                                  Get.toNamed(AppRoutes.VIDEO_PAGE, arguments: {
                                    "id": listElement.allVideoInfo[index].id
                                  });
                                } else {
                                  if (listElement.allVideoInfo[index].kind ==
                                      5) {
                                    Get.toNamed(AppRoutes.PORTRAY, arguments: {
                                      "id": listElement.allVideoInfo[index].id,
                                      "imageList": listElement.allVideoInfo,
                                      "index": index,
                                    });
                                  }

                                  if (listElement.allVideoInfo[index].kind ==
                                      4) {
                                    Get.toNamed(AppRoutes.NOVEL_DETAILS_PAGE,
                                        arguments: {
                                          "id": listElement
                                              .allVideoInfo[index].id,
                                          "type":
                                              MediaKind.mediaKindRealFiction,
                                        });
                                  }
                                  if (listElement.allVideoInfo[index].kind ==
                                      1) {
                                    Get.toNamed(AppRoutes.NOVEL_DETAILS_PAGE,
                                        arguments: {
                                          "id": listElement
                                              .allVideoInfo[index].id,
                                          "type": MediaKind.mediaKindComics
                                        });
                                  }
                                }
                              },
                              child: CustomImage(
                                url: listElement
                                    .allVideoInfo[index].verticalCover
                                    .toString(),
                                fit: BoxFit.cover,
                                width: 111.w,
                                height: 162.w,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(6)),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              child: getMarkIcon(
                                  listElement.allVideoInfo[index].permission,
                                  listElement.allVideoInfo[index].coins),
                            ),
                          ],
                        ),
                        getHeight(6),
                        SizedBox(
                          width: 111.w,
                          child: Text(
                            listElement.allVideoInfo[index].title.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                TextStyle(color: Colors.black, fontSize: 12.sp),
                          ),
                        ),
                        getHeight(2),
                        SizedBox(
                          width: 111.w,
                          child: getTagWidgetM(
                              listElement.allVideoInfo[index].tags,
                              listElement.allVideoInfo[index].kind,
                              isVertical: true),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
      getHeight(12),
      getHeight(1),
      Container(
        color: AppColor.lineColor,
        height: 1.r,
      ),
      getHeight(18),
    ],
  );
}

Widget getVerticalFourCover(
    int index, BuildContext context, AllSectionModel? listElement,
    {List<AdsInfoList>? banner, String? linkName}) {
  return Column(
    children: [
      Column(
        children: [
          getTitle(listElement),
        ],
      ),
      getHeight(9),
      listElement!.allVideoInfo.isEmpty
          ? Container()
          : SizedBox(
              height: 618.w,
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: GridView.builder(
                  itemCount: 4,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, //横向数量
                    crossAxisSpacing: 8, //间距
                    mainAxisSpacing: 8, //行距
                    childAspectRatio: 173.w / 304.w,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            Positioned(
                                top: 0,
                                left: 0,
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        final homeLogicState =
                                            Get.find<HomeLogic>().state;

                                        ConfigStore.to.trackData(
                                            '作品点击',
                                            ConfigStore.to
                                                .getClickProductInfoMap(
                                                    MediaList.fromJson(
                                                        listElement
                                                            .allVideoInfo[index]
                                                            .toJson()),
                                                    linkName!));

                                        if (homeLogicState
                                                .tabController.index ==
                                            5) {
                                          final BaseRespBean mediaResp =
                                              await MediaApi.getMediaInfo(
                                            listElement.allVideoInfo[index].id
                                                .toString(),
                                          );
                                          final MediaInfo mediainfo =
                                              MediaInfo.fromJson(
                                                  mediaResp.toJson());

                                          ///vip
                                          if (mediainfo.data!.permission == 0 &&
                                              !UserStore.to.isVip() &&
                                              !mediainfo.data!.mediaStatus!
                                                  .hasPaid!) {
                                            openMemberPaying(
                                                    isShowCoupon: true,
                                                    productType: 24,
                                                    title: listElement
                                                        .allVideoInfo[index]
                                                        .title,
                                                    id: listElement
                                                        .allVideoInfo[index].id
                                                        .toString())
                                                .then((value) {
                                              if (value ==
                                                  PaySuccess
                                                      .exchangeSuccessFullly) {
                                                List<MediaList>? mediaList = [];

                                                for (var element in listElement
                                                    .allVideoInfo) {
                                                  mediaList.add(
                                                      MediaList.fromJson(
                                                          element.toJson()));
                                                }

                                                jumpPage(
                                                    listElement
                                                        .allVideoInfo[index]
                                                        .kind,
                                                    listElement
                                                        .allVideoInfo[index].id,
                                                    index: index,
                                                    mediaList: mediaList);
                                              }
                                            });

                                            return;
                                          }

                                          ///金豆
                                          if (listElement.allVideoInfo[index]
                                                      .permission ==
                                                  1 &&
                                              listElement.allVideoInfo[index]
                                                      .coins !=
                                                  0 &&
                                              !mediainfo.data!.mediaStatus!
                                                  .hasPaid!) {
                                            openGoldenBeansBuying(
                                              id: listElement
                                                  .allVideoInfo[index].id
                                                  .toString(),
                                              title: listElement
                                                  .allVideoInfo[index].title
                                                  .toString(),
                                              price: listElement
                                                      .allVideoInfo[index]
                                                      .coins ??
                                                  0,
                                              productType: 24,
                                              isShowCoupon: true,
                                            ).then((value) {
                                              if (value ==
                                                      PaySuccess
                                                          .exchangeSuccessFullly ||
                                                  value ==
                                                      PaySuccess
                                                          .successfulPurchase) {
                                                List<MediaList>? mediaList = [];

                                                for (var element in listElement
                                                    .allVideoInfo) {
                                                  mediaList.add(
                                                      MediaList.fromJson(
                                                          element.toJson()));
                                                }

                                                jumpPage(
                                                    listElement
                                                        .allVideoInfo[index]
                                                        .kind,
                                                    listElement
                                                        .allVideoInfo[index].id,
                                                    index: index,
                                                    mediaList: mediaList);
                                              }
                                            });

                                            return;
                                          }
                                        }

                                        List<MediaList>? mediaList = [];

                                        for (var element
                                            in listElement.allVideoInfo) {
                                          mediaList.add(MediaList.fromJson(
                                              element.toJson()));
                                        }

                                        jumpPage(
                                            listElement
                                                .allVideoInfo[index].kind,
                                            listElement.allVideoInfo[index].id,
                                            index: index,
                                            mediaList: mediaList);
                                      },
                                      child: CustomImage(
                                        url: listElement
                                            .allVideoInfo[index].verticalCover
                                            .toString(),
                                        fit: BoxFit.cover,
                                        width: 171.w,
                                        height: 252.w,
                                        borderRadius: BorderRadius.circular(8),
                                        // borderRadius:
                                        //     const BorderRadius.all(Radius.circular(6)),
                                      ),
                                    ),
                                    Container(
                                      height: 60.w,
                                      width: 172.w,
                                      padding: EdgeInsets.only(
                                          left: 12.w, right: 12.w),
                                      // color: AppColor.black.withOpacity(0.6),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // getHeight(6),
                                          Text(
                                            listElement
                                                .allVideoInfo[index].title
                                                .toString(),
                                            maxLines: 1,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          getHeight(2),

                                          getTagWidgetM(
                                              listElement
                                                  .allVideoInfo[index].tags,
                                              listElement
                                                  .allVideoInfo[index].kind,
                                              isVertical: true,
                                              textColor: const Color.fromRGBO(
                                                  153, 153, 153, 1)),
                                          getHeight(3),
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                            Positioned(
                              top: 0,
                              left: 0,
                              child: getMarkIcon(
                                  listElement.allVideoInfo[index].permission,
                                  listElement.allVideoInfo[index].coins),
                            ),
                            Positioned(
                                right: 8,
                                bottom: 60,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 5),
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: listElement
                                              .allVideoInfo[index].status ==
                                          1
                                      ? Text(
                                          listElement.allVideoInfo[index].title
                                              .toString(),
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Color.fromRGBO(
                                                  62, 22, 157, 1),
                                              fontWeight: FontWeight.w500),
                                        )
                                      : listElement
                                                  .allVideoInfo[index].status ==
                                              2
                                          ? Text(
                                              listElement
                                                  .allVideoInfo[index].title
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color.fromRGBO(
                                                      62, 22, 157, 1),
                                                  fontWeight: FontWeight.w500),
                                            )
                                          : Container(),
                                ))
                          ],
                        ));
                  },
                ),
              ),
            ),
      //getHeight(12),
      Container(
        color: AppColor.lineColor,
        height: 1.r,
      ),
      getHeight(18),
    ],
  );
}

Widget getHorizonalFourCover(
    int index, BuildContext context, AllSectionModel? listElement,
    {bool? isHideTitle = false, List<AdsInfoList>? banner, String? linkName}) {
  return Column(
    children: [
      Visibility(
        visible: isHideTitle! ? false : true,
        child: Column(
          children: [
            getTitle(listElement),
          ],
        ),
      ),
      getHeight(9),
      listElement!.allVideoInfo.isEmpty
          ? Container()
          : SizedBox(
              height: 300.w,
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: GridView.builder(
                  itemCount: 4,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, //横向数量
                    crossAxisSpacing: 8, //间距
                    mainAxisSpacing: 8, //行距
                    childAspectRatio: 173.w / 148.w,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              Positioned(
                                top: 0,
                                left: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    ConfigStore.to.trackData(
                                        '作品点击',
                                        ConfigStore.to.getClickProductInfoMap(
                                            MediaList.fromJson(listElement
                                                .allVideoInfo[index]
                                                .toJson()),
                                            linkName!));

                                    if (isVideo(
                                        listElement.allVideoInfo[index].kind)) {
                                      Get.toNamed(AppRoutes.VIDEO_PAGE,
                                          arguments: {
                                            "id": listElement
                                                .allVideoInfo[index].id
                                          });
                                    } else {}
                                  },
                                  child: CustomImage(
                                    url: listElement.allVideoInfo[index].cover,
                                    fit: BoxFit.cover,
                                    width: 171.w,
                                    height: 96.w,
                                    borderRadius: BorderRadius.circular(8),
                                    // borderRadius:
                                    //     const BorderRadius.all(Radius.circular(6)),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                child: getMarkIcon(
                                    listElement.allVideoInfo[index].permission,
                                    listElement.allVideoInfo[index].coins),
                              ),
                              getBottomGridentShadow(
                                  171.w,
                                  listElement.allVideoInfo[index].status,
                                  listElement.allVideoInfo[index].title),
                            ],
                          ),
                          getHeight(6),
                          Text(
                            listElement.allVideoInfo[index].title.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                TextStyle(color: Colors.black, fontSize: 12.sp),
                          ),
                          getHeight(2),
                          getTagWidgetM(listElement.allVideoInfo[index].tags,
                              listElement.allVideoInfo[index].kind,
                              isVertical: false)
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
      getHeight(12),
      getHeight(1),
      Container(
        color: AppColor.lineColor,
        height: 1.r,
      ),
      getHeight(18),
    ],
  );
}

Widget getHorizonalFiveCover(BuildContext context, AllSectionModel? listElement,
    {bool? isHideTitle = false, List<AdsInfoList>? banner, String? linkName}) {
  return Column(
    children: [
      Visibility(
        visible: isHideTitle! ? false : true,
        child: Column(
          children: [
            getTitle(listElement),
          ],
        ),
      ),
      getHeight(9),
      listElement!.allVideoInfo.isEmpty
          ? Container()
          : SizedBox(
              height: 544.w,
              child: Column(
                children: [
                  Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          ConfigStore.to.trackData(
                              '作品点击',
                              ConfigStore.to.getClickProductInfoMap(
                                  MediaList.fromJson(
                                      listElement.allVideoInfo[0].toJson()),
                                  linkName!));

                          if (isVideo(listElement.allVideoInfo[0].kind)) {
                            Get.toNamed(AppRoutes.VIDEO_PAGE, arguments: {
                              "id": listElement.allVideoInfo[0].id
                            });
                          } else {}
                        },
                        child: CustomImage(
                          url: listElement.allVideoInfo[0].cover,
                          fit: BoxFit.cover,
                          width: ScreenUtil().screenWidth,
                          height: 197.w,
                          borderRadius: BorderRadius.circular(8),
                          // borderRadius:
                          //     const BorderRadius.all(Radius.circular(6)),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: getMarkIcon(
                            listElement.allVideoInfo[0].permission,
                            listElement.allVideoInfo[0].coins),
                      ),
                      getBottomGridentShadow(
                          ScreenUtil().screenWidth,
                          listElement.allVideoInfo[0].status,
                          "${listElement.allVideoInfo[0].title}     "),
                    ],
                  ),
                  getHeight(6),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      listElement.allVideoInfo[0].title.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.black, fontSize: 12.sp),
                    ),
                  ),
                  getHeight(2),
                  getTagWidgetM(listElement.allVideoInfo[0].tags,
                      listElement.allVideoInfo[0].kind,
                      isVertical: false),
                  getHeight(12),
                  Expanded(
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: GridView.builder(
                        itemCount: 4,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, //横向数量
                          crossAxisSpacing: 1, //间距
                          mainAxisSpacing: 1, //行距
                          childAspectRatio: 171.w / 142.w,
                        ),
                        itemBuilder: (context, index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      ConfigStore.to.trackData(
                                          '作品点击',
                                          ConfigStore.to.getClickProductInfoMap(
                                              MediaList.fromJson(listElement
                                                  .allVideoInfo[index + 1]
                                                  .toJson()),
                                              linkName!));

                                      if (isVideo(listElement
                                          .allVideoInfo[index + 1].kind)) {
                                        Get.toNamed(AppRoutes.VIDEO_PAGE,
                                            arguments: {
                                              "id": listElement
                                                  .allVideoInfo[index + 1].id
                                            });
                                      } else {}
                                    },
                                    child: CustomImage(
                                      url: listElement
                                          .allVideoInfo[index + 1].cover,
                                      fit: BoxFit.cover,
                                      width: 171.w,
                                      height: 96.w,
                                      borderRadius: BorderRadius.circular(8),
                                      // borderRadius: const BorderRadius.all(
                                      //     Radius.circular(6)),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    child: getMarkIcon(
                                        listElement
                                            .allVideoInfo[index + 1].permission,
                                        listElement
                                            .allVideoInfo[index + 1].coins),
                                  ),
                                  getBottomGridentShadow(
                                      171.w,
                                      listElement
                                          .allVideoInfo[index + 1].status,
                                      listElement
                                          .allVideoInfo[index + 1].title),
                                ],
                              ),
                              getHeight(6),
                              Text(
                                listElement.allVideoInfo[index + 1].title
                                    .toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12.sp),
                              ),
                              getHeight(2),
                              getTagWidgetM(
                                  listElement.allVideoInfo[index].tags,
                                  listElement.allVideoInfo[index].kind,
                                  isVertical: false)
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
      getHeight(12),
      getHeight(1),
      Container(
        color: AppColor.lineColor,
        height: 1.r,
      ),
      getHeight(18),
    ],
  );
}

Widget getHorizonalSixCover(BuildContext context, AllSectionModel? listElement,
    {bool? isHideTitle = false, List<AdsInfoList>? banner, String? linkName}) {
  return Column(
    children: [
      Visibility(
        visible: isHideTitle! ? false : true,
        child: Column(
          children: [
            getTitle(listElement),
          ],
        ),
      ),
      getHeight(9),
      listElement!.allVideoInfo.isEmpty
          ? Container()
          : SizedBox(
              height: 436.w,
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: GridView.builder(
                  itemCount: 6,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, //横向数量
                    crossAxisSpacing: 1, //间距
                    mainAxisSpacing: 1, //行距
                    childAspectRatio: 171.w / 142.w,
                  ),
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                ConfigStore.to.trackData(
                                    '作品点击',
                                    ConfigStore.to.getClickProductInfoMap(
                                        MediaList.fromJson(listElement
                                            .allVideoInfo[index]
                                            .toJson()),
                                        linkName!));

                                if (isVideo(
                                    listElement.allVideoInfo[index].kind)) {
                                  Get.toNamed(AppRoutes.VIDEO_PAGE, arguments: {
                                    "id": listElement.allVideoInfo[index].id
                                  });
                                } else {}
                              },
                              child: CustomImage(
                                url: listElement.allVideoInfo[index].cover,
                                fit: BoxFit.cover,
                                width: 171.w,
                                height: 96.w,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              child: getMarkIcon(
                                  listElement.allVideoInfo[index].permission,
                                  listElement.allVideoInfo[index].coins),
                            ),
                            getBottomGridentShadow(
                                171.w,
                                listElement.allVideoInfo[index].status,
                                listElement.allVideoInfo[index].title),
                          ],
                        ),
                        getHeight(6),
                        Text(
                          listElement.allVideoInfo[index].title.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(color: Colors.black, fontSize: 12.sp),
                        ),
                        getHeight(2),
                        getTagWidgetM(listElement.allVideoInfo[index].tags,
                            listElement.allVideoInfo[index].kind,
                            isVertical: false)
                      ],
                    );
                  },
                ),
              ),
            ),
      getHeight(12),
      getHeight(1),
      Container(
        color: AppColor.lineColor,
        height: 1.r,
      ),
      getHeight(18),
    ],
  );
}

Widget getTagWidgetM(List<TagsModel>? tagNames, int? kind,
    {bool? isVertical = true,
    Color textColor = AppColor.greyishBrown,
    double? fontSize}) {
  return Row(
    children: tagNames!
        .asMap()
        .entries
        .map((e) {
          return GestureDetector(
            onTap: () {
              Get.delete<TagDetailLogic>();
              Get.toNamed(AppRoutes.TAGS_DETAIL, arguments: {
                "title": e.value.name,
                "kind": kind,
                "tags": e.value.id,
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 6.w),
              child: Text(
                e.value.name ?? "",
                style: TextStyle(color: textColor, fontSize: fontSize ?? 10.sp),
              ),
            ),
          );
        })
        .toList()
        .sublist(
            0,
            isVertical!
                ? tagNames.length > 3
                    ? 3
                    : tagNames.length
                : tagNames.length > 5
                    ? 5
                    : tagNames.length),
  );
}

Widget getTagWidget(List<String>? tagNames, List<String>? tagsId, int? kind,
    {bool? isVertical = true,
    Color textColor = AppColor.greyishBrown,
    double? fontSize,
    String? showLightKey}) {
  return Row(
    children: tagNames!
        .asMap()
        .entries
        .map((e) {
          var colorsTxt =
              ((showLightKey == e.value) ? const Color(0xffFF4E7A) : textColor);
          return GestureDetector(
            onTap: () {
              Get.delete<TagDetailLogic>();
              Get.toNamed(AppRoutes.TAGS_DETAIL, arguments: {
                "title": e.value,
                "kind": kind,
                "tags": tagsId![e.key],
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 6.w),
              child: Text(
                e.value,
                style: TextStyle(color: colorsTxt, fontSize: fontSize ?? 10.sp),
              ),
            ),
          );
        })
        .toList()
        .sublist(
            0,
            isVertical!
                ? tagNames.length > 3
                    ? 3
                    : tagNames.length
                : tagNames.length > 5
                    ? 5
                    : tagNames.length),
  );
}

Widget getVideoDetailMarkIcon(int? listenPermission) {
  return getMarkIcon(listenPermission);
}

Widget getMarkIcon(int? permission, [int? price]) {
  if (permission == null) {
    return Container();
  }
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: 6.w,
      vertical: 4.w,
    ),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.5),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Text(
      getProductPriceType(permission),
      textAlign: TextAlign.center,
      style: TextStyle(
        color: permission == 1
            ? const Color.fromRGBO(225, 226, 41, 1)
            : permission == 0
                ? const Color.fromRGBO(222, 208, 255, 1)
                : const Color(0xFF56FAF6),
        fontSize: 10,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

String getProductPriceType(int permission) {
  if (permission == 0) {
    return "VIP";
  } else if (permission == 1) {
    return "金豆";
  }

  return "免费";
}

Widget getCoverIcon(int? permission) {
  return Positioned(
      top: 0,
      left: 0,
      child: SizedBox(
        width: 32,
        height: 20,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 32,
                height: 20,
                decoration: ShapeDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            Positioned(
              left: 6,
              top: 4,
              child: Text(
                getProductPriceType(permission!),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: permission == 1
                      ? const Color.fromRGBO(225, 226, 41, 1)
                      : permission == 0
                          ? const Color.fromRGBO(222, 208, 255, 1)
                          : const Color(0xFF56FAF6),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ));
}

Widget getVideoEpisodeMarkIcon(int? status, int? price) {
  if (status == 0) {
    return Image.asset(
      "assets/images/png/vip_mark.png",
      width: 24.w,
      height: 12.w,
    );
  }

  if (status == 1 && price != 0) {
    return price == 0 || price == null
        ? Image.asset(
            "assets/images/png/gold_mark.png",
            width: 36.w,
            height: 15.w,
          )
        : Container(
            padding: EdgeInsets.only(
                left: 2.w, right: 2.w, top: 1.5.w, bottom: 1.5.w),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(255, 89, 34, 1),
                  Color.fromRGBO(255, 157, 87, 1),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
            child: Text(
              "$price 金豆",
              style: TextStyle(color: Colors.white, fontSize: 8.w),
            ),
          );
  }

  if (status == 1 && price == 0) {
    return Image.asset(
      "assets/images/png/free_mark.png",
      width: 24.w,
      height: 12.w,
    );
  }

  if (status == 2) {
    return Image.asset(
      "assets/images/png/free_mark.png",
      width: 24.w,
      height: 12.w,
    );
  }

  return Image.asset(
    "assets/images/png/vip_mark.png",
    width: 24.w,
    height: 12.w,
  );
}

bool isVideo(int? kind) {
  /**
      MediaKindCartoon = iota //动漫
      MediaKindComics      = 1 //漫画
      MediaKindCosPlay     = 2 //角色扮演
      MediaKindRealPerson  = 3 //真人
      MediaKindRealFiction = 4 //小说
      MediaKindRealPhoto   = 5 //写真
      MediaKindRealBanned  = 6 //禁播
      // **/

  if (kind == 1) {
    return false;
  }

  if (kind == 4 || kind == 7) {
    return false;
  }

  if (kind == 5) {
    return false;
  }

  return true;

  /*if (kind == 1 || kind == 4 || kind == 5) {
    return false;
  } else {
    return true;
  }*/
}

String getProductName(int? kind) {
  /**
      MediaKindCartoon = iota //动漫
      MediaKindComics      = 1 //漫画
      MediaKindCosPlay     = 2 //角色扮演
      MediaKindRealPerson  = 3 //真人
      MediaKindRealFiction = 4 //小说
      MediaKindRealPhoto   = 5 //写真
      MediaKindRealBanned  = 6 //禁播
      // **/

  switch (kind) {
    case 0:
      return "动漫";
    case 1:
      return "漫画";
    case 2:
      return "角色扮演";
    case 3:
      return "真人";
    case 4:
      return "小说";
    case 5:
      return "写真";
    case 6:
      return "原作";
  }

  return "";
}

String getProductType(int? kind) {
  /**
      ///动漫17    //漫画 小说18    //cos19    //真人21  //禁播22  ///写真24   ///图集 短视频 1
      // **/

  switch (kind) {
    case 17:
      return "动漫";
    case 18:
      return "漫画";
    case 19:
      return "角色扮演";
    case 21:
      return "真人";
    case 22:
      return "原作";
    case 24:
      return "写真";
    case 1:
      return "原作";
  }

  return "";
}

void jumpPage(int? kind, String? id,
    {int? index, List<MediaList>? mediaList, bool? isFreeZone = false}) async {
  AppNavigator.to.jumpDetails(kind, id ?? "",
      index: index, mediaList: mediaList, isFreeZone: isFreeZone);
}

Widget getBottomGridentShadowWith8Radius(
    double? width, int? updateStatus, String? updatedDesc,
    {bool? isFreeZone}) {
  //return Container();

  return Positioned(
    bottom: -1,
    child: Container(
      height: 30.w,
      width: width,
      padding: const EdgeInsets.only(right: 6, top: 6),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12.w),
            bottomRight: Radius.circular(12.w)),
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(0, 0, 0, 0),
            Color.fromRGBO(0, 0, 0, 0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        // borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      child: updateStatus == 1
          ? Text(
              updatedDesc.toString(),
              style: const TextStyle(
                  fontSize: 8, color: Color.fromRGBO(0, 255, 255, 1)),
            )
          : updateStatus == 2
              ? Text(
                  updatedDesc.toString(),
                  style: const TextStyle(fontSize: 8, color: Colors.white),
                )
              : Container(),
    ),
  );
}

Widget getBottomGridentShadow(
    double? width, int? updateStatus, String? updatedDesc,
    {bool? isFreeZone,
    bool showShadow = false,
    bool isNeedPosition = true,
    bool isNeedBorderRadius = false}) {
  //return Container();

  return isNeedPosition
      ? Positioned(
          bottom: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(isNeedBorderRadius ? 8 : 0),
              bottomRight: Radius.circular(isNeedBorderRadius ? 8 : 0),
            ),
            child: Container(
                height: 30.w,
                width: width,
                padding: const EdgeInsets.only(right: 6, top: 6),
                alignment: Alignment.centerRight,
                decoration: !showShadow
                    ? null
                    : const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(0, 0, 0, 0),
                            Color.fromRGBO(0, 0, 0, 0.8),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        // borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                child: updatedDesc?.isNotEmpty == true && updateStatus == 2
                    ? Container(
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 4),
                        child: Text(
                          updatedDesc?.toString() ?? "",
                          style: const TextStyle(
                              fontSize: 10,
                              color: Color.fromRGBO(62, 22, 157, 1),
                              fontWeight: FontWeight.w500),
                        ))
                    : null),
          ),
        )
      : ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(isNeedBorderRadius ? 8 : 0),
            bottomRight: Radius.circular(isNeedBorderRadius ? 8 : 0),
          ),
          child: Container(
            height: 30.w,
            width: width,
            padding: const EdgeInsets.only(right: 6, top: 6),
            alignment: Alignment.centerRight,
            decoration: !showShadow
                ? null
                : const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(0, 0, 0, 0),
                        Color.fromRGBO(0, 0, 0, 0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    // borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
            child: updateStatus == 1
                ? Text(
                    updatedDesc.toString(),
                    style: const TextStyle(
                        fontSize: 8, color: Color.fromRGBO(0, 255, 255, 1)),
                  )
                : updateStatus == 2
                    ? Text(
                        updatedDesc.toString(),
                        style:
                            const TextStyle(fontSize: 8, color: Colors.white),
                      )
                    : Container(),
          ),
        );
}

Widget getHomePageSpecialListAds(int index) {
  int j = ((index) / 2).round();
  int i = 0;
  if (state.homePageSpecialAds.isNotEmpty) {
    if (j % state.homePageSpecialAds.length == 0) {
      i = state.homePageSpecialAds.length - 1;
    } else {
      i = (j % state.homePageSpecialAds.length) - 1;
    }
  }

  return state.homePageSpecialAds.isEmpty
      ? Container()
      : Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              state.homePageSpecialAds[i].jumpAdvByType(AdsType.banner);
            },
            child: CustomImage(
              url: state.homePageSpecialAds[i].resourceUrl!,
              fit: BoxFit.cover,
              aspectRatio: 4.8,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
}

Widget buildEmptyUI({VoidCallback? retryTap}) => Container(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: <Widget>[
            getHeight(20),
            Text(
              "没有数据~",
              style: TextStyle(fontSize: 18.sp, color: AppColor.c44415b),
            ),
            Visibility(
              visible: retryTap != null,
              child: InkWell(
                onTap: () {
                  if (retryTap != null) {
                    retryTap.call();
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  child: const Text(
                    "点击重新加载~",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );

Widget advView(int index) {
  bool isShowAd = index % 2 == 1;
  if (!isShowAd) return Container();
  List<AdsInfoList> ads = homeLogic.loadAds();

  return Container(
      margin: EdgeInsets.only(bottom: 10.w, left: 10.w, right: 10.w, top: 10.w),
      width: 1.sw,
      height: 82.h,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 5.w,
          mainAxisSpacing: 8.w,
          childAspectRatio: 60.w / 82.h,
        ),
        itemCount: ads.length,
        itemBuilder: (BuildContext context, int index) {
          return _itemView(ads[index]);
        },
      ));
}

Widget _itemView(AdsInfoList item) {
  Widget body = Column(
    children: [
      AspectRatio(
          aspectRatio: 60.w / 60.w,
          child: CustomImage(
              url: item.resourceUrl, borderRadius: BorderRadius.circular(8))),
      4.verticalSpace,
      Text(
        item.title ?? '',
        maxLines: 1,
        style: TextStyle(
          color: const Color(0xFF555555),
          fontSize: 8.sp,
          fontFamily: 'Dream',
          fontWeight: FontWeight.w900,
        ),
      )
    ],
  );
  return GestureDetector(
      onTap: () {
        item.jumpAdvByType(AdsType.banner);
      },
      child: body);
}
