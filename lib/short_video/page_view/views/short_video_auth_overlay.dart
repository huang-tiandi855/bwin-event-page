import 'package:comics_app/common/entities/video_model/ishort_video_model.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 短视频会员鉴权浮层（`code == 1008`）。
///
/// 视觉对齐长视频 [VipPlayerOverlay] 的「开通会员」UI：
/// - 标题 20.sp、副标题 14.sp、按钮 138.w × 30.h，紫/橙 渐变；
/// - 适配短视频沉浸式竖屏，使用整屏半透明黑蒙层 + 居中文案/按钮，
///   不绘制底部播放控件占位条。
///
/// 组件本身只负责展示 UI 与回调点击事件；具体的路由跳转 / 播放恢复
/// 逻辑由调用方 [AbsShortVideoPlayLogic] 处理。
class ShortVideoAuthOverlay extends StatelessWidget {
  const ShortVideoAuthOverlay({
    super.key,
    required this.videoInfo,
    this.videoType = 0,
    required this.onDismiss,
    required this.onInviteTap,
    required this.onOpenMemberTap,
  });

  final ShortVideoModel videoInfo;

  /// 与长视频 [VipPlayerOverlay] 对齐：`videoType == 2` 时切换为
  /// 「当前内容仅限高级会员观看 / 升级会员免费看」文案；其余情况使用
  /// 普通会员文案。短视频侧目前未引入该字段，默认 0。
  final int videoType;

  final VoidCallback onDismiss;
  final VoidCallback onInviteTap;
  final VoidCallback onOpenMemberTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '开通会员',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              16.w.verticalSpace,
              Text(
                videoType == 2 ? '当前内容仅限高级会员观看' : '全站视频免费观看',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              18.h.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getConfirmButton(
                    '邀请好友得VIP',
                    width: 138.w,
                    height: 30.h,
                    radius: 100.r,
                    onClick: onInviteTap,
                    colors: const [
                      Color(0XFFBA14FF),
                      Color(0XFF601EFF),
                    ],
                  ),
                  20.w.horizontalSpace,
                  getConfirmButton(
                    videoType == 2 ? '升级会员免费看' : '开通预购免费看',
                    width: 138.w,
                    height: 30.h,
                    radius: 100.r,
                    onClick: onOpenMemberTap,
                    colors: const [
                      Color(0XFFE16A20),
                      Color(0XFFE13520),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
