import 'dart:math';

import 'package:comics_app/common/entities/video_model/tags_model.dart';
import 'package:comics_app/common/entities/video_model/tags_model_extension.dart';
import 'package:comics_app/common/entities/video_model/video_model.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

enum VideoCardLayoutAxis {
  horizontal,
  vertical,
}

/// * [axis] 文字和图片布局方向
/// * [verticalCover] 是否是竖图
/// * [url] 图片地址
/// * [title] 标题
/// * [tags] 标签
/// * [views] 观看次数
/// * [permission] 付费类型
/// * [updatedDesc] 更新描述
/// * [updateStatus] 更新状态
class VideoCard extends StatelessWidget {
  const VideoCard._({
    this.axis = VideoCardLayoutAxis.vertical,
    this.verticalCover = false,
    this.url,
    this.title,
    this.permission,
    this.date,
    this.tags,
    this.views,
    this.updateDesc,
    this.titleColor,
    this.backgroundColor,
    this.onTap,
  });

  final VideoCardLayoutAxis axis;
  final bool verticalCover;
  final String? url;
  final String? title;
  final List<TagsModel>? tags;

  final int? views;
  final String? updateDesc;

  final int? permission;
  final DateTime? date;

  final Color? titleColor;
  final Color? backgroundColor;
  // final String? dateStr;
  final void Function()? onTap;

  factory VideoCard.fromVideoModel(
    VideoModel model, {
    bool? forceVerticalCover,
    Color? titleColor,
    Color? backgroundColor,
    VideoCardLayoutAxis axis = VideoCardLayoutAxis.vertical,
    List<VideoModel> shortVideoList = const [],
    void Function()? onTap,
  }) {
    return VideoCard._(
      axis: axis,
      verticalCover: forceVerticalCover ?? model.isVerticalCover,
      url: model.autoCover,
      title: model.title ?? '',
      tags: model.tags,
      permission: model.permission,
      date: model.reviewAt,
      titleColor: titleColor,
      backgroundColor: backgroundColor,
      views: 0,
      updateDesc: null,
      onTap: onTap ?? () => model.navigateTo(shortVideoList: shortVideoList),
    );
  }

  double get aspectRatio {
    if (!verticalCover) {
      return 173 / 98;
    } else {
      return 165 / 243;
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = Stack(
      children: [
        CustomImage(
          url: url,
          borderRadius: BorderRadius.circular(9.r),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: _buildPermissionType(),
        ),
        Positioned(
          bottom: 5.w,
          right: 5.w,
          child: _buildUpdateDesc(),
        ),
      ],
    );
    late Widget child;
    if (axis == VideoCardLayoutAxis.horizontal) {
      child = _buildHorizontalLayout(image);
    } else {
      child = _buildVerticalLayout(image);
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }

  Widget _buildHorizontalLayout(Widget image) {
    return Row(
      children: [
        AspectRatio(
          aspectRatio: aspectRatio,
          child: image,
        ),
        9.horizontalSpace,
        Expanded(
          child: SizedBox(
            height: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildTitle(maxLines: 2),
                10.verticalSpaceFromWidth,
                Flexible(child: _buildTags()),
                10.verticalSpaceFromWidth,
                _buildDate(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(Widget image) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColor.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(5.r),
          top: Radius.circular(10.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: aspectRatio,
            child: image,
          ),
          if (title?.isNotEmpty == true || tags?.isNotEmpty == true)
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title?.isNotEmpty == true) _buildTitle(),
                    2.verticalSpaceFromWidth,
                    Flexible(
                      child: SizedBox(
                        height: 10.sp * 16 / 10,
                        child: _buildTags(),
                      ),
                    ),
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

  Widget _buildTags() {
    if (tags?.isEmpty ?? true) {
      return Container();
    }
    return Wrap(
      spacing: 6.w,
      clipBehavior: Clip.hardEdge,
      children: List.generate(min(tags?.length ?? 0, !verticalCover ? 5 : 3), (index) {
        final e = tags![index];
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: e.navigateTo,
          child: Text(
            e.name ?? '',
            style: TextStyle(
              fontSize: 10.sp,
              color: const Color(0xFF999999),
              height: 16 / 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }

  // Widget _buildViews() {
  //   return Container(
  //     padding: EdgeInsets.symmetric(
  //       horizontal: 2.w,
  //     ),
  //     decoration: BoxDecoration(
  //       color: Colors.black.withOpacity(0.5),
  //       borderRadius: BorderRadius.circular(4.r),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         SvgPicture.asset(
  //           Assets.svgIcPlay2,
  //           height: 10.w,
  //         ),
  //         2.horizontalSpace,
  //         Text(
  //           views.toString(),
  //           style: TextStyle(
  //             fontSize: 10.sp,
  //             color: const Color(0xFFFFFFFF),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildPermissionType() {
    if (permission == null) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 6.w,
        vertical: 4.w,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        permissionText,
        style: TextStyle(
          fontSize: 10.sp,
          color: permission == 0
              ? const Color(0xFFDED0FF)
              : permission == 1
                  ? const Color(0xFFFFE229)
                  : const Color(0xFF56FAF6),
          fontWeight: FontWeight.w900,
          height: 13 / 10,
        ),
      ),
    );
  }

  String get permissionText {
    switch (permission) {
      case 1:
        return '金豆';
      case 2:
        return '免费';
      default:
        return 'VIP';
    }
  }

  // String get _updatedDesc {
  //   final regex = RegExp(r'(?<!·)\d+话');
  //   String desc = updatedDesc ?? '';
  //   // 使用正则表达式进行替换
  //   if (regex.hasMatch(desc)) {
  //     desc = desc.replaceFirst(regex, '·d+话');
  //   }

  //   return desc;
  // }

  Widget _buildUpdateDesc() {
    if (updateDesc == null) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 9.w,
        vertical: 2.w,
      ),
      decoration: ShapeDecoration(
        color: Colors.white.withOpacity(0.5),
        shape: const StadiumBorder(),
      ),
      child: Text(
        updateDesc!,
        style: TextStyle(
          fontSize: 10.sp,
          color: const Color(0xFF3E169D),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildDate() {
    if (date == null) {
      return Container();
    }
    return Text(
      '更新日期：${DateFormat('yyyy-MM-dd').format(date!)}',
      style: TextStyle(
        fontSize: 10.sp,
        color: const Color(0xFF999999),
      ),
    );
  }
}
