import 'package:comics_app/common/entities/home/hot_tag_models.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchFilterRow extends StatelessWidget {
  const SearchFilterRow({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<HotTagItemModel> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.w,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 22),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
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
