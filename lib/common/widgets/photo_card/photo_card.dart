import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../gen/assets.gen.dart';

class PhotoCardData {
  const PhotoCardData({
    this.id = '',
    required this.title,
    required this.views,
    required this.imgCount,
  });

  /// 图集唯一 id（mock 阶段可填占位字符串，真实接口接入后填后端 id）。
  final String id;
  final String title;
  final String views;
  final String imgCount;
}

class PhotoCard extends StatelessWidget {
  const PhotoCard({
    super.key,
    required this.item,
    this.coverAspectRatio = _defaultCoverAspectRatio,
  });

  /// 封面宽高比（width / height），与设计稿「166×244」一致。
  static const double _defaultCoverAspectRatio = 166 / 244;

  final PhotoCardData item;
  final double coverAspectRatio;

  static const Color _placeholder = Color(0xFF2C2C2C);

  @override
  Widget build(BuildContext context) {
    final double titleFontSize = 12.sp;
    const double titleLineHeight = 1.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: AspectRatio(
            aspectRatio: coverAspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueGrey.shade900.withOpacity(0.9),
                        _placeholder,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(
                  left: 4.w,
                  right: 4.w,
                  bottom: 9.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AssetsGen.images.circle.photoEye
                              .image(width: 12.w, height: 12.w),
                          SizedBox(width: 2.w),
                          Text(
                            item.views,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      if (item.imgCount.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AssetsGen.images.circle.photoImg
                                .image(width: 12.w, height: 12.w),
                            SizedBox(width: 2.w),
                            Text(
                              item.imgCount,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 4.w),
        SizedBox(
          height: titleFontSize * titleLineHeight * 2,
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              strutStyle: StrutStyle(
                fontSize: titleFontSize,
                height: titleLineHeight,
                forceStrutHeight: true,
              ),
              style: TextStyle(
                fontSize: titleFontSize,
                height: titleLineHeight,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
