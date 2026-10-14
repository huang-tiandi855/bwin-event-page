import 'package:comics_app/common/entities/home/home_media_list_models.dart';

/// `cms/vod/authors/videos`（[MediaApi.getShortRecommendFollowsList]）返回的
/// 推荐关注作者 + 其代表作短视频列表。`data` 顶层是数组，本文件提供：
/// - [RecommendFollowAuthorModel]：作者卡数据；
/// - [ShortRecommendFollowItemModel]：单项（author + uid + videos[]），
///   其中 `videos` 直接复用首页的 [MediaVideoModel]，避免再造一份只差名字的短视频结构。

int? _rffToInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

bool? _rffToBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString().toLowerCase();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return null;
}

Map<String, dynamic>? _rffAsMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return Map<String, dynamic>.from(v);
  return null;
}

/// 推荐关注 - 作者卡（接口 `author` 字段）。
class RecommendFollowAuthorModel {
  RecommendFollowAuthorModel({
    this.authType,
    this.avatar,
    this.beFollow,
    this.fansNum,
    this.follow,
    this.id,
    this.introduce,
    this.lastPosting,
    this.nickName,
    this.pnum,
    this.sex,
    this.starsNum,
    this.vnum,
  });

  factory RecommendFollowAuthorModel.fromJson(Map<String, dynamic> json) {
    return RecommendFollowAuthorModel(
      authType: _rffToInt(json['authType']),
      avatar: json['avatar']?.toString(),
      beFollow: _rffToBool(json['beFollow']),
      fansNum: _rffToInt(json['fansNum']),
      follow: _rffToBool(json['follow']),
      id: _rffToInt(json['id']),
      introduce: json['introduce']?.toString(),
      lastPosting: _rffToInt(json['lastPosting']),
      nickName: json['nickName']?.toString(),
      pnum: _rffToInt(json['pnum']),
      sex: _rffToInt(json['sex']),
      starsNum: _rffToInt(json['starsNum']),
      vnum: _rffToInt(json['vnum']),
    );
  }

  /// 认证类型，由后端约定（如 0:无 / 1:个人 / 2:机构）。
  final int? authType;

  /// 头像 URL。
  final String? avatar;

  /// 对方是否关注了我（互关判断）。
  final bool? beFollow;

  /// 粉丝数。
  final int? fansNum;

  /// 我是否已关注 TA。
  ///
  /// 故意保持可变：UI 上点击「+关注 / 已关注」按钮成功后，logic 会就地翻这个
  /// 字段（与 `UserAccountModel.follow` 同样的就地切换模式），避免维护一份
  /// 「locally followed uid set」与模型双写。
  bool? follow;

  /// 作者 id。
  final int? id;

  /// 个性签名 / 简介。
  final String? introduce;

  /// 最后一次发帖时间（毫秒时间戳）。
  final int? lastPosting;

  /// 昵称。
  final String? nickName;

  /// 帖子数。
  final int? pnum;

  /// 性别：0 未知 / 1 男 / 2 女。
  final int? sex;

  /// 收藏数。
  final int? starsNum;

  /// 视频数。
  final int? vnum;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'authType': authType,
        'avatar': avatar,
        'beFollow': beFollow,
        'fansNum': fansNum,
        'follow': follow,
        'id': id,
        'introduce': introduce,
        'lastPosting': lastPosting,
        'nickName': nickName,
        'pnum': pnum,
        'sex': sex,
        'starsNum': starsNum,
        'vnum': vnum,
      };
}

/// 推荐关注列表单项。
class ShortRecommendFollowItemModel {
  ShortRecommendFollowItemModel({
    this.author,
    this.uid,
    this.videos = const [],
  });

  factory ShortRecommendFollowItemModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? authorMap = _rffAsMap(json['author']);
    return ShortRecommendFollowItemModel(
      author: authorMap == null
          ? null
          : RecommendFollowAuthorModel.fromJson(authorMap),
      uid: _rffToInt(json['uid']),
      // 复用首页的视频模型，列表解析也走它自带的 [MediaVideoModel.listFromData]，
      // 后端字段（videoType / vodPic / vodPicInfo 等）保持单一真源。
      videos: MediaVideoModel.listFromData(json['videos']),
    );
  }

  /// 作者卡。
  final RecommendFollowAuthorModel? author;

  /// 关联 uid（接口顶层 `uid`）。一般与 [author.id] 一致，分两个字段是为
  /// 兼容服务端在某些场景下 uid 与 author.id 不重合（如代理 / 子账号）。
  final int? uid;

  /// 该作者的代表作短视频列表。
  final List<MediaVideoModel> videos;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'author': author?.toJson(),
        'uid': uid,
        'videos': videos.map((e) => e.toJson()).toList(),
      };

  /// 解析接口 `data`（顶层 JSON 数组）。
  static List<ShortRecommendFollowItemModel> listFromData(dynamic data) {
    if (data == null || data is! List) return [];
    final out = <ShortRecommendFollowItemModel>[];
    for (final e in data) {
      final m = _rffAsMap(e);
      if (m != null) {
        out.add(ShortRecommendFollowItemModel.fromJson(m));
      }
    }
    return out;
  }
}
