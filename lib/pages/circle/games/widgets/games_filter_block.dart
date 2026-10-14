import 'package:comics_app/common/style/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 黄游列表筛选条：分类 / 平台 / 语言 / 排序（视觉对齐 Figma）。
class GamesFilterBlock extends StatelessWidget {
  const GamesFilterBlock({
    super.key,
    required this.rows,
    required this.selectedIndices,
    required this.onSelected,
  });

  final List<GamesFilterRowData> rows;
  final List<int> selectedIndices;
  final void Function(int rowIndex, int optionIndex) onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < rows.length; i++)
          _FilterRow(
            label: rows[i].label,
            options: rows[i].options,
            selectedIndex: selectedIndices[i],
            onSelected: (opt) => onSelected(i, opt),
          ),
      ],
    );
  }
}

class GamesFilterRowData {
  const GamesFilterRowData({required this.label, required this.options});

  final String label;
  final List<String> options;
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.label,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final String label;
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.w,
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Container(
            width: 60.w,
            height: 30.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: options.length,
              separatorBuilder: (_, __) => SizedBox(width: 16.w),
              itemBuilder: (context, i) {
                final bool selected = i == selectedIndex;
                return GestureDetector(
                  onTap: () => onSelected(i),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      options[i],
                      style: TextStyle(
                        color: selected
                            ? AppColor.primaryButtonColor
                            : Colors.white.withOpacity(0.65),
                        fontSize: 14.sp,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
