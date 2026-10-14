import 'dart:convert';

import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';

/// 长视频详情 [MediaApi.getMediaInfo] 顶层包装。
///
/// 接口契约为新版网关 `{ code, message, result, time, ... }`，其中 `result`
/// 严格按 [MediaInfoResult] 解析（`vod` / `operation` / `statistics` / `author`
/// 四段都有明确的强类型映射，详见各子模型的字段注释）。
///
/// [data]（[AllMediaInfoModel]）只是为了让长视频播放页等旧业务模块的引用先行
/// 跑通，暂未删除；后续重构业务调用方时会与新模型一并清理。
class MediaInfo {
  MediaInfo({
    int? code,
    String? message,
    int? total,
    MediaInfoResult? result,
    AllMediaInfoModel? data,
    bool? hash,
    String? msg,
    String? time,
    String? tip,
  }) {
    _code = code;
    _message = message;
    _total = total;
    _result = result;
    _data = data;
    _hash = hash;
    _msg = msg;
    _time = time;
    _tip = tip;
  }

  MediaInfo.fromJson(dynamic json) {
    if (json is! Map) return;
    final Map<String, dynamic> m = Map<String, dynamic>.from(json);
    _code = _miParseCode(m['code'] ?? m['bizCode']);
    _message = m['message']?.toString();
    _msg = (m['msg'] ?? _message)?.toString();
    _total = _miParseInt(m['total']);
    _hash = _miParseBool(m['hash']);
    _time = m['time']?.toString();
    _tip = m['tip']?.toString();

    Map<String, dynamic>? payload;
    if (m['data'] is Map) {
      payload = Map<String, dynamic>.from(m['data'] as Map);
    } else if (m['result'] is Map) {
      payload = Map<String, dynamic>.from(m['result'] as Map);
    }

    if (payload != null) {
      if (payload['vod'] is Map) {
        _result = MediaInfoResult.fromJson(payload);
      }
      _data = AllMediaInfoModel.fromJson(payload);
    }
  }

  int? _code;
  String? _message;
  int? _total;
  MediaInfoResult? _result;
  AllMediaInfoModel? _data;
  bool? _hash;
  String? _msg;
  String? _time;
  String? _tip;

  int? get code => _code;

  /// 网关文案，如 `OK`。
  String? get message => _message;

  int? get total => _total;

  /// 新详情 `result` 原样解析（与 [data] 中 `vod` 一致时可共用）。
  MediaInfoResult? get result => _result;

  AllMediaInfoModel? get data => _data;
  bool? get hash => _hash;
  String? get msg => _msg;
  String? get time => _time;
  String? get tip => _tip;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = _code;
    map['message'] = _message;
    map['total'] = _total;
    if (_result != null) {
      map['result'] = _result!.toJson();
    }
    if (_data != null) {
      map['data'] = _data!.toJson();
    }
    map['hash'] = _hash;
    map['msg'] = _msg;
    map['time'] = _time;
    map['tip'] = _tip;
    return map;
  }
}

int? _miParseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

int? _miParseCode(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}

/// 容错布尔解析：服务端可能返回 `bool`/`int(0|1)`/`"true"|"false"|"0"|"1"` 等形态。
bool? _miParseBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString().trim().toLowerCase();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return null;
}

List<String>? _miParseStringList(dynamic v) {
  if (v == null) return null;
  if (v is List) {
    return v.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }
  final value = v.toString();
  if (value.isEmpty) return null;
  return value
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

/// `getMediaInfo` 返回的 `result` 段：四段强类型子模型严格映射后端字段。
///
/// 接口示例：
/// ```json
/// {
///   "vod": { ... 见 [MediaInfoVod] ... },
///   "operation": { ... 见 [MediaInfoOperation] ... },
///   "statistics": { ... 见 [MediaInfoStatistics] ... },
///   "author": { ... 见 [MediaInfoAuthor] ... }
/// }
/// ```
class MediaInfoResult {
  MediaInfoResult({
    this.vod,
    this.operation,
    this.statistics,
    this.author,
  });

  factory MediaInfoResult.fromJson(Map<String, dynamic> json) {
    return MediaInfoResult(
      vod: json['vod'] is Map
          ? MediaInfoVod.fromJson(Map<String, dynamic>.from(json['vod'] as Map))
          : null,
      operation: json['operation'] is Map
          ? MediaInfoOperation.fromJson(
              Map<String, dynamic>.from(json['operation'] as Map))
          : null,
      statistics: json['statistics'] is Map
          ? MediaInfoStatistics.fromJson(
              Map<String, dynamic>.from(json['statistics'] as Map))
          : null,
      author: json['author'] is Map
          ? MediaInfoAuthor.fromJson(
              Map<String, dynamic>.from(json['author'] as Map))
          : null,
    );
  }

  /// 视频/作品本身（标题、播放地址、海报、标签、计数等）。
  final MediaInfoVod? vod;

  /// 当前登录用户对该作品的交互态（是否收藏 / 点赞 / 评分等）。
  final MediaInfoOperation? operation;

  /// 作品聚合统计（阅读数、点赞数、评分分布）。
  final MediaInfoStatistics? statistics;

  /// 作者/发布者基础资料与关注关系（关注后会就地翻转）。
  MediaInfoAuthor? author;

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (vod != null) 'vod': vod!.toJson(),
        if (operation != null) 'operation': operation!.toJson(),
        if (statistics != null) 'statistics': statistics!.toJson(),
        if (author != null) 'author': author!.toJson(),
      };
}

/// `result.author`：作者/发布者基础资料 + 关注关系。
///
/// 字段一一对照后端返回，示例：
/// ```json
/// {
///   "id": 96, "sex": null, "avatar": "/head/8.png",
///   "nickName": "风月失温", "authType": 1,
///   "follow": false, "fansNum": 0, "starsNum": 0,
///   "beFollow": null, "lastPosting": null,
///   "introduce": null, "pnum": null, "vnum": null
/// }
/// ```
class MediaInfoAuthor {
  MediaInfoAuthor({
    this.id,
    this.sex,
    this.avatar,
    this.nickName,
    this.authType,
    this.follow,
    this.fansNum,
    this.vnum,
    this.starsNum,
    this.beFollow,
    this.lastPosting,
    this.introduce,
    this.pnum,
  });

  factory MediaInfoAuthor.fromJson(Map<String, dynamic> json) {
    return MediaInfoAuthor(
      id: _miParseInt(json['id']),
      sex: _miParseInt(json['sex']),
      avatar: json['avatar']?.toString(),
      nickName: json['nickName']?.toString(),
      authType: _miParseInt(json['authType']),
      follow: _miParseBool(json['follow']),
      fansNum: _miParseInt(json['fansNum']),
      vnum: _miParseInt(json['vnum']),
      starsNum: _miParseInt(json['starsNum']),
      beFollow: _miParseBool(json['beFollow']),
      lastPosting: json['lastPosting']?.toString(),
      introduce: json['introduce']?.toString(),
      pnum: _miParseInt(json['pnum']),
    );
  }

  /// 作者用户 ID（对应 `vod.uid`）。
  final int? id;

  /// 性别：通常 0/1/2，未提供时为 null。
  final int? sex;

  /// 头像相对路径，如 `/head/8.png`。
  final String? avatar;

  /// 昵称（与 `vod.authorName` 一致，关注/取消不会变）。
  final String? nickName;

  /// 认证类型（如 1 表示创作者）。
  final int? authType;

  /// 当前用户是否已关注该作者，关注/取消后会原地翻转。
  bool? follow;

  /// 粉丝数，关注/取消会原地 ±1。
  int? fansNum;

  /// 视频作品数（用户中心「作品」计数取此字段）。
  int? vnum;

  /// 该作者本身关注的人数。
  final int? starsNum;

  /// 是否互相关注/被关注（部分接口未返回，可能为 null）。
  final bool? beFollow;

  /// 最近一次发布时间字符串（接口当前未返回，预留）。
  final String? lastPosting;

  /// 个人简介（接口当前未返回，预留）。
  final String? introduce;

  /// 帖子/动态发布数（接口当前未返回，预留）。
  final int? pnum;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'sex': sex,
        'avatar': avatar,
        'nickName': nickName,
        'authType': authType,
        'follow': follow,
        'fansNum': fansNum,
        'vnum': vnum,
        'starsNum': starsNum,
        'beFollow': beFollow,
        'lastPosting': lastPosting,
        'introduce': introduce,
        'pnum': pnum,
      };
}

/// `result.operation`：当前登录用户对作品的交互态。
///
/// 接口示例（未登录或新作品时大部分字段为 null）：
/// ```json
/// {
///   "readChapterIndex": null,
///   "isCollection": null,
///   "isLike": null,
///   "star": null,
///   "starComment": null,
///   "createDateTime": null
/// }
/// ```
class MediaInfoOperation {
  MediaInfoOperation({
    this.readChapterIndex,
    this.isCollection,
    this.isLike,
    this.star,
    this.starComment,
    this.createDateTime,
  });

  factory MediaInfoOperation.fromJson(Map<String, dynamic> json) {
    return MediaInfoOperation(
      readChapterIndex: _miParseInt(json['readChapterIndex']),
      isCollection: _miParseBool(json['isCollection']),
      isLike: _miParseBool(json['isLike']),
      star: _miParseNum(json['star']),
      starComment: json['starComment']?.toString(),
      createDateTime: _miParseInt(json['createDateTime']),
    );
  }

  /// 上次观看到的集索引（漫画/小说类沿用，长短视频通常为 null）。
  final int? readChapterIndex;

  /// 是否已收藏。
  bool? isCollection;

  /// 是否已点赞。
  bool? isLike;

  /// 用户打分（1-5）。
  final num? star;

  /// 用户评分附带的留言。
  final String? starComment;

  /// 交互发生的时间（毫秒时间戳）。
  final int? createDateTime;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'readChapterIndex': readChapterIndex,
        'isCollection': isCollection,
        'isLike': isLike,
        'star': star,
        'starComment': starComment,
        'createDateTime': createDateTime,
      };
}

/// `result.statistics`：作品聚合统计（阅读 / 点赞 / 评分分布）。
///
/// 接口示例：
/// ```json
/// {
///   "readNumber": null, "likeNumber": null, "starAvg": null,
///   "star1": null, "star2": null, "star3": null,
///   "star4": null, "star5": null
/// }
/// ```
class MediaInfoStatistics {
  MediaInfoStatistics({
    this.readNumber,
    this.likeNumber,
    this.starAvg,
    this.star1,
    this.star2,
    this.star3,
    this.star4,
    this.star5,
  });

  factory MediaInfoStatistics.fromJson(Map<String, dynamic> json) {
    return MediaInfoStatistics(
      readNumber: _miParseInt(json['readNumber']),
      likeNumber: _miParseInt(json['likeNumber']),
      starAvg: _miParseNum(json['starAvg']),
      star1: _miParseInt(json['star1']),
      star2: _miParseInt(json['star2']),
      star3: _miParseInt(json['star3']),
      star4: _miParseInt(json['star4']),
      star5: _miParseInt(json['star5']),
    );
  }

  /// 聚合阅读/播放数。
  final int? readNumber;

  /// 聚合点赞数。
  final int? likeNumber;

  /// 平均评分。
  final num? starAvg;

  /// 1-5 星各档投票数。
  final int? star1;
  final int? star2;
  final int? star3;
  final int? star4;
  final int? star5;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'readNumber': readNumber,
        'likeNumber': likeNumber,
        'starAvg': starAvg,
        'star1': star1,
        'star2': star2,
        'star3': star3,
        'star4': star4,
        'star5': star5,
      };
}

/// `result.vod`：作品本体（与后端 cms vod 表字段对齐）。
///
/// 严格按接口示例的每个 key 都映射成一个具名属性，下面列出的注释里给出了观察
/// 到的取值；当后端字段长期为 `null` 时仍给出预期类型（如 `String?` / `int?`）
/// 而非 `dynamic`，方便上层强类型使用。
class MediaInfoVod {
  MediaInfoVod({
    this.groupId,
    this.vodTime,
    this.vodSerialNumber,
    this.themes,
    this.selfie,
    this.vodPlayUrl,
    this.vodPic,
    this.vodIntro,
    this.id,
    this.vodYear,
    this.vodVersion,
    this.videoType,
    this.scroll,
    this.priority,
    this.tags,
    this.actors,
    this.authorName,
    this.vodHorizontalPic,
    this.vodPicInfo,
    this.authors,
    this.status,
    this.preview,
    this.gif,
    this.vodClass,
    this.recommend,
    this.readNumber,
    this.title,
    this.vodPicSlide,
    this.vodVerticalPic,
    this.gold,
    this.uid,
    this.vodArea,
    this.tagsSort,
    this.collects,
    this.cols,
    this.vodPicThumb,
    this.comments,
    this.original,
    this.vodDuration,
    this.groups,
    this.vodTag,
    this.extendAttr,
    this.isVip,
    this.vodActor,
    this.mp4,
    this.vodFullPlayUrl,
    this.createTime,
    this.vodLang,
    this.likeNumber,
  });

  factory MediaInfoVod.fromJson(Map<String, dynamic> json) {
    return MediaInfoVod(
      groupId: _miParseInt(json['groupId']),
      vodTime: _miParseInt(json['vodTime']),
      vodSerialNumber: json['vodSerialNumber']?.toString(),
      themes: _miParseStringList(json['themes']),
      selfie: _miParseBool(json['selfie']),
      vodPlayUrl: json['vodPlayUrl']?.toString(),
      vodPic: json['vodPic']?.toString(),
      vodIntro: json['vodIntro']?.toString(),
      id: _miParseInt(json['id']),
      vodYear: _miParseInt(json['vodYear']),
      vodVersion: json['vodVersion']?.toString(),
      videoType: _miParseInt(json['videoType']),
      scroll: json['scroll']?.toString(),
      priority: _miParseInt(json['priority']),
      tags: _miParseStringList(json['tags']),
      actors: _miParseStringList(json['actors']),
      authorName: json['authorName']?.toString(),
      vodHorizontalPic: json['vodHorizontalPic']?.toString(),
      vodPicInfo: MediaInfoVodPicInfo.tryParse(json['vodPicInfo']),
      authors: _miParseStringList(json['authors']),
      status: _miParseInt(json['status']),
      preview: json['preview']?.toString(),
      gif: json['gif']?.toString(),
      vodClass: _miParseInt(json['vodClass']),
      recommend: _miParseInt(json['recommend']),
      readNumber: _miParseInt(json['readNumber']),
      title: json['title']?.toString(),
      vodPicSlide: json['vodPicSlide']?.toString(),
      vodVerticalPic: json['vodVerticalPic']?.toString(),
      gold: _miParseInt(json['gold']),
      uid: _miParseInt(json['uid']),
      vodArea: json['vodArea']?.toString(),
      tagsSort: (json['tagsSort'] as List<dynamic>?)
          ?.map(_miParseInt)
          .whereType<int>()
          .toList(),
      collects: _miParseInt(json['collects']),
      cols: json['cols'] is List
          ? List<dynamic>.from(json['cols'] as List<dynamic>)
          : null,
      vodPicThumb: json['vodPicThumb']?.toString(),
      comments: _miParseInt(json['comments']),
      original: _miParseBool(json['original']),
      vodDuration: _miParseInt(json['vodDuration']),
      groups: (json['groups'] as List<dynamic>?)
          ?.map(_miParseInt)
          .whereType<int>()
          .toList(),
      vodTag: json['vodTag']?.toString(),
      extendAttr: json['extendAttr']?.toString(),
      isVip: _miParseBool(json['isVip']),
      vodActor: json['vodActor']?.toString(),
      mp4: json['mp4']?.toString(),
      vodFullPlayUrl: (json['vodFullPlayUrl'] as List<dynamic>?)
          ?.whereType<Map>()
          .map(
              (e) => MediaInfoVodPlayUrl.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      createTime: _miParseInt(json['createTime']),
      vodLang: json['vodLang']?.toString(),
      likeNumber: _miParseInt(json['likeNumber']),
    );
  }

  /// 作品所在的主分组 ID。
  final int? groupId;

  /// 作品发布时间（毫秒时间戳）。
  final int? vodTime;

  /// 系列编号（接口当前未返回，预留为字符串）。
  final String? vodSerialNumber;

  /// 关联的主题列表（接口当前未返回，预期为字符串/ID 列表）。
  final List<String>? themes;

  /// 是否为自拍内容。
  final bool? selfie;

  /// 旧版单路播放地址（新接口走 [vodFullPlayUrl]，此字段一般为 null）。
  final String? vodPlayUrl;

  /// 默认封面相对路径。
  final String? vodPic;

  /// 作品简介。
  final String? vodIntro;

  /// 作品 ID。
  final int? id;

  /// 年份。
  final int? vodYear;

  /// 版本号 / 备注。
  final String? vodVersion;

  /// 视频类型：0 长视频、1 短视频，与列表接口的 `videoType` 一致。
  final int? videoType;

  /// 滚动字幕 / 跑马灯文案。
  final String? scroll;

  /// 排序优先级，数值越大越靠前。
  final int? priority;

  /// 作品标签名（中文标签，例：`["萝莉","少女"]`）。
  final List<String>? tags;

  /// 演员（接口当前未返回，预期为字符串列表）。
  final List<String>? actors;

  /// 作者昵称（取自作者快照，与 [MediaInfoAuthor.nickName] 通常一致）。
  final String? authorName;

  /// 横版封面相对路径。
  final String? vodHorizontalPic;

  /// 多尺寸封面 (`horizontal_large` / `horizontal_small` / `vertical_large` /
  /// `vertical_small`)。接口下发的是 JSON 字符串，这里解析为强类型对象。
  final MediaInfoVodPicInfo? vodPicInfo;

  /// 多作者列表（接口当前未返回，预期为字符串列表）。
  final List<String>? authors;

  /// 上下架状态：1 已上架。
  final int? status;

  /// 预览片段地址。
  final String? preview;

  /// gif 预览地址。
  final String? gif;

  /// 作品分类 ID。
  final int? vodClass;

  /// 推荐位标记。
  final int? recommend;

  /// 阅读 / 播放数（顶层快照，按时统计请走 [MediaInfoStatistics.readNumber]）。
  final int? readNumber;

  /// 作品标题。
  final String? title;

  /// 轮播图片地址。
  final String? vodPicSlide;

  /// 竖版封面相对路径。
  final String? vodVerticalPic;

  /// 解锁所需金币（0 / null 视为免费）。
  final int? gold;

  /// 作者用户 ID（对应 [MediaInfoAuthor.id]）。
  final int? uid;

  /// 地区。
  final String? vodArea;

  /// 标签排序权重，下标与 [tags] 一一对应。
  final List<int>? tagsSort;

  /// 收藏数。
  final int? collects;

  /// 关联专栏列表（结构待补，原样保留）。
  final List<dynamic>? cols;

  /// 缩略图地址。
  final String? vodPicThumb;

  /// 评论数。
  final int? comments;

  /// 是否为原创作品。
  final bool? original;

  /// 时长（秒）。
  final int? vodDuration;

  /// 所属合集分组 ID 列表。
  final List<int>? groups;

  /// 自定义标签字符串（旧字段，新接口一般为 null）。
  final String? vodTag;

  /// 扩展字段（运营自定义，原样字符串）。
  final String? extendAttr;

  /// 是否需要 VIP 才能观看。
  final bool? isVip;

  /// 演员描述（接口当前未返回）。
  final String? vodActor;

  /// 直链 MP4（旧版字段，新接口一般为 null，走 [vodFullPlayUrl]）。
  final String? mp4;

  /// 多清晰度播放地址（`高清` / `超清` / `原画` 等）。
  final List<MediaInfoVodPlayUrl>? vodFullPlayUrl;

  /// 入库时间（毫秒时间戳）。
  final int? createTime;

  /// 语言。
  final String? vodLang;

  /// 点赞数（顶层快照）。
  final int? likeNumber;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'groupId': groupId,
        'vodTime': vodTime,
        'vodSerialNumber': vodSerialNumber,
        'themes': themes,
        'selfie': selfie,
        'vodPlayUrl': vodPlayUrl,
        'vodPic': vodPic,
        'vodIntro': vodIntro,
        'id': id,
        'vodYear': vodYear,
        'vodVersion': vodVersion,
        'videoType': videoType,
        'scroll': scroll,
        'priority': priority,
        'tags': tags,
        'actors': actors,
        'authorName': authorName,
        'vodHorizontalPic': vodHorizontalPic,
        'vodPicInfo': vodPicInfo?.toJson(),
        'authors': authors,
        'status': status,
        'preview': preview,
        'gif': gif,
        'vodClass': vodClass,
        'recommend': recommend,
        'readNumber': readNumber,
        'title': title,
        'vodPicSlide': vodPicSlide,
        'vodVerticalPic': vodVerticalPic,
        'gold': gold,
        'uid': uid,
        'vodArea': vodArea,
        'tagsSort': tagsSort,
        'collects': collects,
        'cols': cols,
        'vodPicThumb': vodPicThumb,
        'comments': comments,
        'original': original,
        'vodDuration': vodDuration,
        'groups': groups,
        'vodTag': vodTag,
        'extendAttr': extendAttr,
        'isVip': isVip,
        'vodActor': vodActor,
        'mp4': mp4,
        'vodFullPlayUrl':
            vodFullPlayUrl?.map((e) => e.toJson()).toList(growable: false),
        'createTime': createTime,
        'vodLang': vodLang,
        'likeNumber': likeNumber,
      };
}

/// `vod.vodFullPlayUrl[]`：单一清晰度的播放源。
///
/// 接口示例：
/// ```json
/// { "duration": 1009, "size": 1009, "addr": "20260519/.../index.m3u8", "type": "高清" }
/// ```
class MediaInfoVodPlayUrl {
  MediaInfoVodPlayUrl({
    this.duration,
    this.size,
    this.addr,
    this.type,
  });

  factory MediaInfoVodPlayUrl.fromJson(Map<String, dynamic> json) {
    return MediaInfoVodPlayUrl(
      duration: _miParseInt(json['duration']),
      size: _miParseInt(json['size']),
      addr: json['addr']?.toString(),
      type: json['type']?.toString(),
    );
  }

  /// 时长（秒）。
  final int? duration;

  /// 文件体积（字节）。
  final int? size;

  /// 相对播放地址（拼接 CDN host 即可播放）。
  final String? addr;

  /// 清晰度名称（如 `高清`、`超清`、`原画`）。
  final String? type;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'duration': duration,
        'size': size,
        'addr': addr,
        'type': type,
      };
}

/// `vod.vodPicInfo`：多尺寸封面相对路径合集。
///
/// 接口下发为 JSON 字符串，例如：
/// ```text
/// {"horizontal_large":"","vertical_small":"",
///  "horizontal_small":"20260519/.../1959222916.png","vertical_large":""}
/// ```
/// 使用 [tryParse] 容错解析，遇到非 JSON / 非 Map 内容时返回 `null`。
class MediaInfoVodPicInfo {
  MediaInfoVodPicInfo({
    this.horizontalLarge,
    this.horizontalSmall,
    this.verticalLarge,
    this.verticalSmall,
  });

  factory MediaInfoVodPicInfo.fromJson(Map<String, dynamic> json) {
    return MediaInfoVodPicInfo(
      horizontalLarge: _emptyToNull(json['horizontal_large']?.toString()),
      horizontalSmall: _emptyToNull(json['horizontal_small']?.toString()),
      verticalLarge: _emptyToNull(json['vertical_large']?.toString()),
      verticalSmall: _emptyToNull(json['vertical_small']?.toString()),
    );
  }

  /// 接口下发的是 JSON 字符串，这里负责安全解码；解码失败返回 `null`，
  /// 调用方应当能正确处理缺省。
  static MediaInfoVodPicInfo? tryParse(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map) {
      return MediaInfoVodPicInfo.fromJson(Map<String, dynamic>.from(raw));
    }
    final str = raw.toString();
    if (str.isEmpty) return null;
    try {
      final decoded = json.decode(str);
      if (decoded is Map) {
        return MediaInfoVodPicInfo.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {}
    return null;
  }

  /// 大尺寸横版封面。
  final String? horizontalLarge;

  /// 小尺寸横版封面。
  final String? horizontalSmall;

  /// 大尺寸竖版封面。
  final String? verticalLarge;

  /// 小尺寸竖版封面。
  final String? verticalSmall;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'horizontal_large': horizontalLarge,
        'horizontal_small': horizontalSmall,
        'vertical_large': verticalLarge,
        'vertical_small': verticalSmall,
      };
}

String? _emptyToNull(String? s) {
  if (s == null) return null;
  return s.isEmpty ? null : s;
}

num? _miParseNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  return num.tryParse(v.toString());
}

/// id : "62bc78e2b0eebf50e6a60297"
/// title : "只属于我的变态女友"
/// horizontalCover : "bf211222/image/1cv/10u/2nm/2pi/021e47f73891bb3d5b0d644bd0e278f6.jpg"
/// verticalCover : "bf211222/image/17a/2ct/1e/k6/a01c3c765737899ecbb71b52a1407780.jpg"
/// tags : ["62ab4404aae377f930517667","62ab3f3daae377f930517620","62ab3fb2aae377f930517628","62ab411aaae377f930517645","62ab41c1aae377f93051765a"]
/// tagNames : ["无码","公主","贫乳","口交","内射"]
/// summary : "有一所著名的全女子學校，去那兒的女孩之一是瀧川雛。我知道她的秘密已有半年了。我不能告訴任何人，除了我，沒人知道。她甚至不知道我知道這件事。但即使我也不知道她的所有秘密..."
/// totalEpisode : 2
/// mediaType : "video"
/// kind : 0
/// price : 0
/// direction : 1
/// sellType : 0
/// general : "000000000000000000000000"
/// generalSort : 0
/// choice : "62ab5aa3a2ec53dcc88fa703"
/// choiceSort : 1
/// isActive : true
/// countPurchases : 0
/// countBrowse : 0
/// countCollect : 0
/// countLike : 0
/// number : 0
/// createdAt : "2022-06-30T00:08:02.207+08:00"
/// updatedAt : "2022-06-30T00:08:02.207+08:00"
/// contents : [{"id":"62bc784ec6152547fc4a8f2d","mediaID":"62bc78e2b0eebf50e6a60297","episodeNumber":1,"listenPermission":1,"price":0,"name":"第一话","text":"","md5":"","videoUrl":"sp/68/b0/jo/u0/db65323f0de749eb8fc2161ddf87f265.m3u8","urlSet":null,"height":0,"weight":0,"mediaSize":0,"playTime":0,"status":0,"isActive":false,"hasPaid":false},{"id":"62bd24a0c6152547fc4a912b","mediaID":"62bc78e2b0eebf50e6a60297","episodeNumber":2,"listenPermission":1,"price":10,"name":"第二话","text":"","md5":"","videoUrl":"sp/5c/ya/4y/t6/3dc3ba9362664785a8245f8305aa9492.m3u8","urlSet":null,"height":0,"weight":0,"mediaSize":0,"playTime":0,"status":0,"isActive":false,"hasPaid":false}]
/// hasLiked : false
/// hasPaid : false
/// hasCollected : false

class Data {
  Data({
    String? id,
    String? title,
    String? horizontalCover,
    String? verticalCover,
    List<String>? tags,
    List<String>? tagNames,
    String? summary,
    int? totalEpisode,
    int? permission,
    String? mediaType,
    int? kind,
    int? price,
    int? direction,
    int? sellType,
    String? general,
    int? generalSort,
    String? choice,
    int? choiceSort,
    bool? isActive,
    int? countPurchases,
    int? countBrowse,
    int? countCollect,
    int? countLike,
    int? number,
    int? countComment,
    String? createdAt,
    String? updatedAt,
    List<Contents>? contents,
    bool? hasLiked,
    bool? hasPaid,
    bool? hasCollected,
    int? updateStatus,
    String? updatedDesc,
  }) {
    _id = id;
    _title = title;
    _horizontalCover = horizontalCover;
    _verticalCover = verticalCover;
    _tags = tags;
    _tagNames = tagNames;
    _summary = summary;
    _totalEpisode = totalEpisode;
    _mediaType = mediaType;
    _permission = permission;
    _kind = kind;
    _price = price;
    _direction = direction;
    _sellType = sellType;
    _general = general;
    _generalSort = generalSort;
    _choice = choice;
    _choiceSort = choiceSort;
    _isActive = isActive;
    _countPurchases = countPurchases;
    _countBrowse = countBrowse;
    _countCollect = countCollect;
    _countLike = countLike;
    _number = number;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _contents = contents;
    _hasLiked = hasLiked;
    _hasPaid = hasPaid;
    _hasCollected = hasCollected;

    _updateStatus = updateStatus;
    _updatedDesc = updatedDesc;
  }

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _title = json['title'];
    _horizontalCover = json['horizontalCover'];
    _verticalCover = json['verticalCover'];
    _tags = json['tags'] != null ? json['tags'].cast<String>() : [];
    _tagNames = json['tagNames'] != null ? json['tagNames'].cast<String>() : [];
    _summary = json['summary'];
    _totalEpisode = json['totalEpisode'];
    _mediaType = json['mediaType'];
    _permission = json['permission'];
    _kind = json['kind'];
    _price = json['price'];
    _direction = json['direction'];
    _sellType = json['sellType'];
    _general = json['general'];
    _generalSort = json['generalSort'];
    _choice = json['choice'];
    _choiceSort = json['choiceSort'];
    _isActive = json['isActive'];
    _countPurchases = json['countPurchases'];
    _countBrowse = json['countBrowse'];
    _countCollect = json['countCollect'];
    _countLike = json['countLike'];
    _number = json['number'];
    _countComment = json['countComment'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    if (json['contents'] != null) {
      _contents = [];
      json['contents'].forEach((v) {
        _contents?.add(Contents.fromJson(v));
      });
    }
    _hasLiked = json['hasLiked'];
    _hasPaid = json['hasPaid'];
    _hasCollected = json['hasCollected'];

    _updateStatus = json['updateStatus'];
    _updatedDesc = json['updatedDesc'];
  }
  String? _id;
  String? _title;
  String? _horizontalCover;
  String? _verticalCover;
  List<String>? _tags;
  List<String>? _tagNames;
  String? _summary;
  int? _totalEpisode;
  String? _mediaType;
  int? _kind;
  int? _permission;
  int? _price;
  int? _direction;
  int? _sellType;
  String? _general;
  int? _generalSort;
  String? _choice;
  int? _choiceSort;
  bool? _isActive;
  int? _countPurchases;
  int? _countBrowse;
  int? _countCollect;
  int? _countLike;
  int? _number;
  int? _countComment;
  String? _createdAt;
  String? _updatedAt;
  List<Contents>? _contents;
  bool? _hasLiked;
  bool? _hasPaid;
  bool? _hasCollected;

  int? _updateStatus;
  String? _updatedDesc;

  String? get id => _id;
  String? get title => _title;
  String? get horizontalCover => _horizontalCover;
  String? get verticalCover => _verticalCover;
  List<String>? get tags => _tags;
  List<String>? get tagNames => _tagNames;
  String? get summary => _summary;
  int? get totalEpisode => _totalEpisode;
  String? get mediaType => _mediaType;
  int? get kind => _kind;
  int? get price => _price;
  int? get permission => _permission;
  int? get direction => _direction;
  int? get sellType => _sellType;
  String? get general => _general;
  int? get generalSort => _generalSort;
  String? get choice => _choice;
  int? get choiceSort => _choiceSort;
  bool? get isActive => _isActive;
  int? get countPurchases => _countPurchases;
  int? get countBrowse => _countBrowse;
  int? get countCollect => _countCollect;
  int? get countLike => _countLike;
  int? get number => _number;
  int? get countComment => _countComment;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  List<Contents>? get contents => _contents;
  bool? get hasLiked => _hasLiked;
  bool? get hasPaid => _hasPaid;
  bool? get hasCollected => _hasCollected;

  int? get updateStatus => _updateStatus;

  String? get updatedDesc => _updatedDesc;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['title'] = _title;
    map['horizontalCover'] = _horizontalCover;
    map['verticalCover'] = _verticalCover;
    map['tags'] = _tags;
    map['tagNames'] = _tagNames;
    map['summary'] = _summary;
    map['permission'] = _permission;
    map['totalEpisode'] = _totalEpisode;
    map['mediaType'] = _mediaType;
    map['kind'] = _kind;
    map['price'] = _price;
    map['direction'] = _direction;
    map['sellType'] = _sellType;
    map['general'] = _general;
    map['generalSort'] = _generalSort;
    map['choice'] = _choice;
    map['choiceSort'] = _choiceSort;
    map['isActive'] = _isActive;
    map['countPurchases'] = _countPurchases;
    map['countBrowse'] = _countBrowse;
    map['countCollect'] = _countCollect;
    map['countLike'] = _countLike;
    map['number'] = _number;
    map['countComment'] = _countComment;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    if (_contents != null) {
      map['contents'] = _contents?.map((v) => v.toJson()).toList();
    }
    map['hasLiked'] = _hasLiked;
    map['hasPaid'] = _hasPaid;
    map['hasCollected'] = _hasCollected;

    map['updateStatus'] = _updateStatus;
    map['updatedDesc'] = _updatedDesc;
    return map;
  }
}

/// id : "62bc784ec6152547fc4a8f2d"
/// mediaID : "62bc78e2b0eebf50e6a60297"
/// episodeNumber : 1
/// listenPermission : 1
/// price : 0
/// name : "第一话"
/// text : ""
/// md5 : ""
/// videoUrl : "sp/68/b0/jo/u0/db65323f0de749eb8fc2161ddf87f265.m3u8"
/// urlSet : null
/// height : 0
/// weight : 0
/// mediaSize : 0
/// playTime : 0
/// status : 0
/// isActive : false
/// hasPaid : false

class Contents {
  Contents(
      {String? id,
      String? mediaID,
      int? episodeNumber,
      int? listenPermission,
      int? price,
      String? name,
      String? text,
      String? md5,
      String? videoUrl,
      List<String>? urlSet,
      int? height,
      int? weight,
      int? mediaSize,
      int? playTime,
      int? status,
      bool? isActive,
      bool? hasPaid,
      double? ratio}) {
    _id = id;
    _mediaID = mediaID;
    _episodeNumber = episodeNumber;
    _listenPermission = listenPermission;
    _price = price;
    _name = name;
    _text = text;
    _md5 = md5;
    _videoUrl = videoUrl;
    _urlSet = urlSet;
    _height = height;
    _weight = weight;
    _mediaSize = mediaSize;
    _playTime = playTime;
    _status = status;
    _isActive = isActive;
    _hasPaid = hasPaid;
    _ratio = ratio;
  }

  Contents.fromJson(dynamic json) {
    _id = json['id'];
    _mediaID = json['mediaID'];
    _episodeNumber = json['episodeNumber'];
    _listenPermission = json['listenPermission'];
    _price = json['price'];
    _name = json['name'];
    _text = json['text'];
    _md5 = json['md5'];
    _videoUrl = json['videoUrl'];
    _urlSet = json['urlSet'] != null ? json['urlSet'].cast<String>() : [];
    _height = json['height'];
    _weight = json['weight'];
    _mediaSize = json['mediaSize'];
    _playTime = json['playTime'];
    _status = json['status'];
    _isActive = json['isActive'];
    _hasPaid = json['hasPaid'];
    _ratio = json['ratio'] == 0 ? null : json['ratio'];
  }
  String? _id;
  String? _mediaID;
  int? _episodeNumber;
  int? _listenPermission;
  int? _price;
  String? _name;
  String? _text;
  String? _md5;
  String? _videoUrl;
  List<String>? _urlSet;
  int? _height;
  int? _weight;
  int? _mediaSize;
  int? _playTime;
  int? _status;
  bool? _isActive;
  bool? _hasPaid;
  num? _ratio;

  String? get id => _id;
  String? get mediaID => _mediaID;
  int? get episodeNumber => _episodeNumber;
  int? get listenPermission => _listenPermission;
  int? get price => _price;
  String? get name => _name;
  String? get text => _text;
  String? get md5 => _md5;
  String? get videoUrl => _videoUrl;
  List<String>? get urlSet => _urlSet;
  int? get height => _height;
  int? get weight => _weight;
  int? get mediaSize => _mediaSize;
  int? get playTime => _playTime;
  int? get status => _status;
  bool? get isActive => _isActive;
  bool? get hasPaid => _hasPaid;
  num? get ratio => _ratio;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['mediaID'] = _mediaID;
    map['episodeNumber'] = _episodeNumber;
    map['listenPermission'] = _listenPermission;
    map['price'] = _price;
    map['name'] = _name;
    map['text'] = _text;
    map['md5'] = _md5;
    map['videoUrl'] = _videoUrl;
    map['urlSet'] = _urlSet;
    map['height'] = _height;
    map['weight'] = _weight;
    map['mediaSize'] = _mediaSize;
    map['playTime'] = _playTime;
    map['status'] = _status;
    map['isActive'] = _isActive;
    map['hasPaid'] = _hasPaid;
    map['ratio'] = _ratio;
    return map;
  }
}
