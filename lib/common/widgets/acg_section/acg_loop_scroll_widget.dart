import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../entities/module_detail_model/all_media_info_model.dart';
import '../card_swiper/src/swiper.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';

class SwiperPage extends StatefulWidget {
  List<AllMediaInfoModel> bannerList;
  final SwiperOnTap? onTap;
  SwiperPage({required this.bannerList, super.key, this.onTap});

  @override
  State<SwiperPage> createState() => _SwiperPageState();
}

class _SwiperPageState extends State<SwiperPage> {
  List<String> imageUrls = [];
  final ValueNotifier<int> selectIndex = ValueNotifier<int>(0);
  @override
  void initState() {
    imageUrls = widget.bannerList.map((e) => e.coverV ?? "").toList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.sw,
      height: 258.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ValueListenableBuilder(
              valueListenable: selectIndex,
              builder: (BuildContext context, dynamic value, Widget? child) {
                return Stack(
                  children: [
                    CustomImage(
                      width: double.infinity,
                      height: double.infinity,
                      url: widget.bannerList[selectIndex.value].autoCover,
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      width: 1.sw,
                      height: 120.w,
                      child: ShaderMask(
                        //此处是背景透明度渐变的处理
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xfff5f5f5),
                              Color.fromRGBO(0, 0, 0, 0.8),
                              Color.fromRGBO(0, 0, 0, 0.6),
                              Color.fromRGBO(0, 0, 0, 0.0),
                            ],
                          ).createShader(Rect.fromLTRB(0, 0, bounds.width, bounds.height));
                        },
                        blendMode: BlendMode.dstIn,
                        child: Container(
                          color: const Color(0xfff5f5f5),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Swiper(
            scrollDirection: Axis.horizontal,
            autoplay: true,
            layout: SwiperLayout.CUSTOM,
            customLayoutOption: CustomLayoutOption(startIndex: 0, stateCount: 3)
              ..addScale([0.8, 0.8, 1.0], Alignment.center)
              ..addOpacity([0.8, 0.8, 1.0])
              ..addTranslate([
                const Offset(-175.0, 0),
                const Offset(175.0, 0),
                const Offset(0.0, 0.0),
              ]),
            itemWidth: 162.w,
            itemHeight: 237.w,
            itemBuilder: (context, index) {
              return SwiperCard(imageUrl: imageUrls[index]);
            },
            onIndexChanged: (index) {
              if (index < imageUrls.length - 2) {
                selectIndex.value = index + 2;
              } else if (index == imageUrls.length - 2) {
                selectIndex.value = 0;
              } else {
                selectIndex.value = index - 4;
              }
            },
            onTap: (index) {
              selectIndex.value = index;
              widget.onTap?.call(index);
            },
            itemCount: imageUrls.length,
          )
        ],
      ),
    );
  }
}

class SwiperCard extends StatelessWidget {
  const SwiperCard({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 162.w,
        height: 237.w,
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
              width: 162.w,
              height: 237.w,
              fit: BoxFit.cover,
              url: imageUrl,
            ),
          ],
        ));
  }
}
