import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 长视频播放器内金币付费浮层。
///
/// 用于两个鉴权 code 共用同一套 UI 框架：
/// - `code == 1038`（未支付，[isInsufficientGold] == false）：
///   标题「视频需要付费观看」，左按钮显示「{price}金币观看」，
///   由调用方在 [onUnlockTap] 中触发 [MediaApi.videoGoldPay] + 刷详情。
/// - `code == 1035`（金币不足，[isInsufficientGold] == true）：
///   标题「金币不足」，左按钮文案改为「去充值」，
///   由调用方在 [onUnlockTap] 中跳转 [AppRoutes.WALLET]。
///
/// 组件本身只负责展示 UI 与触发回调；具体扣费 / 跳转 / 重启播放器逻辑由
/// 调用方处理。
class GoldPlayerOverlay extends StatelessWidget {
  const GoldPlayerOverlay({
    super.key,
    required this.cover,
    required this.priceGold,
    required this.remainGold,
    required this.onBackTap,
    required this.onUnlockTap,
    required this.onOpenMemberTap,
    this.isInsufficientGold = false,
  });

  /// 播放器区域占位封面图。
  final String cover;

  /// 解锁所需金币数（来源：`media.gold`）。
  final int priceGold;

  /// 当前用户剩余金币数（来源：`UserStore.getUserInfoModel.walletApp`，
  /// 应用侧金币余额；旧版本曾用 `account.gold` 现已统一切换）。
  final int remainGold;

  /// 返回按钮点击。
  final VoidCallback onBackTap;

  /// 主按钮点击：
  /// - 1038（[isInsufficientGold] == false）：扣金币购买当前视频。
  /// - 1035（[isInsufficientGold] == true）：跳转钱包充值。
  final VoidCallback onUnlockTap;

  /// 「开通预购免费看」按钮点击：跳转至会员中心。
  final VoidCallback onOpenMemberTap;

  /// 是否以「金币不足」形态展示（对应 code == 1035）。
  final bool isInsufficientGold;

  @override
  Widget build(BuildContext context) {
    final String title = isInsufficientGold ? '金币不足，无法解锁当前视频' : '当前视频需金币解锁';
    final String content =
        isInsufficientGold ? '$priceGold金币 即可观看完整内容。' : '剩余金币数：$remainGold';
    final String unlockButtonText = isInsufficientGold ? '充值金币解锁' : '邀请好友得VIP';
    final List<Color> unlockButtonColors = isInsufficientGold
        ? const [
            Color(0XFFBA14FF),
            Color(0XFF601EFF),
          ]
        : const [
            Color(0XFFE16A20),
            Color(0XFFE13520),
          ];
    final String lockButtonText =
        isInsufficientGold ? '升级会员免费看' : '$priceGold金币解锁';

    final List<Color> lockButtonColors = isInsufficientGold
        ? const [
            Color(0XFFE16A20),
            Color(0XFFE13520),
          ]
        : const [
            Color(0XFFBA14FF),
            Color(0XFF601EFF),
          ];
    return SizedBox(
      height: 212.w,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomImage(
            url: cover,
            height: 212.w,
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.5)),
          Positioned(
            top: 16.w,
            left: 16.w,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onBackTap,
              child: Image.asset(
                'assets/images/png/app_back.png',
                width: 24.w,
                height: 24.w,
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                        lockButtonText,
                        width: 138.w,
                        height: 30.h,
                        radius: 100.r,
                        onClick: onOpenMemberTap,
                        colors: lockButtonColors,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
