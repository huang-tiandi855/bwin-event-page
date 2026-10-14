import 'package:flutter/material.dart';

import '../style/color.dart';
import 'common_ui/loading_animation.dart';

///加载中动画效果,默认
class LoadingWidget extends StatelessWidget {
  final double width;

  final double height;

  const LoadingWidget({
    super.key,
    this.width = 100,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        height: height,
        color: Colors.transparent,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            YJFlickr(
              leftDotColor: AppColor.leftDotColor,
              rightDotColor: AppColor.rightDotColor,
              size: 26,
            ),
            // SizedBox(width: 10.w),
            // Text("加载中...",
            //     style: TextStyle(color: AppColor.c55526b, fontSize: 15.sp)),
          ],
        ),
      ),
    );
  }
}
