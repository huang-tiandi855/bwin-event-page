import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common/routers/app_routes.dart';
import '../../../../common/style/color.dart';

/// 游戏支付底部弹层
Future<void> showGamePayBottomSheet(
  BuildContext context, {
  required int unlockPrice,
  required int coinBalance,
  VoidCallback? onRecharge,
  VoidCallback? onUnlock,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      final bottomInset = MediaQuery.paddingOf(sheetContext).bottom;
      return ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        child: Container(
          color: AppColor.scaffoldBackground,
          padding:
              EdgeInsets.fromLTRB(16.w, 17.5.w, 16.w, 17.5.w + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36.w,
                  height: 5.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),
              SizedBox(height: 37.5.w),
              Text(
                '购买帖子',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10.w),
              _PurchaseInfoRow(
                label: '帖子解锁',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AssetsGen.images.circle.iconGlodenBean
                        .image(width: 20.w, height: 20.w),
                    SizedBox(width: 4.w),
                    Text(
                      '$unlockPrice 金币',
                      style: TextStyle(
                        color: const Color(0xFFFF9100),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _PurchaseInfoRow(
                label: '我的金币',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$coinBalance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        if (onRecharge != null) {
                          onRecharge();
                        } else {
                          Get.toNamed(AppRoutes.WALLET);
                        }
                      },
                      child: Text(
                        '充值',
                        style: TextStyle(
                          color: AppColor.primaryButtonColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.w),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColor.primaryButtonColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    if (onUnlock != null) {
                      onUnlock();
                    } else {
                      showToast(msg: '敬请期待');
                    }
                  },
                  child: Text(
                    '$unlockPrice金币/立即解锁',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _PurchaseInfoRow extends StatelessWidget {
  const _PurchaseInfoRow({
    required this.label,
    required this.trailing,
  });

  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.w),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: trailing,
            ),
          ),
        ],
      ),
    );
  }
}
