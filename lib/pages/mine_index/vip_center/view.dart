import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:comics_app/common/entities/mine/vip_card_model.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/routers/app_routes.dart';
import '../../../common/store/user.dart';
import '../../../common/widgets/common_dialog/select_pay_method_bottom_sheet.dart';
import '../../../common/widgets/common_ui/common_ui.dart';
import 'logic.dart';

class VipCenterPage extends StatelessWidget {
  const VipCenterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(VipCenterLogic());

    return Scaffold(
      backgroundColor: AppColor.scaffoldBackground,
      appBar: commonAppBar('会员中心'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //头像、昵称、会员状态
                  const _ProfileHeader(),
                  //会员卡
                  GetBuilder<VipCenterLogic>(
                    id: VipCenterLogic.kCarousel,
                    builder: (logic) {
                      return SizedBox(
                        height: 243.w,
                        child: _ProductCarousel(
                          key: ValueKey(logic.state.listRevision),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16.w),
                  //会员特权
                  GetBuilder<VipCenterLogic>(
                    id: VipCenterLogic.kPermissions,
                    builder: (_) =>
                        _PermissionsPanel(), // ignore: prefer_const_constructors
                  ),
                  SizedBox(height: 16.w),
                ],
              ),
            ),
          ),
          GetBuilder<VipCenterLogic>(
            id: VipCenterLogic.kPay,
            builder: (logic) {
              return _BottomPayBar(card: logic.selectedCard);
            },
          ),
        ],
      ),
    );
  }
}

/// [carousel_slider]：当前商品卡在视口居中。
class _ProductCarousel extends StatefulWidget {
  const _ProductCarousel({super.key});

  @override
  State<_ProductCarousel> createState() => _ProductCarouselState();
}

class _ProductCarouselState extends State<_ProductCarousel> {
  final CarouselController _carouselController = CarouselController();
  late int _centerIndex;

  @override
  void initState() {
    super.initState();
    final logic = Get.find<VipCenterLogic>();
    final n = logic.state.products.length;
    _centerIndex = n == 0 ? 0 : logic.state.productIndex.clamp(0, n - 1);
  }

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<VipCenterLogic>();
    final products = logic.state.products;
    final screenW = MediaQuery.sizeOf(context).width;
    final cardSlot = 170.w + 16.w;
    final viewportFraction = (cardSlot / screenW).clamp(0.34, 0.55);

    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return CarouselSlider.builder(
      carouselController: _carouselController,
      itemCount: products.length,
      itemBuilder: (context, index, _) {
        return _ProductCard(
          product: products[index],
          selected: _centerIndex == index,
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
        height: 240.w,
        viewportFraction: viewportFraction,
        enlargeFactor: 0.35,
        initialPage: _centerIndex,
        enableInfiniteScroll: products.length > 1,
        enlargeCenterPage: true,
        enlargeStrategy: CenterPageEnlargeStrategy.zoom,
        scrollPhysics: const BouncingScrollPhysics(),
        onPageChanged: (index, reason) {
          setState(() => _centerIndex = index);
          logic.selectProduct(index);
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final u = UserStore.to.getUserInfoModel;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
        child: Row(
          children: [
            CustomImage(
              url: u?.avatarUrl ?? '',
              width: 62.w,
              height: 62.w,
              borderRadius: BorderRadius.circular(31.w),
            ),
            SizedBox(width: 22.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        u?.name ?? '游客',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      if (u?.isVip ?? false)
                        AssetsGen.images.mine.mineVip.image(
                          width: 24.w,
                          height: 24.w,
                        )
                      else
                        AssetsGen.images.mine.mineVipNone.image(
                          width: 24.w,
                          height: 24.w,
                        ),
                    ],
                  ),
                  SizedBox(height: 7.w),
                  Text(
                    u?.isVip ?? false
                        ? (u?.membershipCardName ?? '')
                        : '您还不是会员 开通会员 畅享特权',
                    style: TextStyle(
                      color: Colors.white.withOpacity(.3),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ProductCard extends StatefulWidget {
  const _ProductCard({
    required this.product,
    required this.selected,
    required this.onTap,
  });

  final VipCardModel product;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
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
    final w = 170.w;
    final bg = (widget.product.bg ?? '').trim();
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: widget.selected
                      ? Border.all(color: const Color(0xffFFC600), width: 2)
                      : null),
              child: AspectRatio(
                aspectRatio: 170 / 218,
                child: CustomImage(
                  url: bg,
                  fit: BoxFit.fill,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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

  void _getNewcomerCardText() {
    final user = UserStore.to.getUserInfoModel;
    if (user?.isVip ?? false) {
      countdownText = '';
      return;
    }
    if (widget.product.newcomerCard != 1) {
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

class _PermissionsPanel extends StatelessWidget {
  const _PermissionsPanel();

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<VipCenterLogic>();
    final memberPermissions = logic.state.memberPermissions;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(10.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFAB7828),
                    Color(0xFFEFE397),
                  ],
                ).createShader(Offset.zero & bounds.size),
                child: Text(
                  '专享特权',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '开通会员赢限定好礼',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.w),
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: memberPermissions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 20.w,
                crossAxisSpacing: 20.w,
                childAspectRatio: 56 / 85),
            itemBuilder: (context, index) {
              final item = memberPermissions[index];
              return _PermissionCell(item: item);
            },
          ),
        ],
      ),
    );
  }
}

class _PermissionCell extends StatelessWidget {
  const _PermissionCell({required this.item});

  final VipMemberPermissionModel item;

  @override
  Widget build(BuildContext context) {
    final title = (item.name ?? '').trim();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomImage(
          url: (item.iconUrl ?? '').trim(),
          width: 28.w,
          height: 28.w,
          borderRadius: BorderRadius.circular(4.r),
        ),
        const Spacer(flex: 2),
        Text(
          title.isEmpty ? '特权' : title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(flex: 1),
        Text(
          (item.description ?? '').trim(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white.withOpacity(.5),
              fontSize: 10.sp,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _BottomPayBar extends StatelessWidget {
  const _BottomPayBar({required this.card});

  final VipCardModel? card;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final price = card == null ? '0' : card?.price?.toString() ?? '0';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 26.w, 16.w, bottom + 10.w),
      color: Colors.black,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 48.w,
            child: FilledButton(
              onPressed: card == null
                  ? null
                  : () => selectPayMethodBottomSheet(card: card!),
              style: FilledButton.styleFrom(
                backgroundColor: AppColor.primaryButtonColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.w),
                ),
              ),
              child: Text(
                '¥$price/立即支付',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.w),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '支付问题反馈，点击 ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.MINE_COMMON_PROBLEM),
                child: Text(
                  '在线客服',
                  style: TextStyle(
                    color: AppColor.primaryButtonColor,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
