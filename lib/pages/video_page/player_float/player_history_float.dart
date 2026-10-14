import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// player_float 目录说明：
/// 这里统一放置“叠在播放器画面上的浮层 UI”，组件不直接处理播放权限或路由业务。
///
/// 播放器左下角历史观看进度浮层。
///
/// 只负责展示“上次观看到”和“立即跳转”，具体 seek 行为由调用方提供。
class PlayerHistoryFloat extends StatelessWidget {
  const PlayerHistoryFloat({
    super.key,
    required this.visible,
    required this.timeText,
    required this.onJumpTap,
  });

  /// 是否展示历史进度提示。
  final bool visible;

  /// 上次观看时间文案。
  final String timeText;

  /// 点击“立即跳转”。
  final VoidCallback onJumpTap;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Positioned(
        bottom: 60.w,
        left: 13.w,
        child: Container(
          height: 24.w,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(12.w),
          ),
          alignment: Alignment.center,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  style: TextStyle(color: Colors.white, fontSize: 10.sp),
                  text: '上次观看到 $timeText  ',
                ),
                TextSpan(
                  recognizer: TapGestureRecognizer()..onTap = onJumpTap,
                  style: TextStyle(
                    color: const Color(0xffFDE39C),
                    fontSize: 10.sp,
                  ),
                  text: '立即跳转',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
