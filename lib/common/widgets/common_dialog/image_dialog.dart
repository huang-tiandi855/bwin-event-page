import 'dart:async';

import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/utils/utils.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/common/widgets/space_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:comics_app/pages/image/network/custom_image_network.dart';

import '../../../gen/assets.gen.dart';
import 'package:comics_app/common/utils/ads_manage/ads_info_list_extension.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';

Future openImageAnnouncementDialog({required AdsInfoList ads}) async {
  var res = await Get.dialog(
      AnnouncementImageWidget(
        ads: ads,
      ),
      barrierDismissible: true);
  return res ?? false;
}

class AnnouncementImageWidget extends StatefulWidget {
  final AdsInfoList ads;

  const AnnouncementImageWidget({Key? key, required this.ads})
      : super(key: key);

  @override
  State<AnnouncementImageWidget> createState() => _AnnouncementWidgetState();
}

class _AnnouncementWidgetState extends State<AnnouncementImageWidget> {
  // final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   scrollController.jumpTo(0.01);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          getPhotoMaskView(
            sigmaXY: 2.0,
            color: Colors.transparent,
          ),
          Center(
            child: Container(
              alignment: Alignment.center,
              // height: 532.w,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(9.w)),
              margin: EdgeInsets.symmetric(horizontal: 60.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => widget.ads.jumpAdvByType(AdsType.indexTip),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(6)),
                        child: CustomImage(
                          url: widget.ads.resourceUrl,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                  getHeight(12.w),
                  Container(
                    height: 50.w,
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: AssetsGen.images.home.imageClose
                          .image(width: 40.w, height: 40.w),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomScrollBar extends StatefulWidget {
  final Widget child;

  const CustomScrollBar({Key? key, required this.child}) : super(key: key);

  @override
  State<CustomScrollBar> createState() => _CustomScrollBarState();
}

class _CustomScrollBarState extends State<CustomScrollBar> {
  double _alignmentY = -1;
  double _maxScrollExtent = 0;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        alignment: Alignment.topRight,
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: widget.child,
            ),
          ),
          //滚动条
          _maxScrollExtent > 0
              ? Container(
                  width: 8.w,
                  decoration: BoxDecoration(
                      color: AppColor.c2f2d46,
                      borderRadius: BorderRadius.circular(6.w)),
                  alignment: Alignment(1, _alignmentY),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.w),
                      color: AppColor.c27f8d9,
                    ),
                    height: 40.w,
                    width: 8.w,
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final ScrollMetrics metrics = notification.metrics;
    setState(() {
      if (metrics.pixels < 0) {
        _alignmentY = -1;
      } else if (metrics.pixels > metrics.maxScrollExtent) {
        _alignmentY = 1;
      } else {
        _alignmentY = -1 + (metrics.pixels / metrics.maxScrollExtent) * 2;
      }
      _maxScrollExtent = metrics.maxScrollExtent;
    });
    return true;
  }
}
