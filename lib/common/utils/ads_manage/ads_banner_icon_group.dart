import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'ads_banner_widget.dart';
import 'ads_grid_view_widget.dart';
import 'getAdv.dart';

/// 「banner + icon」组合广告区
///
/// 一次性渲染轮播 banner（[AdsBannerWidget]）与 icon 九宫格（[AdsGridViewWidget]）两块广告位，
/// 是否展示由 [module] 上的 [ModuleModel.isShowBanner] / [ModuleModel.isShowIcon] 控制：
///   - [module] 为 null 时视为两个开关都开启（如搜索发现页这种与 module 无关的场景）；
///   - 两个开关都关闭时整体不渲染（返回 [SizedBox.shrink]）；
///   - 仅其中一个开关打开时也不会在末尾留下多余间距。
///
/// 数据源沿用两个子组件的优先级：显式传入的 [bannerAds] / [iconAds] 优先；否则按
/// [bannerType] / [iconType] 从 `ConfigStore.adsResponse` 自动获取。
class AdsBannerIconGroup extends StatelessWidget {
  /// 当前一级 Tab / 分类对应的 module，提供 isShowBanner / isShowIcon 开关；
  /// 为 null 时不做开关过滤（默认都展示）。
  final ModuleModel? module;

  /// banner 广告槽位
  final AdsType? bannerType;

  /// icon 区域广告槽位
  final AdsType? iconType;

  /// banner 与 icon 之间的纵向间距，默认 16（组件内部按 ScreenUtil `.h` 缩放）
  final double spacing;

  // ---------------- AdsBannerWidget 透传 ----------------
  final List<AdsInfoList>? bannerAds;
  final double? bannerWidth;
  final double? bannerHeight;
  final int? bannerAutoPlayDuration;
  final double? bannerRadius;
  final ValueChanged<int>? onBannerIndexChanged;

  // ---------------- AdsGridViewWidget 透传 ----------------
  /// true: 10 宫格大样式；false: 单行横向滚动小样式（默认 true）
  final bool iconIsBigStyle;
  final EdgeInsetsGeometry? iconPadding;
  final List<AdsInfoList>? iconAds;

  const AdsBannerIconGroup({
    super.key,
    this.module,
    this.bannerType,
    this.iconType,
    this.spacing = 16,
    this.bannerAds,
    this.bannerWidth,
    this.bannerHeight,
    this.bannerAutoPlayDuration = 3000,
    this.bannerRadius,
    this.onBannerIndexChanged,
    this.iconIsBigStyle = true,
    this.iconPadding,
    this.iconAds,
  });

  @override
  Widget build(BuildContext context) {
    final bool showBanner = module?.isShowBanner ?? true;
    final bool showIcon = module?.isShowIcon ?? true;
    if (!showBanner && !showIcon && bannerType == null && iconType == null) {
      return const SizedBox.shrink();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showBanner && bannerType != null)
          AdsBannerWidget(
            adsType: bannerType!,
            ads: bannerAds,
            width: bannerWidth,
            height: bannerHeight,
            autoPlayDuration: bannerAutoPlayDuration,
            radius: bannerRadius,
            onIndexChanged: onBannerIndexChanged,
          ),
        if (showBanner && showIcon && bannerType != null)
          SizedBox(height: spacing.h),
        if (showIcon && iconType != null)
          AdsGridViewWidget(
            adsType: iconType,
            adsArr: iconAds,
            isBigStyle: iconIsBigStyle,
            padding: iconPadding,
          ),
      ],
    );
  }
}
