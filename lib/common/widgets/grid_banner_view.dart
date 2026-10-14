import 'dart:math';

import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../entities/config.dart';
import '../utils/ads_manage/ads_info_list_extension.dart';
import '../utils/ads_manage/getAdv.dart';

class GridBannerView extends StatefulWidget {
  factory GridBannerView.sliver({
    required AdsType bannerType,
    bool? isSliver = true,
    EdgeInsetsGeometry? padding,
  }) {
    return GridBannerView(bannerType: bannerType, isSliver: isSliver, padding: padding);
  }

  factory GridBannerView.common({
    required AdsType bannerType,
    bool? isSliver = false,
    EdgeInsetsGeometry? padding,
  }) {
    return GridBannerView(bannerType: bannerType, isSliver: isSliver, padding: padding);
  }

  factory GridBannerView.singleHorizontalScroll({
    required AdsType bannerType,
    EdgeInsetsGeometry? padding,
  }) {
    return GridBannerView(
      bannerType: bannerType,
      isSliver: false,
      padding: padding,
      scrollDirection: Axis.horizontal,
    );
  }

  final AdsType bannerType;

  final bool? isSliver;

  final EdgeInsetsGeometry? padding;

  final Axis? scrollDirection;

  const GridBannerView({
    super.key,
    required this.bannerType,
    this.isSliver,
    this.padding,
    this.scrollDirection,
  });

  @override
  State<StatefulWidget> createState() {
    return _GridBannerState();
  }
}

class _GridBannerState extends State<GridBannerView> {
  List<AdsInfoList> advList = [];

  int get crossAxisCount {
    if (widget.scrollDirection == Axis.horizontal) return 1;
    return 5;
  }

  double get crossAxisSpacing {
    if (widget.scrollDirection == Axis.horizontal) return 0;
    return 11.w;
  }

  double get mainAxisSpacing {
    if (widget.scrollDirection == Axis.horizontal) return 8.w;
    return 20.w;
  }

  double get aspectRatio {
    if (widget.scrollDirection == Axis.horizontal) return 82 / 60;
    return 60.w / 82.w;
  }

  SliverGridDelegate get gridDelegate {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      childAspectRatio: aspectRatio,
    );
  }

  int get itemCount {
    return min(10, advList.length);
  }

  @override
  void initState() {
    super.initState();
    advList = getAdsByType(widget.bannerType);
  }

  @override
  Widget build(BuildContext context) {
    if (advList.isEmpty == true) return widget.isSliver ?? false ? SliverToBoxAdapter(child: Container()) : Container();
    if (widget.isSliver ?? false) {
      Widget sgv = SliverGrid.builder(
        gridDelegate: gridDelegate,
        itemCount: itemCount,
        itemBuilder: (BuildContext context, int index) {
          return _itemView(advList[index]);
        },
      );
      if (widget.padding != null) {
        return SliverPadding(padding: widget.padding!, sliver: sgv);
      }
      return sgv;
    }
    return GridView.builder(
      shrinkWrap: true,
      scrollDirection: widget.scrollDirection ?? Axis.vertical,
      padding: widget.padding,
      gridDelegate: gridDelegate,
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) {
        return _itemView(advList[index]);
      },
    );
  }

  Widget _itemView(AdsInfoList item) {
    Widget body = Column(
      children: [
        AspectRatio(
            aspectRatio: 60.w / 60.w, child: CustomImage(url: item.resourceUrl, borderRadius: BorderRadius.circular(8))),
        6.verticalSpace,
        Text(
          item.title ?? '',
          maxLines: 1,
          style: TextStyle(
            color: const Color(0xFF555555),
            fontSize: 9.sp,
            fontFamily: 'Dream',
            fontWeight: FontWeight.w900,
          ),
        )
      ],
    );
    return GestureDetector(
        onTap: () {
          item.jumpAdvByType(widget.bannerType);
        },
        child: body);
  }
}
