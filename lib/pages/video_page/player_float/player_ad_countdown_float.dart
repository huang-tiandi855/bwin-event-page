import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// player_float 目录说明：
/// 这里统一放置“叠在播放器画面上的浮层 UI”，组件不直接处理播放权限或路由业务。
///
/// 播放器广告倒计时浮层。
///
/// 用于广告图右上角的倒计时/关闭按钮展示。组件只处理展示和点击回调，
/// 是否允许关闭、是否 VIP 跳过等业务判断交给调用方。
class PlayerAdCountdownFloat extends StatelessWidget {
  const PlayerAdCountdownFloat({
    super.key,
    required this.countdownTime,
    required this.actionText,
    required this.onActionTap,
    this.width,
    this.countdownSuffix = '秒后',
  });

  /// 当前广告倒计时秒数。
  final int countdownTime;

  /// 右侧操作文案，如“关闭”“VIP跳过广告”。
  final String actionText;

  /// 点击右侧操作时触发。
  final VoidCallback onActionTap;

  /// 浮层宽度。默认按短关闭按钮样式展示。
  final double? width;

  /// 倒计时后缀，如“秒后”“秒后关闭”。
  final String countdownSuffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 94.w,
      height: 30.w,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.66),
        borderRadius: BorderRadius.all(Radius.circular(15.w)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            countdownTime > 0 ? '$countdownTime$countdownSuffix' : '',
            style: TextStyle(
              fontSize: 14.w,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 6.w),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onActionTap,
            child: Text(
              actionText,
              style: TextStyle(
                fontSize: 14.w,
                color: const Color.fromRGBO(52, 206, 191, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 广告倒计时结束后展示的单独关闭浮层。
class PlayerAdCloseFloat extends StatelessWidget {
  const PlayerAdCloseFloat({
    super.key,
    required this.onCloseTap,
  });

  /// 点击关闭广告。
  final VoidCallback onCloseTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onCloseTap,
      child: Container(
        width: 64.w,
        height: 30.w,
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.66),
          borderRadius: BorderRadius.all(Radius.circular(15.w)),
        ),
        child: Text(
          '关闭',
          style: TextStyle(
            fontSize: 14.w,
            color: const Color.fromRGBO(52, 206, 191, 1),
          ),
        ),
      ),
    );
  }
}
