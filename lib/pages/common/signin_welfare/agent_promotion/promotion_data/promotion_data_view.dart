import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/common/widgets/general_widget/full_bg.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'promotion_data_logic.dart';
import 'promotion_data_state.dart';

class PromotionDataPage extends StatelessWidget {
  const PromotionDataPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PromotionDataLogic logic = Get.find<PromotionDataLogic>();
    return FullBg(
      height: 211.h,
      bgImage: AssetsGen.images.signin.icSigninExchangeBg,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: commonAppBar(
          '推广数据',
          bgColor: Colors.transparent,
          isShowLine: false,
          // actions: [
          //   GestureDetector(
          //     onTap: logic.openIncomeDetail,
          //     child: Padding(
          //       padding: EdgeInsets.only(right: 16.w),
          //       child: Center(
          //         child: Text(
          //           '收益明细',
          //           style: TextStyle(
          //             color: Colors.white.withOpacity(.45),
          //             fontSize: 14.sp,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ],
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: GetBuilder<PromotionDataLogic>(
            builder: (_) {
              final PromotionDataState state = logic.state;
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16.w, 20, 16.w, 30.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _BalanceCard(
                            state: state,
                            onTapWithdraw: logic.onTapWithdraw,
                          ),
                          16.h.verticalSpace,
                          _StatsCard(state: state),
                          16.h.verticalSpace,
                          _DirectStats(state: state),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PromotionDataColors {
  const _PromotionDataColors._();

  static const List<Color> card = [
    Color(0xFF0F2024),
    Color(0xFF303131),
  ];
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.state,
    required this.onTapWithdraw,
  });

  final PromotionDataState state;
  final VoidCallback onTapWithdraw;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 142.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        gradient: const LinearGradient(
          colors: _PromotionDataColors.card,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: _TopMetric(
                  title: '钱包余额',
                  value: '${state.walletBalanceModel?.invitation ?? 0.0}',
                ),
              ),
              Expanded(
                child: _TopMetric(
                  title: '累计收益',
                  value: '${state.inviteIncomeSummaryModel?.allGold ?? 0.0}',
                ),
              ),
            ],
          ),
          12.h.verticalSpace,
          getCommonButton('提现',
              width: 140.w,
              height: 34.h,
              radius: 100.r,
              onClick: onTapWithdraw,
              color: AppColor.primaryButtonColor,
              textStyle:
                  TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _TopMetric extends StatelessWidget {
  const _TopMetric({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        9.h.verticalSpace,
        Text(
          value,
          style: TextStyle(
            color: AppColor.primaryButtonColor,
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.state});

  final PromotionDataState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 136.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        gradient: const LinearGradient(
          colors: _PromotionDataColors.card,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: _SmallMetric(
                  value:
                      '${state.inviteIncomeSummaryModel?.thisMonthGold ?? 0.0}',
                  label: '当月收益（金币）',
                ),
              ),
              Expanded(
                child: _SmallMetric(
                  value:
                      '${state.inviteIncomeSummaryModel?.thisMonthInvite ?? 0}',
                  label: '当月推广数',
                ),
              ),
            ],
          ),
          19.h.verticalSpace,
          Row(
            children: [
              Expanded(
                child: _SmallMetric(
                  value: '${state.inviteIncomeSummaryModel?.todayGold ?? 0.0}',
                  label: '今日收益',
                ),
              ),
              Expanded(
                child: _SmallMetric(
                  value: '${state.inviteIncomeSummaryModel?.todayInvite ?? 0}',
                  label: '今日推广数',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallMetric extends StatelessWidget {
  const _SmallMetric({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColor.primaryButtonColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        4.h.verticalSpace,
        Text(
          label,
          style: TextStyle(
              color: Colors.white.withOpacity(.5),
              fontSize: 12.sp,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _DirectStats extends StatelessWidget {
  const _DirectStats({required this.state});

  final PromotionDataState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '直推总统计',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        10.h.verticalSpace,
        _DirectRow(
            label: '直推用户数',
            value: '${state.inviteIncomeSummaryModel?.totalInvite ?? 0}'),
        10.h.verticalSpace,
        _DirectRow(
            label: '直推付款用户',
            value:
                '${state.inviteIncomeSummaryModel?.totalInviteRecharge ?? 0}'),
      ],
    );
  }
}

class _DirectRow extends StatelessWidget {
  const _DirectRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(.5),
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
