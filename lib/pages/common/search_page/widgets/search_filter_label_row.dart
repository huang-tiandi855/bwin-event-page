import 'package:comics_app/common/entities/home/hot_tag_models.dart'
    show HotTagItemModel;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'search_filter_multi_row.dart';
import 'search_filter_row.dart';

class SearchFilterLabelRow extends StatelessWidget {
  const SearchFilterLabelRow({
    super.key,
    required this.title,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final String title;
  final List<HotTagItemModel> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.h,
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 30.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF112326),
              borderRadius: BorderRadius.circular(4.w),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 28),
          Expanded(
            child: SearchFilterRow(
              options: options,
              selectedIndex: selectedIndex,
              onSelected: onSelected,
            ),
          ),
        ],
      ),
    );
  }
}

class SearchFilterMultiLabelRow extends StatelessWidget {
  const SearchFilterMultiLabelRow({
    super.key,
    required this.title,
    required this.options,
    required this.selectedIndices,
    required this.onToggle,
  });

  final String title;
  final List<HotTagItemModel> options;
  final Set<int> selectedIndices;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.h,
      child: Row(
        children: [
          Container(
            width: 66.w,
            height: 32.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF112326),
              borderRadius: BorderRadius.circular(4.w),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 28.w),
          Expanded(
            child: SearchFilterMultiRow(
              options: options,
              selectedIndices: selectedIndices,
              onToggle: onToggle,
            ),
          ),
        ],
      ),
    );
  }
}
