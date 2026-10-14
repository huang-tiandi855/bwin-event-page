import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:comics_app/common/apis/mine_apis.dart';
import 'package:comics_app/common/entities/mine/vip_card_model.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../store/user.dart';

typedef VipPurchasePayCallback = Future<void> Function(VipCardModel card);

Future<VipCardModel?> showVipPurchaseBottomSheet({
  int type = 0,
  int showType = 0,
  List<VipCardModel>? cards,
  VipPurchasePayCallback? onPay,
}) {
  return Get.bottomSheet<VipCardModel>(
    VipPurchaseBottomSheet(
      type: type,
      showType: showType,
      cards: cards,
      onPay: onPay,
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class VipPurchaseBottomSheet extends StatefulWidget {
  const VipPurchaseBottomSheet({
    super.key,
    this.type = 0,
    this.showType = 0,
    this.cards,
    this.onPay,
  });

  final int type;
  final int showType;
  final List<VipCardModel>? cards;
  final VipPurchasePayCallback? onPay;

  @override
  State<VipPurchaseBottomSheet> createState() => _VipPurchaseBottomSheetState();
}

class _VipPurchaseBottomSheetState extends State<VipPurchaseBottomSheet> {
  final CarouselController _carouselController = CarouselController();

  bool _loading = true;
  bool _paying = false;
  int _selectedIndex = 0;
  List<VipCardModel> _cards = [];

  VipCardModel? get _selectedCard {
    if (_cards.isEmpty || _selectedIndex >= _cards.length) return null;
    return _cards[_selectedIndex];
  }

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final presetCards = widget.cards;
    if (presetCards != null) {
      setState(() {
        _cards = presetCards;
        _loading = false;
      });
      return;
    }

    final data = await MineApis.getVipCardList(
      type: widget.type,
      showType: widget.showType,
    );
    if (!mounted) return;
    setState(() {
      _cards = data;
      _loading = false;
    });
  }

  Future<void> _handlePay() async {
    final card = _selectedCard;
    if (card == null) {
      showToast(msg: '暂无可购买会员');
      return;
    }
    if (_paying) return;

    if (widget.onPay == null) {
      Get.back(result: card);
      return;
    }

    setState(() => _paying = true);
    try {
      await widget.onPay!(card);
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(maxHeight: 0.92.sh),
        padding: EdgeInsets.fromLTRB(0, 17.5.w, 0, bottom + 26.w),
        decoration: BoxDecoration(
          color: AppColor.scaffoldBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.w)),
        ),
        child: _loading
            ? SizedBox(height: 360.w, child: const Center(child: _LoadingDot()))
            : _cards.isEmpty
                ? SizedBox(
                    height: 360.w,
                    child: Center(
                      child: Text(
                        '暂无会员套餐',
                        style: TextStyle(
                          color: Colors.white.withOpacity(.75),
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  )
                : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final card = _selectedCard!;
    final price = _formatPrice(card.price);
    final carouselWidth = MediaQuery.sizeOf(context).width;
    final cardSlot = 145.w + 12.w;
    final viewportFraction =
        (cardSlot / carouselWidth).clamp(0.38, 0.55).toDouble();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34.w,
          height: 5.w,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.15),
            borderRadius: BorderRadius.circular(100.r),
          ),
        ),
        17.5.h.verticalSpace,
        Text(
          '请选择会员类型',
          style: TextStyle(
            height: 1.2,
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        16.h.verticalSpace,
        _PrivilegeStrip(card: card),
        23.h.verticalSpace,
        SizedBox(
          height: 205.h,
          child: CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: _cards.length,
            itemBuilder: (context, index, _) {
              return _VipPlanCard(
                card: _cards[index],
                selected: index == _selectedIndex,
                onTap: () {
                  _carouselController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                  );
                },
              );
            },
            options: CarouselOptions(
              height: 205.h,
              viewportFraction: viewportFraction,
              initialPage: _selectedIndex,
              enableInfiniteScroll: _cards.length > 1,
              enlargeCenterPage: true,
              enlargeStrategy: CenterPageEnlargeStrategy.zoom,
              enlargeFactor: 0.2,
              scrollPhysics: const BouncingScrollPhysics(),
              onPageChanged: (index, reason) {
                setState(() => _selectedIndex = index);
              },
            ),
          ),
        ),
        30.h.verticalSpace,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '限时特价：',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              height: 22.h,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.15),
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Text(
                '¥$price',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0XFFFF2E55),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        16.h.verticalSpace,
        GestureDetector(
          onTap: _handlePay,
          child: Container(
            height: 48.w,
            width: double.infinity,
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColor.primaryButtonColor,
              borderRadius: BorderRadius.circular(28.w),
            ),
            child: _paying
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    '立即支付',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _PrivilegeStrip extends StatelessWidget {
  const _PrivilegeStrip({required this.card});

  final VipCardModel card;

  @override
  Widget build(BuildContext context) {
    final items = card.memberPermissions;
    return SizedBox(
      height: 83.w,
      child: ListView.separated(
        itemCount: items.length,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        separatorBuilder: (_, __) => SizedBox(width: 20.w),
        itemBuilder: (context, index) => _PrivilegeItem(item: items[index]),
      ),
    );
  }
}

class _PrivilegeItem extends StatelessWidget {
  const _PrivilegeItem({required this.item});

  final VipMemberPermissionModel item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 63.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PrivilegeIcon(iconUrl: item.iconUrl),
          SizedBox(height: 8.w),
          Text(
            item.name ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.w),
          Text(
            item.description ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.sp,
              height: 1.25,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivilegeIcon extends StatelessWidget {
  const _PrivilegeIcon({this.iconUrl});

  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    if (iconUrl != null && iconUrl!.isNotEmpty) {
      return CustomImage(
        url: iconUrl,
        width: 28.w,
        height: 28.w,
        fit: BoxFit.cover,
      );
    }
    return Icon(
      Icons.workspace_premium_rounded,
      color: const Color(0xFFFFE94B),
      size: 28.w,
    );
  }
}

class _VipPlanCard extends StatefulWidget {
  const _VipPlanCard({
    required this.card,
    required this.selected,
    required this.onTap,
  });

  final VipCardModel card;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_VipPlanCard> createState() => _VipPlanCardState();
}

class _VipPlanCardState extends State<_VipPlanCard> {
  Timer? _timer;
  String countdownText = '';

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getNewcomerCardText();
  }

  @override
  Widget build(BuildContext context) {
    final w = 140.w;

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 140 / 180,
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: widget.selected
                          ? Border.all(color: const Color(0xffFFC600), width: 2)
                          : null),
                  child: _buildCover()),
            ),
            const Spacer(),
            if (countdownText.isNotEmpty)
              Container(
                width: w,
                padding: EdgeInsets.symmetric(vertical: 3.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C0000),
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: Text(
                  countdownText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    final bg = widget.card.bg ?? '';
    if (bg.isNotEmpty) {
      return CustomImage(
        url: bg,
        fit: BoxFit.fill,
        borderRadius: BorderRadius.circular(10),
      );
    }
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.w),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF274D61), Color(0xFF0B2227), Color(0xFF201C31)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.card.name ?? 'VIP会员',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            '${widget.card.validDay ?? 0}天',
            style: TextStyle(
              color: Colors.white.withOpacity(.7),
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 4.w),
          Text(
            '¥${_formatPrice(widget.card.price)}',
            style: TextStyle(
              color: const Color(0xFFFFE94B),
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _getNewcomerCardText() {
    final user = UserStore.to.getUserInfoModel;
    if (user?.isVip ?? false) {
      countdownText = '';
      return;
    }
    if (widget.card.newcomerCard != 1) {
      countdownText = '';
      return;
    }
    int seconds = DateTime.fromMillisecondsSinceEpoch(
            int.parse(user?.newUser24HourExpireAt ?? '0'))
        .difference(DateTime.now())
        .inSeconds;
    if (seconds <= 0) {
      countdownText = '';
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds--;
      if (seconds <= 0) {
        timer.cancel();
        _timer = null;
        setState(() {
          countdownText = '';
        });
        return;
      }
      setState(() {
        countdownText =
            '倒计时: ${seconds ~/ 3600}:${(seconds % 3600) ~/ 60}:${seconds % 60}';
      });
    });
  }
}

class _LoadingDot extends StatelessWidget {
  const _LoadingDot();

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.flickr(
      leftDotColor: AppColor.leftDotColor,
      rightDotColor: AppColor.rightDotColor,
      size: 26,
    );
  }
}

String _formatPrice(double? value) {
  if (value == null) return '0';
  if (value % 1 == 0) return value.toInt().toString();
  return value.toStringAsFixed(2);
}
