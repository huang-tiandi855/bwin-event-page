import 'package:comics_app/common/entities/config.dart';

/// 广告位配置元数据，对应 /ads/fetch/batch 响应中 `data` 数组里的单项
class AdsSlotConfig {
  String? app;
  String? slotCode;
  int? slotType;
  int? width;
  int? height;
  int? status;

  AdsSlotConfig({
    this.app,
    this.slotCode,
    this.slotType,
    this.width,
    this.height,
    this.status,
  });

  factory AdsSlotConfig.fromJson(Map<String, dynamic> json) => AdsSlotConfig(
        app: json['app']?.toString(),
        slotCode: json['slotCode']?.toString(),
        slotType: _asInt(json['slotType']),
        width: _asInt(json['width']),
        height: _asInt(json['height']),
        status: _asInt(json['status']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'app': app,
        'slotCode': slotCode,
        'slotType': slotType,
        'width': width,
        'height': height,
        'status': status,
      };

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
}

/// /ads/fetch/batch 接口返回的整体广告数据
///
/// 顶层 key 为广告位 code（如 `OpenScreen` / `INDEX_FIX` / `BANNER` 等），
/// value 为该位下的广告列表；额外的 `data` key 携带广告位配置元数据。
class AdsResponseModel {
  /// 广告位 code -> 该位的广告列表
  final Map<String, List<AdsInfoList>> slotAds;

  /// 广告位配置（来源于响应中的 `data` 字段）
  final List<AdsSlotConfig> slotConfigs;

  const AdsResponseModel({
    this.slotAds = const <String, List<AdsInfoList>>{},
    this.slotConfigs = const <AdsSlotConfig>[],
  });

  factory AdsResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, List<AdsInfoList>> ads = <String, List<AdsInfoList>>{};
    List<AdsSlotConfig> configs = const <AdsSlotConfig>[];

    json.forEach((String key, dynamic value) {
      if (key == 'data') {
        if (value is List) {
          configs = value
              .whereType<Map>()
              .map((e) =>
                  AdsSlotConfig.fromJson(Map<String, dynamic>.from(e)))
              .toList(growable: false);
        }
        return;
      }
      if (value is List) {
        ads[key] = value
            .whereType<Map>()
            .map(
                (e) => AdsInfoList.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false);
      }
    });

    return AdsResponseModel(slotAds: ads, slotConfigs: configs);
  }

  /// 按广告位 code 取广告列表（无数据返回空列表）
  List<AdsInfoList> getBySlotCode(String slotCode) =>
      slotAds[slotCode] ?? const <AdsInfoList>[];

  /// 按广告位 code 查找该位的配置元数据
  AdsSlotConfig? findSlotConfig(String slotCode) {
    for (final AdsSlotConfig c in slotConfigs) {
      if (c.slotCode == slotCode) return c;
    }
    return null;
  }

  bool get isEmpty => slotAds.isEmpty;
  bool get isNotEmpty => slotAds.isNotEmpty;
}
