import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/common/widgets/loading_widget.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/common/widgets/space_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/MediaListInfo.dart';
import '../../../../../common/style/color.dart';
import 'cos_logic.dart';

class CosRankingPage extends StatelessWidget {
  const CosRankingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(CosHorRankingLogic());
    final state = Get.find<CosHorRankingLogic>().state;
    return GetBuilder<CosHorRankingLogic>(builder: (logic) {
      return state.ranking == null
          ? const LoadingWidget()
          : Container(
              margin: EdgeInsets.only(left: 12.w, right: 12.w),
              child: PullRefreshView(
                enablePullUp: false,
                onRefresh: () {
                  logic.getMediaInfo();
                },
                onLoading: () {
                  logic.getMediaInfo();
                },
                controller: state.pullRefreshController,
                child: ListView.builder(
                  itemCount: state.ranking?.data?.mediaList?.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        ConfigStore.to.trackData(
                            '作品点击',
                            ConfigStore.to.getClickProductInfoMap(
                                MediaList.fromJson(state
                                    .ranking?.data?.mediaList?[index]
                                    .toJson()),
                                "热门排行榜-COS"));

                        jumpPage(state.ranking?.data?.mediaList?[index].kind,
                            state.ranking?.data?.mediaList?[index].id);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: 12.w,
                        ),
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                CustomImage(
                                  url: state.ranking?.data?.mediaList?[index]
                                      .horizontalCover,
                                  fit: BoxFit.cover,
                                  //width: isHorizonal ? 161.w : 90.w,
                                  //height: isHorizonal ? 90.w : 132.w,
                                  width: 161.w,
                                  height: 90.w,
                                  // borderRadius: const BorderRadius.all(
                                  //     Radius.circular(6)),
                                ),
                                getBottomGridentShadow(
                                    166.w,
                                    state.ranking?.data?.mediaList?[index]
                                        .updateStatus,
                                    state.ranking?.data?.mediaList?[index]
                                        .updatedDesc),
                              ],
                            ),
                            getWidth(12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 142.w,
                                  child: Text(
                                    state.ranking!.data!.mediaList![index].title
                                        .toString(),
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: AppColor.black,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                getHeight(12),
                                getTagWidget(
                                    state.ranking!.data!.mediaList![index]
                                        .tagNames,
                                    state.ranking!.data!.mediaList![index].tags,
                                    state.ranking!.data!.mediaList![index].kind,
                                    textColor: AppColor.warmGrey),
                                getHeight(12),
                                Row(
                                  children: [
                                    Image.asset(
                                      "assets/images/png/ranking_fire.png",
                                      width: 14.8.w,
                                      height: 17.w,
                                    ),
                                    getWidth(11.8.w),
                                    Text(
                                      state.ranking!.data!.sumSli![index]
                                          .toString(),
                                      style: TextStyle(
                                          color: AppColor.brownishGrey,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            index == 0
                                ? Image.asset(
                                    "assets/images/png/ranking_one.png",
                                    width: 30.w,
                                    height: 30.w,
                                  )
                                : index == 1
                                    ? Image.asset(
                                        "assets/images/png/ranking_two.png",
                                        width: 30.w,
                                        height: 30.w,
                                      )
                                    : index == 2
                                        ? Image.asset(
                                            "assets/images/png/ranking_three.png",
                                            width: 30.w,
                                            height: 30.w,
                                          )
                                        : Text(
                                            index < 9
                                                ? "0${index + 1}"
                                                : (index + 1).toString(),
                                            style: TextStyle(
                                                color: const Color.fromRGBO(
                                                    142, 142, 144, 1),
                                                fontSize: 27.w),
                                          ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
    });
  }
}
