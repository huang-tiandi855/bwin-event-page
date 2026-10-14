import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common/style/color.dart';

/// 三级排序条：选中项字更大、更亮（对齐设计稿「最新 / 最热 …」）。
class CircleSortFilterRow extends StatelessWidget {
  const CircleSortFilterRow({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.horizontalPadding,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final double? horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final pad = horizontalPadding ?? 0;
    return Container(
      color: AppColor.scaffoldContentBackground,
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: SizedBox(
        height: 25.w,
        child: Row(
          children: List.generate(labels.length, (index) {
            final selected = index == selectedIndex;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelected(index),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: selected ? 15.sp : 14.sp,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color:
                        selected ? Colors.white : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
