import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GameTagShowItem {
  const GameTagShowItem({
    required this.name,
    required this.color,
  });

  final String name;
  final Color color;
}

/// 游戏卡片描边色标签（分类 / 平台 / 语言），颜色按 Figma 约定循环。
class GameOutlinedTag extends StatelessWidget {
  const GameOutlinedTag({
    super.key,
    required this.model,
  });

  final GameTagShowItem model;

  /// 分类绿 / 平台橙 / 语言红。
  static const List<Color> palette = <Color>[
    Color(0xFFFFF0DC),
    Color(0xFF00FFD0),
    Color(0xFFD78DFF),
  ];

  static Color colorAt(int index) => palette[index % palette.length];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22.w,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: model.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: model.color, width: 0.75),
      ),
      child: Text(
        model.name,
        style: TextStyle(
          color: model.color,
          fontSize: 10.sp,
          height: 1,
        ),
      ),
    );
  }
}
