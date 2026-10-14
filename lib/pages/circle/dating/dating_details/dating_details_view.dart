import 'package:comics_app/common/entities/circle/dating_models.dart';
import 'package:comics_app/common/extension/int_extension.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/card_swiper/src/swiper.dart';
import 'package:comics_app/common/widgets/dating_style.dart';
import 'package:comics_app/common/widgets/loading_widget.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/pages/circle/dating/dating_details/dating_details_logic.dart';
import 'package:comics_app/pages/circle/dating/dating_details/dating_details_state.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../image/network/custom_image_network.dart';

class DatingDetailsPage extends StatelessWidget {
  DatingDetailsPage({Key? key}) : super(key: key) {
    logic = Get.put(DatingDetailsLogic(), tag: tag);
    state = logic.state;
  }

  final String tag = DateTime.now().millisecond.toString();
  late final DatingDetailsLogic logic;
  late final DatingDetailsState state;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DatingDetailsLogic>(
      tag: tag,
      builder: (_) {
        final state = logic.state;
        final card = state.card;
        return Scaffold(
          backgroundColor: AppColor.scaffoldBackground,
          body: card == null
              ? _loadingBody(context, state)
              : _body(context, state, card),
        );
      },
    );
  }

  Widget _loadingBody(BuildContext context, DatingDetailsState state) {
    return SafeArea(
      child: Column(
        children: [
          _appBar(context, onReport: null),
          Expanded(
            child: Center(
              child: state.loadFailed
                  ? Text(
                      '加载失败',
                      style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    )
                  : const LoadingWidget(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(
    BuildContext context,
    DatingDetailsState state,
    DatingCardModel card,
  ) {
    return ExtendedNestedScrollView(
      headerSliverBuilder: (context, innerBoxScrolled) => [
        SliverToBoxAdapter(child: _hero(context, card)),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16.w),
                _titleBlock(card),
                SizedBox(height: 16.w),
                _infoGrid(card),
                SizedBox(height: 16.w),
                _contactBlock(context, card),
                SizedBox(height: 16.w),
                _introBlock(card),
                SizedBox(height: 16.w),
                _tipBar(),
                SizedBox(height: 16.w),
                _relatedHeader(card),
                SizedBox(height: 12.w),
              ],
            ),
          ),
        ),
      ],
      body: GetBuilder<DatingDetailsLogic>(
        tag: tag,
        id: 'related',
        builder: (_) {
          return PullRefreshView(
            controller: state.relatedPullController,
            onRefresh: () => logic.loadRelatedPage(refresh: true),
            onLoading: () => logic.loadRelatedPage(refresh: false),
            child: getDatingListStyle(
              items: state.relatedCards,
              isSliver: false,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              onItemTap: (_, item) => logic.openRelated(item),
            ),
          );
        },
      ),
    );
  }

  Widget _hero(BuildContext context, DatingCardModel card) {
    return SizedBox(
      height: 294.w,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          SizedBox(
            height: 264.w,
            width: double.infinity,
            child: _picturesView(),
          ),
          Positioned(
              top: 234.w, left: 16.w, right: 16.w, child: _gallery(card)),
          Positioned(
              top: 0,
              left: 16.w,
              right: 16.w,
              bottom: 0,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => logic.onSwiperPrevious(),
                      child: AssetsGen.images.dating.datingIconLeft
                          .image(width: 16.w, height: 16.w),
                    ),
                    GestureDetector(
                      onTap: () => logic.onSwiperNext(),
                      child: AssetsGen.images.dating.datingIconRight
                          .image(width: 16.w, height: 16.w),
                    ),
                  ])),
          Positioned(
              bottom: 73.w,
              right: 16.w,
              child: GetBuilder<DatingDetailsLogic>(
                  tag: tag,
                  id: 'swiperIndex',
                  builder: (_) {
                    final index = logic.state.selectedImageIndex + 1;
                    final total = state.card?.imageUrls.length ?? 0;
                    return Container(
                      width: 35.w,
                      height: 19.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.5),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '$index/$total',
                        style: TextStyle(color: Colors.white, fontSize: 11.sp),
                      ),
                    );
                  })),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: _appBar(
                context,
                onReport: () => logic.onReportTap(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBar(BuildContext context, {VoidCallback? onReport}) {
    return SizedBox(
      height: 44.w,
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: SvgPicture.asset(AssetsGen.images.svg.back),
            ),
          ),
          const Spacer(),
          if (onReport != null)
            GestureDetector(
              onTap: onReport,
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Row(
                  children: [
                    AssetsGen.images.dating.datingIconReport.image(
                      width: 16.w,
                      height: 16.w,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '举报',
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _gallery(DatingCardModel card) {
    final urls = card.imageUrls;
    if (urls.isEmpty) return const SizedBox.shrink();
    return GetBuilder<DatingDetailsLogic>(
        tag: tag,
        id: 'gallery',
        builder: (_) {
          final selectedIndex = logic.state.selectedImageIndex;
          return SizedBox(
            height: 60.w,
            child: ListView.separated(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: selectedIndex == index
                                ? AppColor.primaryButtonColor
                                : Colors.transparent,
                            width: 1.w),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: CustomImage(
                        borderRadius: BorderRadius.circular(8.r),
                        url: urls[index],
                        fit: BoxFit.fill,
                        width: 60.w,
                        height: 60.w,
                      ),
                    ),
                separatorBuilder: (context, index) => SizedBox(width: 9.w),
                itemCount: urls.length),
          );
        });
  }

  Widget _titleBlock(DatingCardModel card) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        card.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    AssetsGen.images.dating.datingIconVerified.image(
                      width: 16.w,
                      height: 16.w,
                    ),
                  ],
                ),
                if (card.recommendTags.isNotEmpty) ...[
                  SizedBox(height: 8.w),
                  SizedBox(
                    height: 20.w,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => _outlineTag(
                          card.recommendTags[index], _recommendTagColor(index)),
                      itemCount: card.recommendTags.length > 3
                          ? 3
                          : card.recommendTags.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(width: 4.w),
                    ),
                  )
                ],
                if ((card.signature ?? '').isNotEmpty) ...[
                  SizedBox(height: 8.w),
                  Text(
                    card.signature ?? '',
                    style: TextStyle(
                      color: const Color(0xFF8494C6),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          _compensateChip(),
        ],
      ),
    );
  }

  Widget _compensateChip() {
    return Column(
      children: [
        if (state.card?.showCompensate ?? false)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.w),
            decoration: BoxDecoration(
              color: const Color(0xFF34C759),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AssetsGen.images.dating.datingIconCompensate.image(
                  width: 10.w,
                  height: 10.w,
                ),
                Text(
                  '支持赔付',
                  style: TextStyle(color: Colors.white, fontSize: 10.sp),
                ),
              ],
            ),
          ),
        SizedBox(height: 8.w),
        Row(
          children: [
            _statCol(
              AssetsGen.images.dating.datingIconWatch,
              state.card?.displayWatch.humanizeFormat ?? '',
              '浏览',
            ),
            SizedBox(width: 8.w),
            Container(
              width: 1.w,
              height: 23.w,
              color: Colors.white.withOpacity(0.05),
            ),
            SizedBox(width: 8.w),
            _statCol(
              AssetsGen.images.dating.datingIconDeal,
              state.card?.displayBuyNum.humanizeFormat ?? '',
              '成交',
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCol(AssetGenImage icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            icon.image(width: 12.w, height: 12.w),
            SizedBox(width: 4.w),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.w),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  Widget _infoGrid(DatingCardModel card) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _infoRow(
                  AssetsGen.images.dating.datingIconLocation,
                  '所在地区',
                  card.regionDetailLabel,
                ),
                SizedBox(height: 12.w),
                _infoRow(
                  AssetsGen.images.dating.datingIconAppoint,
                  '预约时间',
                  card.appointTime ?? '-',
                ),
              ],
            ),
          ),
          Container(
            width: 1.w,
            height: 64.w,
            color: Colors.white.withOpacity(0.1),
            margin: EdgeInsets.symmetric(horizontal: 8.w),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _infoRow(
                        AssetsGen.images.dating.datingIconAge,
                        '年龄范围',
                        card.ageLabel.isEmpty ? '-' : card.ageLabel,
                      ),
                    ),
                    Expanded(
                      child: _infoRow(
                        AssetsGen.images.dating.datingIconPrice,
                        '消费价格',
                        card.priceLabel.isEmpty ? '-' : card.priceLabel,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.w),
                _serviceTypeRow(card),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(AssetGenImage icon, String title, String value) {
    final display = value.isEmpty ? '--' : value;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26.w,
          height: 26.w,
          decoration: BoxDecoration(
            color: const Color(0xFF272832),
            borderRadius: BorderRadius.circular(13.r),
          ),
          alignment: Alignment.center,
          child: icon.image(width: 14.w, height: 14.w),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10.sp,
                ),
              ),
              SizedBox(height: 2.w),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  display,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _serviceTypeRow(DatingCardModel card) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26.w,
          height: 26.w,
          decoration: BoxDecoration(
            color: const Color(0xFF272832),
            borderRadius: BorderRadius.circular(13.r),
          ),
          alignment: Alignment.center,
          child: AssetsGen.images.dating.datingIconService.image(
            width: 14.w,
            height: 14.w,
          ),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '服务类型',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10.sp,
                ),
              ),
              SizedBox(height: 4.w),
              SizedBox(
                height: 20.w,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: ((context, index) => _outlineTag(
                        card.serviceTags[index], const Color(0xFFE85269),
                        showBgColor: false)),
                    separatorBuilder: (context, index) => SizedBox(width: 4.w),
                    itemCount: card.serviceTags.length),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _contactBlock(BuildContext context, DatingCardModel card) {
    final gold = card.gold;
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              AssetsGen.images.dating.datingIconContact.image(
                width: 18.w,
                height: 18.w,
              ),
              SizedBox(width: 4.w),
              Text(
                '联系方式',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (!card.unlocked)
                RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(children: [
                      TextSpan(
                          text: 'VIP会员',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 10.sp)),
                      if (card.gold > 0) ...[
                        TextSpan(
                            text: '或消耗 ',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.45),
                                fontSize: 10.sp)),
                        TextSpan(
                            text: '${card.gold}金币',
                            style: TextStyle(
                                color: const Color(0xFFFFC701),
                                fontSize: 10.sp)),
                      ],
                      TextSpan(
                          text: '可查看联系方式',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 10.sp)),
                    ]))
              else
                Container(
                  height: 21.w,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                    color: const Color(0x337AF6AE),
                    border:
                        Border.all(color: const Color(0xFF34C759), width: .5),
                    borderRadius: BorderRadius.circular(10.5.r),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      AssetsGen.images.dating.datingIconUnlock.image(
                        width: 12.w,
                        height: 12.w,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '已解锁',
                        style: TextStyle(
                            color: const Color(0xFF34C759), fontSize: 11.sp),
                      ),
                    ],
                  ),
                )
            ],
          ),
          SizedBox(height: 12.w),
          if (card.unlocked)
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) =>
                      _contactRow(card.effectiveContacts[index]),
                  separatorBuilder: (context, index) => SizedBox(height: 8.w),
                  itemCount: card.effectiveContacts.length),
            )
          else ...[
            Stack(children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF221A10),
                        Color(0xFF45341C),
                      ],
                    ),
                  ),
                ),
              ),
              LayoutBuilder(builder: (context, constraints) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (card.vipUnlock == 1)
                      SizedBox(
                        width: constraints.maxWidth * 0.5,
                        child: _unlockBtn(
                          isVip: true,
                          icon: AssetsGen.images.dating.datingUnlockVip,
                          title: 'VIP解锁',
                          subtitle: '(VIP专享查看)',
                          onTap: logic.onVipUnlockTap,
                        ),
                      ),
                    if (gold > 0)
                      SizedBox(
                        width: constraints.maxWidth * 0.5,
                        child: _unlockBtn(
                          isVip: false,
                          icon: AssetsGen.images.dating.datingUnlockGold,
                          title: '$gold金币解锁',
                          subtitle: '(消耗$gold金币查看)',
                          onTap: logic.onGoldUnlockTap,
                        ),
                      ),
                  ],
                );
              }),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _contactRow(DatingContactItem item) {
    return GestureDetector(
      onTap: () => logic.copyContact(item.value ?? ''),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            _contactIcon(item.type).image(width: 22.w, height: 22.w),
            SizedBox(width: 12.w),
            Text(
              '${item.displayLabel}：',
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                item.value ?? '',
                style: TextStyle(
                    color: AppColor.primaryButtonColor, fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AssetGenImage _contactIcon(int type) {
    switch (type) {
      case 1:
        return AssetsGen.images.dating.datingConnectWechat;
      case 2:
        return AssetsGen.images.dating.datingConnectQq;
      case 3:
        return AssetsGen.images.dating.datingConnectTelegram;
      case 4:
        return AssetsGen.images.dating.datingConnectPhone;
      default:
        return AssetsGen.images.dating.datingConnectOther;
    }
  }

  Widget _unlockBtn({
    required AssetGenImage icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isVip,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.w,
        decoration: BoxDecoration(
          gradient: isVip
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFFC2663),
                    Color(0xFFFD7050),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon.image(width: 24.w, height: 24.w),
            SizedBox(width: 8.w),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _introBlock(DatingCardModel card) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AssetsGen.images.dating.datingIconPer.image(
                width: 18.w,
                height: 18.w,
              ),
              SizedBox(width: 4.w),
              Text(
                '她的介绍',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.w),
          Text(
            card.myself ?? '',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13.sp,
              height: 1.45,
            ),
          ),
          if (card.personalTags.isNotEmpty) ...[
            SizedBox(height: 10.w),
            SizedBox(
              height: 20.w,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => _outlineTag(
                    card.personalTags[index], const Color(0xFFC3CFEB),
                    isPersonal: true),
                itemCount: card.personalTags.length,
                separatorBuilder: (context, index) => SizedBox(width: 4.w),
              ),
            )
          ],
        ],
      ),
    );
  }

  Widget _tipBar() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          children: [
            AssetsGen.images.dating.datingIconWarming
                .image(width: 12.w, height: 12.w),
            SizedBox(width: 6.w),
            RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: '联系的时候请说明在',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6), fontSize: 10.sp)),
              TextSpan(
                  text: '「萝幼院」',
                  style: TextStyle(
                      color: AppColor.primaryButtonColor, fontSize: 10.sp)),
              TextSpan(
                  text: '上看到的。',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6), fontSize: 10.sp)),
            ])),
          ],
        ));
  }

  Widget _relatedHeader(DatingCardModel card) {
    final province = card.cities.isNotEmpty
        ? (card.cities.first.provinceName ?? card.regionShortLabel)
        : '';
    final title = province.isNotEmpty ? '$province为您推荐' : '为您推荐';
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _picturesView() {
    final urls = state.card?.imageUrls;
    return Swiper(
        itemCount: urls?.length ?? 0,
        autoplay: true,
        controller: state.swiperController,
        onIndexChanged: logic.onSwiperIndexChanged,
        itemBuilder: (context, index) =>
            CustomImage(url: urls?[index] ?? '', fit: BoxFit.cover));
  }

  Widget _outlineTag(DatingTagItem item, Color color,
      {bool showBgColor = true, bool isPersonal = false}) {
    if (item.logo != null && item.logo!.isNotEmpty) {
      return CustomImage(
        url: item.logo!,
        height: 16.w,
        width: 56.w,
        fit: BoxFit.contain,
      );
    }
    Color? bgColor = showBgColor ? color.withOpacity(0.3) : Colors.transparent;
    bgColor = isPersonal ? null : bgColor;
    final borderColor = isPersonal ? const Color(0xFF2C3346) : color;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: borderColor, width: .5),
      ),
      child: Text(
        item.name,
        style: TextStyle(color: color, fontSize: 10.sp),
      ),
    );
  }

  Color _recommendTagColor(int index) {
    return [
      const Color(0xFFFF004B),
      const Color(0xFFF5850B),
      const Color(0xFF00FFF2),
    ][index % 3];
  }
}
