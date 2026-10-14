import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/generated/assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    super.key,
    this.text,
    this.padding,
  });

  final String? text;

  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            Assets.pngNoData,
            width: 200.w,
            height: 200.w,
          ),
          Text(
            text ?? '暂无内容',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColor.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
