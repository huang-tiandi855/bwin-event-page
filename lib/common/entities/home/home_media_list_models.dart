import 'dart:convert';

import 'mine_media_pay_model.dart';

/// `cms/vod/search-json` 返回的 `data` 数组中单条视频/媒体项。

int? _homeMediaToInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

bool _homeMediaToBool(dynamic v, {bool fallback = false}) {
  if (v == null) return fallback;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString().toLowerCase();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return fallback;
}

List<int>? _homeMediaIntList(dynamic raw) {
  if (raw == null || raw is! List) return null;
  final out = <int>[];
  for (final e in raw) {
    final i = _homeMediaToInt(e);
    if (i != null) out.add(i);
  }
  return out.isEmpty ? null : out;
}

/// `vodPicInfo` 解析后的多尺寸封面（接口常为 JSON 字符串）。
class HomeMediaVodPicInfoModel {
  const HomeMediaVodPicInfoModel({
    this.horizontalLarge,
    this.verticalSmall,
    this.horizontalSmall,
    this.verticalLarge,
  });

  factory HomeMediaVodPicInfoModel.fromJson(Map<String, dynamic> json) {
    return HomeMediaVodPicInfoModel(
      horizontalLarge: json['horizontal_large']?.toString(),
      verticalSmall: json['vertical_small']?.toString(),
      horizontalSmall: json['horizontal_small']?.toString(),
      verticalLarge: json['vertical_large']?.toString(),
    );
  }

  final String? horizontalLarge;
  final String? verticalSmall;
  final String? horizontalSmall;
  final String? verticalLarge;

  static HomeMediaVodPicInfoModel? tryDecode(dynamic v) {
    if (v == null) return null;
    if (v is Map) {
      return HomeMediaVodPicInfoModel.fromJson(
        Map<String, dynamic>.from(v),
      );
    }
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return null;
      try {
        final d = json.decode(s);
        if (d is Map) {
          return HomeMediaVodPicInfoModel.fromJson(
            Map<String, dynamic>.from(d),
          );
        }
      } catch (_) {}
    }
    return null;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'horizontal_large': horizontalLarge,
        'vertical_small': verticalSmall,
        'horizontal_small': horizontalSmall,
        'vertical_large': verticalLarge,
      };
}

/// 首页/搜索视频列表单项（与 `data` 数组元素字段对齐）。
class MediaVideoModel {
  MediaVideoModel({
    this.groupId,
    this.vodClass,
    this.vodTime,
    this.recommend,
    this.readNumber,
    this.title,
    this.vodSerialNumber,
    this.gold,
    this.themes,
    this.vodArea,
    this.selfie = false,
    this.vodPic,
    this.id,
    this.vodYear,
    this.collects,
    this.original = false,
    this.vodDuration,
    this.vodVersion,
    this.videoType,
    this.explore = false,
    this.groups,
    this.priority,
    this.isVip = false,
    this.tags,
    this.vodActor,
    this.actors,
    this.createTime,
    this.vodLang,
    this.vodPicInfo,
    this.vodPicInfoRaw,
  });

  factory MediaVideoModel.fromJson(Map<String, dynamic> json) {
    final dynamic picRaw = json['vodPicInfo'];
    return MediaVideoModel(
      groupId: _homeMediaToInt(json['groupId']),
      vodClass: json['vodClass'],
      vodTime: _homeMediaToInt(json['vodTime']),
      recommend: _homeMediaToInt(json['recommend']),
      readNumber: _homeMediaToInt(json['readNumber']),
      title: json['title']?.toString(),
      vodSerialNumber: json['vodSerialNumber'],
      gold: json['gold'],
      themes: _homeMediaIntList(json['themes']),
      vodArea: json['vodArea'],
      selfie: _homeMediaToBool(json['selfie']),
      vodPic: json['vodPic']?.toString(),
      id: json['id']?.toString(),
      vodYear: json['vodYear'],
      collects: _homeMediaToInt(json['collects']),
      original: _homeMediaToBool(json['original']),
      vodDuration: _homeMediaToInt(json['vodDuration']),
      vodVersion: json['vodVersion'],
      videoType: _homeMediaToInt(json['videoType']),
      explore: _homeMediaToBool(json['explore']),
      groups: _homeMediaIntList(json['groups']),
      priority: _homeMediaToInt(json['priority']),
      isVip: _homeMediaToBool(json['isVip']),
      tags: json['tags'],
      vodActor: json['vodActor'],
      actors: json['actors'],
      createTime: _homeMediaToInt(json['createTime']),
      vodLang: json['vodLang'],
      vodPicInfo: HomeMediaVodPicInfoModel.tryDecode(picRaw),
      vodPicInfoRaw: picRaw is String ? picRaw : null,
    );
  }

  final int? groupId;
  final dynamic vodClass;
  final int? vodTime;
  final int? recommend;
  final int? readNumber;
  final String? title;
  final dynamic vodSerialNumber;
  final dynamic gold;
  final List<int>? themes;
  final dynamic vodArea;
  final bool selfie;
  final String? vodPic;
  final String? id;
  final dynamic vodYear;

  /// 收藏数（接口字段 `collects`）。**注意**：底栏「收藏」展示这一项，
  /// 不要错用 [recommend]（那是 0/1 的推荐标记，不是数量）。
  final int? collects;

  final bool original;
  final int? vodDuration;
  final dynamic vodVersion;

  /// 视频类型：0 普通视频 / 1 短视频 / 2 暗网视频，与列表请求参数同源。
  final int? videoType;

  final bool explore;
  final List<int>? groups;
  final int? priority;
  final bool isVip;
  final dynamic tags;
  final dynamic vodActor;
  final dynamic actors;
  final int? createTime;
  final dynamic vodLang;

  /// 解析后的多尺寸图；解析失败时为 `null`，可看 [vodPicInfoRaw]。
  final HomeMediaVodPicInfoModel? vodPicInfo;

  /// 接口原始 `vodPicInfo`（多为 JSON 字符串）。
  final String? vodPicInfoRaw;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'groupId': groupId,
        'vodClass': vodClass,
        'vodTime': vodTime,
        'recommend': recommend,
        'readNumber': readNumber,
        'title': title,
        'vodSerialNumber': vodSerialNumber,
        'gold': gold,
        'themes': themes,
        'vodArea': vodArea,
        'selfie': selfie,
        'vodPic': vodPic,
        'id': id,
        'vodYear': vodYear,
        'collects': collects,
        'original': original,
        'vodDuration': vodDuration,
        'vodVersion': vodVersion,
        'videoType': videoType,
        'explore': explore,
        'groups': groups,
        'priority': priority,
        'isVip': isVip,
        'tags': tags,
        'vodActor': vodActor,
        'actors': actors,
        'createTime': createTime,
        'vodLang': vodLang,
        'vodPicInfo': vodPicInfo?.toJson() ?? vodPicInfoRaw,
      };

  /// 从 MediaPayModel 转换
  factory MediaVideoModel.fromMediaPayModel(MediaPayModel model) {
    final video = model.video;
    if (video == null) {
      return MediaVideoModel();
    }

    return MediaVideoModel(
      groupId: video.groupId,
      vodClass: video.vodClass,
      vodTime: _homeMediaToInt(video.vodTime),
      recommend: video.recommend,
      readNumber: video.readNumber,
      title: video.title ?? video.vodName,
      vodSerialNumber: video.vodSerialNumber,
      gold: video.gold,
      vodArea: video.vodArea,
      selfie: video.selfie ?? false,
      vodPic: video.vodPic,
      id: video.id?.toString(),
      vodYear: video.vodYear,
      collects: video.collects,
      original: video.original ?? false,
      vodDuration: video.vodDuration,
      vodVersion: video.vodVersion,
      videoType: video.videoType,
      priority: video.priority,
      isVip: video.isVip ?? false,
      tags: model.tags,
      vodActor: video.vodActor,
      actors: video.actor,
      createTime: video.createDateTime,
      vodLang: video.vodLang,
      // 解析 vodPicInfo
      vodPicInfo: HomeMediaVodPicInfoModel.tryDecode(video.vodPicInfo),
      vodPicInfoRaw: video.vodPicInfo,
    );
  }

  /// 解析接口 `data`（JSON 数组 → 模型列表）。
  static List<MediaVideoModel> listFromData(dynamic data) {
    if (data == null || data is! List) return [];
    final out = <MediaVideoModel>[];
    for (final e in data) {
      if (e is Map) {
        out.add(MediaVideoModel.fromJson(
          Map<String, dynamic>.from(e),
        ));
      }
    }
    return out;
  }
}
