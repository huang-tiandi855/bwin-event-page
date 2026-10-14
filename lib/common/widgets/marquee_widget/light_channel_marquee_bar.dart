import 'package:comics_app/common/widgets/marquee_widget/marquee_announcement_bar.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 频道首页白底公告条：PNG 小喇叭 + 灰字 Marquee（精选、多数漫画/动漫页等）。
class LightChannelMarqueeBar extends StatelessWidget {
  const LightChannelMarqueeBar({
    Key? key,
    required this.text,
    this.onTap,
  }) : super(key: key);

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MarqueeAnnouncementBar(
      text: text,
      onTap: onTap,
      leading: AssetsGen.images.png.marqueeLaba.image(
        width: 12.4.w,
        height: 12.4.w,
        color: const Color.fromRGBO(148, 214, 218, 1),
      ),
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
