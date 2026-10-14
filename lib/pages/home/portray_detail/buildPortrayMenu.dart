import 'dart:async';

import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/screen.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/pages/home/portray_detail/portray_detail_logic.dart';
import 'package:comics_app/pages/home/portray_detail/portray_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';

import '../../../../common/res/r.dart';
import '../../../generated/assets.dart';

class PortrayBuildMenu extends StatefulWidget {
  VoidCallback? onTap;

  String? mediaInfoContents;

  PortrayBuildMenu({
    Key? key,
    this.onTap,
    this.mediaInfoContents,
  }) : super(key: key);

  @override
  State<PortrayBuildMenu> createState() => _ComicBuildMenuState();
}

class _ComicBuildMenuState extends State<PortrayBuildMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  PortrayDetailLogic logic = Get.find<PortrayDetailLogic>();
  PortrayDetailState state = Get.find<PortrayDetailLogic>().state;
  @override
  initState() {
    super.initState();
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

  hide() {
    animationController.reverse();
    Timer(const Duration(milliseconds: 200), () {
      widget.onTap!();
    });
  }

  lastEpisode() {
    final logic = Get.find<PortrayDetailLogic>();
    logic.lastPortray();
  }

  nextEpisode() {
    final logic = Get.find<PortrayDetailLogic>();
    logic.nextPortray();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => hide(),
          child: Container(
            color: Colors.transparent,
          ),
        ),
        buildTopView(),
        buildBottomView(),
      ],
    );
  }

  Widget buildTopView() {
    String? name = widget.mediaInfoContents;
    return Positioned(
        left: 0,
        right: 0,
        top: -Screen.navigationBarHeight * (1 - animation.value),
        child: Container(
          decoration: BoxDecoration(color: AppColor.white, boxShadow: [
            BoxShadow(color: const Color(0x22000000), blurRadius: 8.w)
          ]),
          height: Screen.navigationBarHeight,
          padding: EdgeInsets.fromLTRB(0, Screen.topSafeHeight, 5.w, 0),
          child: Row(
            children: [
              SizedBox(
                width: 44.w,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: commonBack(),
                ),
              ),
              Expanded(
                child: Text(name.toString(),
                    style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.black,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w500),
                    maxLines: 1),
              ),
              Container(
                margin: const EdgeInsets.only(left: 2, top: 2, right: 8),
                child: GetBuilder<PortrayDetailLogic>(
                  init: logic,
                  id: "collected",
                  builder: (_){
                    return LikeButton(
                      size: 18,
                      isLiked: state.mediaInfo?.data?.mediaStatus?.hasCollected,
                      circleColor: const CircleColor(
                        start: Colors.amberAccent,
                        end: Colors.amberAccent,
                      ),
                      bubblesColor: const BubblesColor(
                        dotPrimaryColor: Colors.amberAccent,
                        dotSecondaryColor: Colors.amberAccent,
                      ),
                      likeBuilder: (bool hasCollected) {
                        return hasCollected
                            ? SvgPicture.asset(
                          Assets.acgCollect,
                          width: 24.w,
                          color: Colors.amberAccent,
                          height: 24.w,
                        )
                            : SvgPicture.asset(
                          Assets.acgCollect,
                          width: 24.w,
                          height: 24.w,
                        );
                      },
                      onTap: (isLike) async {
                        logic.cartoonCollcet();
                        return state.mediaInfo?.data?.mediaStatus?.hasCollected;
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }

  buildBottomView() {
    return Positioned(
        bottom: -(Screen.bottomSafeHeight + 110) * (1 - animation.value),
        left: 0,
        right: 0,
        child: Container(
          decoration: BoxDecoration(color: AppColor.white, boxShadow: [
            BoxShadow(color: const Color(0x22000000), blurRadius: 8.w)
          ]),
          height: Screen.navigationBarHeight + 10.w,
          padding:
              EdgeInsets.only(left: 25.w, right: 25.w, bottom: 24.w, top: 10.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => lastEpisode(),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      R.rightTriangle,
                      width: 20.w,
                      color: AppColor.bluishPurple,
                    ),
                    SizedBox(width: 10.w),
                    Text('上一篇',
                        style:
                            TextStyle(color: AppColor.black, fontSize: 15.sp))
                  ],
                ),
              ),
             const Spacer(),
              GestureDetector(
                onTap: () => nextEpisode(),
                child: Row(
                  children: [
                    Text('下一篇',
                        style:
                            TextStyle(color: AppColor.black, fontSize: 15.sp)),
                    SizedBox(width: 10.w),
                    Transform.rotate(
                      angle: -110.0,
                      child: SvgPicture.asset(R.rightTriangle,
                          width: 20.w, color: AppColor.bluishPurple),
                    ),

                  ],
                ),
              )
            ],
          ),
        ));
  }
}
