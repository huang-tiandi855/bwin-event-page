import 'package:comics_app/common/entities/sign_in/points_exchange_entity.dart';
import 'package:comics_app/common/entities/sign_in/sign_in_overview_entity.dart';
import 'package:comics_app/common/entities/sign_in/welfare_task_entity.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'logic.dart';
import 'sign_reward_cell.dart';
import 'state.dart';

/// 签到 Tab 内容（仅 UI，数据见 [SigninState]）。
class SigninPage extends StatelessWidget {
  const SigninPage({Key? key}) : super(key: key);

  static const Color _cardBg = Color(0xFF1C2226);

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<SigninLogic>();
    final state = logic.state;
    // 处理 SIGNIN_WELFARE 路由 arguments 携带的 `welfareAnchor`：
    // 由外链 `proxinner://signin_welfare_task` / `signin_welfare_reward`
    // 触发，需要在首帧建好后把 segment 切到目标区并滚动到 [welfareSectionKey]。
    // consumePendingAnchor 内部自防御只会消费一次，重复 build 安全。
    if (logic.hasPendingAnchor) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        logic.consumePendingAnchor();
      });
    }
    return Stack(
      children: [
        AssetsGen.images.signin.signBg.image(
          fit: BoxFit.fill,
          alignment: Alignment.topCenter,
        ),
        GetBuilder<SigninLogic>(
          builder: (_) {
            return Padding(
              padding:
                  EdgeInsets.only(top: ScreenUtil().statusBarHeight + 44.h),
              child: SingleChildScrollView(
                controller: logic.contentScrollController,
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _UserHeader(state: state),
                    16.h.verticalSpace,
                    _GradientPillButton(
                      onTap: logic.onTapVip,
                      icon: AssetsGen.images.signin.icSigninOpenVipButton,
                    ),
                    16.h.verticalSpace,
                    //签到奖励
                    _ContinuousCheckInCard(state: state, logic: logic),
                    16.h.verticalSpace,
                    //会员专属
                    _MemberExclusiveCard(state: state, logic: logic),
                    20.h.verticalSpace,
                    _WelfarePointsBlock(
                      key: logic.welfareSectionKey,
                      state: state,
                      logic: logic,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.state});

  final SigninState state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78.h,
      child: Row(
        children: [
          ClipOval(
            child: CustomImage(
              url: state.userPortrait ?? SigninState.avatarPlaceholder,
              width: 62.w,
              height: 62.w,
              fit: BoxFit.cover,
            ),
          ),
          22.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.userName.isEmpty ? '用户' : state.userName,
                  style: TextStyle(
                    color: AppColor.primaryText,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                7.h.verticalSpace,
                Text(
                  '观看次数 ${state.viewCount}',
                  style: TextStyle(
                    color: AppColor.hintTextColor,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          AssetsGen.images.signin.icSigninUserVip.image(
            width: 102.w,
            height: 78.w,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _GradientPillButton extends StatelessWidget {
  const _GradientPillButton({
    required this.onTap,
    required this.icon,
    this.width,
  });

  final double? width;
  final AssetGenImage icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: clickButton(
          onTap: onTap,
          openLimit: true,
          child: icon.image(
            width: width ?? 280.w,
            height: 40.h,
          )),
    );
  }
}

class _ContinuousCheckInCard extends StatelessWidget {
  const _ContinuousCheckInCard({
    required this.state,
    required this.logic,
  });

  final SigninState state;
  final SigninLogic logic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w)
          .copyWith(top: 16.h, bottom: 8.h),
      decoration: BoxDecoration(
        color: SigninPage._cardBg,
        borderRadius: BorderRadius.circular(12.r),
        image: DecorationImage(
          image: AssetsGen.images.signin.icSigninBg.provider(),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '连续打卡奖励加倍',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: FontFamily.dream,
                        fontSize: 15.sp,
                        height: 1,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        shadows: [
                          Shadow(
                            color: const Color(0xFFF38C28).withOpacity(.81),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                clickButton(
                  onTap: () => logic.openSignRecordPage(member: false),
                  child: Text(
                    '签到记录',
                    style: TextStyle(
                      color: Colors.white.withOpacity(.5),
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          4.h.verticalSpace,
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(.15),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                    width: 1.w, color: Colors.white.withOpacity(.05))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.white.withOpacity(.8),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: '已连续签到 '),
                      TextSpan(
                        text: '${state.consecutiveDays}',
                        style: const TextStyle(
                          color: AppColor.primaryButtonColor,
                        ),
                      ),
                      const TextSpan(text: ' 天'),
                    ],
                  ),
                ),
                Text(
                  state.isMember ? '会员签到奖品如下：' : '您当前还不是会员，签到奖品如下：',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.5),
                    fontSize: 12.sp,
                  ),
                ),
                10.h.verticalSpace,
                _RewardGrid(state: state, logic: logic),
              ],
            ),
          ),
          12.h.verticalSpace,
          _GradientPillButton(
            onTap: logic.onTapSignIn,
            icon: (state.overview?.free?.signedToday ?? false)
                ? AssetsGen.images.signin.icSigninCheckedButton
                : AssetsGen.images.signin.icSigninCheckButton,
            width: 169.w,
          ),
        ],
      ),
    );
  }
}

class _RewardGrid extends StatelessWidget {
  const _RewardGrid({
    required this.state,
    required this.logic,
  });

  final SigninState state;
  final SigninLogic logic;

  /// 一行最多展示 5 格，按「今天固定居中」滑动：
  ///   today ≤ 3 → 1..5（左贴边，今天落在第 1/2/3 格）
  ///   today = 4 → 2..6（今天在第 3 格 = 中间）
  ///   today = 5 → 3..7（今天在第 3 格）
  ///   today ≥ totalDays-1 → 末 5 天（右贴边，今天落在第 4/5 格）
  ///
  /// 注：周期不足 5 天时直接全展示。`rowLocked`（非会员看会员行）仅影响
  /// cell 的 locked 显示，不参与窗口位移计算。
  static const int _windowSize = 5;

  static List<SignInRewardItemModel> _visibleCells({
    required List<SignInRewardItemModel> rewards,
    required SignInChannelOverviewModel? channel,
    required bool rowLocked,
    required int cycleCap,
  }) {
    if (rewards.isEmpty) return const [];
    final List<SignInRewardItemModel> sorted = [...rewards]
      ..sort((a, b) => (a.day ?? 0).compareTo(b.day ?? 0));
    if (sorted.length <= _windowSize) return sorted;

    final int totalDays = sorted.length;
    final int today = channel?.todayCycleDay(cycleCap) ?? 1;
    // 让 today 落在第 3 格 → startDay = today - 2；两端做 clamp。
    final int rawStart = today - 2;
    final int maxStart = totalDays - _windowSize + 1;
    final int startDay = rawStart.clamp(1, maxStart);
    final int endDay = startDay + _windowSize - 1;

    return sorted
        .where((r) => r.day != null && r.day! >= startDay && r.day! <= endDay)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _freeRewardSignIn(),
        10.h.verticalSpace,
        _vipRewardSignIn(),
      ],
    );
  }

  Widget _freeRewardSignIn() {
    final overview = state.overview;
    final SignInChannelOverviewModel? channel = overview?.free;
    final List<SignInRewardItemModel> rewards =
        overview?.freeRewards ?? const [];
    final int cycleCap = overview?.dailyCycleDays ?? rewards.length;
    final cells = _visibleCells(
      rewards: rewards,
      channel: channel,
      rowLocked: false,
      cycleCap: cycleCap,
    );
    return SizedBox(
        height: 56.h,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _rowTag('免费', isFree: true),
          for (final r in cells)
            Expanded(
              child: SignRewardCell(
                label: r.displayLabel,
                rewardType: r.rewardType,
                iconUrl: r.iconUrl,
                checked: channel?.isDayClaimed(r.day) ?? false,
                locked: false,
                dayLabel: r.day == null ? null : '第${r.day}天',
              ),
            ),
          6.w.horizontalSpace,
          _lookAll(onTap: () => logic.openSignRecordPage(member: false))
        ]));
  }

  Widget _vipRewardSignIn() {
    final overview = state.overview;
    final SignInChannelOverviewModel? channel = overview?.member;
    final List<SignInRewardItemModel> rewards =
        overview?.memberRewards ?? const [];
    final bool rowLocked = !state.isMember;
    final int cycleCap = overview?.dailyCycleDays ?? rewards.length;
    final cells = _visibleCells(
      rewards: rewards,
      channel: channel,
      rowLocked: rowLocked,
      cycleCap: cycleCap,
    );
    return SizedBox(
        height: 44.h,
        child: Row(children: [
          _rowTag('会员', isFree: false, isMember: state.isMember),
          for (final r in cells)
            Expanded(
                child: SignRewardCell(
              label: r.displayLabel,
              rewardType: r.rewardType,
              iconUrl: r.iconUrl,
              checked: !rowLocked && (channel?.isDayClaimed(r.day) ?? false),
              locked: rowLocked,
              memberStyle: true,
            )),
          6.w.horizontalSpace,
          _lookAll(
            free: false,
            onTap: () => logic.openSignRecordPage(member: true),
          )
        ]));
  }

  Widget _rowTag(String text, {required bool isFree, bool isMember = true}) {
    final image = isFree
        ? AssetsGen.images.signin.icSigninCommonMember.image(
            height: 24.h,
            fit: BoxFit.fitHeight,
          )
        : AssetsGen.images.signin.icSigninVipMember.image(
            height: 24.h,
            fit: BoxFit.fitHeight,
          );
    final imgWiget = isMember
        ? image
        : Stack(alignment: Alignment.center, children: [
            image,
            AssetsGen.images.signin.icSigninVipLock.image(
              width: 18.w,
              height: 18.w,
              fit: BoxFit.contain,
            )
          ]);
    return Padding(
      padding: EdgeInsets.only(right: 6.w, top: isFree ? 0.h : 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          imgWiget,
          Text(
            text,
            style: TextStyle(
                fontSize: 12.sp,
                color: isFree ? Colors.white : AppColor.primaryYellowColor),
          )
        ],
      ),
    );
  }
}

Widget _lookAll({bool free = true, VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 23.w,
      height: 44.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        color: Colors.white.withOpacity(.15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '查看\n全部',
            style: TextStyle(
              fontSize: 7.sp,
              fontWeight: FontWeight.w600,
              color: free ? Colors.white : AppColor.primaryYellowColor,
            ),
          ),
          2.h.verticalSpace,
          AssetsGen.images.signin.icSigninCheckAll.image(
            width: 8.w,
            height: 8.h,
            color: free ? Colors.white : AppColor.primaryYellowColor,
          )
        ],
      ),
    ),
  );
}

class _MemberExclusiveCard extends StatelessWidget {
  const _MemberExclusiveCard({
    required this.state,
    required this.logic,
  });

  final SigninState state;
  final SigninLogic logic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 20.h, 10.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(10.r),
        image: DecorationImage(
          image: AssetsGen.images.signin.signMemberBg.provider(),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '会员专属',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: FontFamily.dream,
                      fontSize: 15.sp,
                      height: 1,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      shadows: [
                        Shadow(
                          color: const Color(0xFFF38C28).withOpacity(.81),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              getCommonButton('签到领取',
                  width: 66.w,
                  height: 29.h,
                  onClick: () => logic.onTapVipSignIn(),
                  color: state.overview?.vipExclusive?.signedToday ?? false
                      ? const Color(0XFF363B3C)
                      : AppColor.primaryButtonColor,
                  textStyle: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ))
            ],
          ),
          10.h.verticalSpace,
          SizedBox(
            height: 48.h,
            child: Builder(builder: (_) {
              final List<SignInRewardItemModel> rewards =
                  state.overview?.vipExclusiveRewards ?? const [];
              final SignInChannelOverviewModel? channel =
                  state.overview?.vipExclusive;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: rewards.length,
                separatorBuilder: (_, __) => SizedBox(width: 7.w),
                itemBuilder: (context, i) {
                  final SignInRewardItemModel r = rewards[i];
                  return _vipExclusiveReward(
                    r,
                    channel?.isDayClaimed(r.day, vip: true) ?? false,
                  );
                },
              );
            }),
          ),
          10.h.verticalSpace,
          Center(
            child: getCommonButton('连续签到可获得超级大礼包',
                width: 209.w,
                height: 22.h,
                radius: 100.r,
                color: Colors.white.withOpacity(.05),
                textStyle: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0XFFFF9100))),
          )
        ],
      ),
    );
  }

  Widget _vipExclusiveReward(SignInRewardItemModel r, bool signed) {
    final String dayLabel = r.day == null ? '' : '第${r.day}天';
    return Container(
      width: 40.w,
      height: 48.w,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetsGen.images.signin.icSigninVipRewardBg.provider(),
          fit: BoxFit.contain,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              getCommonButton(
                '',
                width: 8.w,
                height: 1.h,
                radius: 60.r,
                color: AppColor.primaryYellowColor,
              ),
              CustomImage(
                url: r.iconUrl ?? '',
                width: 22.w,
                height: 22.h,
              ),
              Text(
                dayLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColor.primaryYellowColor,
                ),
              ),
              getCommonButton(
                r.displayLabel,
                width: 33.w,
                height: 9.h,
                radius: 60.r,
                color: const Color(0XFF875417),
                textStyle: TextStyle(
                  fontSize: 6.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if (signed)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.5),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Center(
                  child: AssetsGen.images.signin.icSignedIn.image(
                    width: 23.w,
                    height: 23.h,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WelfarePointsBlock extends StatelessWidget {
  const _WelfarePointsBlock({
    Key? key,
    required this.state,
    required this.logic,
  }) : super(key: key);

  final SigninState state;
  final SigninLogic logic;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 40.h,
          child: Row(
            children: [
              GestureDetector(
                onTap: () => logic.setWelfareSegment(0),
                child: Text(
                  '福利任务',
                  style: TextStyle(
                    color: state.welfareSegment == 0
                        ? Colors.white
                        : Colors.white.withOpacity(.5),
                    fontSize: 16.sp,
                    fontWeight: state.welfareSegment == 0
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
              20.w.horizontalSpace,
              GestureDetector(
                onTap: () => logic.setWelfareSegment(1),
                child: Text(
                  '积分兑换',
                  style: TextStyle(
                    color: state.welfareSegment == 1
                        ? Colors.white
                        : Colors.white.withOpacity(.5),
                    fontSize: 16.sp,
                    fontWeight: state.welfareSegment == 1
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
              const Spacer(),
              getCommonButton(
                '',
                width: 76.w,
                height: 22.h,
                radius: 6.r,
                color: Colors.white.withOpacity(.15),
                onClick: logic.openExchangeRecordPage,
                childWidget: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '兑换记录',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.8),
                        fontSize: 12.sp,
                      ),
                    ),
                    AssetsGen.images.signin.icSigninExchangeRecord.image(
                      width: 14.w,
                      height: 14.w,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 12.sp, height: 1.5),
            children: [
              TextSpan(
                text: '邀请人数',
                style: TextStyle(color: Colors.white.withOpacity(.5)),
              ),
              TextSpan(
                  text: ' ${state.inviteCount} ',
                  style: const TextStyle(color: AppColor.primaryButtonColor)),
              TextSpan(
                text: '人',
                style: TextStyle(color: Colors.white.withOpacity(.5)),
              ),
              const TextSpan(text: '     '),
              TextSpan(
                text: '我的积分：',
                style: TextStyle(color: Colors.white.withOpacity(.5)),
              ),
              TextSpan(
                text: '${state.myPoints}',
                style: const TextStyle(
                  color: AppColor.primaryYellowColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        14.h.verticalSpace,
        if (state.welfareSegment == 0)
          _TaskList(tasks: state.welfareTasks, logic: logic)
        else
          _ExchangeGrid(
            items: state.exchangeItems,
            onTapExchange: logic.onTapExchangeReward,
          ),
      ],
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({required this.tasks, required this.logic});

  final List<WelfareTaskItemModel> tasks;
  final SigninLogic logic;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, i) {
        final WelfareTaskItemModel t = tasks[i];
        taskAvatar(int index) {
          switch (index) {
            case 0:
              return AssetsGen.images.signin.icTaskTopup
                  .image(width: 24.w, height: 24.w);
            case 1:
              return AssetsGen.images.signin.icTaskComment
                  .image(width: 24.w, height: 24.w);
            case 2:
              return AssetsGen.images.signin.icTaskPost
                  .image(width: 24.w, height: 24.w);
            case 3:
              return AssetsGen.images.signin.icTaskCollect
                  .image(width: 24.w, height: 24.w);
            case 4:
              return AssetsGen.images.signin.icTaskInvite
                  .image(width: 24.w, height: 24.w);
            case 5:
              return AssetsGen.images.signin.icTaskBind
                  .image(width: 24.w, height: 24.w);
            default:
              return AssetsGen.images.signin.icTaskTopup
                  .image(width: 24.w, height: 24.w);
          }
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.5.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.05),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              taskAvatar(i),
              14.w.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          t.title ?? '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        10.w.horizontalSpace,
                        Text(
                          t.rewardDisplayLabel,
                          style: TextStyle(
                            color: const Color(0XFFFF2E55),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    4.h.verticalSpace,
                    Text(
                      t.description ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.5),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              10.w.horizontalSpace,
              getCommonButton(
                t.completed ? '已完成' : '去完成',
                width: 84.w,
                height: 34.h,
                radius: 4.r,
                color: t.completed
                    ? Colors.white.withOpacity(0.15)
                    : AppColor.primaryButtonColor,
                textStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color:
                      t.completed ? Colors.white.withOpacity(.5) : Colors.white,
                ),
                onClick: t.completed ? null : () => logic.onTapWelfareTask(t),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExchangeGrid extends StatelessWidget {
  const _ExchangeGrid({
    required this.items,
    required this.onTapExchange,
  });

  final List<PointsExchangeProductModel> items;
  final ValueChanged<PointsExchangeProductModel> onTapExchange;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 167 / 108,
      ),
      itemBuilder: (context, i) {
        final PointsExchangeProductModel e = items[i];
        return Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.05),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text(
              //       e.productName ?? '',
              //       maxLines: 1,
              //       overflow: TextOverflow.ellipsis,
              //       style: TextStyle(
              //         color: AppColor.primaryText,
              //         fontSize: 13.sp,
              //         fontWeight: FontWeight.w700,
              //       ),
              //     ),
              //     2.h.verticalSpace,
              //     Text(
              //       TextUtil.formatReward(e.rewardType,
              //           rewardPayload: e.rewardPayload),
              //       maxLines: 1,
              //       overflow: TextOverflow.ellipsis,
              //       style: TextStyle(
              //         color: AppColor.hintTextColor,
              //         fontSize: 10.sp,
              //       ),
              //     ),
              //   ],
              // ),
              CustomImage(
                url: e.imageUrl ?? '',
                width: 148.w,
                height: 56.w,
                fit: BoxFit.cover,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '花费${e.costPoints ?? 0}积分',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(.5),
                      ),
                    ),
                  ),
                  getCommonButton('积分兑换',
                      width: 60.w,
                      height: 26.h,
                      radius: 100.r,
                      color: AppColor.primaryButtonColor,
                      onClick: () => onTapExchange(e),
                      textStyle: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
