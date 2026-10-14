import 'package:comics_app/common/entities/media_info.dart';
import 'package:comics_app/common/entities/media_info_entity.dart';
import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/entities/video_model/ishort_video_model.dart';
import 'package:comics_app/common/entities/video_model/video_model.dart';

/// 针对项目来调整
enum HistoryRecordType {
  video, // 长视频
  short, // 短视频
  post, // 帖子
  picture, // 写真
  game, // 游戏
}

class HistoryRecordModel extends MediaInfoEntity {
  HistoryRecordModel({
    this.mediaID,
    this.episode = 1,
    this.duration,
    this.recordType,
    this.updateStatus,
    this.updatedDesc,
    this.coverImageCounts = 0,
    List<dynamic>? contentsJson,
  }) : contentsJson = contentsJson ?? [];

  String? mediaID;
  int episode;
  int? duration;
  HistoryRecordType? recordType;
  int? updateStatus;
  String? updatedDesc;
  int coverImageCounts;
  List<dynamic> contentsJson;

  factory HistoryRecordModel.fromJson(Map<String, dynamic> json) {
    final model = HistoryRecordModel(
      mediaID: (json['mediaID'] ?? json['id'])?.toString(),
      episode: _parseInt(json['episode']) ?? 1,
      duration: _parseInt(json['duration']),
      recordType: _parseRecordType(json['recordType']),
      updateStatus: _parseInt(json['updateStatus']),
      updatedDesc: json['updatedDesc']?.toString(),
      coverImageCounts: _parseInt(json['coverImageCounts']) ?? 0,
      contentsJson:
          json['contents'] is List ? List<dynamic>.from(json['contents']) : [],
    );
    model.id = (json['id'] ?? json['mediaID'])?.toString();
    model.title = json['title']?.toString();
    model.horizontalCover = json['horizontalCover']?.toString();
    model.verticalCover = json['verticalCover']?.toString();
    model.direction = _parseInt(json['direction']);
    model.tagNames = _stringList(json['tagNames']);
    model.tags = _stringList(json['tags']);
    model.kind = _parseInt(json['kind']);
    model.price = _parseInt(json['price']);
    model.countBrowse = _parseInt(json['countBrowse']);
    model.totalEpisode = _parseInt(json['totalEpisode']);
    model.permission = _parseInt(json['permission']);
    model.collects = _parseInt(json['collects']);
    return model;
  }

  factory HistoryRecordModel.fromMediaInfoResult(
    MediaInfoResult info, {
    required int episode,
    int? duration,
    required HistoryRecordType recordType,
  }) {
    final vod = info.vod!;
    final mediaId = vod.id.toString();
    final tags = vod.tags?.map((e) => e.toString()).toList();
    final playList = vod.vodFullPlayUrl;
    final model = HistoryRecordModel(
      mediaID: mediaId,
      episode: episode,
      duration: duration,
      recordType: recordType,
      coverImageCounts: 0,
    );
    model.id = mediaId;
    model.title = vod.title;
    model.permission = _parseInt(vod.status);
    model.horizontalCover = vod.vodHorizontalPic ?? vod.vodPic;
    model.verticalCover = vod.vodVerticalPic ?? vod.vodPic;
    model.tagNames = tags;
    model.tags = tags;
    model.kind = _parseInt(vod.vodClass) ?? 0;
    model.price = _parseInt(vod.gold) ?? 0;
    model.countBrowse = vod.readNumber;
    model.totalEpisode = playList?.isNotEmpty == true ? playList!.length : 1;
    model.collects = vod.collects;
    return model;
  }

  factory HistoryRecordModel.fromAllMedia(
    AllMediaInfoModel info, {
    required int episode,
    HistoryRecordType? recordType,
  }) {
    final model = HistoryRecordModel(
      mediaID: info.id,
      episode: episode,
      recordType: recordType,
      updateStatus: info.updateStatus,
      coverImageCounts: info.contents.isNotEmpty
          ? info.contents.first.urlSet?.length ?? 0
          : 0,
      contentsJson: info.contents.map((e) => e.toJson()).toList(),
    );
    model.id = info.id;
    model.title = info.title;
    model.permission = info.permission;
    model.horizontalCover = info.horizontalCover;
    model.verticalCover = info.verticalCover;
    model.direction = info.direction;
    model.tagNames = info.getTagsList();
    model.tags = info.tags;
    model.kind = info.kind;
    model.price = info.price;
    model.countBrowse = info.countBrowse;
    model.totalEpisode = info.totalEpisode;
    model.collects = info.countCollect;
    return model;
  }

  factory HistoryRecordModel.fromVideoModel(
    VideoModel model, {
    required HistoryRecordType recordType,
  }) {
    final record = HistoryRecordModel(
      mediaID: model.id,
      recordType: recordType,
      coverImageCounts: model.imgCount ?? model.seriesCover.length,
    );
    record.id = model.id;
    record.title = model.title;
    record.horizontalCover = model.cover;
    record.verticalCover = model.verticalCover;
    record.tagNames = model.tagNames;
    record.tags =
        model.tags.map((e) => e.name ?? '').where((e) => e.isNotEmpty).toList();
    record.kind = model.kind;
    record.price = model.originCoins;
    record.countBrowse = model.playCount ?? model.pageViewCount;
    record.permission = model.permission;
    record.collects = model.collectCount;
    return record;
  }

  factory HistoryRecordModel.fromShortVideoModel(
    ShortVideoModel model, {
    required HistoryRecordType recordType,
  }) {
    final record = HistoryRecordModel(
      mediaID: model.id,
      recordType: recordType,
    );
    record.id = model.id;
    record.title = model.title;
    record.horizontalCover = model.cover;
    record.verticalCover = model.cover;
    record.tagNames =
        model.tags.map((e) => e.name ?? '').where((e) => e.isNotEmpty).toList();
    record.tags = record.tagNames;
    record.price = model.price;
    record.countBrowse = model.likeCount;
    record.permission = model.permission;
    record.collects = model.collectCount;
    return record;
  }

  @override
  Map<String, dynamic> toJson() => {
        "mediaID": mediaID ?? id,
        "title": title,
        "permission": permission,
        "horizontalCover": horizontalCover,
        "verticalCover": verticalCover,
        "direction": direction,
        "tagNames": tagNames,
        "tags": tags,
        "kind": kind,
        "episode": episode,
        "price": price,
        "id": id ?? mediaID,
        "countBrowse": countBrowse,
        "updateStatus": updateStatus,
        "updatedDesc": updatedDesc,
        "totalEpisode": totalEpisode,
        "coverImageCounts": coverImageCounts,
        "duration": duration,
        "recordType": recordType?.name,
        "contents": contentsJson,
        "collects": collects,
      };

  dynamic operator [](String key) => toJson()[key];

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static List<String>? _stringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return null;
  }

  static HistoryRecordType? _parseRecordType(dynamic value) {
    if (value == null) return null;
    final name = value.toString().replaceFirst('HistoryRecordType.', '');
    for (final type in HistoryRecordType.values) {
      if (type.name == name) return type;
    }
    return null;
  }
}
