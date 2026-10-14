import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/entities/module_detail_model/media_info_model_extension.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:comics_app/common/extension/int_extension.dart';

class SkitsCard extends StatelessWidget {
  const SkitsCard._({
    this.verticalCover = false,
    this.url,
    this.title,
    this.views,
    this.updatedDesc,
    this.titleColor,
    this.backgroundColor,
    this.onTap,
  });

  final bool verticalCover;
  final String? url;
  final String? title;

  final int? views;
  final String? updatedDesc;

  final Color? titleColor;
  final Color? backgroundColor;

  final void Function()? onTap;

  factory SkitsCard.fromMediaModel(
    AllMediaInfoModel model, {
    bool? verticalCover,
    Color? titleColor,
    Color? backgroundColor,
  }) {
    return SkitsCard._(
      verticalCover: verticalCover ?? !model.ifHorizontal,
      url: model.autoCover,
      title: model.title ?? '',
      updatedDesc:
          model.totalEpisode == null ? null : '章节${model.totalEpisode}话',
      views: model.countBrowse,
      titleColor: titleColor,
      backgroundColor: backgroundColor,
      onTap: model.navigateToSkits,
    );
  }

  double get aspectRatio {
    if (!verticalCover) {
      return 173 / 98;
    } else {
      return 111 / 162;
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = Stack(
      children: [
        Positioned.fill(
          child: CustomImage(
            url: url,
            borderRadius: BorderRadius.circular(9.r),
          ),
        ),
        Positioned(
          top: 8.w,
          left: 8.w,
          child: _buildViews(),
        ),
      ],
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: _buildVerticalLayout(image),
    );
  }

  Widget _buildVerticalLayout(Widget image) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(5.r),
          top: Radius.circular(10.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: aspectRatio,
            child: image,
          ),
          if (title?.isNotEmpty == true || updatedDesc?.isNotEmpty == true)
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 5.w,
                ).copyWith(
                  top: 4.w,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (title?.isNotEmpty == true) _buildTitle(),
                    2.verticalSpaceFromWidth,
                    _buildSubTitle(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitle({
    int maxLines = 1,
  }) {
    return Text(
      title!,
      style: TextStyle(
        fontSize: 12.sp,
        color: titleColor ?? AppColor.black,
        fontWeight: FontWeight.w600,
        height: 18 / 12,
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubTitle() {
    if (updatedDesc == null) {
      return Container();
    }
    return Text(
      updatedDesc!,
      style: TextStyle(
        fontSize: 10.sp,
        color: const Color(0xFF999999),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildViews() {
    if (views == null) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 2.w,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            Assets.svgIcPlay2,
            height: 10.w,
          ),
          2.horizontalSpace,
          Text(
            views!.humanizeFormat,
            style: TextStyle(
              fontSize: 10.sp,
              color: const Color(0xFFFFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}
