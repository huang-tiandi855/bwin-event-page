import 'package:comics_app/common/entities/sign_in/sign_in_overview_entity.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/common/widgets/tab_widgets/tab_gradient_indicator_widget.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../sign_reward_cell.dart';
import 'sign_record_logic.dart';

class SignRecordPage extends StatelessWidget {
  const SignRecordPage({Key? key}) : super(key: key);

  static const Color _pageBg = Color(0xFF061313);

  @override
  Widget build(BuildContext context) {
    final SignRecordLogic logic = Get.find<SignRecordLogic>();
    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        bottom: false,
        child: GetBuilder<SignRecordLogic>(
          builder: (_) {
            final TabController? c = logic.tabController;
            if (c == null) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                _Header(tabController: c),
                Expanded(
                  child: TabBarView(
                    controller: c,
                    children: [
                      _RecordTabContent(
                        rewards: logic.state.freeRewards,
                        channel: logic.state.freeChannel,
                        // 免费通道不存在「锁定行」，所有人都能签。
                        rowLocked: false,
                        lastingDays: logic.state.freeLastingDays,
                        memberStyle: false,
                        onTapButton: logic.onTapUpgradeMember,
                      ),
                      _RecordTabContent(
                        rewards: logic.state.memberRewards,
                        channel: logic.state.memberChannel,
                        // 非会员看会员行 → 整行锁定 + 不点亮 checked。
                        rowLocked: !logic.state.isVip,
                        lastingDays: logic.state.memberLastingDays,
                        memberStyle: true,
                        onTapButton: logic.onTapUpgradeMember,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Tab 仅占用中间区域，避免全宽 [TabBar] 盖住左侧返回键的命中区域。
          Center(
            child: SizedBox(
              width: 210.w,
              child: TabGradientIndicatorTabBar(
                isScrollable: true,
                controller: tabController,
                useSigninWelfareDefaults: false,
                labelColor: Colors.white,
                labelPadding: EdgeInsets.symmetric(horizontal: 42.w),
                unselectedLabelColor: Colors.white.withOpacity(.45),
                indicatorPadding: EdgeInsets.only(bottom: 9.h),
                indicatorUnderlineWidth: 18.w,
                tabs: const [
                  Tab(text: '免费'),
                  Tab(text: '会员'),
                ],
              ),
            ),
          ),
          // 置于最上层，保证左侧点击先落到返回，不被 Tab 手势/父级拖动手势抢走。
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Get.back(),
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 22.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordTabContent extends StatelessWidget {
  const _RecordTabContent({
    required this.rewards,
    required this.channel,
    required this.rowLocked,
    required this.lastingDays,
    required this.memberStyle,
    required this.onTapButton,
  });

  final List<SignInRewardItemModel> rewards;
  final SignInChannelOverviewModel? channel;
  final bool rowLocked;
  final int lastingDays;
  final bool memberStyle;
  final VoidCallback onTapButton;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroBlock(
            memberStyle: memberStyle,
            lastingDays: lastingDays,
          ),
          16.h.verticalSpace,
          Container(
            padding: EdgeInsets.all(10.h),
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.05),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rewards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 25.w,
                mainAxisSpacing: 10.h,
                childAspectRatio: 44 / 56,
              ),
              itemBuilder: (context, index) {
                final SignInRewardItemModel r = rewards[index];
                final bool checked =
                    !rowLocked && (channel?.isDayClaimed(r.day) ?? false);
                return SignRewardCell(
                  label: r.displayLabel,
                  rewardType: r.rewardType,
                  checked: checked,
                  locked: rowLocked,
                  iconUrl: r.iconUrl,
                  dayLabel: r.day == null ? '' : '第${r.day}天',
                  memberStyle: memberStyle,
                  showGoldBorder: true,
                  backgroundOpacity: .5,
                  checkedOpacity: .48,
                );
              },
            ),
          ),
          40.h.verticalSpace,
          _UpgradeButton(onTap: onTapButton),
        ],
      ),
    );
  }
}

class _HeroBlock extends StatelessWidget {
  const _HeroBlock({
    required this.memberStyle,
    required this.lastingDays,
  });

  final bool memberStyle;
  final int lastingDays;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 127.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF303131),
                    Color(0xFF051215),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memberStyle ? '会员签到额外大奖' : '连续打卡奖励加倍',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: FontFamily.dream,
                    fontSize: 15.sp,
                    height: 1,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w400,
                    shadows: const [
                      Shadow(
                        color: Color(0xCFFF0000),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                8.h.verticalSpace,
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.white.withOpacity(.8),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      const TextSpan(text: '已连续签到 '),
                      TextSpan(
                        text: '$lastingDays',
                        style: const TextStyle(
                          color: AppColor.primaryButtonColor,
                        ),
                      ),
                      const TextSpan(text: ' 天'),
                    ],
                  ),
                ),
                2.h.verticalSpace,
                Text(
                  memberStyle ? '同时领取免费和会员奖励' : '体验会员、积分兑换\n无法参加会员签到活动',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.5),
                    fontSize: memberStyle ? 12.sp : 10.sp,
                  ),
                ),
                2.h.verticalSpace,
                if (!memberStyle)
                  Text(
                    '您当前还不是会员，签到奖品如下：',
                    style: TextStyle(
                      color: Colors.white.withOpacity(.5),
                      fontSize: 12.sp,
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            right: 16.w,
            child: (memberStyle
                    ? AssetsGen.images.signin.iconSigninRecordVip
                    : AssetsGen.images.signin.iconSigninRecordFree)
                .image(
              width: memberStyle ? 148.w : 128.w,
              height: 118.h,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpgradeButton extends StatelessWidget {
  const _UpgradeButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: getConfirmButton(
        '升级会员 奖励升级',
        width: 343.w,
        height: 40.h,
        radius: 100.r,
        onClick: onTap,
        colors: const [Color(0XFF601EFF), Color(0XFFBA14FF)],
        textStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
