// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'content_model.dart';
import 'media_status.dart';
import 'tag_detail_model.dart';

class AllMediaInfoModel {
  List<ContentModel> contents;
  int? countBrowse;
  int? countCollect;
  int? countComment;
  int? countDisLike;
  int? countGrade;
  int? countLike;
  int? countPurchases;
  int? countView;
  String? createdAt;
  int? direction;
  int? freeTime;
  int? grade;
  bool? hasFollow;
  bool? hasGrade;
  String? horizontalCover;
  int? horizontalWidth;
  int? horizontalHeight;

  String? get coverH {
    return (horizontalCover?.isNotEmpty == true)
        ? horizontalCover
        : verticalCover;
  }

  String? get coverV {
    return (verticalCover?.isNotEmpty == true)
        ? verticalCover
        : horizontalCover;
  }

  bool get isVerticalCover =>
      verticalCover?.isNotEmpty == true || horizontalCover?.isNotEmpty != true;
  bool get ifHorizontal {
    if (horizontalCover?.isNotEmpty == true) {
      return true;
    }
    return false;
  }

  String get autoCover {
    return ifHorizontal ? coverH ?? '' : coverV ?? '';
  }

  bool get hasCollected => mediaStatus?.hasCollected ?? false;

  /// 分页, 总集数按36个一组分页
  /// 1-36 36-72 72-108 108-最后一个
  Map<String, List<ContentModel>> get pagination {
    final totalEpisode = this.totalEpisode ?? 0;
    // final totalEpisode = model.totalEpisode ?? 0;
    final Map<String, List<ContentModel>> pages = {};

    if (totalEpisode == 0) {
      return pages; // 如果总集数为0，返回空的分页结果
    }

    for (int i = 0; i < totalEpisode; i += 30) {
      final start = i + 1;
      final end = (i + 30) > totalEpisode ? totalEpisode : (i + 30);
      pages['$start-$end'] = contents.sublist(i, end);

      // List<int>.generate(end - start + 1, (index) => start + index);
    }

    return pages;
  }

  String? id;
  int? kind;
  String? mId;
  MediaStatus? mediaStatus;
  String? mediaType;
  String? moduleName;
  int? number;
  int? permission;
  bool? permissionIconHide;
  int? price;
  String? sId;
  String? sectionName;
  int? sectionSort;
  int? sellType;
  int? sortCode;
  int? status;
  String? summary;
  List<TagDetailModel> tagDetails;
  List<String>? tagNames;
  // List<AllRankingAllActress>? allActress;
  List<String>? tags;

  String get tagsDesc {
    String desc = "";
    if (tagDetails.isNotEmpty == true) {
      desc = tagDetails.first.name ?? "";
    }
    for (int i = 1; i < tagDetails.length; i++) {
      desc += "、${tagDetails[i].name ?? ""}";
    }
    return desc;
  }

  String get tagsAllDesc {
    String desc = "";
    if (tagDetails.isNotEmpty == true) {
      desc = tagDetails.first.name ?? "";
    }
    for (int i = 1; i < tagDetails.length; i++) {
      desc += "、${tagDetails[i].name ?? ""}";
    }
    return desc;
  }

  String? title;
  int? totalEpisode; //总集数
  int? updateStatus; //0 默认 1、更新中 2、已完结
  String? updateTime;
  String? verticalCover;
  int? verticalWidth;
  int? verticalHeight;

  bool isAd;
  String? adUrl;

  @override
  String toString() {
    return 'AllMediaInfoModel{contents: $contents, countBrowse: $countBrowse, countCollect: $countCollect, countComment: $countComment, countDisLike: $countDisLike, countGrade: $countGrade, countLike: $countLike, countPurchases: $countPurchases, countView: $countView, createdAt: $createdAt, direction: $direction, freeTime: $freeTime, grade: $grade, hasFollow: $hasFollow, hasGrade: $hasGrade, horizontalCover: $horizontalCover, horizontalWidth: $horizontalWidth, horizontalHeight: $horizontalHeight, id: $id, kind: $kind, mId: $mId, mediaStatus: $mediaStatus, mediaType: $mediaType, moduleName: $moduleName, number: $number, permission: $permission, permissionIconHide: $permissionIconHide, price: $price, sId: $sId, sectionName: $sectionName, sectionSort: $sectionSort, sellType: $sellType, sortCode: $sortCode, status: $status, summary: $summary, tagDetails: $tagDetails, tagNames: $tagNames, tags: $tags, title: $title, totalEpisode: $totalEpisode, updateStatus: $updateStatus, updateTime: $updateTime, verticalCover: $verticalCover, verticalWidth: $verticalWidth, verticalHeight: $verticalHeight, isAd: $isAd, adUrl: $adUrl}';
  }

  AllMediaInfoModel({
    this.contents = const [],
    this.countBrowse,
    this.countCollect,
    this.countComment,
    this.countDisLike,
    this.countGrade,
    this.countLike,
    this.countPurchases,
    this.countView,
    this.createdAt,
    this.direction,
    this.freeTime,
    this.grade,
    this.hasGrade,
    this.hasFollow,
    this.horizontalCover,
    this.horizontalWidth,
    this.horizontalHeight,
    this.id,
    this.kind,
    this.mId,
    this.mediaStatus,
    this.mediaType,
    this.moduleName,
    this.number,
    this.permission,
    this.permissionIconHide,
    this.price,
    this.sId,
    this.sectionName,
    this.sectionSort,
    this.sellType,
    this.sortCode,
    this.status,
    this.summary,
    this.tagDetails = const [],
    this.tags,
    this.title,
    this.totalEpisode,
    this.updateStatus,
    this.updateTime,
    this.verticalCover,
    this.verticalWidth,
    this.verticalHeight,
    this.tagNames,
    this.isAd = false,
    this.adUrl,
  });

  factory AllMediaInfoModel.ad({
    required String? id,
    required String? cover,
    required String? verticalCover,
    required String? title,
    required String? adUrl,
  }) {
    return AllMediaInfoModel(
      isAd: true,
      id: id,
      horizontalCover: cover,
      verticalCover: verticalCover,
      title: title,
      adUrl: adUrl,
    );
  }

  // AcgItemWidgetModel toWidgetItemModel({double scale = 0, bool useVerticalCover = true}) {
  //   AcgItemWidgetModel model = AcgItemWidgetModel(id ?? '');
  //   model.imgUrl = useVerticalCover ? coverV ?? '' : coverH ?? '';
  //   model.isColleted = mediaStatus?.hasCollected ?? false;
  //   model.title = title ?? '';
  //   model.desTitle = getUpdateString();
  //   model.tagDetails = tagDetails;
  //   model.mediaType = mediaType ?? '';
  //   model.showBookImg = mediaType == 'image';
  //   model.imgScale = scale;
  //   return model;
  // }

  //获取标签
  String getTagsString() {
    String value = '';
    if (tagDetails.isNotEmpty) {
      for (TagDetailModel element in tagDetails) {
        value = '$value${element.name}、';
      }
      value = value.substring(0, value.length - 1);
    }
    return value;
  }

  List<String> getTagsList() {
    List<String> value = [];
    if (tagDetails.isNotEmpty) {
      for (TagDetailModel element in tagDetails) {
        value.add(element.name ?? '');
      }
    }
    return value;
  }

  String getUpdateString() {
    String unit = '集';
    if (mediaType == 'image') {
      unit = '话';
    }
    if (updateStatus == 1) {
      return '更新至$totalEpisode$unit';
    } else if (updateStatus == 2 || updateStatus == 0) {
      return '已完结';
    } else {
      return '';
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'contents': contents.map((x) => x.toJson()).toList(),
      'countBrowse': countBrowse,
      'countCollect': countCollect,
      'countComment': countComment,
      'countDisLike': countDisLike,
      'countGrade': countGrade,
      'countLike': countLike,
      'countPurchases': countPurchases,
      'countView': countView,
      'createdAt': createdAt,
      'direction': direction,
      'freeTime': freeTime,
      'grade': grade,
      'hasFollow': hasFollow,
      'hasGrade': hasGrade,
      'horizontalCover': horizontalCover,
      'horizontalWidth': horizontalWidth,
      'horizontalHeight': horizontalHeight,
      'id': id,
      'kind': kind,
      'mId': mId,
      'mediaStatus': mediaStatus?.toJson(),
      'mediaType': mediaType,
      'moduleName': moduleName,
      'number': number,
      'permission': permission,
      'permissionIconHide': permissionIconHide,
      'price': price,
      'sId': sId,
      'sectionName': sectionName,
      'sectionSort': sectionSort,
      'sellType': sellType,
      'sortCode': sortCode,
      'status': status,
      'summary': summary,
      'tagDetails': tagDetails.map((x) => x.toJson()).toList(),
      'tags': tags,
      'title': title,
      'totalEpisode': totalEpisode,
      'updateStatus': updateStatus,
      'updateTime': updateTime,
      'verticalCover': verticalCover,
      'verticalWidth': verticalWidth,
      'verticalHeight': verticalHeight,
    };
  }

  factory AllMediaInfoModel.fromJson(Map<String, dynamic> map) {
    if (map['vod'] is Map) {
      return AllMediaInfoModel.fromCmsVodResult(Map<String, dynamic>.from(map));
    }
    return AllMediaInfoModel._fromClassicDetailJson(map);
  }

  /// `getMediaInfo` 新结构：`{ "vod", "operation", "statistics", "author" }`（[BaseRespBean.data] 常为整段 [result]）。
  factory AllMediaInfoModel.fromCmsVodResult(Map<String, dynamic> envelope) {
    final Map<String, dynamic> vod =
        Map<String, dynamic>.from(envelope['vod'] as Map);
    final Map<String, dynamic> op = envelope['operation'] is Map
        ? Map<String, dynamic>.from(envelope['operation'] as Map)
        : <String, dynamic>{};
    final Map<String, dynamic> stats = envelope['statistics'] is Map
        ? Map<String, dynamic>.from(envelope['statistics'] as Map)
        : <String, dynamic>{};

    final String idStr = vod['id']?.toString() ?? '';
    final List<String> themeTags = (vod['themes'] as List<dynamic>?)
            ?.map((dynamic e) => e.toString())
            .toList() ??
        <String>[];

    final MediaStatus topStatus = MediaStatus(
      hasCollected: _cmToBool(op['isCollection']),
      hasLiked: _cmToBool(op['isLike']),
      hasPaid: false,
    );

    final List<ContentModel> contents = <ContentModel>[];
    final List<dynamic>? playList = vod['vodFullPlayUrl'] as List<dynamic>?;
    if (playList != null && playList.isNotEmpty) {
      for (int i = 0; i < playList.length; i++) {
        final dynamic raw = playList[i];
        if (raw is! Map) continue;
        final Map<String, dynamic> p = Map<String, dynamic>.from(raw);
        final String addr = p['addr']?.toString() ?? '';
        contents.add(
          ContentModel(
            id: '${idStr}_$i',
            mediaId: idStr,
            episodeNumber: i + 1,
            name: p['type']?.toString() ?? '第${i + 1}路',
            text: '',
            md5: '',
            videoUrl: addr,
            listenPermission: 1,
            price: _cmToInt(vod['gold']) ?? 0,
            playTime: _cmToInt(p['duration']),
            mediaStatus: MediaStatus(
              hasPaid: topStatus.hasPaid,
              hasLiked: topStatus.hasLiked,
              hasCollected: topStatus.hasCollected,
            ),
          ),
        );
      }
    } else {
      contents.add(
        ContentModel(
          id: idStr,
          mediaId: idStr,
          episodeNumber: 1,
          name: vod['title']?.toString() ?? '',
          text: '',
          md5: '',
          videoUrl: '',
          listenPermission: 1,
          price: _cmToInt(vod['gold']) ?? 0,
          playTime: _cmToInt(vod['vodDuration']),
          mediaStatus: topStatus,
        ),
      );
    }

    final String? pic = vod['vodPic']?.toString();
    final String? hPic = vod['vodHorizontalPic']?.toString();
    final String? vPic = vod['vodVerticalPic']?.toString();

    return AllMediaInfoModel(
      contents: contents,
      countBrowse: _cmToInt(vod['readNumber']),
      countCollect: _cmToIntFromList(vod['collects']),
      countComment: _cmToInt(vod['comments']),
      countLike: _cmToInt(vod['likeNumber']),
      countPurchases: _cmToInt(vod['recommend']),
      createdAt: _cmMillisToIso(vod['createTime']),
      direction: null,
      horizontalCover: (hPic != null && hPic.isNotEmpty) ? hPic : pic,
      verticalCover: (vPic != null && vPic.isNotEmpty) ? vPic : pic,
      id: idStr,
      kind: _cmToInt(vod['vodClass']) ?? 0,
      mediaStatus: topStatus,
      mediaType: 'video',
      permission: _cmToInt(vod['status']),
      price: _cmToInt(vod['gold']),
      sellType: null,
      status: _cmToInt(vod['status']),
      summary: vod['vodIntro']?.toString(),
      tags: themeTags.isNotEmpty ? themeTags : null,
      title: vod['title']?.toString(),
      totalEpisode: contents.length,
      tagNames: null,
      countDisLike: _cmToInt(stats['countDisLike']),
      countGrade: null,
      countView: _cmToInt(stats['readNumber']),
    );
  }

  /// 历史详情：`data` 为作品根对象（含 `contents` 等）。
  factory AllMediaInfoModel._fromClassicDetailJson(Map<String, dynamic> map) {
    var nTags = <String>[];
    var nTagNames = <String>[];
    if (map['tags'] != null) {
      nTags = [];
      map['tags'].forEach((v) {
        nTags.add(v.toString());
      });
    }
    if (map['tagNames'] != null) {
      nTagNames = [];
      map['tagNames'].forEach((v) {
        nTagNames.add(v.toString());
      });
    }
    return AllMediaInfoModel(
      contents: (map['contents'] as List<dynamic>?)
              ?.map((e) => ContentModel.fromJson(e))
              .toList() ??
          [],
      countBrowse: map['countBrowse'] as int?,
      countCollect: map['countCollect'] as int?,
      countComment: map['countComment'] as int?,
      countDisLike: map['countDisLike'] as int?,
      countGrade: map['countGrade'] as int?,
      countLike: map['countLike'] as int?,
      countPurchases: map['countPurchases'] as int?,
      countView: map['countView'] as int?,
      createdAt: map['createdAt'] as String?,
      direction: map['direction'] as int?,
      freeTime: map['freeTime'] as int?,
      grade: map['grade'] as int?,
      hasFollow: map['hasFollow'] as bool?,
      hasGrade: map['hasGrade'] as bool?,
      horizontalCover: map['horizontalCover'] as String?,
      horizontalWidth: map['horizontalWidth'] as int?,
      horizontalHeight: map['horizontalHeight'] as int?,
      id: map['id'] as String?,
      kind: map['kind'] as int?,
      mId: map['mId'] as String?,
      mediaStatus: map['mediaStatus'] != null
          ? MediaStatus.fromJson(map['mediaStatus'] as Map<String, dynamic>)
          : null,
      mediaType: map['mediaType'] as String?,
      moduleName: map['moduleName'] as String?,
      number: map['number'] as int?,
      permission: map['permission'] as int?,
      permissionIconHide: map['permissionIconHide'] as bool?,
      price: map['price'] as int?,
      sId: map['sId'] as String?,
      sectionName: map['sectionName'] as String?,
      sectionSort: map['sectionSort'] as int?,
      sellType: map['sellType'] as int?,
      sortCode: (map['sortCode'] as int?) ?? map['generalSort'] as int?,
      status: map['status'] as int?,
      summary: map['summary'] as String?,
      tagDetails: (map['tagDetails'] as List<dynamic>?)
              ?.map((e) => TagDetailModel.fromJson(e))
              .toList() ??
          [],
      tags: nTags,
      title: map['title'] as String?,
      totalEpisode: map['totalEpisode'] as int?,
      updateStatus: map['updateStatus'] as int?,
      updateTime: map['updateTime'] as String?,
      verticalCover: map['verticalCover'] as String?,
      verticalWidth: map['verticalWidth'] as int?,
      verticalHeight: map['verticalHeight'] as int?,
      tagNames: nTagNames,
    );
  }
}

int? _cmToInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

bool? _cmToBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString().trim().toLowerCase();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return null;
}

int? _cmToIntFromList(dynamic v) {
  if (v is List) return v.length;
  return _cmToInt(v);
}

String? _cmMillisToIso(dynamic v) {
  final int? ms = _cmToInt(v);
  if (ms == null) return null;
  try {
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true)
        .toIso8601String();
  } catch (_) {
    return null;
  }
}
