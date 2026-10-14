import 'package:comics_app/common/style/style.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GradientBorderButton extends StatelessWidget {
  const GradientBorderButton({
    super.key,
    required this.text,
    this.textStyle,
    this.height,
    this.width,
    this.activated = true,
    this.onTap,
  });

  final String text;
  final TextStyle? textStyle;
  final num? height;
  final num? width;
  final bool activated;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          gradient: activated
              ? LinearGradient(
                  colors: [
                    const Color(0xFF000000).withOpacity(0.05),
                    const Color(0xFFD8D8D8).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.6, 1],
                )
              : null,
          color: activated ? null : AppColor.cf5f5f5,
        ),
        width: width?.toDouble(),
        height: height?.toDouble() ?? 26.w,
        padding: EdgeInsets.all(2.w),
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
            color: activated ? AppColor.white : null,
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 2.w,
            horizontal: 8.w,
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: activated ? AppColor.primaryColor : AppColor.c999999,
              fontWeight: FontWeight.w400,
            ).merge(textStyle),
          ),
        ),
      ),
    );
  }
}
