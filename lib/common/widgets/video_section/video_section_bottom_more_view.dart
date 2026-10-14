import 'package:comics_app/generated/assets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class VideoSectionBottomMoreView extends StatelessWidget {
  const VideoSectionBottomMoreView({
    super.key,
    this.isSliver = false,
    this.onMoreTap,
    this.onChangeTap,
  });

  final bool isSliver;

  final void Function()? onMoreTap;
  final void Function()? onChangeTap;

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      height: 38.w,
      decoration: ShapeDecoration(
        color: const Color(0xFFF0F0F3),
        shape: const StadiumBorder(),
        shadows: [
          BoxShadow(
            offset: Offset(5.w, 5.w),
            color: const Color(0xFFAEAEC0).withOpacity(0.5),
            blurRadius: 20.w,
          ),
          BoxShadow(
            offset: Offset(-5.w, -5.w),
            color: const Color(0xFFFFFFFF).withOpacity(0.5),
            blurRadius: 20.w,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onMoreTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    Assets.svgIcPlayOutline,
                    width: 16.w,
                    color: const Color(0xFFB09FD9),
                  ),
                  10.horizontalSpace,
                  Text(
                    '更多片源',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: const Color(0xFFB09FD9),
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Dream',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const CustomVerticalDivider(),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onChangeTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    Assets.svgIcRefreshOutline,
                    width: 16.w,
                    color: const Color(0xFFB09FD9),
                  ),
                  10.horizontalSpace,
                  Text(
                    '更换一批',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: const Color(0xFFB09FD9),
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Dream',
                    ),
                  ),
                ],
              ),
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

class CustomVerticalDivider extends StatelessWidget {
  const CustomVerticalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: double.infinity,
          width: 1.w,
          decoration: BoxDecoration(
            color: const Color(0xFFC3C9CD).withOpacity(0.5),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 1.w),
                color: const Color(0xFF000000).withOpacity(0.05),
                blurRadius: 10.w,
              ),
            ],
          ),
        ),
        Container(
          height: double.infinity,
          width: 1.w,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF).withOpacity(0.5),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, -1.w),
                color: const Color(0xFFFFFFFF).withOpacity(0.25),
                blurRadius: 10.w,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
