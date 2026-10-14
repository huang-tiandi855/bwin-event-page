import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/entities/module_detail_model/all_tag_model.dart';
import 'package:comics_app/common/entities/video_model/video_model.dart';
import 'package:comics_app/common/utils/cover_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'plan_video_tabview.dart';
import 'skits_card.dart';
import 'video_card.dart';
import 'video_grid_view.dart';

class VideoGridLayoutView extends StatelessWidget {
  const VideoGridLayoutView({
    super.key,
    required this.showType,
    this.medias = const [],
    this.videos = const [],
    this.tags = const [],
  });

  final int? showType;
  final List<AllTagModel> tags;
  final List<AllMediaInfoModel> medias;
  final List<VideoModel> videos;

  Widget itemBuilder(BuildContext context, int index) {
    final e = videos[index];
    return VideoCard.fromVideoModel(
      e,
      forceVerticalCover: CoverUtil.isVerticalCover(showType),
      shortVideoList: videos,
    );
  }

  @override
  Widget build(BuildContext context) {
    late Widget gridView;
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
    // 14:一大四小样式
    // 15：短剧顶部轮播样式
    // 16：短剧三竖屏滑动样式
    // 17：短剧六宫格竖屏样式
    switch (showType) {
      case 0:
      case 3:
      case 5:
      case 14:
        // 0: 兼容一大四小样式
        // 3: 六宫格横屏样式
        // 5：四宫格横屏样式
        // 14:一大四小样式
        gridView = VideoGridView(
          crossAxisCount: 2,
          crossAxisSpacing: 9.w,
          mainAxisSpacing: 10.w,
          firstAspectRatio: showType == 14 || showType == 0 ? 355 / 251 : null,
          itemBuilder: itemBuilder,
          itemCount: videos.length,
        );
        break;
      case 1:
        gridView = Container();
        break;
      case 2:
        // 2：六宫格竖屏样式
        gridView = VideoGridView(
          crossAxisCount: 3,
          mainAxisSpacing: 7.w,
          crossAxisSpacing: 8.w,
          aspectRatio: 113 / 216,
          itemBuilder: itemBuilder,
          itemCount: videos.length,
        );
        break;
      case 4:
      case 6:
        // 6: 四宫格竖屏列表样式(无限滚动)
        // 4: 四宫格竖屏样式
        gridView = VideoGridView(
          crossAxisCount: 2,
          mainAxisSpacing: 10.w,
          crossAxisSpacing: 9.w,
          aspectRatio: 173 / 304,
          itemBuilder: itemBuilder,
          itemCount: videos.length,
        );
        break;
      case 7:
        // 7: 企业影片样式
        gridView = PlanVideoTabView(
          itemTitleBuilder: (index) {
            final e = tags[index];
            return e.tagName ?? '';
          },
          itemBuilder: (context, index) {
            final e = tags[index].allVideoInfo.first;
            return VideoCard.fromVideoModel(e);
          },
          itemCount: tags.length,
        );

        break;
      case 8:
        // 8: 三横屏列表样式
        gridView = Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Column(
            children: List.generate(videos.length, (index) {
              final e = videos[index];
              return Container(
                height: 116.w,
                margin: EdgeInsets.only(top: index == 0 ? 0 : 10.w),
                child: VideoCard.fromVideoModel(
                  e,
                  axis: VideoCardLayoutAxis.horizontal,
                  shortVideoList: videos,
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
          child: VideoGridView(
            crossAxisCount: showType == 9 ? 1 : 2,
            mainAxisSpacing: 4.w,
            crossAxisSpacing: 16.w,
            aspectRatio: 293 / 165,
            allowScroll: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: itemBuilder,
            itemCount: videos.length,
          ),
        );
        break;
      case 11:
        // 11: 十二横屏划动样式
        gridView = SizedBox(
          width: double.infinity,
          height: 141.w * 2 + 16.w,
          child: VideoGridView(
            crossAxisCount: 2,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 9.w,
            allowScroll: true,
            scrollDirection: Axis.horizontal,
            aspectRatio: 141 / 161,
            itemBuilder: itemBuilder,
            itemCount: videos.length,
          ),
        );
        break;
      case 12:
        // 12: 片源推荐样式
        gridView = SizedBox(
          height: 141.w,
          child: VideoGridView(
            crossAxisCount: 1,
            mainAxisSpacing: 9.w,
            allowScroll: true,
            scrollDirection: Axis.horizontal,
            aspectRatio: 141 / 161,
            itemBuilder: itemBuilder,
            itemCount: videos.length,
          ),
        );
        break;
      case 13:
        // 13：情色电影样式
        gridView = SizedBox(
          width: double.infinity,
          height: 216.w,
          child: VideoGridView(
            crossAxisCount: 1,
            crossAxisSpacing: 0.w,
            mainAxisSpacing: 8.w,
            aspectRatio: 216 / 113,
            allowScroll: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: itemBuilder,
            itemCount: videos.length,
          ),
        );
        break;
      case 15:
        gridView = Container();
        break;
      case 16:
        // 16：短剧三竖屏滑动样式
        gridView = SizedBox(
          width: double.infinity,
          height: 202.w,
          child: VideoGridView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            crossAxisCount: 1,
            mainAxisSpacing: 5.w,
            aspectRatio: 202 / 111,
            allowScroll: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final e = medias[index];
              return SkitsCard.fromMediaModel(
                e,
                verticalCover: CoverUtil.isVerticalCover(showType),
                titleColor: Colors.white,
              );
            },
            itemCount: medias.length,
          ),
        );
        break;
      case 17:
        // 17：短剧六宫格竖屏样式
        gridView = VideoGridView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          crossAxisCount: 3,
          mainAxisSpacing: 5.w,
          crossAxisSpacing: 5.w,
          aspectRatio: 111 / 202,
          itemBuilder: (context, index) {
            final e = medias[index];
            return SkitsCard.fromMediaModel(
              e,
              verticalCover: CoverUtil.isVerticalCover(showType),
              titleColor: Colors.white,
            );
          },
          itemCount: medias.length,
        );
        break;
      default:
        return Container();
    }
    return gridView;
  }
}
