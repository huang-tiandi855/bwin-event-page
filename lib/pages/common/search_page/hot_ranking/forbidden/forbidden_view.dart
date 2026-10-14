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
import 'forbidden_logic.dart';

class ForbiddenRankingPage extends StatelessWidget {
  const ForbiddenRankingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(ForbiddenHotRankingLogic());
    final state = Get.find<ForbiddenHotRankingLogic>().state;
    return GetBuilder<ForbiddenHotRankingLogic>(builder: (logic) {
      return state.ranking == null
          ? const LoadingWidget()
          : Container(
              margin: EdgeInsets.only(left: 12.w, right: 12.w),
              child: PullRefreshView(
                onRefresh: () {
                  logic.getMediaInfo();
                },
                onLoading: () {
                  logic.getMediaInfo();
                },
                controller: state.pullRefreshController,
                child: GridView.builder(
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
                                "热门排行榜-动漫"));

                        jumpPage(state.ranking?.data?.mediaList?[index].kind,
                            state.ranking?.data?.mediaList?[index].id);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: 0.w,
                        ),
                        color: Colors.transparent,
                        child: Column(
                          children: [
                            Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                ClipRRect(
                                  borderRadius:
                                      const BorderRadius.all(Radius.circular(8)),
                                  child: CustomImage(
                                    url: state.ranking?.data?.mediaList?[index]
                                        .verticalCover,
                                    fit: BoxFit.cover,
                                    width: 111.w,
                                    height: 162.w,
                                    // borderRadius: const BorderRadius.all(
                                    //     Radius.circular(6)),
                                  ),
                                ),
                                getBottomGridentShadow(
                                    111.w,
                                    state.ranking?.data?.mediaList?[index]
                                        .updateStatus,
                                    state.ranking?.data?.mediaList?[index]
                                        .updatedDesc),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: index == 0
                                      ? Image.asset(
                                          "assets/images/png/ranking_one.png",
                                          width: 24.w,
                                          height: 30.w,
                                        )
                                      : index == 1
                                          ? Image.asset(
                                              "assets/images/png/ranking_two.png",
                                              width: 24.w,
                                              height: 30.w,
                                            )
                                          : index == 2
                                              ? Image.asset(
                                                  "assets/images/png/ranking_three.png",
                                                  width: 24.w,
                                                  height: 30.w,
                                                )
                                              : Container(
                                                  alignment: Alignment.center,
                                                  width: 24.w,
                                                  height: 24.w,
                                                  decoration:
                                                      const BoxDecoration(
                                                    image: DecorationImage(
                                                        image: AssetImage(
                                                            "assets/images/png/ranking_bg_grey.png")),
                                                  ),
                                                  child: Text(
                                                    index < 9
                                                        ? "0${index + 1}"
                                                        : (index + 1)
                                                            .toString(),
                                                    style: TextStyle(
                                                        color: const Color
                                                            .fromRGBO(
                                                            255, 255, 255, 1),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 12.w),
                                                  ),
                                                ),
                                ),
                              ],
                            ),
                            getWidth(12),
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  getHeight(4),
                                  SizedBox(
                                    width: 200.w,
                                    child: Text(
                                      state.ranking!.data!.mediaList![index]
                                          .title
                                          .toString(),
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: AppColor.black,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  getHeight(2),
                                  getTagWidget(
                                    state.ranking!.data!.mediaList![index]
                                        .tagNames,
                                    state.ranking!.data!.mediaList![index].tags,
                                    state.ranking!.data!.mediaList![index].kind,
                                    textColor: const Color.fromRGBO(74, 74, 74, 1),
                                  ),
                                ],
                              ),
                            ),
                            /*const Spacer(),
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
                                          ),*/
                          ],
                        ),
                      ),
                    );
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 111 / 200,
                      crossAxisCount: 3,
                      crossAxisSpacing: 0.w,
                      mainAxisSpacing: 0.w),
                ),
              ),
            );
    });
  }
}
