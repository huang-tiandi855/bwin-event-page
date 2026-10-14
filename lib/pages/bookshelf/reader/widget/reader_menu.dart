import 'dart:async';

import 'package:comics_app/common/utils/screen.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/pages/bookshelf/reader/widget/reader_bg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../common/entities/readerChapterModel.dart';
import '../../../../common/res/r.dart';
import '../../../../common/widgets/common_ui/common_ui.dart';
import '../../../../common/widgets/common_dialog/custom_dialog.dart';
import '../reader_logic.dart';

class ReaderMenu extends StatefulWidget {
  final List<ReaderChapterModel> chapters;
  final int articleIndex;
  final BgType bgType;
  final Color menuBg;
  final Color menuColor;

  final VoidCallback onTap;
  final VoidCallback onPreviousArticle;
  final VoidCallback onNextArticle;
  final VoidCallback updateNightDay;
  final void Function(int index) onToggleChapter;

  const ReaderMenu(
      {Key? key,
      required this.onTap,
      required this.articleIndex,
      required this.onPreviousArticle,
      required this.onNextArticle,
      required this.onToggleChapter,
      required this.chapters,
      required this.updateNightDay,
      required this.bgType,
      required this.menuBg,
      required this.menuColor})
      : super(key: key);

  @override
  State<ReaderMenu> createState() => _ReaderMenuState();
}

class _ReaderMenuState extends State<ReaderMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  double progressValue = 0.0;
  bool isTipVisible = false;

  @override
  initState() {
    super.initState();
    progressValue = (widget.articleIndex) / (widget.chapters.length);
    animationController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(animationController);

    animation.addListener(() {
      setState(() {});
    });
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ReaderMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    progressValue = (widget.articleIndex) / (widget.chapters.length);
  }

  hide() {
    animationController.reverse();
    Timer(const Duration(milliseconds: 200), () {
      widget.onTap();
    });
    setState(() {
      isTipVisible = false;
    });
  }

  previousArticle() {
    if (widget.articleIndex == 1) {
      showToast(msg: "已经是第一章了");
      return;
    }
    widget.onPreviousArticle();
    setState(() {
      isTipVisible = true;
    });
  }

  nextArticle() {
    if (widget.articleIndex >= widget.chapters.length) {
      showToast(msg: "已经是最后一章了");
      return;
    }
    widget.onNextArticle();
    setState(() {
      isTipVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => hide(),
          child: Container(color: Colors.transparent),
        ),
        buildTopView(),
        buildBottomView()
      ],
    );
  }

  int currentArticleIndex() {
    return ((widget.chapters.length - 1) * progressValue).toInt();
  }

  Widget buildProgressTipView() {
    if (!isTipVisible) {
      return Container();
    }
    ReaderChapterModel readerChapterModel =
        widget.chapters[currentArticleIndex()];
    String title = readerChapterModel.name;
    double percentage = widget.articleIndex / (widget.chapters.length) * 100;
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xff404448),
          borderRadius: BorderRadius.circular(5.w)),
      margin: EdgeInsets.fromLTRB(15.w, 0, 15.w, 10.w),
      padding: EdgeInsets.symmetric(vertical: 15.w, horizontal: 30.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
              width: 220.w,
              child: Text(
                title,
                style: TextStyle(
                    color: const Color(0xffd6d7d8),
                    fontSize: 16.sp,
                    overflow: TextOverflow.ellipsis),
                maxLines: 1,
              )),
          Text('${percentage.toStringAsFixed(1)}%',
              style: TextStyle(color: Colors.white, fontSize: 16.sp)),
        ],
      ),
    );
  }

  Widget buildBottomMenus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        GestureDetector(
          onTap: () => widget.updateNightDay(),
          child: buildBottomItem(widget.bgType == BgType.greenBg ? '夜间' : "日间",
              widget.bgType == BgType.yellowBg ? R.nighttime : R.daytime),
        ),
        SizedBox(width: 25.w)
      ],
    );
  }

  Widget buildBottomItem(String title, String icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 7.w),
      child: Column(
        children: [
          SvgPicture.asset(icon,
              fit: BoxFit.cover, width: 22.w, color: widget.menuColor),
          SizedBox(height: 5.w),
          Text(title,
              style: TextStyle(fontSize: 14.sp, color: widget.menuColor)),
        ],
      ),
    );
  }

  Widget buildProgressView() {
    return Container(
      padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: previousArticle,
            child: Text("上一章",
                style: TextStyle(color: widget.menuColor, fontSize: 16.sp)),
          ),
          Expanded(
              child: Slider(
            value: progressValue,
            onChanged: (double value) {
              setState(() {
                isTipVisible = true;
                progressValue = value;
              });
            },
            onChangeEnd: (double value) {
              widget.onToggleChapter(currentArticleIndex());
            },
            activeColor: const Color(0xFF23B38E),
            inactiveColor: const Color(0xFF888888),
          )),
          GestureDetector(
            onTap: nextArticle,
            child: Text("下一章",
                style: TextStyle(color: widget.menuColor, fontSize: 16.sp)),
          )
        ],
      ),
    );
  }

  Widget buildBottomView() {
    return Positioned(
      bottom: -(Screen.bottomSafeHeight + 110) * (1 - animation.value),
      left: 0,
      right: 0,
      child: Column(
        children: [
          buildProgressTipView(),
          Container(
            decoration: BoxDecoration(color: widget.menuBg, boxShadow: [
              BoxShadow(color: const Color(0x22000000), blurRadius: 8.w)
            ]),
            child: Column(
              children: [
                SizedBox(height: 10.w),
                // buildProgressView(),
                buildBottomMenus(),
                SizedBox(height: Screen.bottomSafeHeight),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildTopView() {
    ReaderChapterModel readerChapterModel =
        widget.chapters[currentArticleIndex()];
    String title = readerChapterModel.name;
    final readerState = Get.find<ReaderLogic>().state;
    bool hasCollected = readerState.mediaInfoEntity.hasCollected;
    return Positioned(
        top: -Screen.navigationBarHeight * (1 - animation.value),
        left: 0,
        right: 0,
        child: Container(
          decoration: BoxDecoration(color: widget.menuBg, boxShadow: [
            BoxShadow(color: const Color(0x22000000), blurRadius: 8.w)
          ]),
          height: Screen.navigationBarHeight,
          padding: EdgeInsets.fromLTRB(0, Screen.topSafeHeight, 5, 0),
          child: Row(
            children: [
              SizedBox(
                width: 44.w,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: commonBack(color: widget.menuColor),
                ),
              ),
              Expanded(
                  child: SizedBox(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 18.sp,
                        color: widget.menuColor,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w500),
                    maxLines: 1),
              )),
              InkWell(
                onTap: () => customDialog('是否${hasCollected ? '取消' : ""}收藏该作品',
                    onTap: () {
                  final readerLogic = Get.find<ReaderLogic>();
                  readerLogic.cartoonCollcet();
                  Get.back();
                }),
                child: SvgPicture.asset(
                    hasCollected ? R.readerCollected : R.readerCollect,
                    color: !hasCollected ? widget.menuColor : null,
                    width: 22.w),
              ),
              SizedBox(width: 16.w),
              // GetPlatform.isAndroid
              //     ? InkWell(
              //         onTap: () {
              //           Get.back();
              //         },
              //         child: SvgPicture.asset(R.particular,
              //             color: widget.menuColor, width: 24.w))
              //     : Container(),
              // SizedBox(width: 16.w),
              InkWell(
                onTap: () {
                  final readerLogic = Get.find<ReaderLogic>();
                  readerLogic.openDrawer();
                },
                child: SvgPicture.asset(R.contents,
                    color: widget.menuColor, width: 20.w),
              ),
              SizedBox(width: 16.w),
            ],
          ),
        ));
  }
}
