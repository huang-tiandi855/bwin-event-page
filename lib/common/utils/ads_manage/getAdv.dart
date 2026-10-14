// ignore_for_file: file_names

import 'dart:math';

import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/store/store.dart';

/// 广告位类型
///
/// `value` 即后端约定的广告位 code（slotCode）。新增广告位时按
/// `slotCodeName('SLOT_CODE')` 的格式补充对应枚举即可。
enum AdsType {
  /// 启动页广告
  openScreen('OpenScreen'),

  /// 首页弹窗
  indexTip('INDEX_TIP'),

  /// 首页九宫格弹窗
  indexTipGuild('INDEX_TIP_GUILD'),

  /// 首页悬浮广告
  indexFix('INDEX_FIX'),

  /// 侧边导航栏小 banner 广告
  sideBanner('SIDE_BANNER'),

  /// 主页/暗网/社区一级分类下的大 banner
  banner('BANNER'),

  /// 主页双头像广告
  dbLineHead('DB_LINE_HEAD'),

  /// 搜索页 banner
  bannerSearch('BANNER_SEARCH'),

  /// 搜索页双头像广告
  dbLineHeadSearch('DB_LINE_HEAD_SEARCH'),

  /// 长视频播放页 banner
  bannerPlay('BANNER_PLAY'),

  /// 长视频播放页双头像广告
  dbLineHeadPlay('DB_LINE_HEAD_PLAY'),

  /// 帖子详情 banner
  bannerPosting('BANNER_POSTING'),

  /// 帖子详情双头像广告
  dbLineHeadPosting('DB_LINE_HEAD_POSTING'),

  /// 我的页面 banner
  bannerMy('BANNER_MY'),

  /// 我的页面双头像广告
  dbLineHeadMy('DB_LINE_HEAD_MY'),

  /// 推荐应用 导航栏
  recommendAppBanner('BANNER_APP'),

  /// 推荐应用 应用图标
  recommendAppIcon('ICON_APP'),

  /// AI 创作首页 banner
  aiBanner('AI_BANNER'),

  gameAppIcon('GAMING_APPS'),

  /// 约会首页 banner
  datingBanner('YUEHUI_BANNER'),
  ;

  const AdsType(this.value);

  /// 后端广告位 code（slotCode）
  final String value;
}

/// 按广告位类型获取广告数据
List<AdsInfoList> getAdsByType(AdsType adsType) =>
    getAdsBySlotCode(adsType.value);

/// 直接通过广告位 code 获取广告列表
List<AdsInfoList> getAdsBySlotCode(String slotCode) {
  final response = ConfigStore.to.adsResponse;
  return response?.getBySlotCode(slotCode) ?? const <AdsInfoList>[];
}

class AdSubResult {
  final List<AdsInfoList> ads;
  final int index;

  AdSubResult({required this.ads, required this.index});

  @override
  String toString() {
    return 'AdSubResult{ads: $ads, index: $index}';
  }
}

class AdsManager {
  static AdSubResult subList(
      List<AdsInfoList> list, int adIndex, int? adCount) {
    if (adCount == null) {
      return AdSubResult(ads: list, index: adIndex);
    }
    if (adIndex >= list.length) {
      adIndex = 0;
    }
    // 一次取adCount个，如果当前index+adCount大于list长度，取到数组末尾之后再从0开始取surplus个
    int surplus = adIndex + adCount - list.length;
    int end = min(adIndex + adCount, list.length);
    final List<AdsInfoList> adsToInsert = list.sublist(adIndex, end);
    adIndex = end;
    if (surplus > 0) {
      final result = subList(list, 0, surplus);
      adsToInsert.addAll(result.ads);
      adIndex = result.index;
      surplus = 0;
    }
    return AdSubResult(ads: adsToInsert, index: adIndex);
  }
}
