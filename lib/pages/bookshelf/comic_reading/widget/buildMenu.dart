import 'dart:async';
import 'package:comics_app/common/entities/module_detail_model/content_model.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/screen.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../../common/res/r.dart';
import '../../../../generated/assets.dart';
import '../comic_reading_logic.dart';

class ComicBuildMenu extends StatefulWidget {
  final VoidCallback onTap;
  final ContentModel? mediaInfoContents;
  final bool hasCollected;
  final String? title;

  const ComicBuildMenu(
      {Key? key,
      required this.onTap,
      required this.mediaInfoContents,
      required this.hasCollected,
      this.title})
      : super(key: key);

  @override
  State<ComicBuildMenu> createState() => _ComicBuildMenuState();
}

class _ComicBuildMenuState extends State<ComicBuildMenu> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  initState() {
    animationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(animationController);

    animation.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  hide() {
    final logic = Get.find<ComicReadingLogic>();
    final state = logic.state;
    if(logic.isAutoPlay) {
      if (state.isAutoPlayShow) {
        state.isAutoPlayShow = false;
        logic.update([ "menu"]);
        Timer(const Duration(milliseconds: 200), () {
          widget.onTap();
        });
      } else {
        state.isAutoPlayShow = true;
        logic.isOpenSpeed = false;
        animationController.reverse();
      }
    }else{
      animationController.reverse();
      Timer(const Duration(milliseconds: 200), () {
        widget.onTap();
      });
    }
  }

  showMenuItem(){
    final logic = Get.find<ComicReadingLogic>();
    final state = logic.state;
    logic.stop();
    animationController.forward();
    state.isAutoPlayShow = false;
    logic.update([ "menu"]);
  }

  isShowAutoAnim(){
    final logic = Get.find<ComicReadingLogic>();
    final state = logic.state;
    return state.isAutoPlayShow;
  }

  lastEpisode() {
    final logic = Get.find<ComicReadingLogic>();
    logic.updateIndex(UpdateType.pre);
  }

  autoPlay() {
    final logic = Get.find<ComicReadingLogic>();
    logic.openAutoSpeed();
  }

  nextEpisode() {
    final logic = Get.find<ComicReadingLogic>();
    logic.updateIndex(UpdateType.next);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        GestureDetector(
          onTap: () => hide(),
          child: Container(
            color: Colors.transparent,
          ),
        ),
        buildTopView(),
        buildSpeedView(),
        buildBottomView(),
        buildAutoPlayAnim(),
      ],
    );
  }

  Widget buildAutoPlayAnim(){
    return Positioned(
        bottom: 20,
        child:Visibility(
        visible: isShowAutoAnim(),
        child:GestureDetector(
          onTap: (){
            showMenuItem();
          },
          child:  Container(
            height: 70,
            width: 50,
            margin: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 4)]),
            child: Lottie.asset(
              Assets.acgRun,
              animate: true,
            ),
          ),
        )));
  }

  Widget buildTopView() {
    String name = widget.title ?? widget.mediaInfoContents?.name ?? "";
    return Positioned(
        left: 0,
        right: 0,
        top: -Screen.navigationBarHeight * (1 - animation.value),
        child: Container(
          width: 1.sw,
          decoration: BoxDecoration(
              color: AppColor.white, boxShadow: [BoxShadow(color: const Color(0x22000000), blurRadius: 8.w)]),
          height: Screen.navigationBarHeight,
          padding: EdgeInsets.fromLTRB(0, Screen.topSafeHeight, 5.w, 0),
          child: Stack(
            children: [
              SizedBox(
                width: 44.w,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: commonBack(),
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(left: 50.w),
                child: Text(name,
                    style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.black,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w500),
                    maxLines: 1),
              ),
              // InkWell(
              //   onTap: () => customDialog('是否${hasCollected ? '取消' : ""}收藏该作品', onTap: () {
              //     final readerLogic = Get.find<ComicReadingLogic>();
              //     readerLogic.cartoonCollcet();
              //     Get.back();
              //   }),
              //   child: SvgPicture.asset(hasCollected ? R.readerCollected : R.readerCollect,
              //       color: !hasCollected ? AppColor.black : null, width: 25.w),
              // ),
              // SizedBox(width: 16.w),
              // // GetPlatform.isAndroid
              // //     ? InkWell(
              // //         onTap: () => Get.back(),
              // //         child: SvgPicture.asset(R.particular,
              // //             color: Colors.black, width: 25.w))
              // //     : Container(),
              // SizedBox(width: 16.w),
              // InkWell(
              //   onTap: () {
              //     final comicReadingLogic = Get.find<ComicReadingLogic>();
              //     comicReadingLogic.openDrawer();
              //   },
              //   child: SvgPicture.asset(R.contents, color: AppColor.black, width: 25.w),
              // ),
              // SizedBox(width: 16.w),
            ],
          ),
        ));
  }

  buildSpeedView() {
    final logic = Get.find<ComicReadingLogic>();
    return Positioned(
        bottom: -(Screen.bottomSafeHeight + 110) * (1 - animation.value)+90,
        left: 50,
        child: GetBuilder<ComicReadingLogic>(
          id: logic.updateSpeedId,
          builder: (_)=>Visibility(
              visible: logic.isOpenSpeed,
              child: Stack(
                children: [
                  SvgPicture.asset(
                    Assets.acgReadSpeedBg,
                    width: 170,
                    height: 45,
                    fit: BoxFit.fill,
                  ),
                  Container(
                    width: 220,
                    height: 45,
                    padding: const EdgeInsets.only(left: 10, bottom: 4,right: 10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          logic.state.readSpeed.length,
                              (index) => GestureDetector(
                                onTap: (){
                                  logic.selectSpeed(index);
                                  hide();
                                },
                              child: Container(
                                width: 40,
                                height: 22,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: logic.currentSpeedIndex == index ? Colors.white38:null,
                                  borderRadius: BorderRadius.circular(8),

                                ),
                                child: Text(logic.state.readSpeed[index],
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w900,
                                        fontStyle: FontStyle.italic)),
                              )),
                        )),
                  )
                ],
              )),
        ));
  }

  buildBottomView() {
    return Positioned(
        bottom: -(Screen.bottomSafeHeight + 110) * (1 - animation.value) + 20,
        left: 20,
        right: 20,
        child: Container(
          decoration: ShapeDecoration(
            color: AppColor.white,
            shadows: [BoxShadow(color: const Color(0xffAEAEC0), blurRadius: 8.w, spreadRadius: 3)],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          height: 60,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => lastEpisode(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      R.rightTriangle,
                      width: 24.w,
                    ),
                    Text('上一话', style: TextStyle(color: const Color(0xff814CFF), fontSize: 10.sp))
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => autoPlay(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      Assets.acgAutoplayIcon,
                      width: 24.w,
                    ),
                    Text('自动播放', style: TextStyle(color: const Color(0xff814CFF), fontSize: 10.sp))
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  final comicReadingLogic = Get.find<ComicReadingLogic>();
                  comicReadingLogic.openDrawer();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      R.camicMenu,
                      width: 24.w,
                    ),
                    Text('目录', style: TextStyle(color: const Color(0xff814CFF), fontSize: 10.sp))
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => nextEpisode(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Transform.rotate(
                      angle: -110.0,
                      child: SvgPicture.asset(
                        R.rightTriangle,
                        width: 24.w,
                      ),
                    ),
                    Text('下一话',
                        style: TextStyle(
                          color: const Color(0xff814CFF),
                          fontSize: 10.sp,
                        )),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
