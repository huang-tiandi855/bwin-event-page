import 'package:comics_app/common/res/r.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'logic.dart';
import 'state.dart';

/// 提现
class WithDrawalPage extends StatelessWidget {
  const WithDrawalPage({Key? key}) : super(key: key);

  static const List<String> _instructionLines = [
    '提现金额将在1-3个工作日内到账',
    '单笔最低提现金额为100元',
    '每日最多可提现3次',
    '提现手续费为2%，最低2元',
  ];

  @override
  Widget build(BuildContext context) {
    Get.put(WithDrawalLogic());

    return Scaffold(
      backgroundColor: AppColor.scaffoldBackground,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AssetsGen.images.mine.createCenterBg.image(),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _navigationBar(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, 42.w, 16.w, 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GetBuilder<WithDrawalLogic>(
                        id: WithDrawalLogic.bodyUpdateId,
                        builder: (logic) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 可提现余额
                              _BalanceCard(state: logic.state),
                              SizedBox(height: 16.w),
                              // 输入框
                              _AmountInputCard(logic: logic),
                              SizedBox(height: 16.w),
                              // 选择额度
                              _QuickAmountGrid(logic: logic),
                            ],
                          );
                        },
                      ),
                      const _InstructionCard(),
                    ],
                  ),
                ),
              ),
              const _SubmitBar(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navigationBar(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final h = top + 56.w;

    return SizedBox(
      height: h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: EdgeInsets.only(top: top),
            child: SizedBox(
              height: 56.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: Get.back,
                      icon: SvgPicture.asset(
                        R.back,
                        width: 24.w,
                      ),
                    ),
                  ),
                  Text(
                    '提现',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
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

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.state});

  final WithDrawalState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.w, horizontal: 16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF303131),
            Color(0xFF0F2024),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '可提现余额 (元)',
            style: TextStyle(
              color: Colors.white.withOpacity(.5),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 14.w),
          Text(
            '¥${state.availableBalance}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountInputCard extends StatelessWidget {
  const _AmountInputCard({required this.logic});

  final WithDrawalLogic logic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '¥',
            style: TextStyle(
              color: const Color(0xFF9F9FA9),
              fontSize: 20.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: logic.amountController,
              onChanged: logic.onAmountFieldChanged,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: '请输入提现金额',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(.5),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAmountGrid extends StatelessWidget {
  const _QuickAmountGrid({required this.logic});

  final WithDrawalLogic logic;

  static const int _allIndex = 3;

  @override
  Widget build(BuildContext context) {
    final sel = logic.state.selectedQuickIndex;

    return GridView.builder(
      padding: EdgeInsets.only(bottom: 16.w),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8.w,
        crossAxisSpacing: 12.w,
        childAspectRatio: 1.90,
      ),
      itemBuilder: (context, index) {
        final label = index < WithDrawalState.quickAmounts.length
            ? '${WithDrawalState.quickAmounts[index]}'
            : '全部';
        final selected = sel == index;
        return _QuickChip(
          label: label,
          selected: selected,
          onTap: () => logic.selectQuickAmount(
            index < WithDrawalState.quickAmounts.length ? index : _allIndex,
          ),
        );
      },
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected
                ? AppColor.primaryButtonColor
                : Colors.white.withOpacity(.15),
            width: 1,
          ),
          color: selected
              ? AppColor.primaryButtonColor.withOpacity(.15)
              : Colors.white.withOpacity(.05),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (selected)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.5.w,
                    vertical: 3.w,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primaryButtonColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4.r),
                      bottomRight: Radius.circular(10.r),
                    ),
                  ),
                  child: AssetsGen.images.mine.withDrawVector.image(
                    width: 9.w,
                    height: 6.w,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '提现说明',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.w),
          ...List.generate(WithDrawalPage._instructionLines.length, (i) {
            return Text(
              '${i + 1}. ${WithDrawalPage._instructionLines[i]}',
              style: TextStyle(
                color: Colors.white.withOpacity(.5),
                fontSize: 12.sp,
                height: 2,
                fontWeight: FontWeight.w400,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar();

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<WithDrawalLogic>();

    return SafeArea(
      top: false,
      minimum: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.w, 16.w, 12.w),
        child: GestureDetector(
          onTap: logic.submitWithdraw,
          child: Container(
            height: 48.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColor.primaryButtonColor,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Text(
              '确认提现',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
