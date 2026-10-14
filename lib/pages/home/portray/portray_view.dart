import 'package:card_swiper/card_swiper.dart';
import 'package:comics_app/common/entities/feature_info.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/style/text_styles.dart';
import 'package:comics_app/common/utils/utils.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/common/widgets/space_widget.dart';
import 'package:comics_app/pages/home/home_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:comics_app/common/widgets/marquee_widget/marquee_widget.dart';

import '../../../common/style/color.dart';
import 'portray_logic.dart';
import 'package:comics_app/common/utils/ads_manage/ads_info_list_extension.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';

class PortrayPage extends StatelessWidget {
  const PortrayPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(PortrayLogic());
    final state = Get.find<PortrayLogic>().state;

    final homeLogicState = Get.find<HomeLogic>().state;

    List<Widget> lists = [];

    return GetBuilder<PortrayLogic>(builder: (logic) {
      if (state.featureEntity != null &&
          homeLogicState.homePageSpecialAds.isNotEmpty) {
        for (var element in state.featureEntity!.data!.list!) {
          lists.add(getItem(state.featureEntity!.data!.list!.indexOf(element),
              context, element));
        }

        for (int i = 0; i < lists.length; i++) {
          if ((i + 1) % 2 == 0) {
            lists.insert(i, getHomePageSpecialListAds(i));
          }
        }
      }

      return Container(
        color: AppColor.bgGrey,
        padding: EdgeInsets.only(left: 12.w, right: 12.w),
        child: PullRefreshView(
          controller: state.pullRefreshPortrayController,
          onLoading: () {
            state.pageNum = state.pageNum! + 1;
            logic.doInit();
          },
          onRefresh: () {
            state.pageNum = 1;
            lists.clear();
            logic.doInit();
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: () {
                    //banner为空的容错处理
                    if (homeLogicState.banner?.isEmpty ?? true) return;
                    homeLogicState.banner![state.selectIndex].jumpAdvByType(AdsType.banner);
                  },
                  child: Container(
                    height: 143.w,
                    width: ScreenUtil().screenWidth,
                    color: AppColor.bgGrey,
                    padding: const EdgeInsets.only(top: 12),
                    // height: 143.w,
                    child: Stack(
                      children: [
                        Swiper(
                          onIndexChanged: (index) {
                            state.selectIndex = index;
                          },
                          itemBuilder: (BuildContext context, int index) {
                            return ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              child: GestureDetector(
                                onTap: () {
                                  homeLogicState.banner![index].jumpAdvByType(AdsType.banner);
                                },
                                child: CustomImage(
                                  url: homeLogicState.banner![index].resourceUrl!,
                                  //height: 262.w,
                                  aspectRatio: 2.39,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            );
                          },
                          autoplayDelay: 5000,
                          itemCount: homeLogicState.banner!.length,
                          autoplay: true,
                          loop: true,
                          pagination: (homeLogicState.banner?.length ?? 0) > 1
                              ? const SwiperPagination(
                                  alignment: Alignment.bottomRight,
                                  builder: DotSwiperPaginationBuilder(
                                    activeColor:
                                        Color.fromRGBO(148, 214, 218, 1),
                                    space: 6,
                                    size: 6,
                                    activeSize: 9,
                                    color: Color.fromRGBO(48, 214, 218, 0.5),
                                  ),
                                )
                              : null,
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            color: Colors.transparent,
                            height: 130.w,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: getHeight(18.w)),
              SliverToBoxAdapter(
                child: SizedBox(
                  width: ScreenUtil().screenWidth,
                  child: LightChannelMarqueeBar(
                    text: ConfigStore.to.homePageAnnounceMent == null
                        ? ""
                        : ConfigStore.to.homePageAnnounceMent.toString(),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: getHeight(18.w)),
              SliverToBoxAdapter(
                  child: Column(
                children: [
                  SizedBox(
                    height: 10.w,
                  ),
                  ConfigStore.to.configBean.jingangArea == null
                      ? Container()
                      : Container(
                          alignment: Alignment.center,
                          height: 85.w,
                          margin: EdgeInsets.only(left: 10.w),
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: ConfigStore
                                  .to.configBean.jingangArea!.list!.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    AppNavigator.to.jumpAdv(
                                        id: ConfigStore.to.configBean
                                            .jingangArea!.list![index].id
                                            .toString(),
                                        title: ConfigStore.to.configBean
                                            .jingangArea!.list![index].name
                                            .toString(),
                                        url: ConfigStore.to.configBean
                                            .jingangArea!.list![index].linkUrl.toString(), planId: '', slotCode: '');
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 28.w),
                                    child: Column(
                                      children: [
                                        CustomImage(
                                          url: ConfigStore.to.configBean
                                              .jingangArea!.list![index].img,
                                          fit: BoxFit.cover,
                                          width: 42.w,
                                          height: 42.w,
                                        ),
                                        SizedBox(
                                          height: 10.w,
                                        ),
                                        Text(
                                          ConfigStore.to.configBean.jingangArea!
                                              .list![index].name
                                              .toString(),
                                          style: AppTextStyles.blackRegular10,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                  commonLine(),
                ],
              )),
              getSliverHeight(12),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return Column(
                    children: [
                      getItem(index, context,
                          state.featureEntity?.data?.list![index]),
                      if (homeLogicState.homePageSpecialAds.isNotEmpty)
                        advView(index)
                    ],
                  );
                }, childCount: state.featureEntity?.data?.list?.length),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget getItem(
    int index,
    BuildContext context,
    ListElement? listElement,
  ) {
    switch (listElement?.direction!) {
      case 0:
        return getThreeCover(index, listElement,
            isFreeZone: true,
            banner: state.banner,
            linkName: "首页-写真-${listElement!.name}");
      case 1:
        return getSixCover(index, context, listElement,
            banner: state.banner, linkName: "首页-写真-${listElement!.name}");
      case 2:
        return getVerticalFourCover(index, context, listElement,
            banner: state.banner, linkName: "首页-写真-${listElement!.name}");
      case 3:
        return getHorizonalFourCover(index, context, listElement,
            banner: state.banner, linkName: "首页-写真-${listElement!.name}");
      case 4:
        return getHorizonalFiveCover(context, listElement,
            banner: state.banner, linkName: "首页-写真-${listElement!.name}");
      case 5:
        return getHorizonalSixCover(context, listElement,
            banner: state.banner, linkName: "首页-写真-${listElement!.name}");

      default:
        return getSixCover(index, context, listElement,
            banner: state.banner, linkName: "首页-写真-${listElement!.name}");
    }
  }
}
