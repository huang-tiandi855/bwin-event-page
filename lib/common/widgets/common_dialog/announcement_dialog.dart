import 'dart:async';

import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../entities/modules_config/notice_model.dart';
import '../../routers/app_navigator.dart';
import '../general_widget/common_widget.dart';

Future openAnnouncementDialog({required NoticeModel notice}) async {
  var res = await Get.dialog(AnnouncementWidget(notice: notice));
  return res ?? false;
}

class AnnouncementWidget extends StatefulWidget {
  final NoticeModel notice;

  const AnnouncementWidget({Key? key, required this.notice}) : super(key: key);

  @override
  State<AnnouncementWidget> createState() => _AnnouncementWidgetState();
}

class _AnnouncementWidgetState extends State<AnnouncementWidget> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(0.01);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = ScreenUtil().screenWidth;
    final height = width / 375 * 472;
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          alignment: Alignment.center,
          children: [
            getPhotoMaskView(
              sigmaXY: 2.0,
              color: Colors.transparent,
            ),
            Center(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AssetsGen.images.home.announcementBg.image(
                      width: width,
                      height: height,
                    ),
                    Positioned(
                        top: 177.w,
                        left: 74.w,
                        right: 74.w,
                        bottom: (52 + 34 + 5).w,
                        child: ScrollbarTheme(
                          data: ScrollbarThemeData(
                              thumbColor: MaterialStateProperty.all(
                                  Colors.white.withOpacity(.5))),
                          child: Scrollbar(
                            thumbVisibility: true,
                            controller: scrollController,
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              controller: scrollController,
                              child: GestureDetector(
                                onTap: () =>
                                    AppNavigator.to.go(widget.notice.url ?? ''),
                                child: Text(
                                  widget.notice.content ?? '',
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      height: 1.4,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(.9)),
                                ),
                              ),
                            ),
                          ),
                        )),
                    Positioned(
                        bottom: 52.w,
                        child: InkWell(
                          onTap: () => Get.back(),
                          child: AssetsGen.images.home.announcementButton
                              .image(width: 148.w, height: 34.w),
                        ))
                  ],
                ),
                GestureDetector(
                  onTap: Get.back,
                  behavior: HitTestBehavior.opaque,
                  child: AssetsGen.images.upgrade.icDialogClose
                      .image(width: 36.w, height: 36.w),
                )
              ],
            )),
          ],
        ));
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
                      color: AppColor.whiteBackground,
                      borderRadius: BorderRadius.circular(6.w)),
                  alignment: Alignment(1, _alignmentY),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.w),
                      color: AppColor.bluishPurple.withOpacity(0.2),
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
