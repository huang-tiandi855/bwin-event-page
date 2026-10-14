import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/entities/video_model/short_recommend_follow_model.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/date_time_util.dart';
import 'package:comics_app/common/utils/text_util.dart';
import 'package:comics_app/common/utils/utils.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/common/widgets/item/home_video_list_widgets.dart';
import 'package:comics_app/common/widgets/item/meida_cover_item.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'short_video_skits_follow_tab_logic.dart';
import 'short_video_skits_follow_tab_state.dart';

class ShortVideoSkitsFollowTabView extends StatelessWidget {
  const ShortVideoSkitsFollowTabView({super.key});

  String get tag => 'follow';

  ShortVideoSkitsFollowTabLogic get logic => Get.find(tag: tag);
  ShortVideoSkitsFollowTabState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    Get.put(
      ShortVideoSkitsFollowTabLogic(),
      tag: tag,
    );
    return PullRefreshView(
      controller: state.pullRefreshController,
      onRefresh: logic.onRefresh,
      onLoading: logic.onLoad,
      retryOnTap: logic.onRefresh,
      child: CustomScrollView(
        slivers: [
          GetBuilder<ShortVideoSkitsFollowTabLogic>(
            tag: tag,
            id: 'list',
            builder: (_) {
              if (state.isShowRecommend) {
                return _RecommendSliver(logic: logic, state: state, tag: tag);
              }
              return getFourGrid(
                state.mediaList ?? [],
                sliver: true,
                sliverPadding: EdgeInsets.symmetric(horizontal: 16.w),
                onItemClick: logic.navigateToPlayPage,
                displayType: MediaCoverDisplayType.shortvideo,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 推荐作者列表：每张卡片 = 作者头像 + 关注按钮 + 横向 3 个代表作封面。
class _RecommendSliver extends StatelessWidget {
  const _RecommendSliver({
    required this.logic,
    required this.state,
    required this.tag,
  });

  final ShortVideoSkitsFollowTabLogic logic;
  final ShortVideoSkitsFollowTabState state;
  final String tag;

  @override
  Widget build(BuildContext context) {
    final List<ShortRecommendFollowItemModel> list = state.recommendList;
    return SliverList.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (_, i) {
        return _RecommendAuthorCard(
          item: list[i],
          logic: logic,
          tag: tag,
        );
      },
    );
  }
}

class _RecommendAuthorCard extends StatelessWidget {
  const _RecommendAuthorCard({
    required this.item,
    required this.logic,
    required this.tag,
  });

  final ShortRecommendFollowItemModel item;
  final ShortVideoSkitsFollowTabLogic logic;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AuthorHeader(item: item, logic: logic, tag: tag),
        10.h.verticalSpace,
        _AuthorVideosRow(item: item, logic: logic),
      ],
    );
  }
}

class _AuthorHeader extends StatelessWidget {
  const _AuthorHeader({
    required this.item,
    required this.logic,
    required this.tag,
  });

  final ShortRecommendFollowItemModel item;
  final ShortVideoSkitsFollowTabLogic logic;
  final String tag;

  @override
  Widget build(BuildContext context) {
    final RecommendFollowAuthorModel? author = item.author;
    final int uid = author?.id ?? item.uid ?? 0;
    final String avatar = author?.avatar?.trim() ?? '';
    final String name = author?.nickName?.trim().isNotEmpty == true
        ? author!.nickName!.trim()
        : '匿名作者';
    final int fans = author?.fansNum ?? 0;
    final int works = (author?.vnum ?? 0) + (author?.pnum ?? 0);

    return clickButton(
      onTap: () => AppNavigator.to.go(
        AppRoutes.USER_CENTER,
        arguments: <String, dynamic>{
          'uid': uid,
          'author': <String, dynamic>{
            'id': author?.id,
            'avatar': avatar,
            'nickName': name,
            'follow': author?.follow,
            'fansNum': fans,
            'vnum': author?.vnum,
            'pnum': author?.pnum,
          },
        },
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: CustomImage(
                url: avatar,
                width: 44.w,
                height: 44.w,
                fit: BoxFit.cover,
              ),
            ),
            10.w.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  4.h.verticalSpace,
                  Text(
                    '${getShowCountStr(fans)}粉丝   ${getShowCountStr(works)}作品',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.5),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            10.w.horizontalSpace,
            _FollowButton(item: item, uid: uid, logic: logic, tag: tag),
          ],
        ),
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({
    required this.item,
    required this.uid,
    required this.logic,
    required this.tag,
  });

  final ShortRecommendFollowItemModel item;
  final int uid;
  final ShortVideoSkitsFollowTabLogic logic;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShortVideoSkitsFollowTabLogic>(
      tag: tag,
      id: 'follow_$uid',
      builder: (_) {
        final bool followed = item.author?.follow == true;
        final bool pending = logic.isFollowPending(uid);
        // 三态文案：pending 优先；其次按是否已关注切换。
        final String label = pending ? '加载中' : (followed ? '已关注' : '+ 关注');
        // pending / 已关注 共用低对比灰底；未关注用主品红。
        final Color bgColor = (pending || followed)
            ? Colors.white.withOpacity(.12)
            : AppColor.primaryButtonColor;
        final Color textColor =
            (pending || followed) ? Colors.white.withOpacity(.6) : Colors.white;
        return getCommonButton(
          label,
          width: 76.w,
          height: 32.h,
          radius: 100.r,
          color: bgColor,
          // pending 期间 onClick = null，既视觉灰化（已通过 textColor）也拦截重复点击。
          onClick: pending ? null : () => logic.toggleFollow(item),
          textStyle: TextStyle(
            color: textColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        );
      },
    );
  }
}

/// 作者卡下的横向代表作列表：固定 108×150 封面 + 10px 间距，横滑列表展示全部。
class _AuthorVideosRow extends StatelessWidget {
  const _AuthorVideosRow({
    required this.item,
    required this.logic,
  });

  final ShortRecommendFollowItemModel item;
  final ShortVideoSkitsFollowTabLogic logic;

  static const double _coverWidth = 108;
  static const double _coverHeight = 150;
  static const double _itemSpacing = 10;

  @override
  Widget build(BuildContext context) {
    final List<MediaVideoModel> videos = item.videos;
    if (videos.isEmpty) return const SizedBox.shrink();

    final double width = _coverWidth.w;
    final double height = _coverHeight.w;
    final double spacing = _itemSpacing.w;

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const BouncingScrollPhysics(),
        itemCount: videos.length,
        separatorBuilder: (_, __) => SizedBox(width: spacing),
        itemBuilder: (context, index) {
          return SizedBox(
            width: width,
            height: height,
            child: _VideoCoverThumb(
              model: videos[index],
              onTap: () => logic.navigateToRecommendPlay(item, index),
            ),
          );
        },
      ),
    );
  }
}

/// 竖版短视频封面 + 左下角播放量 + 右下角时长。比 [MediaCoverItem] 简化：
/// 不显示标题、不显示底栏，仅做封面缩略图。
class _VideoCoverThumb extends StatelessWidget {
  const _VideoCoverThumb({
    required this.model,
    required this.onTap,
  });

  final MediaVideoModel model;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String? cover = _pickCover(model);
    final int play = model.readNumber ?? 0;
    final int? duration = model.vodDuration;
    final String? durationText =
        (duration == null || duration <= 0) ? null : buildHHMMSS(duration);

    // 尺寸完全跟随外层 SizedBox（由 [_AuthorVideosRow] 给定 108×150）。
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (cover != null && cover.isNotEmpty)
              CustomImage(
                url: cover,
                fit: BoxFit.cover,
              )
            else
              Container(color: const Color(0xFF2C2C2C)),
            // const Positioned.fill(
            //   child: DecoratedBox(
            //     decoration: BoxDecoration(
            //       gradient: LinearGradient(
            //         begin: Alignment.center,
            //         end: Alignment.bottomCenter,
            //         colors: [
            //           Colors.transparent,
            //           Color(0x99000000),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            Positioned(
              bottom: 6.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                width: 108,
                child: Row(
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AssetsGen.images.home.shortCoverPlay
                              .image(width: 7.w, height: 7.w),
                          2.w.horizontalSpace,
                          Text(
                            getShowCountStr(play < 0 ? 0 : play),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (durationText != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 2.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          durationText,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 按短视频偏好的封面顺序拣一个非空 URL。与 [MediaCoverItem] 的逻辑保持一致。
  String? _pickCover(MediaVideoModel m) {
    String? pick(String? s) {
      final t = s?.trim();
      return (t != null && t.isNotEmpty) ? t : null;
    }

    final v = m.vodPicInfo;
    return pick(m.vodPic) ??
        pick(v?.verticalLarge) ??
        pick(v?.verticalSmall) ??
        pick(v?.horizontalLarge) ??
        pick(v?.horizontalSmall);
  }
}
