import 'package:comics_app/common/values/config.dart';
import 'package:comics_app/common/widgets/marquee_widget/marquee_announcement_bar.dart';
import 'package:comics_app/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 带新年主题切换的频道公告条（漫画首页等）：PNG / SVG 小喇叭 + 白底 Marquee。
class ThemedChannelMarqueeBar extends StatelessWidget {
  const ThemedChannelMarqueeBar({
    Key? key,
    required this.text,
    this.onTap,
  }) : super(key: key);

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget leading = Config.isNewYearTheme()
        ? Image.asset(Assets.pngMarqueeLaba, width: 20.w, height: 20.w)
        : SvgPicture.asset(
            Assets.acgMarqueeLaba,
            width: 12.4,
            height: 12.4,
          );

    return MarqueeAnnouncementBar(
      text: text,
      onTap: onTap,
      leading: leading,
      padding: EdgeInsets.only(
        top: 4.w,
        bottom: 4.w,
        left: 8.w,
        right: 13.w,
      ),
      barHeight: null,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      leadingGap: 4.6.w,
      marqueeLineHeight: 26.w,
      textStyle: TextStyle(
        fontSize: 12.sp,
        color: const Color.fromRGBO(153, 153, 153, 1),
      ),
      blankSpace: 0,
      pauseAfterRound: const Duration(seconds: 1),
      startPadding: 10.0,
      velocity: 25,
      accelerationDuration: const Duration(seconds: 1),
      decelerationDuration: const Duration(milliseconds: 500),
      accelerationCurve: Curves.linear,
      decelerationCurve: Curves.easeOut,
    );
  }
}
