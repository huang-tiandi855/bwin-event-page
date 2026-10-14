import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../gen/assets.gen.dart';

const _surface = Color(0xFF101010);
const _accent = Color(0xFFF5850B);
const _gold = Color(0xFFFFCF86);
const _muted = Color(0xFF8D8D8D);

/// Figma「余额不足」弹窗（原稿尺寸 560 × 466，按 2x 设计稿还原）。
Future<void> showAiInsufficientBalanceDialog({
  required BuildContext context,
  required int costCoins,
  required int balanceCoins,
  required VoidCallback onRecharge,
}) async {
  await showDialog<void>(
    context: context,
    barrierColor: Colors.black.withOpacity(.68),
    builder: (dialogContext) => Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 47.5.w),
      child: Container(
        width: 280.w,
        height: 233.w,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Column(
          children: [
            SizedBox(height: 25.w),
            SvgPicture.asset(
              AssetsGen.images.ai.aiInsufficientBalance,
              width: 40.w,
              height: 36.w,
            ),
            SizedBox(height: 14.w),
            Text(
              '对不起,您的余额不足',
              style: TextStyle(
                height: 1,
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 17.w),
            _CostLine(costCoins: costCoins),
            SizedBox(height: 14.w),
            _BalanceLine(balanceCoins: balanceCoins),
            SizedBox(height: 20.w),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.of(dialogContext).pop();
                onRecharge();
              },
              child: Container(
                width: 158.w,
                height: 35.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(49.5.r),
                ),
                child: Text(
                  '前往充值',
                  style: TextStyle(
                    height: 1,
                    color: _surface,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CostLine extends StatelessWidget {
  const _CostLine({required this.costCoins});

  final int costCoins;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          height: 1,
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
        children: [
          const TextSpan(text: '本次将消耗 '),
          TextSpan(
            text: '$costCoins',
            style: TextStyle(
              color: _gold,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          const TextSpan(text: ' 金币'),
        ],
      ),
    );
  }
}

class _BalanceLine extends StatelessWidget {
  const _BalanceLine({required this.balanceCoins});

  final int balanceCoins;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          height: 1,
          color: _muted,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
        children: [
          const TextSpan(text: '(账户余额 '),
          TextSpan(
            text: '$balanceCoins',
            style: TextStyle(
              color: _gold,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          const TextSpan(text: ' 金币)'),
        ],
      ),
    );
  }
}

/// 上传失败提示：按参考图的 470 × 164 像素（2x）灰色短提示还原。
void showAiUploadFailureToast() {
  BotToast.showCustomText(
    align: Alignment.center,
    duration: const Duration(seconds: 2),
    onlyOne: true,
    clickClose: true,
    toastBuilder: (_) => Container(
      width: 235.w,
      height: 82.w,
      decoration: BoxDecoration(
        color: const Color(0xFF909090),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_dissatisfied_outlined,
            size: 34.w,
            color: Colors.white,
          ),
          SizedBox(height: 8.w),
          Text(
            '图片上传失败,请重新上传',
            style: TextStyle(
              height: 1,
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}
