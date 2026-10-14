import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignRewardCell extends StatelessWidget {
  const SignRewardCell({
    Key? key,
    required this.label,
    this.rewardType,
    this.dayLabel,
    this.iconUrl,
    this.checked = false,
    this.locked = false,
    this.memberStyle = false,
    this.showGoldBorder = false,
    this.backgroundOpacity = .35,
    this.checkedOpacity = .45,
    this.labelAboveCheckedOverlay = true,
  }) : super(key: key);

  final String label;
  final String? rewardType;
  final String? dayLabel;
  final bool checked;
  final bool locked;
  final String? iconUrl;
  final bool memberStyle;
  final bool showGoldBorder;
  final double backgroundOpacity;
  final double checkedOpacity;
  final bool labelAboveCheckedOverlay;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 44.w,
          height: 44.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AssetsGen.images.signin.icSigninPrizeBg.image(
                width: 44.w,
                height: 44.w,
                fit: BoxFit.contain,
              ),
              CustomImage(
                url: iconUrl ?? '',
                width: 35.w,
                height: 35.w,
              ),
              if (!labelAboveCheckedOverlay) _buildLabel(),
              CustomImage(
                url: iconUrl ?? '',
                width: 35.w,
                height: 35.w,
              ),
              if (checked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(checkedOpacity),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: AssetsGen.images.signin.icSignedIn.image(
                        width: 22.w,
                        height: 22.w,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                )
              else if (locked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(checkedOpacity),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: AssetsGen.images.signin.icSigninVipLock.image(
                        width: 18.w,
                        height: 18.w,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              if (labelAboveCheckedOverlay) _buildLabel(),
            ],
          ),
        ),
        if (dayLabel != null && dayLabel!.isNotEmpty) ...[
          1.h.verticalSpace,
          Text(
            dayLabel!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(.5),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLabel() {
    return Positioned(
      bottom: showGoldBorder ? 3.h : 2.h,
      left: 2.w,
      right: 2.w,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 7.sp,
          fontWeight: FontWeight.w600,
          color: memberStyle
              ? AppColor.primaryYellowColor
              : Colors.white.withOpacity(showGoldBorder ? .9 : .8),
        ),
      ),
    );
  }
}
