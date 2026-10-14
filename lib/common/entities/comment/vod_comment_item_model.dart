import 'package:comics_app/common/entities/user/user_account_model.dart';

/// 长视频评论列表项（`MediaApi.getVodCommentList` 返回数组的元素）。
///
/// 接口示例（顶层是数组，每条形如下）：
/// ```json
/// {
///   "account": {
///     "authType": 0,
///     "avatar": "string",
///     "beFollow": true,
///     "fansNum": 0,
///     "follow": true,
///     "id": 0,
///     "introduce": "string",
///     "lastPosting": 0,
///     "nickName": "string",
///     "pnum": 0,
///     "sex": 0,
///     "starsNum": 0,
///     "vnum": 0
///   },
///   "comment": {
///     "aid": 0,
///     "content": "string",
///     "createTime": "2026-05-21T06:56:20.200Z",
///     "id": 0,
///     "vid": 0
///   }
/// }
/// ```
///
/// `account` 与 [UserAccountModel] 完全同构（同一个用户简档结构），这里直接
/// 复用，避免重复实体；`comment` 由 [VodCommentModel] 表达。
///
/// 后追加的同层字段：
/// - `likeNum`：点赞数；
/// - `like`：当前登录用户是否点过赞；
/// - `lower`：踩 / 不喜欢标记（接口未定具体类型，按宽松 `dynamic` 透传）；
/// - `childNum`：子评论数（楼中楼），暂未在 UI 中展开。
class VodCommentItemModel {
  VodCommentItemModel({
    this.account,
    this.comment,
    this.likeNum = 0,
    this.like = false,
    this.lower,
    this.childNum = 0,
  });

  /// 评论作者的用户简档。
  UserAccountModel? account;

  /// 评论正文与元信息。
  VodCommentModel? comment;

  /// 点赞数。
  int likeNum;

  /// 当前用户是否已点赞。
  bool like;

  /// 踩 / 不喜欢标记（接口未明确类型，原样透传备用）。
  dynamic lower;

  /// 子评论数（楼中楼）。
  int childNum;

  /// 便捷别名：拿到评论 id。
  int? get commentId => comment?.id;

  /// 便捷别名：拿到评论用户 uid。
  int? get authorUid => account?.id;

  factory VodCommentItemModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawAccount = json['account'];
    final dynamic rawComment = json['comment'];
    return VodCommentItemModel(
      account: rawAccount is Map
          ? UserAccountModel.fromJson(Map<String, dynamic>.from(rawAccount))
          : null,
      comment: rawComment is Map
          ? VodCommentModel.fromJson(Map<String, dynamic>.from(rawComment))
          : null,
      likeNum: _parseInt(json['likeNum'] ?? json['comment']['perfect']) ?? 0,
      like: _parseBool(json['like'] ?? json['perfect']),
      lower: json['lower'],
      childNum: _parseInt(json['childNum']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'account': account?.toJson(),
        'comment': comment?.toJson(),
        'likeNum': likeNum,
        'like': like,
        'lower': lower,
        'childNum': childNum,
      };

  /// 从接口返回的任意 `data`（直接是 `List` 或包了一层 `{list: [...]}`）里
  /// 提取列表并解析。
  static List<VodCommentItemModel> listFromData(dynamic data) {
    final List? raw = data is List
        ? data
        : (data is Map ? (data['list'] as List?) : null);
    if (raw == null) return <VodCommentItemModel>[];
    return raw
        .whereType<Map>()
        .map((e) => VodCommentItemModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

/// `comment` 子对象：评论正文与元信息。
class VodCommentModel {
  VodCommentModel({
    this.id,
    this.aid,
    this.vid,
    this.content,
    this.createTime,
  });

  /// 评论 id。
  int? id;

  /// 评论者 uid（`account.id` 通常与之一致；以本字段为准做引用）。
  int? aid;

  /// 所属视频 id。
  int? vid;

  /// 评论正文。
  String? content;

  /// 创建时间。后端两套形态都见过：
  /// - ISO8601 字符串，例 `2026-05-21T06:56:20.200Z`
  /// - 毫秒时间戳数字（被原样 `toString` 后存为 `"1779356700000"`）
  ///
  /// 统一用 [createDateTime] 兼容解析，不强转字段类型，避免破坏旧调用。
  String? createTime;

  /// 把 `createTime` 解析为 [DateTime]：先按毫秒数字处理，再按 ISO 字符串。
  /// 都失败返回 `null`。
  DateTime? get createDateTime {
    final s = createTime;
    if (s == null || s.isEmpty) return null;
    final int? asMillis = int.tryParse(s);
    if (asMillis != null) {
      return DateTime.fromMillisecondsSinceEpoch(asMillis);
    }
    return DateTime.tryParse(s);
  }

  factory VodCommentModel.fromJson(Map<String, dynamic> json) {
    return VodCommentModel(
      id: _parseInt(json['id']),
      aid: _parseInt(json['aid']),
      vid: _parseInt(json['vid']),
      content: json['content']?.toString(),
      createTime: json['createTime']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'aid': aid,
        'vid': vid,
        'content': content,
        'createTime': createTime,
      };
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final s = value.toString().toLowerCase();
  return s == 'true' || s == '1';
}
