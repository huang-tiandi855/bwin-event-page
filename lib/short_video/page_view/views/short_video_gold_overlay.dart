import 'package:comics_app/common/entities/video_model/ishort_video_model.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 短视频金币付费浮层。
///
/// 视觉对齐长视频 [GoldPlayerOverlay] 的双形态 UI；适配短视频沉浸式
/// 竖屏：使用整屏半透明黑蒙层 + 居中文案/按钮，不绘制底部播放控件占位条。
///
/// 双形态：
/// - `isInsufficientGold == false`（[ShortVideoModel.playerCode] == 1038）：
///   * 标题「当前视频需金币解锁」、副标题「剩余金币数：x」；
///   * 左按钮「邀请好友得VIP」（橙色） → [onUnlockTap]；
///   * 右按钮「{price}金币解锁」（紫色） → [onOpenMemberTap]
///     （即扣金币购买）。
/// - `isInsufficientGold == true`（`videoGoldPay` 返回 1035）：
///   * 标题「金币不足，无法解锁当前视频」、副标题「{price}金币 即可观看完整内容。」；
///   * 左按钮「充值金币解锁」（紫色） → [onUnlockTap]
///     （即跳 [AppRoutes.WALLET]）；
///   * 右按钮「升级会员免费看」（橙色） → [onOpenMemberTap]
///     （即跳 [AppRoutes.MEMBER_CENTER]）。
///
/// 组件本身只负责展示 UI 与触发回调；具体扣费 / 路由跳转 / 重启播放
/// 逻辑由调用方 [AbsShortVideoPlayLogic] 处理。
class ShortVideoGoldOverlay extends StatelessWidget {
  const ShortVideoGoldOverlay({
    super.key,
    required this.videoInfo,
    required this.onDismiss,
    required this.onUnlockTap,
    required this.onOpenMemberTap,
    this.isInsufficientGold = false,
  });

  final ShortVideoModel videoInfo;

  /// 点击蒙层空白处关闭浮层。
  final VoidCallback onDismiss;

  /// 左按钮回调：
  /// - 普通态：跳邀请页（「邀请好友得VIP」）。
  /// - 金币不足态：跳钱包（「充值金币解锁」）。
  final VoidCallback onUnlockTap;

  /// 右按钮回调：
  /// - 普通态：扣金币购买当前视频（「{price}金币解锁」）。
  /// - 金币不足态：跳会员中心（「升级会员免费看」）。
  final VoidCallback onOpenMemberTap;

  /// 是否以「金币不足」形态展示（对应 `videoGoldPay` 返回 1035）。
  final bool isInsufficientGold;

  @override
  Widget build(BuildContext context) {
    final int priceGold = videoInfo.price ?? 0;
    final int remainGold = UserStore.to.getUserInfoModel?.walletApp ?? 0;
    final String title =
        isInsufficientGold ? '金币不足，无法解锁当前视频' : '当前视频需金币解锁';
    final String content = isInsufficientGold
        ? '$priceGold金币 即可观看完整内容。'
        : '剩余金币数：$remainGold';
    final String unlockButtonText =
        isInsufficientGold ? '充值金币解锁' : '邀请好友得VIP';
    final List<Color> unlockButtonColors = isInsufficientGold
        ? const [
            Color(0XFFBA14FF),
            Color(0XFF601EFF),
          ]
        : const [
            Color(0XFFE16A20),
            Color(0XFFE13520),
          ];
    final String memberButtonText =
        isInsufficientGold ? '升级会员免费看' : '$priceGold金币解锁';
    final List<Color> memberButtonColors = isInsufficientGold
        ? const [
            Color(0XFFE16A20),
            Color(0XFFE13520),
          ]
        : const [
            Color(0XFFBA14FF),
            Color(0XFF601EFF),
          ];

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
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              14.w.verticalSpace,
              Text(
                content,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              16.w.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getConfirmButton(
                    unlockButtonText,
                    width: 138.w,
                    height: 30.h,
                    radius: 100.r,
                    onClick: onUnlockTap,
                    colors: unlockButtonColors,
                  ),
                  20.w.horizontalSpace,
                  getConfirmButton(
                    memberButtonText,
                    width: 138.w,
                    height: 30.h,
                    radius: 100.r,
                    onClick: onOpenMemberTap,
                    colors: memberButtonColors,
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
