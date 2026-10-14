import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/utils/screen.dart';
//import 'package:comics_app/common/widgets/gesture_zoom_box.dart';
import 'package:comics_app/common/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gesture_zoom_box/gesture_zoom_box.dart';
import 'package:get/get.dart';

import '../../widgets/common_ui/common_ui.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'picture_preview_logic.dart';

class PicturePreviewPage extends StatelessWidget {
  PicturePreviewPage({Key? key}) : super(key: key);

  final logic = Get.find<PicturePreviewLogic>();
  final state = Get.find<PicturePreviewLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBackground,
      appBar: commonAppBar(state.title ?? '',
          titleColor: Colors.white,
          bgColor: Colors.black,
          leadingColor: Colors.white,
          isShowLine: false,
          actions: [
            Obx(() => Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.w),
                decoration: BoxDecoration(
                    color: AppColor.c191641.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6.w)),
                child:
                    Text('${state.curIndex.value + 1}/${state.urlList.length}',
                        style: const TextStyle(
                          color: Color(0xFFF5F5F5),
                          fontSize: 12,
                        ))))
          ]),
      body: Padding(
        padding: EdgeInsets.only(bottom: Screen.bottomSafeHeight),
        child: GetBuilder<PicturePreviewLogic>(builder: (logic) {
          return Swiper(
            physics: state.limit
                ? const NeverScrollableScrollPhysics()
                : const ClampingScrollPhysics(),
            controller: state.swiperController,
            duration: 300,
            autoplayDelay: 5000,
            onIndexChanged: (index) => logic.onIndexChanged(index),
            itemBuilder: (BuildContext context, int index) {
              String url = state.urlList[index] ?? "";
              return GestureZoomBox(
                maxScale: 5.0,
                doubleTapScale: 2.0,
                duration: const Duration(milliseconds: 200),
                child: state.isLocalImg
                    ? Image.file(File(url), fit: BoxFit.contain)
                    : CustomImage(
                        borderRadius: BorderRadius.circular(6.w),
                        fit: BoxFit.contain,
                        url: url,
                        loadingAndErrorWidget: const LoadingWidget(),
                      ),
                onPressed: () => Get.back(),
                /*limitCallback: (bool limit) {
                  state.limit = limit;
                  logic.update();
                },*/
              );
            },
            itemCount: state.urlList.length,
            // pagination: SwiperCustomPagination(
            //     builder: (BuildContext context, SwiperPluginConfig config) {
            //   return Stack(
            //     children: [
            //       Positioned(
            //           bottom: 20.w,
            //           right: 10.w,
            //           child: Container(
            //             padding: EdgeInsets.symmetric(
            //                 horizontal: 6.w, vertical: 2.w),
            //             decoration: BoxDecoration(
            //                 color: AppColor.c191641.withOpacity(0.3),
            //                 borderRadius: BorderRadius.circular(6.w)),
            //             child: Text(
            //                 '${config.activeIndex + 1}/${config.itemCount}'),
            //           ))
            //     ],
            //   );
            // }),
          );
        }),
      ),
    );
  }
}
