import 'package:comics_app/common/utils/event_bus/event_bus_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../common/widgets/tab_widgets/custom_tab_bar.dart';
import '../../common/utils/widget_utils.dart';
import '../../common/values/config.dart';
import '../../generated/assets.dart';
import '../loading/loading_center_widget.dart';
import 'comics/comics_view.dart';
import 'girl/girl_view.dart';
import 'original_logic.dart';
import 'vip/vip_view.dart';

class OriginalPage extends StatelessWidget {
  const OriginalPage({
    super.key,
    required this.initialJumpEevent,
  });

  final DarkJumpModuleEvent? initialJumpEevent;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OriginalLogic>(
      init: OriginalLogic(initialJumpEevent: initialJumpEevent),
      builder: (controller) {
        if (controller.tabs.isEmpty) {
          return const SizedBox(
            height: 111,
            child: LoadingCenterWidget(),
          );
        }

        // if (Config.isNewYearTheme()) {
        //   return Stack(children: [
        //     newYearContainer(url: Assets.imagesNewYearFeedBg),
        //     buildScaffold(controller),
        //   ]);
        // }

        return buildScaffold(controller);
      },
    );
  }

  Scaffold buildScaffold(OriginalLogic controller) {
    return Scaffold(
      // backgroundColor: Config.isNewYearTheme()?Colors.white:Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        flexibleSpace: Config.isNewYearTheme()
            ? newYearContainer(
                url: Assets.imagesNewYearOriginBg, fit: BoxFit.fitWidth)
            : FlexibleSpaceBar(
                collapseMode: CollapseMode.pin, //视差效果
                background: Container(color: const Color(0xffA3B2D8)),
              ),
        title: Obx(
          () => Container(
            alignment: Alignment.topLeft,
            child: CustomTabBar(
              tabAlignment: TabAlignment.start,
              tabs: List.generate(
                  controller.tabs.length,
                  (index) => Container(
                        constraints:
                            BoxConstraints(maxWidth: 86.w, maxHeight: 35.w),
                        alignment: Alignment.center,
                        child: Tab(
                            icon: Image.asset(
                          index == controller.tabSelectIndex.value
                              ? controller.tabs[index].selectImage ?? ''
                              : controller.tabs[index].normalImage ?? '',
                          width: index == controller.tabSelectIndex.value
                              ? 86.w
                              : 55.w,
                          height: index == controller.tabSelectIndex.value
                              ? 35.w
                              : 20.w,
                          fit: BoxFit.fill,
                        )),
                      )),
              controller: controller.tabController,
              // isScrollable: true,
              labelColor: Colors.black,
              labelPadding: const EdgeInsets.symmetric(horizontal: 5),
              imagePath: null,
            ),
          ),
        ),
      ),
      body: TabBarView(controller: controller.tabController, children: [
        ComicsOriginPage(id: controller.tabs[0].bizId ?? ''),
        GirlPage(id: controller.tabs[1].bizId ?? ''),
        VipPage(id: controller.tabs[2].bizId ?? '')
      ]),
    );
  }

  // Widget _buildSections(
  //     List<Section> sections, {
  //       Function(Section section)? onTapSection,
  //     }) {
  //   return SingleChildScrollView(
  //     scrollDirection: Axis.horizontal,
  //     child: Container(
  //       margin: EdgeInsets.symmetric(horizontal: 16.w).copyWith(bottom: 18.h),
  //       padding: EdgeInsets.symmetric(
  //         horizontal: 10.w,
  //         vertical: 18.h,
  //       ),
  //       decoration: const BoxDecoration(
  //         border: Border(
  //           bottom: BorderSide(color: AppColor.ce6e6e6),
  //         ),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         children: sections.map((e) {
  //           return GestureDetector(
  //             onTap: () => onTapSection?.call(e),
  //             child: Container(
  //               margin: EdgeInsets.symmetric(horizontal: 15.w),
  //               child: Column(
  //                 children: [
  //                   CustomImage(
  //                     width: 78.w,
  //                     height: 66.h,
  //                     url: e.img,
  //                   ),
  //                   Text(
  //                     e.name ?? "",
  //                     style: TextStyle(
  //                       fontSize: 14.sp,
  //                       color: AppColor.primaryText,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         }).toList() ??
  //             [],
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _buildBannerItem(OriginalBannerVideoList item) {
  //   return GestureDetector(
  //     onTap: () {
  //       Get.toNamed(
  //         AppRoutes.VIDEO_PAGE,
  //         arguments: {
  //           "id": item.id,
  //           "isFreeZoneArgs": false,
  //         },
  //       );
  //     },
  //     child: Stack(
  //       alignment: AlignmentDirectional.center,
  //       children: [
  //         ClipRRect(
  //           borderRadius: BorderRadius.all(
  //             Radius.circular(8.r),
  //           ),
  //           child: CustomImage(
  //             url: item.verticalCover ?? "",
  //             fit: BoxFit.cover,
  //           ),
  //         ),
  //         Align(
  //           alignment: Alignment.center,
  //           child: Image.asset(
  //             "assets/images/png/play_icon.png",
  //             width: 40.w,
  //             height: 40.w,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // SizedBox _buildGridContent(
  //     double itemWidth,
  //     OriginalLogic controller,
  //     int sectionIndex,
  //     NormalSection normalSection,
  //     int mediaIndex,
  //     ) {
  //   final mediaItem = normalSection.media![mediaIndex];
  //   return SizedBox(
  //     width: itemWidth,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.stretch,
  //       children: [
  //         Stack(
  //           children: [
  //             GestureDetector(
  //               onTap: () => controller.onMediaTap(
  //                 sectionIndex,
  //                 normalSection,
  //                 mediaIndex,
  //               ),
  //               child: ClipRRect(
  //                 borderRadius: BorderRadius.all(
  //                   Radius.circular(8.r),
  //                 ),
  //                 child: Stack(
  //                   children: [
  //                     CustomImage(
  //                       url: (mediaItem.verticalCover?.isNotEmpty ?? false)
  //                           ? mediaItem.verticalCover
  //                           : mediaItem.horizontalCover,
  //                       fit: BoxFit.cover,
  //                       height: 162.h,
  //                     ),
  //                     getBottomGridentShadow(
  //                       111.w,
  //                       mediaItem.updateStatus,
  //                       mediaItem.updatedDesc,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             Positioned(
  //               top: 6.6.w,
  //               right: 6.6.w,
  //               child: getMarkIcon(
  //                 mediaItem.permission,
  //                 mediaItem.price,
  //               ),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 4.h),
  //         Text(
  //           mediaItem.title ?? "",
  //           maxLines: 1,
  //           overflow: TextOverflow.ellipsis,
  //           style: TextStyle(
  //             color: AppColor.primaryText,
  //             fontSize: 12.sp,
  //           ),
  //         ),
  //         SizedBox(height: 2.h),
  //         getTagWidget(
  //           mediaItem.tagNames,
  //           mediaItem.tags,
  //           mediaItem.kind,
  //           isVertical: true,
  //         )
  //       ],
  //     ),
  //   );
  // }
  //
  // Widget _buildHeader(NormalSection item) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.stretch,
  //     children: [
  //       GestureDetector(
  //         onTap: () {
  //           if (!item.name.toString().contains("推荐")) {
  //             Get.toNamed(AppRoutes.TOPIC_PAGE, arguments: {
  //               "title": item.name.toString(),
  //               "id": item.id.toString(),
  //               "zone": item.zone,
  //               "isJinGangZone": false,
  //             });
  //           }
  //         },
  //         child: Row(
  //           children: [
  //             Expanded(
  //               child: Text(
  //                 item.name ?? "",
  //                 style: TextStyle(
  //                   color: AppColor.primaryText,
  //                   fontSize: 18.sp,
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //             ),
  //             if (!(item.name?.contains('推荐') ?? false))
  //               Image.asset(
  //                 "assets/images/png/right_arrow.png",
  //                 width: 12.w,
  //               ),
  //           ],
  //         ),
  //       ),
  //       const SizedBox(height: 5),
  //       Text(
  //         item.desc ?? "",
  //         style: TextStyle(
  //           color: AppColor.c999999,
  //           fontSize: 12.sp,
  //         ),
  //       ),
  //       if(item.desc?.isNotEmpty ?? false )SizedBox(height: 10.w,)
  //     ],
  //   );
  // }
}
