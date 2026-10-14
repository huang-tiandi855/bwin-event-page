import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/widgets/space_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../common/entities/module_detail_model/content_model.dart';
import '../../../../common/widgets/common_ui/common_ui.dart';
import '../../../../generated/assets.dart';
import '../../../home/categories/categories_view.dart';
import '../comic_reading_logic.dart';

import 'package:comics_app/common/utils/logger.dart';

Future openComicMenu(
    {AllMediaInfoModel? mediaInfoEntity,
    List<int> hasRead = const [],
    required int chaptersNumber,
    required void Function() hideMenu,
    required void Function(UpdateType type, {int index}) updateIndex,
    required void Function() setDirectoryReverseOrder}) async {
  var res = await Get.dialog(
      ComicDicWidget(
          hasRead: hasRead,
          mediaInfoEntity: mediaInfoEntity,
          chaptersNumber: chaptersNumber,
          hideMenu: hideMenu,
          updateIndex: updateIndex,
          setDirectoryReverseOrder: setDirectoryReverseOrder),
      barrierDismissible: true);
  return res ?? false;
}

class ComicDicWidget extends StatelessWidget {
  StateSetter? sortTitleState;
  StateSetter? sortContentState;
  bool isUpSort = true;
  AllMediaInfoModel? mediaInfoEntity;
  List<int> hasRead = [];
  final int chaptersNumber;
  final Function() hideMenu;
  final Function(UpdateType type, {int index}) updateIndex;
  final Function() setDirectoryReverseOrder;
  ComicDicWidget(
      {this.mediaInfoEntity,
      super.key,
      this.hasRead = const [],
      required this.chaptersNumber,
      required this.hideMenu,
      required this.updateIndex,
      required this.setDirectoryReverseOrder});
  Widget comicDrawer() {
    List list = mediaInfoEntity?.contents ?? [];
    String title = mediaInfoEntity?.title ?? "未知";
    int totalEpisode = mediaInfoEntity?.totalEpisode ?? 0;
    return SizedBox(
        height: 1.sw,
        child: Scaffold(
            appBar: commonAppBar(title),
            backgroundColor: Colors.transparent,
            body: Container(
                width: 1.sw,
                height: 0.5.sh,
                decoration: ShapeDecoration(
                  shape: CustomBottomShapeBorder(
                    protrusionHeight: 18.w,
                    protrusionWidth: 80.w,
                    protrusionRadius: 8.r,
                    borderRadius: 10.r,
                  ),
                  color: AppColor.white,
                ),
                child: Column(
                  children: [
                    Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              '目录',
                              style: TextStyle(
                                  color: AppColor.c333333,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900),
                            ),
                            StatefulBuilder(
                                builder: (ctx, StateSetter setState) {
                              sortTitleState = setState;
                              return GestureDetector(
                                onTap: () {
                                  isUpSort = !isUpSort;
                                  sortTitleState?.call(() {});
                                  sortContentState?.call(() {});
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  alignment: Alignment.center,
                                  child: Text(
                                    isUpSort ? "倒序" : '升序',
                                    style: const TextStyle(
                                        color: AppColor.c777777,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              );
                            }),
                          ],
                        )),
                    Container(
                        padding: const EdgeInsets.only(
                            left: 12, right: 12, bottom: 12),
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '共$totalEpisode章',
                              style: const TextStyle(
                                  color: AppColor.c555555,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        )),
                    Expanded(
                        child: Container(
                      color: Colors.white,
                      height: 0.4.sh,
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: StatefulBuilder(builder: (context, setterState) {
                        sortContentState = setterState;
                        return ListView.builder(
                          reverse: !isUpSort,
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            index = index;
                            var item = list[index];
                            return InkWell(
                              onTap: () {
                                Get.back();
                                updateIndex(UpdateType.customize, index: index);
                              },
                              child: _audioWidget(item, index),
                            );
                          },
                          itemCount: list.length,
                        );
                      }),
                    )),
                    30.verticalSpace,
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        width: 80.sw,
                        height: 18.w,
                        alignment: Alignment.topCenter,
                        child: SvgPicture.asset(
                          Assets.svgIcExpand,
                          height: 10.w,
                        ),
                      ),
                    ),
                  ],
                ))));
  }

  Widget _audioWidget(ContentModel item, int index) {
    bool hasRead =
        item.mediaStatus?.hasRead == true || this.hasRead.contains(index);
    var statusTxt = chaptersNumber == index
        ? "观看中"
        : hasRead
            ? "已观看"
            : "未观看";
    l.d("====${this.hasRead.toString()}");
    return Container(
      width: 1.sw,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: chaptersNumber == index || hasRead
              ? const Color(0xffF5F5F5)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: chaptersNumber == index || hasRead
                  ? Colors.white
                  : const Color(0xffD8D8D8).withOpacity(0.5),
              width: 2),
          boxShadow: const [
            BoxShadow(
                color: Color(0xffD8D8D8), blurRadius: 2, offset: Offset(0, 0))
          ]),
      child: Row(
        children: [
          getMarkIcon(item.listenPermission ?? 2),
          8.horizontalSpace,
          Text(
            "${item.episodeNumber}-${item.name}",
            style: const TextStyle(
                color: Color(0xffB09FD9),
                fontSize: 14,
                fontWeight: FontWeight.w900),
          ),
          const Spacer(),
          Text(
            statusTxt,
            style: const TextStyle(
                color: Color(0xffB09FD9),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return comicDrawer();
  }
}
