import 'package:comics_app/common/store/store.dart';

import 'package:comics_app/common/utils/utils.dart';
import 'package:comics_app/common/widgets/acg_section/acg_media_card.dart';

import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/common/widgets/space_widget.dart';

import 'package:comics_app/pages/home/home_logic.dart';
import 'package:comics_app/pages/common/mine/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:comics_app/common/widgets/marquee_widget/marquee_widget.dart';

import '../../../common/style/color.dart';

import '../../../common/widgets/acg_section/acg_media_grid_view.dart';
import '../home_state.dart';
import 'comic_logic.dart';
import 'comic_state.dart';
import 'package:comics_app/common/utils/ads_manage/ads_info_list_extension.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';

class ComicPage2 extends StatelessWidget {
  String? moduleId;
  final int crossCount;
  int? showTabNum;
  final double? aspectRatio;
  bool showAd = true;
  bool isFlow = false;
  ComicPage2(
      {Key? key,
      this.moduleId,
      this.crossCount = 3,
      this.aspectRatio,
      this.showTabNum,
      this.showAd = true,
      this.isFlow = false})
      : super(key: key);
  ComicLogic2 get logic =>
      Get.put(ComicLogic2(moduleId, showTabNum: showTabNum),
          tag: key.toString());
  @override
  Widget build(BuildContext context) {
    final state = logic.state;
    final homeLogicState = Get.find<HomeLogic>().state;
    return GetBuilder<ComicLogic2>(
        init: logic,
        tag: key.toString(),
        builder: (logic) {
          return Container(
            color: AppColor.bgGrey,
            // padding: EdgeInsets.only(left: 10.w, right: 10.w),
            child: PullRefreshView(
              controller: state.pullRefreshControllerComic,
              onLoading: () {
                state.pageNum = state.pageNum + 1;
                logic.getData();
              },
              onRefresh: () {
                state.pageNum = 1;
                // lists.clear();
                logic.getData();
              },
              child: CustomScrollView(
                slivers: [
                  if (showAd) _buildNewBanner(state, homeLogicState),
                  if (showAd) SliverToBoxAdapter(child: getHeight(18.w)),
                  if (showAd &&
                      ConfigStore.to.homePageAnnounceMent != null &&
                      ConfigStore.to.homePageAnnounceMent?.content != null)
                    SliverToBoxAdapter(
                      child: Container(
                        width: ScreenUtil().screenWidth,
                        height: 36.w,
                        margin:
                            const EdgeInsets.only(left: 12, right: 12, top: 12),
                        alignment: Alignment.center,
                        child: ThemedChannelMarqueeBar(
                          text: ConfigStore.to.homePageAnnounceMent == null
                              ? ""
                              : ConfigStore.to.homePageAnnounceMent?.content ??
                                  '',
                          onTap: () {
                            if (ConfigStore.to.homePageAnnounceMent == null) {
                              return;
                            }
                            AppNavigator.to.go(
                                ConfigStore.to.homePageAnnounceMent?.link ??
                                    '');
                          },
                        ),
                      ),
                    ),
                  getSliverHeight(12),
                  if (showTabNum != null)
                    SliverToBoxAdapter(
                      child: Container(
                        height: 35,
                        width: 1.sw,
                        margin: EdgeInsets.symmetric(
                            vertical: 2.w, horizontal: 12.w),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 4),
                        decoration: BoxDecoration(
                            color: const Color(0xffF0F0F3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.6))),
                        child: TabBar(
                          controller: state.tabController,
                          tabs: state.currentTabs.map((f) {
                            return Text(f);
                          }).toList(),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelPadding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 2),
                          isScrollable: false,
                          labelColor: AppColor.c555555,
                          unselectedLabelColor: AppColor.c999999,
                          unselectedLabelStyle: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColor.c999999),
                          indicator: BoxDecoration(
                              color: Colors.white,
                              gradient: const LinearGradient(colors: [
                                Color.fromRGBO(0, 0, 0, 0.05),
                                Color.fromRGBO(141, 141, 141, 0.05)
                              ]),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color:
                                      const Color(0xff8D8D8D).withOpacity(0.1),
                                  width: 2)),
                          labelStyle: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColor.c555555),
                        ),
                      ),
                    ),
                  if (showTabNum != null) getSliverHeight(12),
                  if (isFlow &&
                      state.moduleDetailModel?.allMediaInfo.isNotEmpty == true)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      sliver: SliverList(
                          delegate: SliverChildListDelegate([
                        staggeredAllMediaList(
                            state.moduleDetailModel!.allMediaInfo)
                      ])),
                    )
                  else if (state.moduleDetailModel?.allMediaInfo.isNotEmpty ==
                      true)
                    MediaGridView.sliver(
                      crossAxisCount: crossCount, //横向数量
                      crossAxisSpacing: 8, //间距
                      mainAxisSpacing: 8, //行距
                      aspectRatio: aspectRatio ?? 113.w / 216.w,
                      itemBuilder: (p0, index) {
                        final e = state.moduleDetailModel!.allMediaInfo[index];
                        return MediaCard.fromVideoModel(
                          e,
                          mediaList: state.moduleDetailModel!.allMediaInfo,
                          index: index,
                          forceVerticalCover: (aspectRatio ?? 0) < 1,
                        );
                      },
                      itemCount:
                          state.moduleDetailModel?.allMediaInfo.length ?? 0,
                    ),
                ],
              ),
            ),
          );
        });
  }

  SliverPadding _buildNewBanner(ComicState2 state, HomeState homeLogicState) {
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
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xff333333)),
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
