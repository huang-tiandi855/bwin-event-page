import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/values/address.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'logic.dart';
import 'state.dart';

/// 代理赚钱 Tab。
class AgentPromotionPage extends StatelessWidget {
  const AgentPromotionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AgentPromotionLogic logic = Get.find<AgentPromotionLogic>();
    final AgentPromotionState state = logic.state;
    return GetBuilder<AgentPromotionLogic>(
      builder: (_) {
        return getBgColorsView(
          child: Padding(
            padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight + 44.h),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(14.w, 13.h, 14.w, 26.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _UserSummary(state: state, logic: logic),
                  16.h.verticalSpace,
                  _AgentEntrance(onTap: logic.onTapJoinAgent),
                  16.h.verticalSpace,
                  const _RuleBlock(),
                  16.h.verticalSpace,
                  _InviteCodeCard(state: state, logic: logic),
                  16.h.verticalSpace,
                  const _InviteSteps(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UserSummary extends StatelessWidget {
  const _UserSummary({
    required this.state,
    required this.logic,
  });

  final AgentPromotionState state;
  final AgentPromotionLogic logic;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: CustomImage(
                url:
                    state.userPortrait ?? AgentPromotionState.avatarPlaceholder,
                width: 62.w,
                height: 62.w,
                fit: BoxFit.cover,
              ),
            ),
            22.w.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.userName.isEmpty ? '用户' : state.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  4.h.verticalSpace,
                  Text(
                    '邀请好友快速提现',
                    style: TextStyle(
                      color: Colors.white.withOpacity(.3),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  '可提现余额',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.45),
                    fontSize: 12.sp,
                  ),
                ),
                7.h.verticalSpace,
                Text(
                  '${state.withdrawableReward}',
                  style: TextStyle(
                    color: AppColor.primaryButtonColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        16.h.verticalSpace,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SmallActionButton(
              text: '立即提现',
              onTap: logic.onTapWithdraw,
            ),
            60.w.horizontalSpace,
            _SmallActionButton(
              text: '推广数据',
              onTap: logic.onTapPromotionData,
            ),
          ],
        )
      ],
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.text,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 91.w,
        height: 28.h,
        decoration: BoxDecoration(
          color: const Color(0xFF403A25),
          borderRadius: BorderRadius.circular(100.r),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: const Color(0xFFD8BB75),
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AgentEntrance extends StatelessWidget {
  const _AgentEntrance({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AssetsGen.images.signin.icAgentEntrance.image(
        height: 126.h,
        fit: BoxFit.fill,
      ),
    );
  }
}

class _RuleBlock extends StatelessWidget {
  const _RuleBlock();

  @override
  Widget build(BuildContext context) {
    final TextStyle normal = TextStyle(
      color: Colors.white.withOpacity(.78),
      fontSize: 12.sp,
      height: 1.45,
    );
    const TextStyle red = TextStyle(
      color: AppColor.primaryButtonColor,
      fontWeight: FontWeight.w600,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '规则说明',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        7.h.verticalSpace,
        Text.rich(
          TextSpan(
            style: normal,
            children: const [
              TextSpan(text: '1. 邀请好友'),
              TextSpan(text: '成功注册', style: red),
              TextSpan(text: '即可获取积分兑换会员\n'),
              TextSpan(text: '2. 邀请好友充值可获取'),
              TextSpan(text: '充值金额70%返利\n', style: red),
              TextSpan(text: '如：邀请好友A，A充值'),
              TextSpan(text: '100元年卡VIP', style: red),
              TextSpan(text: '，即可获得'),
              TextSpan(text: '70元收益', style: red),
              TextSpan(text: '，可提现\n'),
              TextSpan(text: '邀请说明：点击【保存二维码】或【复制推广链接】分享给朋友下载即可'),
            ],
          ),
        ),
      ],
    );
  }
}

class _InviteCodeCard extends StatelessWidget {
  const _InviteCodeCard({
    required this.state,
    required this.logic,
  });

  final AgentPromotionState state;
  final AgentPromotionLogic logic;

  @override
  Widget build(BuildContext context) {
    final String qrPayload =
        '${Address.shareUrlLink ?? ''}${state.inviteCode}'.trim();
    final String qrData =
        qrPayload.isNotEmpty ? qrPayload : state.inviteCode.trim();
    final double qrSize = 125.w;

    return Column(
      children: [
        RepaintBoundary(
          key: state.boundaryKey,
          child: SizedBox(
            width: 241.w,
            height: 300.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: AssetsGen.images.signin.icAgentInviteCodeBg.image(
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  top: 68.h,
                  child: AssetsGen.images.signin.icAgentCodeLine
                      .image(height: 1.h, width: 216.w),
                ),
                Positioned(
                  top: 12.h,
                  child: Column(
                    children: [
                      AssetsGen.images.app.icAppLogo
                          .image(width: 80.w, height: 33.h),
                      Text(
                        '全球最大成人平台',
                        style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(.5)),
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: 90.h,
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        color: Colors.white.withOpacity(.65),
                        fontSize: 12.sp,
                      ),
                      children: [
                        const TextSpan(text: '累计邀请：'),
                        TextSpan(
                          text: '${state.inviteCount}人',
                          style: const TextStyle(
                            color: AppColor.primaryButtonColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 118.h,
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: qrData.isEmpty
                        ? SizedBox(
                            width: qrSize,
                            height: qrSize,
                            child: Center(
                              child: Text(
                                '—',
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          )
                        : QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: qrSize,
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.white,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Color(0xFF111111),
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Color(0xFF111111),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 18.h,
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        color: Colors.white.withOpacity(.65),
                        fontSize: 12.sp,
                      ),
                      children: [
                        const TextSpan(text: '邀请码：'),
                        TextSpan(
                          text: state.inviteCode,
                          style: const TextStyle(
                            color: AppColor.primaryButtonColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        16.h.verticalSpace,
        getCommonButton(
          '请截图保存',
          width: 240.w,
          height: 40.h,
          radius: 100.r,
          color: AppColor.primaryButtonColor,
          onClick: logic.onTapSavePoster,
          textStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        6.h.verticalSpace,
        // 「复制链接」文字按钮：扩一圈点击热区，并显式开启 [HitTestBehavior.opaque]，
        // 否则字体在 14sp 时纯文字的命中区域很窄、容易点空。
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: logic.onTapCopyLink,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            child: Text(
              '复制链接',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColor.primaryButtonColor,
              ),
            ),
          ),
        )
      ],
    );
  }
}

class _InviteSteps extends StatelessWidget {
  const _InviteSteps();

  @override
  Widget build(BuildContext context) {
    return AssetsGen.images.signin.icAgentInvitationSteps.image(
      fit: BoxFit.fitWidth,
    );
  }
}
