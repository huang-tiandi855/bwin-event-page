import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/common/widgets/item/media_ranking_item_common.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 影片排行榜列表项（横版 16:9 封面 + 标题 + 播放量 / 时长 + 星标数据）。
///
/// 数据字段对齐 [MediaVideoModel]。
class MovieRankingItem extends StatelessWidget {
  const MovieRankingItem({
    super.key,
    required this.model,
    required this.rank,
    this.onTap,
  });

  final MediaVideoModel model;
  final int rank;
  final VoidCallback? onTap;

  static final Color _cardBg = Colors.white.withOpacity(.05);
  static final Color _borderColor = Colors.white.withOpacity(.15);

  @override
  Widget build(BuildContext context) {
    final double thumbW = 165.w;
    final double thumbH = thumbW * 98 / 165;
    final String coverUrl = mediaRankingCoverUrl(model, portrait: false) ?? '';
    final String title = model.title ?? '';
    final String play = mediaRankingPlayCount(model);
    final String? duration = mediaRankingDuration(model);
    final String collectText = mediaRankingCollectsText(model);

    final Widget card = Stack(
      children: [
        Container(
          height: 100.h,
          margin: EdgeInsets.only(top: 8.h),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: _borderColor, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: (10 + 165 + 12).w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColor.primaryText,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                    6.h.verticalSpace,
                    Row(
                      children: [
                        Icon(
                          Icons.star_outline,
                          size: 16.w,
                          color: AppColor.hintTextColor,
                        ),
                        4.w.horizontalSpace,
                        Text(
                          collectText,
                          style: TextStyle(
                            color: AppColor.hintTextColor,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 10.w,
          child: SizedBox(
            width: thumbW,
            height: thumbH,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: CustomImage(
                    url: coverUrl,
                    width: thumbW,
                    height: thumbH,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4.h,
                  left: 4.w,
                  child: MediaRankingRankBadge(rank: rank),
                ),
                Positioned(
                  left: 4.w,
                  right: 4.w,
                  bottom: 4.h,
                  child: Row(
                    children: [
                      mediaRankingMediaPill(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AssetsGen.images.home.icCoverPlayer
                                .image(width: 8.w, height: 8.h),
                            2.w.horizontalSpace,
                            Text(
                              play,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (duration != null)
                        mediaRankingMediaPill(
                          Text(
                            duration,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: card,
      ),
    );
  }
}
