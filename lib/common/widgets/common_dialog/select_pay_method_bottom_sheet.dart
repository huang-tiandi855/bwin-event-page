import 'package:comics_app/common/apis/mine_apis.dart';
import 'package:comics_app/common/entities/mine/vip_card_model.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../routers/app_navigator.dart';
import '../../routers/app_routes.dart';

const List<String> _kPayTips = <String>[
  '因超时支付无法到帐，请重新发起',
  '每天发起支付不能超过5次，连续发起切未付款，账号可能加入黑名单',
];

/// 弹出「请选择支付方式」底部弹窗。
///
/// 用户取消（点遮罩/返回键）返回 null；点击支付返回所选 [VipPayWayModel]。
Future<VipPayWayModel?> selectPayMethodBottomSheet({
  required VipCardModel card,
}) {
  var payWays = <VipPayWayModel>[];
  if (card.payWays.isNotEmpty) {
    final firstPayWay = card.payWays.first;
    payWays.add(firstPayWay);
    final secondPayWay = card.payWays
        .firstWhereOrNull((element) => element.payType != firstPayWay.payType);
    if (secondPayWay != null) {
      payWays.add(secondPayWay);
    }
  }
  return Get.bottomSheet<VipPayWayModel>(
    _SelectPayMethodBottomSheet(
      amount: card.price?.toString() ?? '0',
      payWays: payWays,
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _SelectPayMethodBottomSheet extends StatefulWidget {
  const _SelectPayMethodBottomSheet({
    required this.amount,
    required this.payWays,
  });

  final String amount;
  final List<VipPayWayModel> payWays;

  @override
  State<_SelectPayMethodBottomSheet> createState() =>
      _SelectPayMethodBottomSheetState();
}

class _SelectPayMethodBottomSheetState
    extends State<_SelectPayMethodBottomSheet> {
  int _selectedIndex = 0;
  bool _submitting = false;

  VipPayWayModel? get _selected =>
      widget.payWays.isEmpty ? null : widget.payWays[_selectedIndex];

  Future<void> _handlePay() async {
    final picked = _selected;
    if (picked == null || _submitting) return;

    setState(() => _submitting = true);
    try {
      final payUrl = await MineApis.submitOrder(
        productId: picked.productId,
        payType: picked.payType,
        // payWayId: picked.id,
      );
      if (payUrl == null) {
        setState(() => _submitting = false);
        showToast(msg: '下单失败，请重试');
        return;
      }
      AppNavigator.to.launchWebUrl(payUrl);
      Get.back<VipPayWayModel>(result: picked);
    } catch (e, st) {
      debugPrint('submitOrder error: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.scaffoldBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.only(bottom: bottom + 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DragHandle(),
            _Title(),
            SizedBox(height: 12.w),
            if (widget.payWays.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: widget.payWays.length,
                itemBuilder: (_, i) => _PayMethodTile(
                  payWay: widget.payWays[i],
                  selected: i == _selectedIndex,
                  onTap: () => setState(() => _selectedIndex = i),
                ),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.w),
                child: Text(
                  '暂无可用的支付方式',
                  style: TextStyle(
                      color: Colors.white.withOpacity(.5),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500),
                ),
              ),
            const _Tips(),
            SizedBox(height: 24.w),
            _PayButton(
              amount: widget.amount,
              loading: _submitting,
              onTap: (_selected == null || _submitting) ? null : _handlePay,
            ),
            SizedBox(height: 16.w),
            const _FooterLink(),
          ],
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 17.5.w),
      child: Container(
        width: 34.w,
        height: 5.w,
        decoration: BoxDecoration(
          color: const Color(0x26FFFFFF),
          borderRadius: BorderRadius.circular(100.r),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      '请选择支付方式',
      style: TextStyle(
        height: 1.2,
        color: Colors.white,
        fontSize: 20.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _PayMethodTile extends StatelessWidget {
  const _PayMethodTile({
    required this.payWay,
    required this.selected,
    required this.onTap,
  });

  final VipPayWayModel payWay;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = payWay.name?.trim() ?? '';
    final tag = payWay.content?.trim();
    final label = (tag == null || tag.isEmpty) ? name : '$name【$tag】';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.w),
        child: Row(
          children: [
            payWay.payImg.image(width: 30.w, height: 30.w),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            _SelectIndicator(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _SelectIndicator extends StatelessWidget {
  const _SelectIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return AssetsGen.images.mine.vipCenterSel.image(
        width: 24.w,
        height: 24.w,
      );
    }
    return AssetsGen.images.mine.vipCenterNor.image(
      width: 24.w,
      height: 24.w,
    );
  }
}

class _Tips extends StatelessWidget {
  const _Tips();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '支付小贴士',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.w),
          for (int i = 0; i < _kPayTips.length; i++)
            Padding(
              padding:
                  EdgeInsets.only(bottom: i == _kPayTips.length - 1 ? 0 : 4.w),
              child: Text(
                '${i + 1}.${_kPayTips[i]}',
                style: TextStyle(
                  color: const Color(0x80FFFFFF),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton({
    required this.amount,
    required this.loading,
    required this.onTap,
  });

  final String amount;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 48.w,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColor.primaryButtonColor,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: loading
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  '¥$amount/立即支付',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '支付问题反馈，点击 ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.MINE_COMMON_PROBLEM),
          behavior: HitTestBehavior.opaque,
          child: Text(
            '在线客服',
            style: TextStyle(
              color: AppColor.primaryButtonColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
