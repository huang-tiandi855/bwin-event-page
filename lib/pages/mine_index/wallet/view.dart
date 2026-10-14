import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/routers/app_routes.dart';
import 'logic.dart';
import 'state.dart';

/// 设计色（#RRGGBBAA 末两位为透明度）
class _WalletColors {
  static const Color white80 = Color(0x80FFFFFF);
  static const Color blackCC = Color(0xCC000000);
  static const Color fac142 = Color(0xFFFAC142);
  static const Color ff9100 = Color(0xFFFF9100);
}

/// 金币充值
class WalletPage extends StatelessWidget {
  const WalletPage({Key? key}) : super(key: key);

  static const String _noticeGrayPart =
      '*如提示【交易失败】【账户风险】等，课重新发起订单，活在15分后重新支付。如支付未到账，请反馈客服';
  static const String _noticeOrangePart = '订单反馈客服订单号';

  @override
  Widget build(BuildContext context) {
    Get.put(WalletLogic());

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: AssetsGen.images.mine.walletBg.image(fit: BoxFit.fill),
          ),
          GetBuilder<WalletLogic>(builder: (logic) {
            final state = logic.state;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _walletNavBar(context),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(16.w),
                    children: [
                      _balanceCard(state),
                      SizedBox(height: 12.w),
                      _rechargeGrid(logic, state),
                      SizedBox(height: 20.w),
                      _noticeText(),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _unlockButton(logic),
                      SizedBox(height: 9.w),
                      _customerServiceLine(),
                      SizedBox(
                        height: MediaQuery.paddingOf(context).bottom,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// 与 [commonAppBar] 一致：黑底、白返回、[18.sp]/[w600] 标题、底部分割线（默认透明）
  Widget _walletNavBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: kToolbarHeight,
            child: Row(
              children: [
                commonBack(),
                Expanded(
                  child: Center(
                    child: Text(
                      '金币充值',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 56.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceCard(WalletState state) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 20.w, 16.w, 20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '我的金币余额',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.w),
          Row(
            children: [
              AssetsGen.images.circle.iconGlodenBean.image(
                width: 34.w,
                height: 34.w,
              ),
              SizedBox(width: 12.w),
              Text(
                '${state.coinBalance}',
                style: TextStyle(
                  fontSize: 36.sp,
                  color: _WalletColors.ff9100,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rechargeGrid(WalletLogic logic, WalletState state) {
    if (state.loading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 48.w),
        child: const Center(
          child: CircularProgressIndicator(color: _WalletColors.ff9100),
        ),
      );
    }
    if (state.products.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 48.w),
        child: Center(
          child: Text(
            '暂无充值档位',
            style: TextStyle(fontSize: 14.sp, color: _WalletColors.white80),
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12.w,
        crossAxisSpacing: 10.w,
        childAspectRatio: 108 / 136,
      ),
      itemCount: state.products.length,
      itemBuilder: (context, index) {
        final product = state.products[index];
        final giftLabel = WalletLogic.giftLabel(product);
        final selected = state.selectedIndex == index;
        return GestureDetector(
          onTap: () => logic.selectOption(index),
          child: Stack(
            children: [
              Positioned.fill(
                  top: 8.w,
                  child: Container(
                    padding: EdgeInsets.only(top: 20.w),
                    decoration: BoxDecoration(
                      color: AppColor.scaffoldBackground,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: selected
                            ? _WalletColors.fac142
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        AssetsGen.images.circle.iconGlodenBean.image(
                          width: 28.w,
                          height: 28.w,
                          fit: BoxFit.contain,
                        ),
                        const Spacer(),
                        Text(
                          '${product.gold ?? 0}金币',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: _WalletColors.white80,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4.w),
                        Text(
                          '${product.price ?? 0}RMB',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: _WalletColors.ff9100,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  )),
              if (giftLabel != null)
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
                    decoration: BoxDecoration(
                      color: _WalletColors.fac142,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.r),
                        bottomRight: Radius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      giftLabel,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: _WalletColors.blackCC,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if ((product.gameGold ?? 0) > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 25.h,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 7.w),
                      decoration: BoxDecoration(
                        color: _WalletColors.fac142,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.r),
                          bottomRight: Radius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        '赠送${(product.gameGold ?? 0).toStringAsFixed(0)}金币',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(.8),
                        ),
                      ),
                    ),
                  ],
                )
            ],
          ),
        );
      },
    );
  }

  Widget _noticeText() {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 14.sp,
          color: _WalletColors.white80,
          fontWeight: FontWeight.w500,
          height: 1.45,
        ),
        children: [
          const TextSpan(text: _noticeGrayPart),
          TextSpan(
            text: _noticeOrangePart,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColor.primaryButtonColor,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _unlockButton(WalletLogic logic) {
    final selected = logic.selectedProduct;
    final enabled = selected != null && !logic.state.loading;
    return GestureDetector(
      onTap: enabled ? logic.onTapUnlock : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Container(
          height: 48.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColor.primaryButtonColor,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Text(
            selected != null ? '¥${selected.price ?? 0}/立即解锁' : '立即解锁',
            style: TextStyle(
              fontSize: 20.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _customerServiceLine() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '点击联系 ',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.MINE_COMMON_PROBLEM),
          child: Text(
            '在线客服',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColor.primaryButtonColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
