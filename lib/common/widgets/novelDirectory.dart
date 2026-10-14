import 'package:comics_app/common/entities/media_info_entity.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/values/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../pages/bookshelf/novel_details/novel_details_logic.dart';
import '../res/r.dart';
import '../routers/app_routes.dart';

novelDirectory(MediaInfoEntity mediaInfoEntity, MediaKind mediaKind) async {
  int totalEpisode = mediaInfoEntity.totalEpisode ?? 0;
  int curLength = mediaInfoEntity.contents?.length ?? 0;
  String chapter = mediaKind == MediaKind.mediaKindComics
      ? "剧集（全$totalEpisode话）"
      : "目录（全$totalEpisode章）";
  final novelDetailsLogic = Get.find<NovelDetailsLogic>();
  return await Get.bottomSheet(
      SizedBox(
        height: 439.w,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppLocation.appHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 18.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(chapter,
                        style: TextStyle(
                            fontSize: 18.sp,
                            color: AppColor.black,
                            fontWeight: FontWeight.w500)),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child:
                          Icon(Icons.close, size: 24.sp, color: AppColor.black),
                    )
                  ],
                ),
              ),
              Expanded(
                  child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 19.w,
                    crossAxisSpacing: 19.w),
                itemBuilder: (context, index) {
                  bool isActive = false;
                  int episodeNumber = index + 1;
                  if (index < curLength) {
                    isActive =
                        mediaInfoEntity.contents?[index].isActive ?? false;
                    episodeNumber =
                        mediaInfoEntity.contents?[index].episodeNumber ??
                            index + 1;
                  }
                  return !isActive
                      ? InkWell(
                          onTap: () {
                            showToast(msg: "敬请期待");
                          },
                          child: Container(
                            height: 55.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: AppColor.warmGrey.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(3)),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text('$episodeNumber',
                                    style: TextStyle(
                                        fontSize: 18.sp,
                                        color: AppColor.black.withOpacity(0.8),
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () async {
                            final novelDetailsLogic =
                                Get.find<NovelDetailsLogic>();
                            bool isOk = await novelDetailsLogic
                                .checkPlayPermission(index);
                            if (!isOk) return;
                            if (mediaKind == MediaKind.mediaKindRealFiction) {
                              //EventTrackingManager().addEpisodeVideoDatas(mediaInfoEntity.id, mediaInfoEntity.title);

                              await Get.toNamed(AppRoutes.READER, arguments: {
                                "data": mediaInfoEntity,
                                "index": index + 1
                              });
                              Get.back();
                            } else if (mediaKind == MediaKind.mediaKindComics) {
                              //EventTrackingManager().addEpisodeVideoDatas(mediaInfoEntity.id, mediaInfoEntity.title);
                              await Get.toNamed(AppRoutes.COMIC_READER,
                                  arguments: {
                                    "data": mediaInfoEntity,
                                    "index": index + 1
                                  });
                              Get.back();
                            }
                          },
                          child: Container(
                            height: 55.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: novelDetailsLogic.state.index ==
                                        index
                                    ? AppColor.bluishPurple.withOpacity(0.1)
                                    : AppColor.whiteBackground,
                                borderRadius: BorderRadius.circular(3)),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                GetBuilder<NovelDetailsLogic>(
                                    id: 'refreshOldEpisode',
                                    builder: (logic) {
                                      return Text('$episodeNumber',
                                          style: TextStyle(
                                              fontSize: 18.sp,
                                              color: novelDetailsLogic
                                                          .state.index ==
                                                      index
                                                  ? AppColor.bluishPurple
                                                  : Colors.black,
                                              fontWeight: FontWeight.w500));
                                    }),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: _getNovelIcon(mediaInfoEntity
                                          .contents?[index].listenPermission ??
                                      0),
                                )
                              ],
                            ),
                          ),
                        );
                },
                itemCount: totalEpisode,
              )),
              SizedBox(height: 10.w)
            ],
          ),
        ),
      ),
      backgroundColor: AppColor.white);
}

_getNovelIcon(int index) {
  if (index == 0) {
    return SvgPicture.asset(R.vip, width: 24.w);
  } else if (index == 1) {
    return SvgPicture.asset(R.goldMask, width: 24.w);
  } else {
    return SvgPicture.asset(R.freeMark, width: 28.w);
  }
}
