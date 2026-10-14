import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/utils/date_time_util.dart';
import 'package:comics_app/common/utils/text_util.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 排行榜封面：竖版海报优先或横版封面优先（与 [MediaCoverItem] 逻辑对齐）。
String? mediaRankingCoverUrl(
  MediaVideoModel m, {
  required bool portrait,
}) {
  final HomeMediaVodPicInfoModel? v = m.vodPicInfo;
  String? pick(String? s) {
    final t = s?.trim();
    return (t != null && t.isNotEmpty) ? t : null;
  }

  if (portrait) {
    return pick(m.vodPic) ??
        pick(v?.verticalLarge) ??
        pick(v?.verticalSmall) ??
        pick(v?.horizontalLarge) ??
        pick(v?.horizontalSmall);
  }
  return pick(m.vodPic) ??
      pick(v?.horizontalSmall) ??
      pick(v?.horizontalLarge) ??
      pick(v?.verticalLarge);
}

String mediaRankingPlayCount(MediaVideoModel m) {
  final n = m.readNumber ?? 0;
  return getShowCountStr(n < 0 ? 0 : n);
}

String? mediaRankingDuration(MediaVideoModel m) {
  final d = m.vodDuration;
  if (d == null || d <= 0) return null;
  final s = buildHHMMSS(d);
  if (s.isEmpty || s == '00:00') return null;
  return s;
}

String? mediaRankingFirstTag(MediaVideoModel m) {
  final tags = m.tags;
  if (tags == null) return null;
  if (tags is String) {
    final t = tags.trim();
    return t.isEmpty ? null : t;
  }
  if (tags is List && tags.isNotEmpty) {
    final first = tags.first;
    if (first is Map) {
      final n = first['name'] ?? first['tag'] ?? first['title'];
      if (n != null) {
        final t = n.toString().trim();
        if (t.isNotEmpty) return t;
      }
    } else if (first != null) {
      final t = first.toString().trim();
      if (t.isNotEmpty) return t;
    }
  }
  return null;
}

/// 影片 / 动漫信息区副标题：年份 · 地区 · 首标签。
String mediaRankingMetaSubtitle(MediaVideoModel m) {
  final parts = <String>[];
  if (m.vodYear != null) {
    final y = m.vodYear.toString().trim();
    if (y.isNotEmpty) parts.add(y);
  }
  if (m.vodArea != null) {
    final a = m.vodArea.toString().trim();
    if (a.isNotEmpty) parts.add(a);
  }
  final tag = mediaRankingFirstTag(m);
  if (tag != null) parts.add(tag);
  return parts.join(' · ');
}

/// 角标区：连载数 / 图集数等（接口字段 [MediaVideoModel.vodSerialNumber]）。
String? mediaRankingSerialLabel(MediaVideoModel m) {
  final v = m.vodSerialNumber;
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

/// 星标旁数字：收藏数
String mediaRankingCollectsText(MediaVideoModel m) {
  final n = m.collects ?? 0;
  return getShowCountStr(n < 0 ? 0 : n);
}

/// 第 1–5 名使用首页角标资源 [AssetsGen.images.home.icRankOne] … [icRankFive]，其余为数字。
class MediaRankingRankBadge extends StatelessWidget {
  const MediaRankingRankBadge({
    super.key,
    required this.rank,
  });

  final int rank;

  static const double _kBadgeSize = 28;

  @override
  Widget build(BuildContext context) {
    final double s = _kBadgeSize.w;
    switch (rank) {
      case 1:
        return AssetsGen.images.home.icRankOne.image(width: s, height: s);
      case 2:
        return AssetsGen.images.home.icRankTwo.image(width: s, height: s);
      case 3:
        return AssetsGen.images.home.icRankThree.image(width: s, height: s);
      case 4:
        return AssetsGen.images.home.icRankFour.image(width: s, height: s);
      case 5:
        return AssetsGen.images.home.icRankFive.image(width: s, height: s);
      default:
        return const SizedBox.shrink();
    }
  }
}

/// 封面左下 / 右下半透明胶囊（与 [MediaCoverItem] 一致风格）。
Widget mediaRankingMediaPill(Widget child) {
  return Container(
    height: 16.h,
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.45),
      borderRadius: BorderRadius.circular(100),
    ),
    padding: EdgeInsets.symmetric(horizontal: 5.w),
    alignment: Alignment.center,
    child: child,
  );
}
