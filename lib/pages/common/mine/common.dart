import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:comics_app/common/entities/media_list_entity.dart';
import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/entities/video_model/video_model.dart';
import 'package:comics_app/common/widgets/video_section/video_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../common/entities/MediaListInfo.dart';
import '../../../common/res/r.dart';
import '../../../common/utils/toast_util.dart';
import '../../../common/utils/utils.dart';
import '../../../common/values/enum.dart';
import 'package:comics_app/pages/image/network/image_cache_manager.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import '../../../common/widgets/space_widget.dart';
import '../../../generated/assets.dart';

Widget title() {
  return SliverToBoxAdapter(
    child: Padding(
      padding: EdgeInsets.only(top: 13.w, bottom: 12.w),
      child: Text(
        "猜你想看",
        style: TextStyle(fontSize: 18.sp, color: Colors.black),
      ),
    ),
  );
}

// 历史记录每行3个item
Widget sliverGrid3History(List list,
    {childLogic, parentLogic, required MediaKind type, String? linkName}) {
  return SliverGrid(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 113 / 216),
    delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
      String verticalCover = list[index]['verticalCover'] ?? "";
      String title = list[index]['title'] ?? "未知";
      int kind = list[index]['kind'] ?? 0;
      String id = list[index]['mediaID'] ?? "";
      int episode = list[index]['episode'] ?? 1;
      List<String> tagNames = list[index]['tagNames'] != null
          ? list[index]['tagNames'].cast<String>()
          : [];
      List<String> tags =
          list[index]['tags'] != null ? list[index]['tags'].cast<String>() : [];
      int permission = list[index]['permission'] ?? 0;

      int updateStatus = list[index]['updateStatus'] ?? 0;

      int totalEpisode = list[index]['totalEpisode'] ?? 0;
      return GestureDetector(
        onTap: () async {
          /*ConfigStore.to.trackData(
              '作品点击',
              ConfigStore.to
                  .getClickProductInfoMap(MediaList.fromJson(e.value.toJson()),linkName!));*/

          if (kind == 5) {
            List<MediaListMediaList> lists = [];

            for (int i = 0; i < list.length; i++) {
              lists.add(MediaListMediaList.fromJson(list[i]));
            }

            AppNavigator.to.jumpDetails(kind, id,
                selectedEpisode: episode, index: index, portrayList: lists);
          } else {
            AppNavigator.to
                .jumpDetails(kind, id, selectedEpisode: episode, index: index);
          }

          Timer(const Duration(milliseconds: 300), () {
            childLogic.refreshPage();
          });
        },
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomImage(
                      height: 166.w,
                      url: verticalCover,
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    getCoverIcon(permission),
                    Positioned(
                        right: 6,
                        bottom: 6,
                        child: SizedBox(
                          width: 78,
                          height: 20,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 2),
                                decoration: ShapeDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      (updateStatus == 2 || updateStatus == 0)
                                          ? '已完结·$totalEpisode话'
                                          : '更新中·$totalEpisode话',
                                      style: const TextStyle(
                                        color: Color(0xFF3D169C),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                    Obx(() => Offstage(
                          offstage: parentLogic.state.isEdit.value,
                          child: GestureDetector(
                            onTap: () async {
                              bool? isOk = HistoryOperation.getInstance()
                                      ?.delete(type, index) ??
                                  false;
                              if (isOk) {
                                if (list.isEmpty) {
                                  parentLogic.state.isEdit.value = true;
                                }
                                childLogic.update(['list']);
                                showToast(msg: "删除成功");
                                return;
                              }
                              showToast(msg: "删除失败");
                            },
                            child: Container(
                              height: 162.w,
                              color: Colors.black.withOpacity(0.72),
                              alignment: Alignment.center,
                              child: SvgPicture.asset(R.delete, width: 30.w),
                            ),
                          ),
                        )),
                    getBottomGridentShadow(112.w, list[index]['updateStatus'],
                        list[index]['updatedDesc'],
                        isNeedPosition: false),
                  ],
                ),
                SizedBox(height: 4.w),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(height: 2.w),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: getTagWidget(tagNames, tags, kind),
                ),
                // Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                // Text.rich(
                //   TextSpan(
                //       children: List.generate(
                //           list[index]['tagNames']?.length ?? 0,
                //           (kIndex) => TextSpan(
                //               text: '${list[index]['tagNames']?[kIndex]} '))),
                //   maxLines: 1,
                //   style: TextStyle(
                //       overflow: TextOverflow.ellipsis,
                //       color: AppColor.c27f8d9,
                //       fontSize: 12.sp),
                // )
              ],
            ),
          ),
        ),
      );
    }, childCount: list.length),
  );
}

Widget sliverGrid3PhotoHistory(List list,
    {childLogic, parentLogic, required MediaKind type, String? linkName}) {
  return SliverGrid(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 173 / 226),
    delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
      String verticalCover = list[index]['verticalCover'] ?? "";
      String title = list[index]['title'] ?? "未知";
      int kind = list[index]['kind'] ?? 0;
      String id = list[index]['mediaID'] ?? "";
      int episode = list[index]['episode'] ?? 1;
      list[index]['tagNames'] != null
          ? list[index]['tagNames'].cast<String>()
          : [];
      list[index]['tags'] != null ? list[index]['tags'].cast<String>() : [];
      int permission = list[index]['permission'] ?? 0;

      int countBrowse = list[index]['countBrowse'] ?? 0;
      int coverImageCounts = list[index]['coverImageCounts'] ?? 0;
      return GestureDetector(
        onTap: () async {
          /*ConfigStore.to.trackData(
              '作品点击',
              ConfigStore.to
                  .getClickProductInfoMap(MediaList.fromJson(e.value.toJson()),linkName!));*/

          if (kind == 5) {
            List<MediaListMediaList> lists = [];

            for (int i = 0; i < list.length; i++) {
              lists.add(MediaListMediaList.fromJson(list[i]));
            }

            AppNavigator.to.jumpDetails(kind, id,
                selectedEpisode: episode, index: index, portrayList: lists);
          } else {
            AppNavigator.to
                .jumpDetails(kind, id, selectedEpisode: episode, index: index);
          }

          Timer(const Duration(milliseconds: 300), () {
            childLogic.refreshPage();
          });
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.w),
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomImage(
                      height: 173.w,
                      url: verticalCover,
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      //child: getPermissionIcon(permission),
                      child: getMarkIcon(permission, list[index]['price']),
                    ),
                    Obx(() => Offstage(
                          offstage: parentLogic.state.isEdit.value,
                          child: GestureDetector(
                            onTap: () async {
                              bool? isOk = HistoryOperation.getInstance()
                                      ?.delete(type, index) ??
                                  false;
                              if (isOk) {
                                if (list.isEmpty) {
                                  parentLogic.state.isEdit.value = true;
                                }
                                childLogic.update(['list']);
                                showToast(msg: "删除成功");
                                return;
                              }
                              showToast(msg: "删除失败");
                            },
                            child: Container(
                              height: 162.w,
                              color: Colors.black.withOpacity(0.72),
                              alignment: Alignment.center,
                              child: SvgPicture.asset(R.delete, width: 30.w),
                            ),
                          ),
                        )),
                    getBottomGridentShadow(112.w, list[index]['updateStatus'],
                        list[index]['updatedDesc']),
                  ],
                ),
                SizedBox(height: 4.w),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 2.w),
                Container(
                  width: 163,
                  height: 16,
                  margin: const EdgeInsets.only(left: 4, right: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/photo_view_count.webp",
                            width: 12.8,
                            height: 12.8,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            countBrowse.toString(),
                            style: const TextStyle(
                              color: Color(0xFF777777),
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/photo_img_count.webp",
                            width: 12.8,
                            height: 12.8,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            coverImageCounts.toString(),
                            style: const TextStyle(
                              color: Color(0xFF777777),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                // Text.rich(
                //   TextSpan(
                //       children: List.generate(
                //           list[index]['tagNames']?.length ?? 0,
                //           (kIndex) => TextSpan(
                //               text: '${list[index]['tagNames']?[kIndex]} '))),
                //   maxLines: 1,
                //   style: TextStyle(
                //       overflow: TextOverflow.ellipsis,
                //       color: AppColor.c27f8d9,
                //       fontSize: 12.sp),
                // )
              ],
            ),
          ),
        ),
      );
    }, childCount: list.length),
  );
}

// 历史记录每行3个item
Widget sliverGrid2History(List list,
    {childLogic, parentLogic, required MediaKind type}) {
  return SliverGrid(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 10,
        childAspectRatio: 171 / 144),
    delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
      String horizontalCover = list[index]['horizontalCover'] ?? "";
      String title = list[index]['title'] ?? "未知";
      int kind = list[index]['kind'] ?? 0;
      String id = list[index]['mediaID'] ?? "";
      int episode = list[index]['episode'] ?? 1;
      List<String> tagNames = list[index]['tagNames'] != null
          ? list[index]['tagNames'].cast<String>()
          : [];
      List<String> tags =
          list[index]['tags'] != null ? list[index]['tags'].cast<String>() : [];
      int permission = list[index]['permission'] ?? 0;
      int updateStatus = list[index]['updateStatus'] ?? 0;

      int totalEpisode = list[index]['totalEpisode'] ?? 0;
      return GestureDetector(
        onTap: () async {
          await AppNavigator.to
              .jumpDetails(kind, id, selectedEpisode: episode, index: index);
          Timer(const Duration(milliseconds: 300), () {
            childLogic.refreshPage();
          });
        },
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomImage(
                      height: 96.w,
                      url: horizontalCover,
                      // borderRadius: BorderRadius.circular(6.w),
                    ),
                    getCoverIcon(permission),
                    Positioned(
                        right: 6,
                        bottom: 6,
                        child: SizedBox(
                          width: 78,
                          height: 20,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 2),
                                decoration: ShapeDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      (updateStatus == 2 || updateStatus == 0)
                                          ? '已完结·$totalEpisode话'
                                          : '更新中·$totalEpisode话',
                                      style: const TextStyle(
                                        color: Color(0xFF3D169C),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                    Obx(() => Offstage(
                          offstage: parentLogic.state.isEdit.value,
                          child: GestureDetector(
                            onTap: () async {
                              bool? isOk = HistoryOperation.getInstance()
                                      ?.delete(type, index) ??
                                  false;
                              if (isOk) {
                                if (list.isEmpty) {
                                  parentLogic.state.isEdit.value = true;
                                }
                                childLogic.update(['list']);
                                showToast(msg: "删除成功");
                                return;
                              }
                              showToast(msg: "删除失败");
                            },
                            child: Container(
                              height: 96.w,
                              color: Colors.black.withOpacity(0.72),
                              alignment: Alignment.center,
                              child: SvgPicture.asset(R.delete, width: 30.w),
                            ),
                          ),
                        )),
                    getBottomGridentShadow(176.w, list[index]['updateStatus'],
                        list[index]['updatedDesc']),
                  ],
                ),
                SizedBox(height: 8.w),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
                SizedBox(height: 4.w),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: getTagWidget(tagNames, tags, kind),
                ),
                // Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                // Text.rich(
                //   TextSpan(
                //       children: List.generate(
                //           list[index]['tagNames']?.length ?? 0,
                //           (kIndex) => TextSpan(
                //               text: '${list[index]['tagNames']?[kIndex]} '))),
                //   maxLines: 1,
                //   style: TextStyle(
                //       overflow: TextOverflow.ellipsis,
                //       color: AppColor.c27f8d9,
                //       fontSize: 12.sp),
                // )
              ],
            ),
          ),
        ),
      );
    }, childCount: list.length),
  );
}

//每行3个item
Widget sliverGrid3(List<MediaListMediaList> list,
    {bool isShowDelete = false, childLogic, parentLogic}) {
  return SliverGrid(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 113 / 216),
    delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
      String verticalCover = list[index].verticalCover ?? "";
      String title = list[index].title ?? "未知";
      int kind = list[index].kind ?? 0;
      String id = list[index].id ?? "";
      List<String> tagNames = list[index].tagNames ?? [];
      List<String> tags = list[index].tags ?? [];
      int permission = list[index].permission ?? 0;
      int updateStatus = list[index].updateStatus ?? 0;
      int totalEpisode = list[index].totalEpisode ?? 0;
      return GestureDetector(
        onTap: () async {
          if (kind == 5) {
            await AppNavigator.to
                .jumpDetails(kind, id, index: index, portrayList: list);
          } else {
            await AppNavigator.to.jumpDetails(kind, id, index: index);
          }
          Timer(const Duration(milliseconds: 1000), () {
            childLogic.refreshPage();
          });
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CustomImage(
                    height: 166.w,
                    url: verticalCover,
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  getCoverIcon(permission),
                  Positioned(
                      right: 6,
                      bottom: 6,
                      child: SizedBox(
                        width: 78,
                        height: 20,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 2),
                              decoration: ShapeDecoration(
                                color: Colors.white.withOpacity(0.7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    (updateStatus == 2 || updateStatus == 0)
                                        ? '已完结·$totalEpisode话'
                                        : '更新中·$totalEpisode话',
                                    style: const TextStyle(
                                      color: Color(0xFF3D169C),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                  isShowDelete
                      ? Obx(() => Offstage(
                            offstage: parentLogic.state.isEdit.value,
                            child: GestureDetector(
                              onTap: () async {
                                bool isOk =
                                    await parentLogic.unCollect(kind, id);
                                list.removeAt(index);
                                if (isOk) {
                                  if (list.isEmpty) {
                                    parentLogic.state.isEdit.value = true;
                                  }
                                  childLogic.update(['list']);
                                  showToast(msg: "移除成功");
                                  return;
                                }
                                showToast(msg: "删除失败");
                              },
                              child: Container(
                                height: 162.w,
                                color: Colors.black.withOpacity(0.72),
                                alignment: Alignment.center,
                                child: SvgPicture.asset(R.delete, width: 30.w),
                              ),
                            ),
                          ))
                      : Container(),
                  getBottomGridentShadow(
                      116.w, list[index].updateStatus, list[index].updatedDesc,
                      isNeedPosition: false),
                ],
              ),
              SizedBox(height: 4.w),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w700)),
              ),
              SizedBox(height: 2.w),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: getTagWidget(tagNames, tags, kind),
              ),
              // Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
              // Text.rich(
              //   TextSpan(
              //       children: List.generate(
              //           list[index].tagNames?.length ?? 0,
              //           (kIndex) => TextSpan(
              //               text: '${list[index].tagNames?[kIndex] ?? ""} '))),
              //   maxLines: 1,
              //   style: TextStyle(
              //       overflow: TextOverflow.ellipsis,
              //       color: AppColor.c27f8d9,
              //       fontSize: 12.sp),
              // )
            ],
          ),
        ),
      );
    }, childCount: list.length),
  );
}

Widget sliverVideoTypeGrid2(List<VideoModel> list,
    {bool isShowDelete = false, logic, String? linkName}) {
  // final bookShelfState = Get.find<BookshelfLogic>().state;
  // final bookshelfLogic = Get.find<BookshelfLogic>();
  return SliverGrid(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5,
        mainAxisSpacing: 3,
        childAspectRatio: 171 / 144),
    delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
      // String horizontalCover = list[index].horizontalCover ?? "";
      // String title = list[index].title ?? "未知";
      // String id = list[index].id ?? "";
      // int kind = list[index].kind ?? 0;
      // int permission = list[index].permission ?? 0;
      final model = list[index];
      return Stack(children: [
        VideoCard.fromVideoModel(
          model,
          forceVerticalCover: false,
          // onTap: () => logic.navigateTo(model, index),
        ),
        // if (isShowDelete)
        //   Obx(() => Positioned.fill(
        //           child: Offstage(
        //         offstage: bookShelfState.isEdit.value,
        //         child: GestureDetector(
        //           onTap: () async {
        //             bool isOk = await bookshelfLogic.cancelCollectResponse(model.id ?? '', type: 'video');
        //             list.removeAt(index);
        //             if (isOk) {
        //               if (list.isEmpty) {
        //                 bookShelfState.isEdit.value = true;
        //               }
        //               logic.update(['list']);
        //               showToast(msg: "移除成功");
        //               return;
        //             }
        //             showToast(msg: "删除失败");
        //           },
        //           child: Container(
        //             height: 96.w,
        //             color: Colors.black.withOpacity(0.72),
        //             alignment: Alignment.center,
        //             child: SvgPicture.asset(R.delete, width: 30.w),
        //           ),
        //         ),
        //       ))),
      ]);
    }, childCount: list.length),
  );
}

//每行2个item
Widget sliverGrid2(List<MediaListMediaList> list,
    {bool isShowDelete = false, childLogic, parentLogic}) {
  return SliverGrid(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 10,
        childAspectRatio: 171 / 144),
    delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
      String horizontalCover = list[index].horizontalCover ?? "";
      String title = list[index].title ?? "未知";
      String id = list[index].id ?? "";
      int kind = list[index].kind ?? 0;
      List<String> tagNames = list[index].tagNames ?? [];
      List<String> tags = list[index].tags ?? [];
      int permission = list[index].permission ?? 0;
      return GestureDetector(
        onTap: () async {
          await AppNavigator.to.jumpDetails(kind, id, index: index);
          Timer(const Duration(milliseconds: 300), () {
            childLogic.refreshPage();
          });
        },
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomImage(
                      height: 96.w,
                      url: horizontalCover,
                      // borderRadius: BorderRadius.circular(6.w),
                    ),
                    getCoverIcon(permission),
                    isShowDelete
                        ? Obx(() => Offstage(
                              offstage: parentLogic.state.isEdit.value,
                              child: GestureDetector(
                                onTap: () async {
                                  bool isOk =
                                      await parentLogic.unCollect(kind, id);
                                  list.removeAt(index);
                                  if (isOk) {
                                    if (list.isEmpty) {
                                      parentLogic.state.isEdit.value = true;
                                    }
                                    childLogic.update(['list']);
                                    showToast(msg: "移除成功");
                                    return;
                                  }
                                  showToast(msg: "删除失败");
                                },
                                child: Container(
                                  height: 96.w,
                                  color: Colors.black.withOpacity(0.72),
                                  alignment: Alignment.center,
                                  child:
                                      SvgPicture.asset(R.delete, width: 30.w),
                                ),
                              ),
                            ))
                        : Container(),
                    getBottomGridentShadow(176.w, list[index].updateStatus,
                        list[index].updatedDesc),
                  ],
                ),
                SizedBox(height: 4.w),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w700)),
                ),
                SizedBox(height: 2.w),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: getTagWidget(tagNames, tags, kind),
                ),
                // Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                // Text.rich(
                //   TextSpan(
                //       children: List.generate(
                //           list[index].tagNames?.length ?? 0,
                //           (kIndex) => TextSpan(
                //               text: '${list[index].tagNames?[kIndex] ?? ""} '))),
                //   maxLines: 1,
                //   style: TextStyle(
                //       overflow: TextOverflow.ellipsis,
                //       color: AppColor.c27f8d9,
                //       fontSize: 12.sp),
                // )
              ],
            ),
          ),
        ),
      );
    }, childCount: list.length),
  );
}

Widget staggeredList(
  List<dynamic> list,
) {
  return StaggeredGrid.count(
    crossAxisCount: 2,
    crossAxisSpacing: 6,
    mainAxisSpacing: 6,
    children: list.asMap().entries.map((e) {
      String verticalCover = e.value['verticalCover'] ?? "";
      String horizontalCover = e.value['horizontalCover'] ?? "";
      String title = e.value['title'] ?? "未知";
      int kind = e.value['kind'] ?? 0;
      String id = e.value['mediaID'] ?? "";
      int episode = e.value['episode'] ?? 1;
      List<String> tagNames =
          e.value['tagNames'] != null ? e.value['tagNames'].cast<String>() : [];
      List<String> tags =
          e.value['tags'] != null ? e.value['tags'].cast<String>() : [];
      int permission = e.value['permission'] ?? 0;


      int totalEpisode = e.value['totalEpisode'] ?? 0;

      int updateStatus = e.value['updateStatus'] ?? 0;

      String imageUrl =
          verticalCover.isEmpty == true ? horizontalCover : verticalCover;

      return GestureDetector(
        onTap: () async {
          if (kind == 5) {
            List<MediaListMediaList> lists = [];

            for (int i = 0; i < list.length; i++) {
              lists.add(MediaListMediaList.fromJson(list[i]));
            }

            AppNavigator.to.jumpDetails(kind, id,
                selectedEpisode: episode, index: e.key, portrayList: lists);
          } else {
            AppNavigator.to.jumpDetails(
              kind,
              id,
              selectedEpisode: episode,
              index: e.key,
            );
          }
        },
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CachedNetworkImage(
                      cacheManager: ImgCacheMgr(),
                      imageUrl: getPath(imageUrl),
                      placeholder: (context, url) {
                        return Image(
                          image: () {
                            return const AssetImage(
                                "assets/images/png/place_holder_image.png");
                          }(),
                          width: 0.5.sw,
                          height: 180,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                    getCoverIcon(permission),
                    if (kind == 7)
                      Positioned(
                        bottom: 5,
                        left: 5,
                        child: SvgPicture.asset(
                          Assets.acgNovalVoiceIcon,
                          width: 15,
                          height: 15,
                        ),
                      ),
                    Positioned(
                        right: 6,
                        bottom: 6,
                        child: SizedBox(
                          width: 78,
                          height: 20,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 2),
                                decoration: ShapeDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      (updateStatus == 2 || updateStatus == 0)
                                          ? '已完结·$totalEpisode话'
                                          : '更新中·$totalEpisode话',
                                      style: const TextStyle(
                                        color: Color(0xFF3D169C),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
                SizedBox(height: 4.w),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(height: 4.w),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: getTagWidget(tagNames, tags, kind),
                ),
                SizedBox(height: 6.w),
              ],
            ),
          ),
        ),
      );
    }).toList(),
  );
}

Widget staggeredMediaList(List<MediaList> list, {String? showLightKey}) {
  return StaggeredGrid.count(
      crossAxisCount: 2,
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
      children: List.generate(list.length, (index) {
        var e = list[index];
        return GestureDetector(
          onTap: () async {
            AppNavigator.to
                .jumpDetails(e.kind, e.id ?? "", mediaList: list, index: index);
          },
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CachedNetworkImage(
                        cacheManager: ImgCacheMgr(),
                        imageUrl: getPath(e.isVerticalCover
                            ? e.verticalCover
                            : e.horizontalCover),
                        placeholder: (context, url) {
                          return Image(
                            image: () {
                              return const AssetImage(
                                  "assets/images/png/place_holder_image.png");
                            }(),
                            width: 0.5.sw,
                            height: 180,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                      getCoverIcon(e.permission),
                      Positioned(
                          right: 6,
                          bottom: 6,
                          child: SizedBox(
                            width: 78,
                            height: 20,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 2),
                                  decoration: ShapeDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        (e.updateStatus == 2 ||
                                                e.updateStatus == 0)
                                            ? '已完结·${e.totalEpisode}话'
                                            : '更新中·${e.totalEpisode}话',
                                        style: const TextStyle(
                                          color: Color(0xFF3D169C),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                  SizedBox(height: 4.w),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text(
                      e.title ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.w),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: getTagWidget(e.tagNames, e.tags, e.kind,
                        showLightKey: showLightKey),
                  ),
                  SizedBox(height: 6.w),
                ],
              ),
            ),
          ),
        );
      }));
}

Widget _hotRankWidget(int sortCode) {
  int rankIndex = sortCode;
  return rankIndex < 3
      ? Positioned(
          right: 2,
          top: -3,
          child: rankIndex == 0
              ? Image.asset(
                  Assets.acgRange01,
                  width: 24.w,
                  height: 30.w,
                )
              : rankIndex == 1
                  ? Image.asset(
                      Assets.acgRange02,
                      width: 24.w,
                      height: 30.w,
                    )
                  : rankIndex == 2
                      ? Image.asset(
                          Assets.acgRange03,
                          width: 24.w,
                          height: 30.w,
                        )
                      : Container(
                          alignment: Alignment.topRight,
                          width: 24.w,
                          height: 24.w,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(Assets.acgRankBottomBg)),
                          ),
                          child: Container(
                            width: 24.w,
                            height: 24.w,
                            alignment: Alignment.topRight,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(Assets.acgRankTopBg)),
                            ),
                            child: Text(
                              rankIndex < 9
                                  ? "0${rankIndex + 1}"
                                  : (rankIndex + 1).toString(),
                              style: TextStyle(
                                  color: const Color.fromRGBO(255, 255, 255, 1),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 8.w),
                            ),
                          ),
                        ),
        )
      : Positioned(
          right: -3,
          top: 0,
          child: Container(
            alignment: Alignment.topRight,
            width: 24.w,
            height: 24.w,
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage(Assets.acgRankBottomBg)),
            ),
            child: Stack(
              children: [
                Container(
                  width: 24.w,
                  height: 26.w,
                  padding: const EdgeInsets.only(right: 4, top: 2),
                  alignment: Alignment.topRight,
                  child: Text(
                    rankIndex < 9
                        ? "0${rankIndex + 1}"
                        : (rankIndex + 1).toString(),
                    style: TextStyle(
                        color: const Color.fromRGBO(255, 255, 255, 1),
                        fontWeight: FontWeight.w600,
                        fontSize: 10.sp,
                        fontStyle: FontStyle.italic),
                  ),
                ),
                Container(
                  width: 24.w,
                  height: 26.w,
                  decoration: const BoxDecoration(
                    image:
                        DecorationImage(image: AssetImage(Assets.acgRankTopBg)),
                  ),
                ),
              ],
            ),
          ));
}

Widget staggeredAllMediaList(List<AllMediaInfoModel> list,
    [bool isHotRank = false]) {
  return StaggeredGrid.count(
      crossAxisCount: 2,
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
      children: List.generate(list.length, (index) {
        var e = list[index];
        return GestureDetector(
          onTap: () async {
            AppNavigator.to
                .jumpDetails(e.kind, e.id ?? "", modelList: list, index: index);
          },
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CachedNetworkImage(
                        cacheManager: ImgCacheMgr(),
                        imageUrl: getPath(e.coverV),
                        placeholder: (context, url) {
                          return Image(
                            image: () {
                              return const AssetImage(
                                  "assets/images/png/place_holder_image.png");
                            }(),
                            width: 0.5.sw,
                            height: 180,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                      getCoverIcon(e.permission),
                      Positioned(
                          right: 6,
                          bottom: 6,
                          child: SizedBox(
                            width: 78,
                            height: 20,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 2),
                                  decoration: ShapeDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '已完结·${e.totalEpisode}话',
                                        style: const TextStyle(
                                          color: Color(0xFF3D169C),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                      if (isHotRank) _hotRankWidget(index)
                    ],
                  ),
                  SizedBox(height: 4.w),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text(
                      e.title ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.w),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: getTagWidget(
                        e.tagNames?.isNotEmpty == true
                            ? e.tagNames
                            : e.getTagsList(),
                        e.tags ?? e.tagDetails.map((e) => e.id ?? "").toList(),
                        e.kind),
                  ),
                  SizedBox(height: 6.w),
                ],
              ),
            ),
          ),
        );
      }));
}
