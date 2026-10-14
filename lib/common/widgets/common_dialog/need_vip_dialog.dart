import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

const Color _kBodyColor = Color(0x80FFFFFF);
const Color _kButtonTextColor = Color(0xFFFFFFFF);

/// 显示需要开通会员的弹窗
Future<void> showNeedVipDialog({
  String bodyLine1 = '您还不是VIP无法修昵称',
  String bodyLine2 = '开通会员 即可解锁',
  VoidCallback? onOpenVip,
  bool barrierDismissible = true,
  String sureText = '立即开通',
}) {
  return Get.dialog<void>(
    barrierDismissible: barrierDismissible,
    barrierColor: const Color(0xB2181818),
    Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 47),
      child: NeedVipDialog(
        bodyLine1: bodyLine1,
        bodyLine2: bodyLine2,
        onOpenVip: onOpenVip,
        sureText: sureText,
      ),
    ),
  );
}

class NeedVipDialog extends StatelessWidget {
  const NeedVipDialog({
    super.key,
    required this.bodyLine1,
    required this.bodyLine2,
    this.onOpenVip,
    this.sureText = '立即开通',
  });

  final String bodyLine1;
  final String bodyLine2;
  final VoidCallback? onOpenVip;
  final String sureText;

  static const TextStyle _bodyStyle = TextStyle(
    color: _kBodyColor,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: ColoredBox(
        color: AppColor.primaryDialogBgColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 15.w),
            const Text(
              '温馨提示',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 15.w),
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.white.withOpacity(0.05),
            ),
            SizedBox(height: 10.w),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    bodyLine1,
                    textAlign: TextAlign.center,
                    style: _bodyStyle,
                  ),
                  SizedBox(height: 6.w),
                  Text(
                    bodyLine2,
                    textAlign: TextAlign.center,
                    style: _bodyStyle,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.w),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColor.primaryButtonColor,
                    foregroundColor: _kButtonTextColor,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                    final open = onOpenVip;
                    if (open != null) {
                      open();
                    } else {
                      Get.toNamed(AppRoutes.MEMBER_CENTER);
                    }
                  },
                  child: Text(
                    sureText,
                    style: const TextStyle(
                      color: _kButtonTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
