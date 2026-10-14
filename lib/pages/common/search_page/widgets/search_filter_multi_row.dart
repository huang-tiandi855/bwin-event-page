import 'package:comics_app/common/entities/home/hot_tag_models.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchFilterMultiRow extends StatelessWidget {
  const SearchFilterMultiRow({
    super.key,
    required this.options,
    required this.selectedIndices,
    required this.onToggle,
  });

  final List<HotTagItemModel> options;
  final Set<int> selectedIndices;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.w,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: options.length,
        separatorBuilder: (_, __) => SizedBox(width: 22.w),
        itemBuilder: (context, index) {
          final selected = selectedIndices.contains(index);
          return GestureDetector(
            onTap: () => onToggle(index),
            child: Center(
              child: Text(
                options[index].tag ?? '',
                style: TextStyle(
                  color: selected
                      ? AppColor.primaryButtonColor
                      : Colors.white.withOpacity(.5),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
