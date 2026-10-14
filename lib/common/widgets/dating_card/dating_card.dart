import 'package:comics_app/common/entities/circle/dating_models.dart';
import 'package:comics_app/common/extension/int_extension.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../style/color.dart';

/// 约会列表双列卡片（对齐 Figma `Frame 2131333914`）。
class DatingCard extends StatelessWidget {
  const DatingCard({super.key, required this.card});

  final DatingCardModel card;

  static const Color _priceColor = AppColor.primaryButtonColor;
  static const Color _compensateGreen = Color(0xFF34C759);

  @override
  Widget build(BuildContext context) {
    final tags = card.serviceTags.take(3).map((e) => e.name).toList();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _coverSection(),
          _info(tags),
        ],
      ),
    );
  }

  Widget _coverSection() {
    return AspectRatio(
      aspectRatio: 167 / 200,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _coverImage(card.coverUrl ?? ''),
          Positioned(
            left: 6.w,
            top: 6.w,
            right: 6.w,
            child: Row(
              children: [
                Expanded(child: _regionBadges()),
                if (card.showCompensate) _compensateBadge(),
              ],
            ),
          ),
          Positioned(
            left: 6.w,
            bottom: 6.w,
            child: Row(
              children: [
                _metricBadge(
                  AssetsGen.images.dating.datingIconWatch,
                  card.displayWatch.humanizeFormat,
                ),
                SizedBox(width: 4.w),
                _metricBadge(
                  AssetsGen.images.dating.datingIconDeal,
                  card.displayBuyNum.humanizeFormat,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _regionBadges() {
    final province = card.regionShortLabel;
    final city = card.cityChipLabel;
    if (province.isEmpty && city.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        if (province.isNotEmpty)
          _darkBadge(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AssetsGen.images.dating.datingIconLocation.image(
                  width: 8.w,
                  height: 8.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 2.w),
                Text(
                  province,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        if (city.isNotEmpty) ...[
          SizedBox(width: 4.w),
          _darkBadge(
            child: Text(
              city,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                height: 1,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _compensateBadge() {
    return Container(
      height: 16.w,
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        color: _compensateGreen,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: _compensateGreen.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AssetsGen.images.dating.datingIconCompensate.image(
            width: 10.w,
            height: 10.w,
            fit: BoxFit.contain,
          ),
          Text(
            '支持赔付',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricBadge(AssetGenImage icon, String text) {
    return Container(
      height: 16.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(3.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon.image(width: 10.w, height: 10.w, fit: BoxFit.contain),
          SizedBox(width: 2.w),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _darkBadge({required Widget child}) {
    return Container(
      height: 16.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(3.r),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _info(List<String> tagNames) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8.w),
        color: Colors.white.withOpacity(0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    card.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      height: 16 / 14,
                    ),
                  ),
                ),
                if (card.ageLabel.isNotEmpty)
                  Text(
                    card.ageLabel,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      height: 1,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.w),
            Text(
              card.priceLabel,
              style: TextStyle(
                color: _priceColor,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            SizedBox(height: 8.w),
            SizedBox(
              height: 20.w,
              child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) =>
                      _serviceChip(tagNames[index]),
                  separatorBuilder: (context, index) => SizedBox(width: 4.w),
                  itemCount: tagNames.length),
            ),
            SizedBox(height: 8.w),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _relativeUpdate(card.updateTime),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10.sp,
                    height: 1,
                  ),
                ),
                Text(
                  '100%真实',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10.sp,
                    height: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: 10.sp, height: 1.1),
      ),
    );
  }

  Widget _coverImage(String url) {
    if (url.isEmpty) {
      return const ColoredBox(color: Color(0xFF2C2C2C));
    }
    return CustomImage(url: url, fit: BoxFit.cover);
  }

  static String _relativeUpdate(int ms) {
    if (ms <= 0) return '';
    final now = DateTime.now();
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 30) return '${diff.inDays}天前';
    return '${dt.month}月${dt.day}日';
  }
}
