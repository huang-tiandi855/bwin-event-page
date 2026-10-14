import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common/style/color.dart';
import '../../common/widgets/common_ui/loading_animation.dart';

class LoadingCenterWidget extends StatelessWidget {
  final double? width;
  final double? height;

  const LoadingCenterWidget({super.key, this.width = 40, this.height = 20});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: YJFlickr(
        leftDotColor: AppColor.leftDotColor,
        rightDotColor: AppColor.rightDotColor,
        size: 26,
      ),
    );
  }
}
