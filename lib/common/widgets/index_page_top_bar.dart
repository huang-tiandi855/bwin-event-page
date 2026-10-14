import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IndexPageTopBar extends StatelessWidget {
  const IndexPageTopBar({
    super.key,
    this.horizontalPadding = 16,
    this.searchHint = '搜索你感兴趣的内容',
    required this.onSearchTap,
    required this.onSignInTap,
    required this.onMenuTap,
  });

  final double horizontalPadding;
  final String searchHint;
  final VoidCallback onSearchTap;
  final VoidCallback onSignInTap;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 29.h,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
      margin: EdgeInsets.only(top: 21.w),
      child: Row(
        children: [
          AssetsGen.images.app.icAppLogo.image(height: 24.h),
          16.w.horizontalSpace,
          Expanded(child: _buildSearchField()),
          10.w.horizontalSpace,
          GestureDetector(
            onTap: onSignInTap,
            child:
                AssetsGen.images.circle.signIn.image(width: 24.w, height: 24.h),
          ),
          6.w.horizontalSpace,
          GestureDetector(
            onTap: onMenuTap,
            child: AssetsGen.images.home.icNavigation
                .image(width: 24.w, height: 24.h),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return GestureDetector(
      onTap: onSearchTap,
      child: Container(
        height: 29.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.15),
          borderRadius: BorderRadius.circular(20.w),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                searchHint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(.5),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            AssetsGen.images.circle.search.image(width: 20.w, height: 24.h),
          ],
        ),
      ),
    );
  }
}
