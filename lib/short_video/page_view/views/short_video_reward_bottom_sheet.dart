import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/widgets/gradient_border_button.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/style/picker_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ShortVideoRewardBottomSheet extends StatelessWidget {
  const ShortVideoRewardBottomSheet(
      {super.key, this.onConfirm, this.title, this.openCustom, this.rightTopWidget, this.bottomWidget});

  final void Function(int)? onConfirm;
  final String? title;
  final void Function(BuildContext context)? openCustom;
  final Widget? rightTopWidget;
  final Widget? bottomWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(8.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          12.verticalSpaceFromWidth,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  title ?? '选择金额',
                  style: TextStyle(
                    color: AppColor.c333333,
                    fontFamily: 'Dream',
                    fontWeight: FontWeight.w900,
                    fontSize: 16.sp,
                  ),
                ),
                const Spacer(),
                if (rightTopWidget != null) rightTopWidget!
              ],
            ),
          ),
          38.verticalSpaceFromWidth,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: [
                _buildItem(text: '10'),
                const Spacer(),
                _buildItem(text: '20'),
                const Spacer(),
                _buildItem(text: '30'),
                const Spacer(),
                _buildItem(text: '45'),
                const Spacer(),
                _buildItem(text: '60'),
                const Spacer(),
                GradientBorderButton(
                  height: 40.w,
                  text: '自定义',
                  activated: true,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  onTap: openCustom != null ? () => openCustom!.call(context) : _showCustomAmount,
                ),
              ],
            ),
          ),
          if (bottomWidget != null) bottomWidget!,
          40.verticalSpaceFromWidth,
        ],
      ),
    );
  }

  Widget _buildItem({
    required String text,
  }) {
    return GradientBorderButton(
      width: 40.w,
      height: 40.w,
      text: text,
      activated: true,
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
      onTap: () {
        onConfirm?.call(int.parse(text));
      },
    );
  }

  void _showCustomAmount() {
    return Pickers.showSinglePicker(
      Get.overlayContext!,
      data: List.generate(100, (index) {
        return '${index + 1}';
      }),
      onCancel: (isCancel) {},
      onConfirm: (data, position) {
        onConfirm?.call(int.parse(data));
      },
      pickerStyle: PickerStyle(
        backgroundColor: AppColor.white,
        cancelButton: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            '取消',
            style: TextStyle(
              color: AppColor.c999999,
              fontSize: 15.sp,
            ),
          ),
        ),
        commitButton: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            '完成',
            style: TextStyle(
              color: AppColor.c333333,
              fontSize: 15.sp,
            ),
          ),
        ),
        menuHeight: 44.w,
        headDecoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(8.r),
          ),
        ),
        textSize: 18.sp,
        textColor: AppColor.c333333,
      ),
    );
  }
}
