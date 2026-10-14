import 'package:comics_app/short_video/base/abs_short_video_play_logic.dart';
import 'package:comics_app/common/entities/video_model/ishort_video_model.dart';
import 'package:comics_app/common/extension/int_extension.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/values/address.dart';
import 'package:comics_app/common/widgets/common_dialog/line_switch_bottom_sheet.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/pages/video_page/player_code_manage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ShortVideoInfoView<T extends AbsShortVideoPlayLogic>
    extends StatelessWidget {
  const ShortVideoInfoView({
    super.key,
    required this.videoInfo,
    required this.tag,
  });

  final ShortVideoModel videoInfo;
  final String tag;

  T get logic => Get.find<T>(tag: tag);

  AbsShortVideoPlayState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<T>(
      id: 'visible',
      tag: tag,
      builder: (_) {
        if (state.visible) {
          return Container();
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductPrice(),
            8.verticalSpaceFromWidth,
            _buildAuthInfoView(context),
            16.verticalSpaceFromWidth,
            Text(
              videoInfo.title,
              maxLines: 2,
              style: TextStyle(
                height: 18 / 12,
                fontSize: 12.sp,
                color: AppColor.white,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w600,
              ),
            ),
            22.verticalSpaceFromWidth,
            _buildTags(),
          ],
        );
      },
    );
  }

  Widget _buildAuthInfoView(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: 100.w),
          child: Text(
            '@${videoInfo.authorName ?? "未知"}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.white.withOpacity(.5),
            ),
          ),
        ),
        17.w.horizontalSpace,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AssetsGen.images.video.icShortViews
                .image(width: 20.w, height: 20.h),
            2.w.horizontalSpace,
            Text(
              videoInfo.playCount.humanizeFormat,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(.5),
              ),
            )
          ],
        ),
        17.w.horizontalSpace,
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            showLineSwitchBottomSheet(
              context: context,
              title: '短视频线路',
              lines: lineSwitchItemsFromPlayLines(Address.h5PlayLines ?? []),
              selectedLine: Address.h5PlayLine,
              onSelected: (item, _) {
                Address.h5PlayLine = item.line;
                logic.switchLine();
              },
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AssetsGen.images.video.icShortLines
                    .image(width: 20.w, height: 20.h),
                2.w.horizontalSpace,
                Text(
                  '线路',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 4.w,
      runSpacing: 4.w,
      clipBehavior: Clip.hardEdge,
      children: List.generate(videoInfo.tags.length, (index) {
        final e = videoInfo.tags[index];
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => logic.onTapTag(e),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.05),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              '#${e.name ?? ''}',
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColor.white,
                height: 20 / 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProductPrice() {
    if (videoInfo.needPermission == 0 || videoInfo.needPermission == 1) {
      final text = _buildProductPriceText();
      if (text.isEmpty) return const SizedBox.shrink();

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (videoInfo.shouldAutoShowAuthOverlay) {
            logic.showAuthOverlay(videoInfo);
            return;
          }
          if (videoInfo.needPermission == 1) {
            logic.showGoldOverlay(videoInfo);
            return;
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            gradient: const LinearGradient(
              colors: [
                Color(0XFFFFE273),
                Color(0XFFFACD1A),
              ],
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 5.w,
          ),
          child: Text(
            text,
            style: TextStyle(
                color: const Color(0XFF7C0000),
                fontSize: 12.sp,
                fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return Container();
  }

  String _buildProductPriceText() {
    switch (videoInfo.playerCode) {
      case PlayerCodeManage.nonMember:
        return '开通会员 畅享完整内容';
      case PlayerCodeManage.noPay:
        return '需要购买后观看';
      default:
        return '';
    }
  }
}
