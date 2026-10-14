import 'package:comics_app/common/utils/utils.dart';
import 'package:comics_app/common/widgets/acg_section/swip_one_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../entities/module_detail_model/all_media_info_model.dart';
import '../with_bg_banner.dart';
import 'acg_loop_scroll_widget.dart';
import 'acg_media_card.dart';
import 'acg_media_grid_view.dart';

class MediaGridLayoutView extends StatelessWidget {
  const MediaGridLayoutView(
      {super.key,
      required this.showType,
      required this.medias,
      this.isOriginModule,
      this.padding,
      this.hotRank,
      this.isLastItem,
      this.onItemTap});

  /// 是否是原创模块
  final bool? isOriginModule;

  /// 是否是最后一个item 是：需求全部展示，否 则固定展示
  final bool? isLastItem;
  final int? showType;
  final List<AllMediaInfoModel> medias;
  final EdgeInsets? padding;
  final bool? hotRank;
  final ValueChanged? onItemTap;

  Widget itemBuilder(BuildContext context, int index) {
    if (medias.isNotEmpty == true) {
      final forceVerticalCover = showType == 21 ||
          showType == 20 ||
          showType == 22 ||
          showType == 23 ||
          showType == 26 ||
          showType == 27 ||
          showType == 28 ||
          showType == 2 ||
          showType == 4 ||
          showType == 6 ||
          showType == 9 ||
          showType == 10 ||
          showType == 13;
      final e = medias[index];
      if (showType == 27 || showType == 26) {
        return MediaCard.fromVideoModelRank(
          e,
          forceVerticalCover: forceVerticalCover,
          index: index,
          isShowSorCode: showType != 26,
          mediaList: medias,
          onTap: onItemTap != null
              ? () {
                  onItemTap!(index);
                }
              : null,
        );
      }
      if (hotRank == true) {
        return MediaCard.fromVideoModelHotRank(
          e,
          forceVerticalCover: forceVerticalCover,
          index: index,
          mediaList: medias,
          onTap: onItemTap != null
              ? () {
                  onItemTap!(index);
                }
              : null,
        );
      }
      return MediaCard.fromVideoModel(
        e,
        forceVerticalCover: forceVerticalCover,
        mediaList: medias,
        index: index,
        onTap: onItemTap != null
            ? () {
                onItemTap!(index);
              }
            : null,
      );
    }
    return Container();
  }

  // 1：顶部轮播样式
// 2：六宫格竖屏样式
// 3: 六宫格横屏样式
// 4: 四宫格竖屏样式
// 5：四宫格横屏样式
// 6: 四宫格竖屏列表样式
// 7: 企业影片样式
// 8: 三横屏列表样式
// 9: 八竖屏划动样式
// 10: 十六竖屏划动样式
// 11: 十二横屏划动样式
// 12: 片源推荐样式
// 13：情色电影样式
// 14: 一大四小样式
// 15：短剧顶部轮播样式
// 16：短剧三竖屏滑动样式
// 17：短剧六宫格竖屏样式
// 18：ACG模块-居左顶部轮播样式
// 19：ACG模块-居中顶部轮播样式
// 20：ACG模块-六宫格竖屏样式
// 21：ACG模块-四宫格竖屏样式
// 22：ACG模块-九宫格竖屏样式
// 23：ACG模块-二竖屏左右滑动样式
// 24：ACG模块-二横屏左右滑动样式
// 25: ACG模块-一大四小样式
// 26：ACG模块-四宫格竖屏滑动样式
// 27：ACG模块-排行榜样式
// 28：ACG模块-随便看看样式
  @override
  Widget build(BuildContext context) {
    late Widget gridView;
    int itemCount = medias.length;
    switch (showType) {
      // case -1:
      //   gridView = MediaGridView.staggeredGridView(
      //     padding: padding ?? padding ?? const EdgeInsets.all(0),
      //     crossAxisCount: 2,
      //     crossAxisSpacing: 9.w,
      //     mainAxisSpacing: 10.w,
      //     itemBuilder: itemBuilder,
      //     itemCount: 5,
      //   );
      //   break;
      case 0:
      case 25:
      case 14:
        // 0: 兼容一大四小样式

        // 14:一大四小样式
        gridView = MediaGridView(
          padding: padding ?? padding ?? const EdgeInsets.all(0),
          crossAxisCount: 2,
          crossAxisSpacing: 9.w,
          mainAxisSpacing: 10.w,
          firstAspectRatio: 355 / 251,
          itemBuilder: itemBuilder,
          itemCount: 5,
        );
        break;
      case 3:
        gridView = MediaGridView(
          padding: padding ?? padding ?? const EdgeInsets.all(0),
          crossAxisCount: 3,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.w,
          itemBuilder: itemBuilder,
          aspectRatio: 113 / 216,
          itemCount: itemCount,
        );
        break;
      case 5:
        gridView = MediaGridView(
          padding: padding ?? padding ?? const EdgeInsets.all(0),
          crossAxisCount: 2,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.w,
          itemBuilder: itemBuilder,
          aspectRatio: 173 / 148,
          itemCount: itemCount,
        );
        break;
      case 20:
        itemCount = itemCount > 6 ? 6 : itemCount;
        // 2：六宫格竖屏样式
        gridView = MediaGridView(
          padding: padding ?? const EdgeInsets.all(0),
          crossAxisCount: 3,
          mainAxisSpacing: 7.w,
          crossAxisSpacing: 8.w,
          aspectRatio: 113 / 216,
          itemBuilder: itemBuilder,
          itemCount: itemCount,
        );
        break;
      case 22:
        itemCount = itemCount > 9 ? 9 : itemCount;
        // 22：宫格竖屏样式
        gridView = MediaGridView(
          padding: padding ?? const EdgeInsets.all(0),
          crossAxisCount: 3,
          mainAxisSpacing: 7.w,
          crossAxisSpacing: 8.w,
          aspectRatio: 113 / 216,
          itemBuilder: itemBuilder,
          itemCount: itemCount,
        );
        break;
      case 28:
      case 2:
        // 2：六宫格竖屏样式
        gridView = MediaGridView(
          padding: padding ?? EdgeInsets.symmetric(horizontal: isOriginModule ?? false ? 10.w : 0),
          crossAxisCount: 3,
          mainAxisSpacing: 7.w,
          crossAxisSpacing: 8.w,
          aspectRatio: 113 / 216,
          itemBuilder: itemBuilder,
          itemCount: itemCount,
        );
        break;
      case 21:
      case 4:
      case 6:
        // 6: 四宫格竖屏列表样式
        // 4: 四宫格竖屏样式

        gridView = MediaGridView(
          padding: padding ?? EdgeInsets.symmetric(horizontal: isOriginModule ?? false ? 10.w : 0),
          crossAxisCount: 2,
          mainAxisSpacing: 10.w,
          crossAxisSpacing: 9.w,
          aspectRatio: 173 / 304,
          itemBuilder: itemBuilder,
          itemCount: ((isLastItem ?? false) && (isOriginModule ?? false)) ? 4 : itemCount,
        );
        break;
      case 7:
        // 7: 企业影片样式
        gridView = PlanView(
          itemTitleBuilder: (index) {
            final e = medias[index];
            return e.title ?? '';
          },
          itemBuilder: itemBuilder,
          itemCount: itemCount,
        );
        break;
      case 8:
        // 8: 三横屏列表样式
        gridView = Container(
          padding: EdgeInsets.symmetric(horizontal: 0.w),
          child: Column(
            children: List.generate(itemCount, (index) {
              final e = medias[index];
              return Container(
                height: 116.w,
                margin: EdgeInsets.only(top: index == 0 ? 0 : 10.w),
                child: MediaCard.fromVideoModel(
                  e,
                  axis: ACGItemCardWidget.horizontal,
                  index: index,
                ),
              );
            }).toList(),
          ),
        );
        break;
      case 9:
      case 10:
        // 9: 八竖屏划动样式
        // 10: 十六竖屏划动样式
        gridView = SizedBox(
          width: double.infinity,
          height: showType == 9 ? 293.w : 293.w * 2 + 16.w,
          child: MediaGridView(
            padding: padding ?? const EdgeInsets.all(0),
            crossAxisCount: showType == 9 ? 1 : 2,
            mainAxisSpacing: 4.w,
            crossAxisSpacing: 16.w,
            aspectRatio: 293 / 165,
            allowScroll: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: itemBuilder,
            itemCount: itemCount,
          ),
        );
        break;
      case 11:
        // 11: 十二横屏划动样式
        gridView = SizedBox(
          width: double.infinity,
          height: 141.w * 2 + 16.w,
          child: MediaGridView(
            padding: padding ?? const EdgeInsets.all(0),
            crossAxisCount: 2,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 9.w,
            allowScroll: true,
            scrollDirection: Axis.horizontal,
            aspectRatio: 141 / 161,
            itemBuilder: itemBuilder,
            itemCount: itemCount,
          ),
        );
        break;
      case 24:
      case 12:
        // 12: 片源推荐样式
        gridView = SizedBox(
          height: 141.w,
          child: MediaGridView(
            padding: padding ?? const EdgeInsets.all(0),
            crossAxisCount: 1,
            mainAxisSpacing: 9.w,
            allowScroll: true,
            scrollDirection: Axis.horizontal,
            aspectRatio: 141 / 161,
            itemBuilder: itemBuilder,
            itemCount: itemCount,
          ),
        );
        break;
      case 13:
        // 13：情色电影样式
        gridView = SizedBox(
          width: double.infinity,
          height: 216.w,
          child: MediaGridView(
            padding: padding ?? const EdgeInsets.all(0),
            crossAxisCount: 1,
            crossAxisSpacing: 0.w,
            mainAxisSpacing: 8.w,
            aspectRatio: 216 / 113,
            allowScroll: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: itemBuilder,
            itemCount: itemCount,
          ),
        );
        break;
      case 19:
        gridView = SwiperPage(
          bannerList: medias,
          onTap: (int index) {
            var item = medias[index];
            AppNavigator.to.jumpDetails(item.kind ?? 0, item.id ?? "");
          },
        );
        break;
      case 18:
      case 1:
        gridView = WithBgBanner(
          bannerList: medias,
          onTap: (int index) {
            var item = medias[index];
            AppNavigator.to.jumpDetails(item.kind ?? 0, item.id ?? "");
          },
        );
        break;
      case 23:
        gridView = SizedBox(
          width: double.infinity,
          height: 293.w + 16.w,
          child: MediaGridView(
            padding: padding ?? const EdgeInsets.all(0),
            crossAxisCount: 1,
            mainAxisSpacing: 4.w,
            crossAxisSpacing: 16.w,
            aspectRatio: 293 / 165,
            allowScroll: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: itemBuilder,
            itemCount: itemCount,
          ),
        );
        break;

      case 26:
      case 27:
        gridView = SizedBox(
            width: double.infinity,
            height: 99.w * 2 + 16.w,
            child: MediaGridView(
              padding: padding ?? const EdgeInsets.all(0),
              crossAxisCount: 2,
              mainAxisSpacing: 4.w,
              crossAxisSpacing: 16.w,
              aspectRatio: 99 / 234,
              allowScroll: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: itemBuilder,
              itemCount: itemCount,
            ));
        break;
      default:
        gridView = MediaGridView(
          padding: padding ?? const EdgeInsets.all(0),
          crossAxisCount: 3,
          mainAxisSpacing: 7.w,
          crossAxisSpacing: 8.w,
          aspectRatio: 113 / 216,
          itemBuilder: itemBuilder,
          itemCount: itemCount,
        );
        break;
    }
    return gridView;
  }
}
