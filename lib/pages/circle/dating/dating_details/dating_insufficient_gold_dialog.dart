import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 约会详情 · 金币不足（对齐 Figma 社区-约会-无金币弹窗）。
Future<void> showDatingInsufficientGoldDialog({
  required int requiredGold,
  required int currentBalance,
  VoidCallback? onGetGold,
  bool barrierDismissible = true,
}) {
  final need = requiredGold < 0 ? 0 : requiredGold;
  final balance = currentBalance < 0 ? 0 : currentBalance;
  final shortfall = (need - balance).clamp(0, need);

  return Get.dialog<void>(
    barrierDismissible: barrierDismissible,
    barrierColor: const Color(0xB2181818),
    Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 47.5.w),
      child: _DatingInsufficientGoldDialog(
        requiredGold: need,
        currentBalance: balance,
        shortfall: shortfall,
        onGetGold: onGetGold,
      ),
    ),
  );
}

class _DatingInsufficientGoldDialog extends StatelessWidget {
  const _DatingInsufficientGoldDialog({
    required this.requiredGold,
    required this.currentBalance,
    required this.shortfall,
    this.onGetGold,
  });

  final int requiredGold;
  final int currentBalance;
  final int shortfall;
  final VoidCallback? onGetGold;

  static const _titleGradient = LinearGradient(
    begin: Alignment(-0.9, 0),
    end: Alignment(0.9, 0),
    colors: [Color(0xFFFCCAB4), Color(0xFFFDAFC2)],
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: ColoredBox(
        color: AppColor.primaryDialogBgColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 46.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFE8E8E9).withOpacity(0.15),
                  ),
                ),
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => _titleGradient.createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Text(
                  '金币不足',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    height: 16 / 20,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.w),
              child: Column(
                children: [
                  SizedBox(height: 18.w),
                  Text(
                    '当前余额不足$requiredGold金币',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFE8E8E9),
                      fontSize: 14.sp,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 4.w),
                  Text(
                    '获取金币后可继续解锁联系方式',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12.sp,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 18.w),
                  _balanceCard(),
                  SizedBox(height: 18.w),
                  SizedBox(
                    width: 208.w,
                    height: 40.w,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColor.primaryButtonColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () {
                        Get.back();
                        final open = onGetGold;
                        if (open != null) {
                          open();
                        } else {
                          Get.toNamed(AppRoutes.WALLET);
                        }
                      },
                      child: Text(
                        '去获取金币',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.w),
                  GestureDetector(
                    onTap: Get.back,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.w),
                      child: Text(
                        '取消',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _balanceCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 5.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: const Color(0xFFE8E8E9).withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFFCC00).withOpacity(0.1),
              borderRadius: BorderRadius.circular(32.r),
            ),
            alignment: Alignment.center,
            child: AssetsGen.images.dating.datingUnlockGold.image(
              width: 24.w,
              height: 24.w,
            ),
          ),
          SizedBox(width: 10.w),
          _goldColumn('当前余额', currentBalance, Colors.white),
          Container(
            width: 1,
            height: 27.w,
            margin: EdgeInsets.symmetric(horizontal: 12.w),
            color: Colors.white.withOpacity(0.15),
          ),
          _goldColumn('还差', shortfall, const Color(0xFFF7B60A)),
        ],
      ),
    );
  }

  Widget _goldColumn(String label, int amount, Color numberColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 10.sp,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$amount',
              style: TextStyle(
                color: numberColor,
                fontSize: 20.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              '金币',
              style: TextStyle(
                color: numberColor == Colors.white
                    ? Colors.white.withOpacity(0.5)
                    : numberColor,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
