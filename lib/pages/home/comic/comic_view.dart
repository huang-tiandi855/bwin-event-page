import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/style/text_styles.dart';
import 'package:comics_app/common/utils/utils.dart';
import 'package:comics_app/common/widgets/acg_section/acg_media_grid_layout_view.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/common/widgets/space_widget.dart';
import 'package:comics_app/pages/home/comic/comic_state.dart';
import 'package:comics_app/pages/home/home_logic.dart';
import 'package:comics_app/pages/home/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:comics_app/common/widgets/marquee_widget/marquee_widget.dart';

import '../../../common/entities/module_detail_model/all_section_model.dart';
import '../../../common/routers/app_routes.dart';
import '../../../common/style/color.dart';
import '../../../common/widgets/acg_section/acg_media_card.dart';
import '../../../common/widgets/acg_section/acg_media_grid_view.dart';
import '../../../common/widgets/acg_section/media_rank_layout_view.dart';
import '../../../common/utils/ads_manage/ads_grid_view_widget.dart';
import 'comic_logic.dart';
import 'package:comics_app/common/utils/ads_manage/ads_info_list_extension.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';

class ComicPage extends StatelessWidget {
  String? moduleId;
  bool showJingangqu = false;
  bool showAd = true;

  ComicPage({Key? key, this.moduleId, this.showJingangqu = false, this.showAd = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeLogicState = Get.find<HomeLogic>().state;
    return GetBuilder<ComicLogic>(
        init: ComicLogic(moduleId),
        tag: key?.toString(),
        builder: (logic) {
          var state = logic.state;
          return Container(
            color: AppColor.bgGrey,
            // ,
            child: PullRefreshView(
              controller: state.pullRefreshControllerComic,
              onLoading: () {
                if (logic.isSeeType()) {
                  state.seePageNum += 1;
                  logic.getSee();
                } else {
                  state.pageNum = state.pageNum + 1;
                  logic.getData();
                }
              },
              onRefresh: () {
                state.pageNum = 1;
                logic.getData();
              },
              child: CustomScrollView(
                slivers: [
                  if (showAd) _buildNewBanner(state, homeLogicState),
                  if (showAd) SliverToBoxAdapter(child: getHeight(18.w)),
                  if (showAd &&  ConfigStore.to.homePageAnnounceMent != null && ConfigStore.to.homePageAnnounceMent?.content != null)
                    SliverToBoxAdapter(
                      child: Container(
                        width: ScreenUtil().screenWidth,
                        height: 36.w,
                        margin: const EdgeInsets.only(left: 12, right: 12, top: 12),
                        alignment: Alignment.center,
                        child: ThemedChannelMarqueeBar(
                          text: ConfigStore.to.homePageAnnounceMent == null
                              ? ""
                              : ConfigStore.to.homePageAnnounceMent?.content ?? '',
                          onTap: () {
                            if (ConfigStore.to.homePageAnnounceMent == null) {
                              return;
                            }
                            AppNavigator.to.go(
                                ConfigStore.to.homePageAnnounceMent?.link ?? '');
                          },
                        ),
                      ),
                    ),
                  if (showJingangqu) SliverToBoxAdapter(child: getHeight(18.w)),
                  if (showJingangqu)
                    SliverToBoxAdapter(
                        child: Column(
                      children: [
                        SizedBox(
                          height: 10.w,
                        ),
                        ConfigStore.to.configBean.jingangArea?.acgList == null
                            ? Container()
                            : Container(
                                alignment: Alignment.center,
                                height: 85.w,
                                margin: EdgeInsets.only(left: 10.w),
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: ConfigStore.to.configBean.jingangArea!.acgList!.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          AppNavigator.to.jumpAdv(
                                              id: ConfigStore.to.configBean.jingangArea!.acgList![index].id.toString(),
                                              title: ConfigStore.to.configBean.jingangArea!.acgList![index].name.toString(),
                                              url: ConfigStore.to.configBean.jingangArea!.acgList![index].linkUrl.toString(), planId: '', slotCode: '');
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(right: 28.w),
                                          child: Column(
                                            children: [
                                              CustomImage(
                                                url: ConfigStore.to.configBean.jingangArea!.acgList![index].img,
                                                fit: BoxFit.cover,
                                                width: 42.w,
                                                height: 42.w,
                                                borderRadius: BorderRadius.circular(21),
                                                boxShadow: const [
                                                  BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 10, offset: Offset(0, 0))
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10.w,
                                              ),
                                              Text(
                                                ConfigStore.to.configBean.jingangArea!.acgList![index].name.toString(),
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
                    delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                      var item = state.featureEntity!.allSection[index];
                      bool isRank = item.allRankInfo.isNotEmpty;
                      if (isRank) logic.initController(item.allRankInfo.length);
                      var adsArr = item.isAdsArr();
                      return adsArr
                          ? AdsGridViewWidget(adsArr: item.adsInfoArr,padding: EdgeInsets.symmetric(horizontal: 16.w,vertical: 5.h),)
                          : Column(
                              children: [
                                if (item.showType != 19 && item.showType != 18)
                                  getTitle(item,
                                      hPadding: 12.w,
                                      onTap: isRank
                                          ? () {
                                              if (item.linkUrl?.isNotEmpty == true) {
                                                AppNavigator.to.jumpAdv(url: item.linkUrl!, planId: '', slotCode: '');
                                                return;
                                              }
                                              Get.toNamed(AppRoutes.HOT_RANKING_PAGE);
                                            }
                                          : null,
                                      showMore: !logic.isHideMore(item)),
                                if (isRank)
                                  MediaRankLayoutView(
                                    rankTabController: logic.state.rankTabController!,
                                    allRankInfo: item.allRankInfo,
                                  )
                                else
                                  MediaGridLayoutView(
                                      showType: item.showType,
                                      medias: item.allMediaInfo,
                                      padding: EdgeInsets.only(left: 12.w, right: 12.w)),
                              ],
                            );
                    }, childCount: state.featureEntity?.allSection.length ?? 0),
                  ),
                  MediaGridView.sliver(
                    crossAxisCount: 3, //横向数量
                    crossAxisSpacing: 8, //间距
                    mainAxisSpacing: 8, //行距
                    aspectRatio: 113.w / 216.w,
                    itemBuilder: (p0, index) {
                      final e = state.topicSectionModel!.mediaList![index];
                      return MediaCard.fromVideoModel(
                        e,
                        forceVerticalCover: true,
                        index: index,
                      );
                    },
                    itemCount: state.topicSectionModel?.mediaList?.length ?? 0,
                  ),
                ],
              ),
            ),
          );
        });
  }

  // 1：顶部轮播样式
  // 2：六宫格竖屏样式
  // 3: 六宫格横屏样式
  // 4: 四宫格竖屏样式
  // 5：四宫格横屏样式
  // 6: 四宫格竖屏列表样式
  // 7: 企业影片样式
  // 8: 三横屏列表样式
  // 9: 八竖屏划动样式
  // 10: 十六竖屏划动样式
  // 11: 十二横屏划动样式
  // 12: 片源推荐样式
  // 13：情色电影样式
  // 14:一大四小样式
  Widget getItem(
    int index,
    BuildContext context,
    AllSectionModel? listElement,
  ) {
    switch (listElement?.showType ?? 0) {
      case 0:
        return getThreeCover(index, listElement, isFreeZone: true, banner: state.banner, linkName: "首页-漫画-${listElement!.sectionName}");
      case 2:
        return getSixCover(index, context, listElement, banner: state.banner, linkName: "首页-漫画-${listElement!.sectionName}");
      case 4:
      case 6:
        return getVerticalFourCover(index, context, listElement, banner: state.banner, linkName: "首页-漫画-${listElement!.sectionName}");
      case 5:
        return getHorizonalFourCover(index, context, listElement, banner: state.banner, linkName: "首页-漫画-${listElement!.sectionName}");
      case 14:
        return getHorizonalFiveCover(context, listElement, banner: state.banner, linkName: "首页-漫画-${listElement!.sectionName}");
      case 3:
        return getHorizonalSixCover(context, listElement, banner: state.banner, linkName: "首页-漫画-${listElement!.sectionName}");

      default:
        return getSixCover(index, context, listElement, banner: state.banner, linkName: "首页-漫画-${listElement!.sectionName}");
    }
  }

  SliverPadding _buildNewBanner(ComicState state, HomeState homeLogicState) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(6, 12, 6, 0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          return GestureDetector(
            onTap: () {
              state.banner[index].jumpAdvByType(AdsType.banner);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: CustomImage(
                    url: state.banner[index].resourceUrl!,
                    width: 60.w,
                    height: 60.h,
                    fit: BoxFit.cover,
                  ),
                ),
                Text(
                  state.banner[index].title!,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Color(0xff333333)),
                ),
              ],
            ),
          );
        }, childCount: state.banner.length >= 10 ? 10 : state.banner.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 12,
          childAspectRatio: 60 / 82,
        ),
      ),
    );
  }

}
