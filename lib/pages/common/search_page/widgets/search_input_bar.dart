import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchInputBar extends StatefulWidget {
  const SearchInputBar({
    super.key,
    required this.controller,
    required this.onSearch,
    this.height,
    this.horizontalPadding,
    this.backgroundColor,
    this.borderRadius,
    this.icon,
    this.hintText = '搜索感兴趣的内容',
    this.textStyle,
    this.hintStyle,
    this.buttonWidth,
    this.buttonHeight,
    this.buttonTextStyle,
  });

  final TextEditingController controller;
  final Future<void> Function(String text) onSearch;
  final double? height;
  final EdgeInsetsGeometry? horizontalPadding;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final Widget? icon;
  final String hintText;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final double? buttonWidth;
  final double? buttonHeight;
  final TextStyle? buttonTextStyle;

  @override
  State<SearchInputBar> createState() => _SearchInputBarState();
}

class _SearchInputBarState extends State<SearchInputBar> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 40.h,
      padding:
          widget.horizontalPadding ?? EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white.withOpacity(.15),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(100.r),
        border: _focusNode.hasFocus
            ? Border.all(color: AppColor.primaryButtonColor, width: 1.w)
            : null,
      ),
      child: Row(
        children: [
          widget.icon ??
              AssetsGen.images.circle.search.image(width: 25.w, height: 25.h),
          6.w.horizontalSpace,
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              controller: widget.controller,
              cursorColor: Colors.white,
              style: widget.textStyle ??
                  TextStyle(color: Colors.white, fontSize: 14.sp),
              textInputAction: TextInputAction.search,
              onSubmitted: _handleSearch,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: widget.hintStyle ??
                    TextStyle(
                      color: Colors.white.withOpacity(.5),
                      fontSize: 14.sp,
                    ),
              ),
            ),
          ),
          getCommonButton('搜索',
              width: widget.buttonWidth ?? 60.w,
              height: widget.buttonHeight ?? 24.h,
              radius: 100.r,
              color: AppColor.primaryButtonColor,
              onClick: () => _handleSearch(widget.controller.text),
              textStyle: widget.buttonTextStyle ??
                  TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  )),
        ],
      ),
    );
  }

  Future<void> _handleSearch(String text) async {
    await widget.onSearch(text);
  }
}
