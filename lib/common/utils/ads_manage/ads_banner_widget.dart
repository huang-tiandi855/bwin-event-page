import 'package:card_swiper/card_swiper.dart';
import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/store/config.dart';
import 'package:comics_app/common/utils/screen.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../style/color.dart';
import 'ads_info_list_extension.dart';
import 'getAdv.dart';

/// 广告轮播
///
/// 数据来源（按优先级）：
/// 1. 显式传入的 [ads] 列表（外部已准备好的广告数据，优先使用）；
/// 2. 通过 [adsType] 自动调用 [getAdsByType] 获取广告。
///
/// 至少需要提供其中之一。
class AdsBannerWidget extends StatefulWidget {
  final AdsType adsType;
  final List<AdsInfoList>? ads;
  final double? width;
  final double? height;
  final int? autoPlayDuration;
  final double? radius;
  final bool showDicator;
  final EdgeInsetsGeometry? padding;
  final ValueChanged<int>? onIndexChanged;

  const AdsBannerWidget({
    Key? key,
    required this.adsType,
    this.ads,
    this.width,
    this.height,
    this.padding,
    this.showDicator = true,
    this.autoPlayDuration = 3000,
    this.radius,
    this.onIndexChanged,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AdsBannerWidgetState();
}

class _AdsBannerWidgetState extends State<AdsBannerWidget> {
  int selectIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 外部显式传入列表 → 直接渲染；
    // 否则用 GetBuilder<ConfigStore> 监听广告数据加载完成的 update()，
    // 在 ConfigStore.adsResponse 就绪后自动刷新本组件。
    if (widget.ads != null) {
      return _buildSwiper(widget.ads!);
    }
    return GetBuilder<ConfigStore>(
      builder: (_) => _buildSwiper(getAdsByType(widget.adsType!)),
    );
  }

  Widget _buildSwiper(List<AdsInfoList> ads) {
    if (ads.isEmpty) {
      return const SizedBox.shrink();
    }
    if (selectIndex >= ads.length) {
      selectIndex = 0;
    }
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: SizedBox(
        width: widget.width ?? 343.w,
        height: widget.height ?? 193.h,
        child: Stack(
          children: <Widget>[
            Swiper(
              index: selectIndex,
              autoplay: ads.length > 1,
              autoplayDelay: widget.autoPlayDuration ?? 3000,
              loop: ads.length > 1,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                  width: Screen.width,
                  child: CustomImage(
                    fit: BoxFit.fill,
                    url: ads[index].resourceUrl,
                    borderRadius: BorderRadius.all(
                        Radius.circular(widget.radius ?? 10.r)),
                  ),
                );
              },
              onTap: (index) => _handleTap(ads, index),
              onIndexChanged: (int index) {
                setState(() {
                  selectIndex = index;
                });
                widget.onIndexChanged?.call(index);
              },
              itemCount: ads.length,
            ),
            if (ads.length > 1 && widget.showDicator)
              Positioned(
                bottom: 10,
                right: 10,
                child: CIndicator(
                  itemCount: ads.length,
                  selectIndex: selectIndex,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleTap(List<AdsInfoList> ads, int index) {
    if (index < 0 || index >= ads.length) return;
    final ad = ads[index];
    ad.jumpAdvByType(widget.adsType);
  }
}

/// 分页指示器
class CIndicator extends StatefulWidget {
  const CIndicator({
    Key? key,
    this.itemCount,
    this.selectIndex,
    this.space = 5.0,
    this.callBack,
    this.isRedCircle = true,
  }) : super(key: key);

  final int? itemCount;
  final int? selectIndex;
  final double? space;
  final Function(int)? callBack;
  final bool isRedCircle;

  @override
  State<StatefulWidget> createState() => _CIndicatorState();
}

class _CIndicatorState extends State<CIndicator> {
  Widget _getBall(int index) {
    var normalBall = Padding(
      padding: EdgeInsets.only(left: widget.space ?? 0),
      child: ClipOval(
        child: Container(
          width: 5,
          height: 5,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
    if (widget.isRedCircle == true) {
      normalBall = Padding(
        padding: EdgeInsets.only(left: widget.space ?? 0),
        child: ClipOval(
          child: Container(
            width: 8,
            height: 8,
            color: AppColor.primaryColor.withOpacity(0.5),
          ),
        ),
      );
    }
    var selectBall = Padding(
        padding: EdgeInsets.only(left: widget.space ?? 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Container(
            width: 15,
            height: 5,
            color: Colors.white,
          ),
        ));
    if (widget.isRedCircle == true) {
      selectBall = Padding(
          padding: EdgeInsets.only(left: widget.space ?? 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 10,
              height: 10,
              color: AppColor.primaryColor,
            ),
          ));
    }
    return (widget.selectIndex == index) ? selectBall : normalBall;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> list = [];
    for (int i = 0; i < (widget.itemCount ?? 0); ++i) {
      list.add(_getBall(i));
    }
    return Row(children: list);
  }
}
