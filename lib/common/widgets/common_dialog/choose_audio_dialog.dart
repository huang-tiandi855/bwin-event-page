import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/entities/module_detail_model/content_model.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../res/r.dart';

import 'package:comics_app/common/utils/logger.dart';

Future openChooseAudioItemDialog(
    {required AllMediaInfoModel info,
    required int currentIndex,
    int? productType}) async {
  var res = await Get.bottomSheet(ChooseAudioItemWidget(
    productType: productType,
    isAudio: info.kind == 7,
    info: info,
    currentIndex: currentIndex,
  ));
  return res ?? false;
}

class ChooseAudioItemWidget extends StatelessWidget {
  final AllMediaInfoModel info;

  final bool isAudio;
  final int currentIndex;

  ///动漫17    //漫画18    //cos19    //真人21  //禁播22
  final int? productType; //产品类型
  ChooseAudioItemWidget(
      {Key? key,
      this.productType,
      this.isAudio = true,
      required this.info,
      required this.currentIndex})
      : super(key: key);
  StateSetter? sortTitleState;
  StateSetter? sortContentState;
  bool isUpSort = true;
  @override
  Widget build(BuildContext context) {
    int totalEpisode = info.totalEpisode ?? 0;
    int currentContents = info.contents.length;
    bool isFinished =
        totalEpisode > 0 ? currentContents == totalEpisode : false;
    return Container(
      padding: EdgeInsets.only(left: 0.w, right: 0.w, bottom: 0),
      decoration: ShapeDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)))),
      child: Container(
        width: 1.sw,
        height: 0.8.sh,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: const ShapeDecoration(
          color: Color(0xffF5F5F5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  isAudio ? '目录' : "选集",
                  style: const TextStyle(
                      color: AppColor.c333333,
                      fontSize: 16,
                      fontWeight: FontWeight.w900),
                ),
                StatefulBuilder(builder: (ctx, StateSetter setState) {
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
            ),
            10.verticalSpace,
            if (isAudio)
              Row(
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
                  Text(
                    '已完结${isFinished ? '' : currentContents.toString()}章',
                    style: const TextStyle(
                        color: AppColor.c555555,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            10.verticalSpace,
            Expanded(child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              sortContentState ??= setState;
              var contents = info.contents;
              contents = !isUpSort ? contents.reversed.toList() : contents;
              return isAudio
                  ? ListView.builder(
                      itemCount: currentContents,
                      itemBuilder: (context, index) {
                        var item = contents[index];
                        return itemWidget(item, index);
                      })
                  : info.contents.length > 30
                      ? splitItem()
                      : contentWidget(info.contents);
            }))
          ],
        ),
      ),
    );
  }

  Widget contentWidget(List<ContentModel> contents,
      {bool isSingle = true, int startIndex = 0}) {
    contents = !isUpSort ? contents.reversed.toList() : contents;
    return GridView.builder(
        itemCount: contents.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1.sw ~/ 60.0,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 50 / 67),
        itemBuilder: (context, index) {
          var item = contents[index];
          return itemWidget(item, index, startIndex);
        });
  }

  Widget itemWidget(ContentModel item, int index, [int startIndex = 0]) {
    int realIndex = index + startIndex;
    return GestureDetector(
      onTap: () {
        Get.back(result: realIndex);
      },
      child: isAudio
          ? _audioWidget(item, index)
          : _otherWidget(item, index, startIndex),
    );
  }

  Widget _otherWidget(ContentModel item, int index, [int startIndex = 0]) {
    bool hasRead = item.mediaStatus?.hasRead == true;
    var episodeNumber = item.episodeNumber ?? 0;
    int realIndex = index + startIndex;
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: !hasRead && realIndex != currentIndex
              ? const Color.fromRGBO(245, 245, 245, 1)
              : AppColor.whiteBackground,
          border: Border.all(
              width: 2,
              color: !hasRead && realIndex != currentIndex
                  ? Colors.black12
                  : Colors.white),
          borderRadius: BorderRadius.circular(8.w)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${episodeNumber > 9 ? episodeNumber : "0$episodeNumber"}',
              style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xffb09fd9),
                  fontWeight: FontWeight.w900)),
          4.verticalSpace,
          Align(
            alignment: Alignment.center,
            child: _getNovelIcon(
                item.listenPermission ?? 2, item.price?.toDouble() ?? 0),
          )
        ],
      ),
    );
  }

  Widget _audioWidget(ContentModel item, int index) {
    bool hasRead = item.mediaStatus?.hasRead == true;
    bool isAudio = info.kind == KindConst.AUDIOKIND;
    var statusTxt = index == currentIndex
        ? (isAudio ? "收听中" : "观看中")
        : hasRead
            ? (isAudio ? "已收听" : "已观看")
            : (isAudio ? "未收听" : "未观看");
    return Container(
      width: 1.sw,
      height: 40,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: hasRead || index == currentIndex
              ? const Color(0xffF5F5F5)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: const Color(0xffD8D8D8).withOpacity(0.5), width: 2),
          boxShadow: const [
            BoxShadow(
                color: Color(0xffD8D8D8), blurRadius: 4, offset: Offset(4, 4))
          ]),
      child: Row(
        children: [
          _getNovelIcon(
              item.listenPermission ?? 2, item.price?.toDouble() ?? 0),
          Text(
            item.name ?? "",
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

  _getNovelIcon(int index, double price) {
    if (index == 0) {
      return SvgPicture.asset(R.vip, width: 31.w);
    } else if (index == 1 || price > 0) {
      return SvgPicture.asset(R.gold, width: 31.w);
    } else {
      return SvgPicture.asset(R.free, width: 31.w);
    }
  }

  Widget splitItem() {
    var items = getItems();
    Widget topWidget =
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return SizedBox(
        width: 1.sw,
        child: TabBar(
          isScrollable: true,
          labelColor: const Color.fromRGBO(85, 85, 85, 1),
          labelStyle: TextStyle(
              fontSize: 12.sp, fontWeight: FontWeight.w900, height: 1.6),
          unselectedLabelColor: const Color.fromRGBO(153, 153, 153, 1),
          unselectedLabelStyle: TextStyle(
              fontSize: 12.sp, fontWeight: FontWeight.w900, height: 1.6),
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              width: 2.w,
              color: const Color.fromRGBO(229, 229, 232, 1),
            ),
          ),
          tabs: items.keys.map((e) {
            l.d("==dd===dd==$e");
            return Container(
              alignment: Alignment.center,
              height: 30.h,
              child: Text(
                e,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
      );
    });
    Widget splitContentWidget =
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return TabBarView(
          children: List.generate(items.values.length, (index) {
        var e = items.values.toList()[index];
        int startIndex = index * 30;
        return contentWidget(e, isSingle: false, startIndex: startIndex);
      }));
    });
    return DefaultTabController(
        length: items.length,
        child: Column(
          children: [
            topWidget,
            12.verticalSpace,
            Expanded(child: splitContentWidget)
          ],
        ));
  }

  Map<String, List<ContentModel>> getItems() {
    int totalLength = info.contents.length;
    int splitCount = totalLength ~/ 30 + 1;
    l.d("=== $splitCount");
    Map<String, List<ContentModel>> splitItems = {};
    for (int v = 0; v < splitCount; v++) {
      int index = v + 1;
      int last = index * 30;
      int start = v * 30;
      if (last > totalLength) {
        last = totalLength;
      }
      String key = "${start + 1}-$last";
      l.d("$key $start $last $splitCount");
      var val = info.contents.sublist(start, last);
      splitItems[key] = val;
    }
    return splitItems;
  }
}
