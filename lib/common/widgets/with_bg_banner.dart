import 'package:comics_app/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../entities/module_detail_model/all_media_info_model.dart';
import 'card_swiper/src/swiper.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';

class WithBgBanner extends StatefulWidget {
  List<AllMediaInfoModel> bannerList;
  final SwiperOnTap? onTap;
  WithBgBanner({super.key, required this.bannerList, this.onTap});

  @override
  State<StatefulWidget> createState() {
    return WithBgBannerState();
  }
}

class WithBgBannerState extends State<WithBgBanner> {
  final ValueNotifier<int> selectIndex = ValueNotifier<int>(0);

  List<Offset> offsetValue = [];
  List<double> scaleValue = [];
  List<double> opacityValue = [];

  @override
  void initState() {
    super.initState();
    // double itemWidth = screenWidth - 20.w;
  }

  void _createValue(double itemWidth) {
    for (int i = 0; i < widget.bannerList.length; i++) {
      if (i == 0) {
        offsetValue.add(Offset(-itemWidth + 30.w, 0));
        scaleValue.add(0.65);
        opacityValue.add(0.0);
      } else if (i == 1) {
        offsetValue.add(Offset(-itemWidth / 2, 0));
        scaleValue.add(1.0);
        opacityValue.add(1.0);
      } else if (i == 2) {
        offsetValue.add(Offset(itemWidth / 2 - 30.w, 0));
        scaleValue.add(0.65);
        opacityValue.add(1.0);
      } else if (i == 3) {
        offsetValue.add(Offset(itemWidth - 30.w, 0));
        scaleValue.add(
          0.65 * 0.65,
        );
        opacityValue.add(1.0);
      } else if (i == 4) {
        offsetValue.add(
          Offset(itemWidth + itemWidth / 2 - 60.w, 0),
        );
        scaleValue.add(
          0.65 * 0.65 * 0.65,
        );
        opacityValue.add(1.0);
      } else {
        offsetValue.add(Offset(itemWidth + itemWidth - 120.w, 0));
        scaleValue.add(
          0.65 * 0.65 * 0.65,
        );
        opacityValue.add(0.0);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Column(
      children: [
        SizedBox(
            height: 276.w,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.3,
                    child: ValueListenableBuilder(
                      valueListenable: selectIndex,
                      builder: (BuildContext context, dynamic value, Widget? child) {
                        return CustomImage(
                          width: double.infinity,
                          height: double.infinity,
                          url: widget.bannerList[selectIndex.value].autoCover,
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: _buildSwiper(),
                ),
              ],
            )),
        5.verticalSpace,
        Center(
          child: ValueListenableBuilder(
            valueListenable: selectIndex,
            builder: (BuildContext context, dynamic value, Widget? child) {
              return Container(
                margin: EdgeInsets.only(right: 16.w),
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(widget.bannerList.length, (index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.5),
                        color: selectIndex.value == index ? const Color(0xFFB09FD9) : const Color(0xFFB09FD9),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 5,
                      width: selectIndex.value == index ? 15 : 5,
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );

    // return SliverToBoxAdapter(
    //     child: body);
    return body;
  }

  //轮播 三个一item，新版
  Widget _buildSwiper() {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;
            debugPrint('max width = $width');
            final itemWidth = width / 2;
            _createValue(itemWidth);
            return Swiper(
              autoplay: true,
              layout: SwiperLayout.CUSTOM,
              loop: true,
              index: 0,
              customLayoutOption: CustomLayoutOption(startIndex: -1, stateCount: widget.bannerList.length)
                ..addTranslate(offsetValue)
                ..addScale(scaleValue, Alignment.bottomLeft)
                ..addOpacity(opacityValue)
                ..addTransformZList((v) {
                  return v.reversed.toList();
                }),
              itemHeight: 276.w,
              itemWidth: itemWidth,
              onIndexChanged: (index) {
                selectIndex.value = index;
              },
              onTap: widget.onTap,
              itemBuilder: (context, index) {
                return Container(
                  width: double.infinity,
                  height: 280.w,
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFE8EAF6),
                        offset: Offset(0, -5),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      CustomImage(
                        url: widget.bannerList[index].coverV,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      if (selectIndex.value == index)
                        Positioned(
                          right: 16.w,
                          bottom: 10.w,
                          child: Image.asset(
                            Assets.imagesBannerPlayIcon,
                            width: 30.w,
                            height: 30.w,
                          ),
                        )
                    ],
                  ),
                );
              },
              itemCount: widget.bannerList.length,
            );
          }),
        ),
      ],
    );
  }
}
