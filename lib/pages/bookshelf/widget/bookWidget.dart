import 'package:comics_app/common/entities/video_model/video_model.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/widgets/video_section/video_card.dart';
import 'package:comics_app/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../common/entities/MediaListInfo.dart';
import '../../../common/entities/media_list_entity.dart';
import '../../../common/res/r.dart';
import '../../../common/utils/utils.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import '../../../common/widgets/space_widget.dart';
import '../bookshelf_logic.dart';

Widget title() {
  return SliverToBoxAdapter(
    child: Padding(
      padding: EdgeInsets.only(top: 13.w, bottom: 12.w),
      child: Text(
        "猜你想看",
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

///获取权限图标
Widget getPermissionIcon(int index, int price) {
  return getMarkIcon(index, price);
}

//每行3个item
Widget sliverGrid3(List<MediaListMediaList> list, {bool isShowDelete = false, logic, String? linkName, int? kind}) {
  final bookShelfState = Get.find<BookshelfLogic>().state;
  final bookshelfLogic = Get.find<BookshelfLogic>();
  return SliverGrid(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 8.w, mainAxisSpacing: 8.w, childAspectRatio: 111 / 210),
    delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
      String verticalCover = list[index].verticalCover ?? "";
      String title = list[index].title ?? "未知";
      int kind_ = kind ?? list[index].kind ?? 0;
      String id = list[index].id ?? "";
      int permission = list[index].permission ?? 0;
      int updateStatus = list[index].updateStatus ?? 0;
      debugPrint(title);
      debugPrint('$permission');
      return GestureDetector(
        onTap: () {
          ConfigStore.to.trackData(
              '作品点击', ConfigStore.to.getClickProductInfoMap(MediaList.fromJson(list[index].toJson()), linkName!));

          AppNavigator.to.jumpDetails(
            list[index].kind ?? 0,
            id,
            index: index,
            portrayList: list,
          );
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
                      height: 162.w,
                      url: verticalCover,
                      // borderRadius: BorderRadius.circular(6.w),
                    ),
                    getCoverIcon(permission),
                    if (list[index].kind == 7)
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
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
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
                                          ? '已完结·${list[index].totalEpisode}话'
                                          : '更新中·${list[index].totalEpisode}话',
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
                              offstage: bookShelfState.isEdit.value,
                              child: GestureDetector(
                                onTap: () async {
                                  bool isOk = await bookshelfLogic.unCollect(kind_, id);
                                  list.removeAt(index);
                                  if (isOk) {
                                    if (list.isEmpty) {
                                      bookShelfState.isEdit.value = true;
                                    }
                                    logic.update(['list']);
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
                    getBottomGridentShadow(118.w, list[index].updateStatus, list[index].updatedDesc,
                        isNeedPosition: false),
                  ],
                ),
                SizedBox(height: 4.w),

                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.black),
                  ),
                ),
                SizedBox(height: 2.w),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: getTagWidget(list[index].tagNames, list[index].tags, kind),
                ),
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

Widget sliverVideoTypeGrid2(List<VideoModel> list, {bool isShowDelete = false, logic, String? linkName}) {
  final bookShelfState = Get.find<BookshelfLogic>().state;
  final bookshelfLogic = Get.find<BookshelfLogic>();
  return SliverGrid(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 5, mainAxisSpacing: 3, childAspectRatio: 171 / 144),
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
        if (isShowDelete)
          Obx(() => Positioned.fill(
                  child: Offstage(
                offstage: bookShelfState.isEdit.value,
                child: GestureDetector(
                  onTap: () async {
                    bool isOk = await bookshelfLogic.cancelCollectResponse(model.id ?? '', type: 'video');
                    list.removeAt(index);
                    if (isOk) {
                      if (list.isEmpty) {
                        bookShelfState.isEdit.value = true;
                      }
                      logic.update(['list']);
                      showToast(msg: "移除成功");
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
              ))),
      ]);
    }, childCount: list.length),
  );
}

//每行2个item
Widget sliverGrid2(List<MediaListMediaList> list, {bool isShowDelete = false, logic, String? linkName}) {
  final bookShelfState = Get.find<BookshelfLogic>().state;
  final bookshelfLogic = Get.find<BookshelfLogic>();
  return SliverGrid(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 5, mainAxisSpacing: 3, childAspectRatio: 171 / 144),
    delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
      String horizontalCover = list[index].horizontalCover ?? "";
      String title = list[index].title ?? "未知";
      String id = list[index].id ?? "";
      int kind = list[index].kind ?? 0;
      int permission = list[index].permission ?? 0;
      return GestureDetector(
        onTap: () {
          ConfigStore.to.trackData(
              '作品点击', ConfigStore.to.getClickProductInfoMap(MediaList.fromJson(list[index].toJson()), linkName!));

          AppNavigator.to.jumpDetails(kind, id, index: index);
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
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
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
                                      '已完结·${list[index].totalEpisode}话',
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
                              offstage: bookShelfState.isEdit.value,
                              child: GestureDetector(
                                onTap: () async {
                                  bool isOk = await bookshelfLogic.unCollect(kind, id);
                                  list.removeAt(index);
                                  if (isOk) {
                                    if (list.isEmpty) {
                                      bookShelfState.isEdit.value = true;
                                    }
                                    logic.update(['list']);
                                    showToast(msg: "移除成功");
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
                            ))
                        : Container(),
                    getBottomGridentShadow(176.w, list[index].updateStatus, list[index].updatedDesc),
                  ],
                ),
                SizedBox(height: 4.w),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.black),
                  ),
                ),
                SizedBox(height: 2.w),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: getTagWidget(list[index].tagNames, list[index].tags, kind),
                ),
              ],
            ),
          ),
        ),
      );
    }, childCount: list.length),
  );
}
