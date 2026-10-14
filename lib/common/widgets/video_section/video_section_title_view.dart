import 'package:comics_app/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class VideoSectionTitleWidget extends StatelessWidget {
  const VideoSectionTitleWidget({
    super.key,
    required this.title,
    this.titleStyle,
    this.subTitle,
    this.subTitleStyle,
    this.icon,
    this.rightText,
    this.rightTextStyle,
    this.showMoreIcon = true,
    this.onMoreTap,
    this.isSliver = false,
    this.padding,
  });

  final String title;
  final TextStyle? titleStyle;

  final String? subTitle;
  final TextStyle? subTitleStyle;
  final Widget? icon;
  final String? rightText;
  final TextStyle? rightTextStyle;
  final bool showMoreIcon;
  final void Function()? onMoreTap;

  final bool isSliver;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        children: [
          if (icon != null)
            Container(
              padding: EdgeInsets.only(right: 8.w),
              child: icon,
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20.sp,
                  color: const Color(0xFF292E30),
                  fontWeight: FontWeight.w900,
                  height: 28 / 20,
                  fontFamily: 'Dream',
                ).merge(titleStyle),
              ),
              if (subTitle?.isNotEmpty == true)
                Container(
                  margin: EdgeInsets.only(top: 10.w),
                  child: Text(
                    subTitle!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w400,
                      height: 18 / 12,
                    ).merge(subTitleStyle),
                  ),
                ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onMoreTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  rightText ?? '更多',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF777777),
                    height: 18 / 12,
                  ).merge(rightTextStyle),
                ),
                if (showMoreIcon)
                  SvgPicture.asset(
                    Assets.svgIcArrowRight,
                    width: 20.w,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (isSliver) {
      return SliverToBoxAdapter(
        child: child,
      );
    }
    return child;
  }
}
