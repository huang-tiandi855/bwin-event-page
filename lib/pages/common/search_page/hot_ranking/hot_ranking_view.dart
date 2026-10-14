import 'package:comics_app/common/widgets/common_dialog/custom_loading_dialog.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/pages/loading/l_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../common/style/color.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import '../../../../common/widgets/space_widget.dart';
import 'hot_ranking_logic.dart';

class HotRankingPage extends StatelessWidget {
  final logic = Get.find<HotRankingLogic>();
  final state = Get.find<HotRankingLogic>().state;

  HotRankingPage({super.key});

  Widget getListView(bool isHorizonal) {
    return Container(
      margin: EdgeInsets.only(left: 12.w, right: 12.w),
      child: ListView.builder(
        itemCount: 36,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(
              bottom: 12.w,
            ),
            child: Row(
              children: [
                CustomImage(
                  url:
                      "https://i.pinimg.com/originals/0b/75/7c/0b757c02ace9a69e1959f1ce6273b74b.jpg",
                  fit: BoxFit.cover,
                  width: isHorizonal ? 161.w : 90.w,
                  height: isHorizonal ? 90.w : 132.w,
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                ),
                getWidth(12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "这是标题文字…",
                      maxLines: 1,
                      style: TextStyle(
                          color: const Color.fromRGBO(255, 255, 255, 1),
                          fontSize: 15.w),
                    ),
                    getHeight(12),
                    Row(
                      children: [
                        Text(
                          "动漫",
                          style: TextStyle(
                              color: const Color.fromRGBO(39, 248, 217, 1),
                              fontSize: 12.w),
                        ),
                        getWidth(3),
                        Text(
                          "动漫",
                          style: TextStyle(
                              color: const Color.fromRGBO(39, 248, 217, 1),
                              fontSize: 12.w),
                        ),
                        getWidth(3),
                        Text(
                          "动漫",
                          style: TextStyle(
                              color: const Color.fromRGBO(39, 248, 217, 1),
                              fontSize: 12.w),
                        ),
                      ],
                    ),
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
                          "3.5w",
                          style: TextStyle(
                              color: const Color.fromRGBO(98, 98, 98, 1),
                              fontSize: 12.w),
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
                                    color:
                                        const Color.fromRGBO(142, 142, 144, 1),
                                    fontSize: 27.w),
                              ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(
        "热门排行榜",
      ),
      body: Container(
        color: AppColor.bgGrey,
        child: GetBuilder<HotRankingLogic>(
          init: logic,
          builder: (_) {
            if (state.rankModel == null) {
              return LoadingWidget();
            }
            if (state.rankModel != null &&
                state.rankModel?.rankList?.isNotEmpty != true) {
              return const CErrorWidget();
            }
            return Column(
              children: [
                getHeight(8),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.r),
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 17.w, vertical: 2.w),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 4),
                      decoration: BoxDecoration(
                          color: const Color(0xffF0F0F3),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.6))),
                      child: TabBar(
                        controller: state.tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: state.rankModel!.rankList!.map((f) {
                          return Text(f.name ?? "");
                        }).toList(),
                        labelPadding:
                            EdgeInsets.symmetric(horizontal: 2.w, vertical: 2),
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
                                color: const Color(0xff8D8D8D).withOpacity(0.1),
                                width: 2)),
                        labelStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColor.c555555),
                      ),
                    )),
                getHeight(12),
                Expanded(
                  child: TabBarView(
                    controller: state.tabController,
                    children: state.tabViews,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
