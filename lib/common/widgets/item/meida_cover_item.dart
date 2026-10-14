import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/utils/date_time_util.dart';
import 'package:comics_app/common/utils/text_util.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 视频封面展示形态（与设计稿三种样式对应）。
enum MediaCoverDisplayType {
  /// 竖版宫格：约 3:4，标题单行省略，底部左播放量 / 右时长。
  portrait,

  /// 横版宫格：16:9，标题至多两行，底部信息同上。
  landscape,

  /// 竖排列表：与横版一致，使用竖向卡片 [_buildVerticalCard]（上封面、下标题与底部信息）。
  list,

  /// 短视频封面
  shortvideo,

  /// 横排列表：大横排,横版封面
  bighorizontallist,

  /// 横排列表：小横排，横版封面
  smallhorizontallist,

  /// 横排列表：小横排，竖版版封面
  smallverticallist,
}

String? _coverUrlFromModel(MediaVideoModel m, MediaCoverDisplayType type) {
  final HomeMediaVodPicInfoModel? v = m.vodPicInfo;
  String? pick(String? s) {
    final t = s?.trim();
    return (t != null && t.isNotEmpty) ? t : null;
  }

  if (type == MediaCoverDisplayType.portrait) {
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

/// 仅解析 [MediaVideoModel.tags]：首项文案用于底栏左侧（单行省略）。
String _tagLabelFromModel(MediaVideoModel m) {
  final tags = m.tags;
  if (tags == null) return '';

  if (tags is String) {
    final s = tags.trim();
    return s.isEmpty ? '' : s;
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

  return '';
}

/// 通用视频封面卡片（文案与封面取自 [MediaVideoModel]）。
class MediaCoverItem extends StatelessWidget {
  const MediaCoverItem({
    Key? key,
    required this.displayType,
    required this.model,
    this.onTap,
    this.borderRadius,
    this.titleColor = Colors.white,
    this.secondaryColor = AppColor.hintTextColor,
    this.placeholderColor = const Color(0xFF2C2C2C),
    this.collectLabel = '收藏',
  }) : super(key: key);

  final MediaCoverDisplayType displayType;
  final MediaVideoModel model;

  final VoidCallback? onTap;

  final double? borderRadius;
  final Color titleColor;
  final Color secondaryColor;
  final Color placeholderColor;

  final String collectLabel;

  double get _radius => borderRadius ?? 8.w;

  String get _title => model.title ?? '';

  String? get _coverUrl => _coverUrlFromModel(model, displayType);

  String get _playCountText {
    final n = model.readNumber ?? 0;
    final safe = n < 0 ? 0 : n;
    return getShowCountStr(safe);
  }

  String? get _durationText {
    final d = model.vodDuration;
    if (d == null || d <= 0) return null;
    return buildHHMMSS(d);
  }

  String get _categoryTag => _tagLabelFromModel(model);

  /// 底栏「收藏」数量。
  String get _collectCountText {
    final n = model.collects ?? 0;
    final safe = n < 0 ? 0 : n;
    return getShowCountStr(safe);
  }

  double get _imageAspectRatio {
    switch (displayType) {
      case MediaCoverDisplayType.portrait:
        return 108 / 150;
      case MediaCoverDisplayType.landscape:
        return 165 / 98;
      case MediaCoverDisplayType.list:
        return 343 / 180;
      case MediaCoverDisplayType.shortvideo:
        return 166 / 244;
      case MediaCoverDisplayType.bighorizontallist:
        return 300 / 169;
      case MediaCoverDisplayType.smallhorizontallist:
        return 167 / 93;
      case MediaCoverDisplayType.smallverticallist:
        return 134 / 178;
    }
  }

  int get _titleMaxLines {
    switch (displayType) {
      case MediaCoverDisplayType.portrait:
        return 1;
      case MediaCoverDisplayType.landscape:
        return 2;
      case MediaCoverDisplayType.list:
        return 1;
      case MediaCoverDisplayType.shortvideo:
        return 2;
      case MediaCoverDisplayType.bighorizontallist:
        return 1;
      case MediaCoverDisplayType.smallhorizontallist:
        return 1;
      case MediaCoverDisplayType.smallverticallist:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = _buildVerticalCard(context);

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: clickButton(
        onTap: onTap,
        child: content,
      ),
    );
  }

  Widget _buildVerticalCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(_radius),
          child: AspectRatio(
            aspectRatio: _imageAspectRatio,
            child: _coverStack(),
          ),
        ),
        4.h.verticalSpace,
        SizedBox(
          height: (displayType == MediaCoverDisplayType.landscape ||
                  displayType == MediaCoverDisplayType.shortvideo)
              ? 34.h
              : null,
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              _title,
              maxLines: _titleMaxLines,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: titleColor,
                fontSize: 12.sp,
                height: 1.35,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        1.h.verticalSpace,
        _footerRow(context),
      ],
    );
  }

  Widget _coverStack() {
    final BorderRadius r = BorderRadius.circular(_radius);
    final play = _playCountText;
    final dur = _durationText;
    return Stack(
      fit: StackFit.expand,
      children: [
        _coverLayer(r),
        Positioned(
            top: 4.w,
            right: 6.w,
            child: PayTypeView(isVip: model.isVip, price: model.gold ?? 0)),
        Positioned(
          left: 4.w,
          bottom: 4.w,
          child: _pill(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AssetsGen.images.home.icCoverPlayer
                    .image(width: 7.w, height: 7.h),
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
        ),
        if (dur != null && dur.isNotEmpty && dur != '00:00')
          Positioned(
            right: 4.w,
            bottom: 4.w,
            child: _pill(
              Text(
                dur,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _coverLayer(BorderRadius radius) {
    return CustomImage(
      url: _coverUrl,
      fit: BoxFit.cover,
      borderRadius: radius,
    );
  }

  Widget _pill(Widget child) {
    return Container(
      height: 16.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        child: child,
      ),
    );
  }

  Widget _footerRow(BuildContext context) {
    final String left = _categoryTag;
    final String right = _collectText();
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: secondaryColor,
              fontSize:
                  displayType == MediaCoverDisplayType.portrait ? 11.sp : 12.sp,
            ),
          ),
        ),
        Text(
          right,
          style: TextStyle(
            color: secondaryColor,
            fontSize:
                displayType == MediaCoverDisplayType.portrait ? 11.sp : 12.sp,
          ),
        ),
      ],
    );
  }

  String _collectText() {
    final c = _collectCountText;
    return '$collectLabel $c';
  }
}

class PayTypeView extends StatelessWidget {
  final bool isVip;
  final int price;
  const PayTypeView({super.key, required this.isVip, required this.price});

  @override
  Widget build(BuildContext context) {
    if (!isVip && price <= 0) return const SizedBox.shrink();
    final text = isVip ? 'VIP' : '金币';
    return Container(
      alignment: Alignment.center,
      height: 14.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isVip ? AppColor.vipPayTypeColors : AppColor.goldPayTypeColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 8.sp, color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}
