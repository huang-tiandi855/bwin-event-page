import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../routers/app_routes.dart';
import '../../store/wallet.dart';

Future<T?> showCoinDialog<T>(
  BuildContext context, {
  String? title,
  required int coin,
  required Function(bool) onPayCoin,
  void Function()? onRecharge,
  bool canUseCoupon = false,
}) {
  return showDialog<T>(
    context: context,
    builder: (context) {
      return CoinDialog(
        title: title,
        coin: coin,
        canUseCoupon: canUseCoupon,
        onPayCoin: (useCoupon) {
          onPayCoin(useCoupon);
        },
        onRecharge: onRecharge ??
            () {
              Get.back();
              Get.toNamed(AppRoutes.MEMBER_CENTER,
                  arguments: {"initialIndex": 1})?.then((value) {});
            },
      );
    },
  );
}

showNeedChargeCoinDialog({
  Function()? onRecharge,
}) {
  return showDialog(
    context: Get.overlayContext!,
    builder: (context) {
      return CoinDialog(
        forceNeedChargeCoins: true,
        onRecharge: onRecharge ??
            () {
              Get.back();
              Get.toNamed(AppRoutes.MEMBER_CENTER,
                  arguments: {"initialIndex": 1});
            },
      );
    },
  );
}

/// 金币弹窗view
class CoinDialog extends StatelessWidget {
  String? title;
  int? coin;

  /// true 需要跳转至充值金币页  false 根据自己的业务去消耗金币
  /// true 是否使用了观影劵
  Function(bool)? onPayCoin;

  /// 使用观影劵
  void Function()? onRecharge;

  bool forceNeedChargeCoins;

  bool canUseCoupon;

  CoinDialog({
    super.key,
    this.title,
    this.coin,
    this.onPayCoin,
    this.onRecharge,
    this.canUseCoupon = false,
    this.forceNeedChargeCoins = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 300.w,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              Text(
                title ?? (isNeedChargeCoins() ? "温馨提示" : "金豆解锁"),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff333333),
                ),
              ),
              18.verticalSpace,
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: const Color(0xff333333).withOpacity(0.1),
              ),
              24.verticalSpace,
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: isNeedChargeCoins()
                    ? const Text(
                        '您当前金豆余额不足',
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    : textSpans([
                        textSpan('您只需花费', const Color(0xFF333333), 20,
                            FontWeight.w400),
                        textSpan('$coin', const Color(0xFFFC4162), 28,
                            FontWeight.w500),
                        textSpan(' 金豆', const Color(0xFF333333), 20,
                            FontWeight.w400),
                      ]),
              ),
              const SizedBox(height: 18),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  isNeedChargeCoins() ? '前往购买金豆 返回继续操作' : '即可解锁继续查看',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff333333),
                  ),
                ),
              ),
              24.verticalSpace,
              _buildButtonMenu(context),
              24.verticalSpace,
              if (canUseCoupon) _buildCoupon(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoupon() {
    int watchCount = UserStore.to.userRightWatchReadCouponList.length;
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: EdgeInsets.only(bottom: 14.w),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // if (watchCount == 0) {
          //   showToast(msg: "观阅券不足");
          // } else {
          //   onPayCoin?.call(true);
          // }
          onPayCoin?.call(true);
        },
        child: Text(
          '使用观阅券 ($watchCount)',
          style: TextStyle(
            color: const Color(0xFF333333),
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildButtonMenu(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 108,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                // Get.toNamed(AppRoutes.SHARE_PROMOTION);
              },
              child: Container(
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: const Color(0xFFF5F5F5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x7FAEAEC0),
                      blurRadius: 20,
                      offset: Offset(5, 5),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Color(0xFFFFFFFF),
                      blurRadius: 20,
                      offset: Offset(-5, -5),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: const Text(
                  "稍后再说",
                  style: TextStyle(
                    color: Color(0xFFB09FD9),
                    fontSize: 14,
                    fontFamily: 'Dream',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 136,
            child: GestureDetector(
              onTap: () {
                if (isNeedChargeCoins()) {
                  onRecharge?.call();
                } else {
                  onPayCoin?.call(false);
                }
              },
              child: Container(
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: const Color(0xFFF5F5F5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x7FAEAEC0),
                      blurRadius: 20,
                      offset: Offset(5, 5),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Color(0xFFFFFFFF),
                      blurRadius: 20,
                      offset: Offset(-5, -5),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Text(
                  isNeedChargeCoins() ? '立即充值' : "立即支付",
                  style: const TextStyle(
                    color: Color(0xFFB09FD9),
                    fontSize: 14,
                    fontFamily: 'Dream',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isNeedChargeCoins() {
    if (forceNeedChargeCoins) {
      return true;
    }

    int totalCoin = WalletStore.to.obtainTotalCoin();
    return totalCoin < (coin ?? 0);
  }
}
