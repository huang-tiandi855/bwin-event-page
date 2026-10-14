// ignore_for_file: file_names

import 'package:card_swiper/card_swiper.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:flutter/cupertino.dart';

import '../../entities/config.dart';
import 'ads_info_list_extension.dart';
import 'getAdv.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';

class AdvSwiper extends StatefulWidget {
  final List<AdsInfoList> advList;
  final AdsType adsType;

  final double? aspectDatio;

  final double? radius;

  const AdvSwiper({
    Key? key,
    required this.advList,
    required this.adsType,
    this.aspectDatio,
    this.radius,
  }) : super(key: key);

  @override
  State<AdvSwiper> createState() => _AdvSwiperState();
}

class _AdvSwiperState extends State<AdvSwiper> {
  @override
  Widget build(BuildContext context) {
    return Swiper(
      duration: 300,
      autoplayDelay: 1000 * 5,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            widget.advList[index].jumpAdvByType(widget.adsType);
          },
          child: widget.aspectDatio != null
              ? AspectRatio(
                  aspectRatio: widget.aspectDatio!,
                  child: CustomImage(
                    fit: BoxFit.fill,
                    borderRadius:
                        BorderRadius.all(Radius.circular(widget.radius ?? 0)),
                    url: widget.advList[index].resourceUrl,
                  ),
                )
              : CustomImage(
                  // borderRadius: BorderRadius.circular(6.w),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.fill,
                  borderRadius:
                      BorderRadius.all(Radius.circular(widget.radius ?? 0)),
                  url: widget.advList[index].resourceUrl,
                ),
        );
      },
      itemCount: widget.advList.length,
      autoplay: true,
      loop: true,
      pagination: widget.advList.length > 1
          ? const SwiperPagination(
              alignment: Alignment.bottomRight,
              builder: DotSwiperPaginationBuilder(
                activeColor: AppColor.bluishPurple,
                space: 6,
                size: 6,
                activeSize: 9,
                color: Color.fromRGBO(255, 255, 255, 0.45),
              ),
            )
          : null,
    );
  }
}
