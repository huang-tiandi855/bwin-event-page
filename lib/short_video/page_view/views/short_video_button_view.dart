import 'package:comics_app/short_video/base/abs_short_video_play_logic.dart';
import 'package:comics_app/common/entities/video_model/ishort_video_model.dart';
import 'package:comics_app/common/extension/int_extension.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class ShortVideoButtonView<T extends AbsShortVideoPlayLogic>
    extends StatelessWidget {
  const ShortVideoButtonView({
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
          return Container(
            width: 44.w,
            alignment: Alignment.bottomCenter,
            child: _buildButton(
              icon: AssetsGen.images.video.icShortEyeClose,
              onTap: () {
                logic.onTapVisible();
              },
            ),
          );
        }
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: Column(
            children: [
              _buildAvatar(),
              20.verticalSpaceFromWidth,
              GetBuilder<T>(
                id: 'like_${videoInfo.id}',
                tag: tag,
                builder: (_) {
                  return _buildButton(
                    icon: AssetsGen.images.video.icShortLike,
                    iconColor:
                        videoInfo.hasLiked ? const Color(0xFFF92B6C) : null,
                    text: videoInfo.likeCount.humanizeFormat,
                    onTap: () {
                      logic.onTapLike(videoInfo);
                    },
                  );
                },
              ),
              20.verticalSpaceFromWidth,
              // _buildButton(
              //   icon: Assets.svgIcVideoReward,
              //   text: '打赏',
              //   onTap: () {
              //     logic.onTapReward(videoInfo);
              //   },
              // ),
              // 20.verticalSpaceFromWidth,
              GetBuilder<T>(
                id: 'collect_${videoInfo.id}',
                tag: tag,
                builder: (_) {
                  return _buildButton(
                    icon: AssetsGen.images.video.icShortCollect,
                    iconColor:
                        videoInfo.hasCollected ? const Color(0xFFF92B6C) : null,
                    text: videoInfo.collectCount.humanizeFormat,
                    onTap: () {
                      logic.onTapCollect(videoInfo);
                    },
                  );
                },
              ),
              20.verticalSpaceFromWidth,
              GetBuilder<T>(
                id: 'comment_${videoInfo.id}',
                tag: tag,
                builder: (_) {
                  return _buildButton(
                    icon: AssetsGen.images.video.icShortComment,
                    text: videoInfo.commentCount > 0
                        ? videoInfo.commentCount.humanizeFormat
                        : '评论',
                    onTap: () {
                      logic.onTapComment(videoInfo);
                    },
                  );
                },
              ),
              20.verticalSpaceFromWidth,
              _buildButton(
                icon: AssetsGen.images.video.icShortShare,
                text: '分享',
                onTap: () {
                  logic.onTapShare(videoInfo);
                },
              ),
              20.verticalSpaceFromWidth,
              // SwitchLineButton(
              //   buttonBuilder: (BuildContext context) {
              //     return _buildButton(
              //       icon: Assets.svgIcVideoLine,
              //       text: '线路',
              //     );
              //   },
              //   callback: (p0) {
              //     logic.switchLine();
              //   },
              // ),
              // 20.verticalSpaceFromWidth,
              _buildButton(
                icon: AssetsGen.images.video.icShortEye,
                onTap: () {
                  logic.onTapVisible();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButton({
    required AssetGenImage icon,
    Color? iconColor,
    String? text,
    void Function()? onTap,
  }) {
    // 点赞 / 收藏 / 评论 / 分享 / 可见切换都走这里，一律启用 clickButton 防抖。
    return clickButton(
      onTap: onTap,
      openLimit: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon.image(width: 18.w, height: 18.h, color: iconColor),
          if (text?.isNotEmpty == true)
            Container(
              margin: EdgeInsets.only(top: 2.h),
              child: Text(
                text!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColor.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 50.w,
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: () {
              logic.navigateToPublisher(videoInfo);
            },
            child: SizedBox(
              width: 40.w,
              height: 40.w,
              child: CustomImage(
                url: videoInfo.authorAvatar ?? "",
                borderRadius: BorderRadius.circular(22.w),
              ),
            ),
          ),
        ),
        GetBuilder<T>(
          id: 'follow_${videoInfo.id}',
          tag: tag,
          builder: (logic) {
            bool hasFollowed = videoInfo.hasFollowed;
            return Positioned(
              left: 0,
              bottom: 0,
              child: clickButton(
                onTap: () {
                  logic.onTapFollow(videoInfo);
                },
                openLimit: true,
                child: Container(
                  alignment: Alignment.center,
                  width: 44.w,
                  child: SvgPicture.asset(
                    hasFollowed ? Assets.svgIcFollowed : Assets.svgIcFollow,
                    width: 20.w,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
