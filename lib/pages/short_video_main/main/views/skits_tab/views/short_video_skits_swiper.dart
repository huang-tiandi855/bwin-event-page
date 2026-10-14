import 'package:card_swiper/card_swiper.dart';
import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShortVideoSkitsSwiper extends StatelessWidget {
  const ShortVideoSkitsSwiper({
    super.key,
    this.medias = const [],
    this.onTap,
  });

  final List<AllMediaInfoModel> medias;

  final void Function(AllMediaInfoModel)? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 12.w),
      child: AspectRatio(
        aspectRatio: 343 / 143,
        child: Swiper(
          key: ValueKey(medias),
          onIndexChanged: (index) {
            // state.selectIndex = index;
          },
          itemBuilder: (BuildContext context, int index) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Stack(
                children: [
                  CustomImage(
                    url: medias[index].autoCover,
                    fit: BoxFit.fitWidth,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      ignoring: true,
                      child: Container(
                        width: double.infinity,
                        height: 36.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.r)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF0B0A0A).withOpacity(0),
                              const Color(0xFF0B0A0A).withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          autoplayDelay: 5000,
          itemCount: medias.length,
          autoplay: true,
          loop: true,
          onTap: (index) {
            onTap?.call(medias[index]);
          },
          pagination: SwiperPagination(
            margin: EdgeInsets.only(bottom: 6.w),
            alignment: Alignment.bottomCenter,
            builder: RRectSwiperPaginationBuilder(
              activeColor: Colors.white,
              color: const Color(0xFF333333).withOpacity(0.36),
              size: Size(11.w, 3.w),
              space: 2.w,
              borderRadius: BorderRadius.circular(2.w),
            ),
          ),
        ),
      ),
    );
  }
}

class RRectSwiperPaginationBuilder extends SwiperPlugin {
  const RRectSwiperPaginationBuilder({
    this.activeColor,
    this.color,
    this.key,
    this.size = const Size(10.0, 2.0),
    this.space = 3.0,
    this.borderRadius,
  });

  ///color when current index,if set null , will be Theme.of(context).primaryColor
  final Color? activeColor;

  ///,if set null , will be Theme.of(context).scaffoldBackgroundColor
  final Color? color;

  ///Size of the rect
  final Size size;

  /// Space between rects
  final double space;

  final Key? key;

  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    final themeData = Theme.of(context);
    final activeColor = this.activeColor ?? themeData.primaryColor;
    final color = this.color ?? themeData.scaffoldBackgroundColor;

    final list = <Widget>[];

    final itemCount = config.itemCount;
    final activeIndex = config.activeIndex;
    // if (itemCount > 20) {
    //   log(
    //     'The itemCount is too big, we suggest use FractionPaginationBuilder '
    //     'instead of DotSwiperPaginationBuilder in this situation',
    //   );
    // }

    for (var i = 0; i < itemCount; ++i) {
      final active = i == activeIndex;
      final size = this.size;
      list.add(Container(
        decoration: BoxDecoration(
          color: active ? activeColor : color,
          borderRadius: borderRadius,
        ),
        width: size.width,
        height: size.height,
        key: Key('pagination_$i'),
        margin: EdgeInsets.all(space),
      ));
    }
    // print(list);
    // return Container(
    //   width: 100.w,
    //   height: 20.w,
    //   color: Colors.red,
    //   child: Row(
    //     key: key,
    //     mainAxisSize: MainAxisSize.min,
    //     children: list,
    //   ),
    // );

    if (config.scrollDirection == Axis.vertical) {
      return Column(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: list,
      );
    } else {
      return Row(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: list,
      );
    }
  }
}
