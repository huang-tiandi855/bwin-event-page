import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NovelCardData {
  const NovelCardData({
    this.id = '',
    required this.title,
    required this.meta,
  });

  /// 小说唯一 id（mock 阶段可填占位字符串，真实接口接入后填后端 id）。
  final String id;
  final String title;
  final String meta;
}

class NovelCard extends StatelessWidget {
  const NovelCard({
    super.key,
    required this.item,
    this.coverAspectRatio = _defaultCoverAspectRatio,
  });

  /// 封面宽高比（width / height），与设计稿「108×150」一致。
  static const double _defaultCoverAspectRatio = 108 / 150;

  final NovelCardData item;
  final double coverAspectRatio;

  static const Color _placeholder = Color(0xFF2C2C2C);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: AspectRatio(
            aspectRatio: coverAspectRatio,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.teal.shade900.withOpacity(0.85),
                    _placeholder,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 4.w),
        Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.sp,
            height: 1.5,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 4.w),
        Text(
          item.meta,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              TextStyle(fontSize: 12.sp, color: Colors.white.withOpacity(.5)),
        ),
      ],
    );
  }
}
