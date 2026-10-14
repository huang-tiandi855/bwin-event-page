import 'package:comics_app/common/widgets/space_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'hot_ranking_detail_logic.dart';

class HotRankingDetailPage extends StatelessWidget {
  const HotRankingDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(HotRankingDetailLogic());

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
                  //width: isHorizonal ? 161.w : 90.w,
                  //height: isHorizonal ? 90.w : 132.w,
                  width: 90.w,
                  height: 132.w,
                  // borderRadius: const BorderRadius.all(Radius.circular(6)),
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
}
