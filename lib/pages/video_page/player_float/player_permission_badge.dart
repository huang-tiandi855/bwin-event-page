import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// player_float 目录说明：
/// 这里统一放置“叠在播放器画面上的浮层 UI”，组件不直接处理播放权限或路由业务。
///
/// 播放器右上角权限提示浮层。
///
/// 会员视频展示“开通会员”，金豆视频展示“金豆解锁”，点击后的购买逻辑由调用方传入。
class PlayerPermissionBadge extends StatelessWidget {
  const PlayerPermissionBadge({
    super.key,
    required this.highlightText,
    required this.highlightColor,
    required this.onTap,
    this.normalText = '畅享完整内容',
  });

  /// 高亮文案，如“开通会员”“金豆解锁”。
  final String highlightText;

  /// 高亮文案颜色。
  final Color highlightColor;

  /// 普通文案。
  final String normalText;

  /// 点击浮层。
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 24.w,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12.w),
        ),
        alignment: Alignment.center,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                style: TextStyle(
                  color: highlightColor,
                  fontSize: 10.sp,
                ),
                text: highlightText,
              ),
              TextSpan(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                ),
                text: normalText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
