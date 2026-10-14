import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/common/widgets/item/media_ranking_item_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 动漫排行榜列表项（竖版海报与右侧信息区叠压 + 角标集数 / 图集数）。
///
/// 数据字段对齐 [MediaVideoModel]。
class AnimeRankingItem extends StatelessWidget {
  const AnimeRankingItem({
    super.key,
    required this.model,
    required this.rank,
    this.onTap,
  });

  final MediaVideoModel model;
  final int rank;
  final VoidCallback? onTap;

  static const Color _panelBg = Color(0xFF1A1F26);
  static const Color _borderColor = Color(0xFF2E3238);

  @override
  Widget build(BuildContext context) {
    final double posterW = 94.w;
    final double posterH = 132.h;
    final String coverUrl = mediaRankingCoverUrl(model, portrait: true) ?? '';
    final String title = model.title ?? '';
    final String subtitle = mediaRankingMetaSubtitle(model);
    final String? serial = mediaRankingSerialLabel(model);

    /// 海报压在信息区之上：信息区左缘与海报水平重叠约 [overlap]。
    final double overlap = 36.w;

    final Widget card = SizedBox(
      height: posterH + 16.h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: overlap,
            right: 0,
            top: 8.h,
            bottom: 8.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _panelBg,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _borderColor, width: 1),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  posterW - overlap + 10.w,
                  10.h,
                  12.w,
                  10.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColor.primaryText,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      6.h.verticalSpace,
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColor.hintTextColor,
                          fontSize: 12.sp,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 8.h,
            child: SizedBox(
              width: posterW,
              height: posterH,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: CustomImage(
                      url: coverUrl,
                      width: posterW,
                      height: posterH,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4.h,
                    left: 4.w,
                    child: MediaRankingRankBadge(rank: rank),
                  ),
                  if (serial != null)
                    Positioned(
                      right: 4.w,
                      bottom: 4.h,
                      child: mediaRankingMediaPill(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 11.w,
                              color: Colors.white,
                            ),
                            3.w.horizontalSpace,
                            Text(
                              serial,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
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
