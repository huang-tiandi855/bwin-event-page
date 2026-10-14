import 'package:comics_app/common/entities/module_detail_model/all_section_model.dart';
import 'package:comics_app/common/entities/module_detail_model/media_info_model_extension.dart';
import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/common/widgets/video_section/video_grid_layout_view.dart';
import 'package:comics_app/common/widgets/video_section/video_section_layout_view.dart';
import 'package:comics_app/common/widgets/video_section/video_section_title_view.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'short_video_skits_tab_logic.dart';
import 'short_video_skits_tab_state.dart';
import 'views/short_video_skits_swiper.dart';

class ShortVideoSkitsTabView extends StatelessWidget {
  const ShortVideoSkitsTabView({
    super.key,
    required this.module,
    this.moduleSort,
  });

  final ModuleModel module;

  final int? moduleSort;

  String get id => module.id!.toString();

  String get tag => '${id}_$moduleSort';

  ShortVideoSkitsTabLogic get logic => Get.find(tag: tag);
  ShortVideoSkitsTabState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    Get.put(
      ShortVideoSkitsTabLogic(module: module, moduleSort: moduleSort),
      tag: tag,
    );
    return ExtendedNestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: GetBuilder<ShortVideoSkitsTabLogic>(
              tag: tag,
              id: 'banner',
              builder: (_) {
                return Column(
                  children: state.banner.map((e) {
                    return ShortVideoSkitsSwiper(
                      medias: e.allMediaInfo,
                      onTap: (p0) {
                        p0.navigateToSkits();
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ];
      },
      body: GetBuilder<ShortVideoSkitsTabLogic>(
        tag: tag,
        id: 'list',
        builder: (_) {
          return PullRefreshView(
            controller: state.pullRefreshController,
            onRefresh: logic.onRefresh,
            onLoading: logic.onLoad,
            retryOnTap: logic.onRefresh,
            child: CustomScrollView(
              slivers: state.moduleDetailModel?.allSection.map((e) {
                    return _buildItem(e);
                  }).toList() ??
                  [],
            ),
          );
        },
      ),
    );
  }

  Widget _buildItem(AllSectionModel section) {
    if (section.allMediaInfo.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(),
      );
    }

    final sectionTitleWidget = VideoSectionTitleWidget(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      title: section.sectionName ?? '',
      titleStyle: TextStyle(
        color: AppColor.white,
        fontSize: 16.sp,
        height: 22.4 / 16,
        fontWeight: FontWeight.w500,
      ),
      showMoreIcon: false,
      rightText: '查看更多',
      rightTextStyle: const TextStyle(color: AppColor.c999999),
      onMoreTap: () {
        logic.onMoreTap(section);
      },
    );

    EdgeInsets padding = EdgeInsets.only(
      top: 37.w,
    );

    return SliverPadding(
      padding: padding,
      sliver: VideoSectionLayoutView(
        showType: section.showType,
        sectionCover: section.sectionCover,
        title: sectionTitleWidget,
        isSliver: true,
        child: GetBuilder<ShortVideoSkitsTabLogic>(
          tag: tag,
          id: 'section_${tag}_${section.sectionId}',
          builder: (_) {
            return VideoGridLayoutView(
              tags: const [],
              videos: const [],
              medias: section.allMediaInfo,
              showType: section.showType,
            );
          },
        ),
      ),
    );
  }
}
