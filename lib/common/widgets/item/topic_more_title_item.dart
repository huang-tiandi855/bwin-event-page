import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TopicMoreTitleItem extends StatelessWidget {
  const TopicMoreTitleItem({
    Key? key,
    required this.title,
    this.moreText = '更多',
    this.showMore = true,
    this.onMoreTap,
    this.boxHeight,
  }) : super(key: key);

  final String title;
  final bool showMore;
  final String moreText;
  final double? boxHeight;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: boxHeight ?? 40.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (showMore)
              InkWell(
                onTap: onMoreTap,
                child: Container(
                  height: 22.h,
                  padding: EdgeInsets.fromLTRB(10.w, 0, 4.w, 0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.15),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    children: [
                      Text(
                        moreText,
                        style: TextStyle(
                          color: Colors.white.withOpacity(.8),
                          fontSize: 12.sp,
                        ),
                      ),
                      AssetsGen.images.home.icTopicMore
                          .image(width: 14.w, height: 14.h)
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
