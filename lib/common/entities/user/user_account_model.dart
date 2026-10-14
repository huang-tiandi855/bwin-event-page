/// 用户简档（账号信息）通用模型。
///
/// 后端多个接口的"用户对象"形状一致，本模型作为公共复用实体：
/// - `POST /fans/stars`  我的关注（[MineApis.getMyFollowList]）
/// - `POST /fans/fans`   我的粉丝（[MineApis.getMyFansList]）
/// - `GET  cms/vod/comment/list` 评论列表的 `account` 字段
///   （[MediaApi.getVodCommentList] → [VodCommentItemModel.account]）
/// - 其它返回"用户简档"形状的接口均可复用。
///
/// 接口示例：
/// ```json
/// {
///   "authType": 0,
///   "avatar": "string",
///   "beFollow": true,
///   "fansNum": 0,
///   "follow": true,
///   "id": 0,
///   "introduce": "string",
///   "lastPosting": 0,
///   "nickName": "string",
///   "pnum": 0,
///   "sex": 0,
///   "starsNum": 0,
///   "vnum": 0
/// }
/// ```
class UserAccountModel {
  UserAccountModel({
    this.id,
    this.nickName,
    this.avatar,
    this.introduce,
    this.authType,
    this.sex,
    this.follow,
    this.beFollow,
    this.fansNum,
    this.starsNum,
    this.vnum,
    this.pnum,
    this.lastPosting,
  });

  /// 用户 uid。
  int? id;

  /// 昵称。
  String? nickName;

  /// 头像 URL。
  String? avatar;

  /// 个性签名 / 简介，空字符串视为「这个人还没有签名」。
  String? introduce;

  /// 认证类型：0 普通用户 / 其他枚举见后端文档。
  int? authType;

  /// 性别：0 未知 / 1 男 / 2 女（按通用约定，具体以后端为准）。
  int? sex;

  /// 当前登录用户「是否已关注 TA」。
  bool? follow;

  /// 对方「是否关注了我」。`follow == true && beFollow == true` 可视为互关。
  bool? beFollow;

  /// TA 的粉丝数。
  int? fansNum;

  /// TA 关注的用户数。
  int? starsNum;

  /// TA 的视频 / 作品数（与 `MediaInfoAuthor.vnum` 同义）。
  int? vnum;

  /// TA 的帖子数。
  int? pnum;

  /// TA 最后一次发帖时间（毫秒时间戳）。
  int? lastPosting;

  /// 互关：双向都关注。
  bool get isMutual => (follow ?? false) && (beFollow ?? false);

  factory UserAccountModel.fromJson(Map<String, dynamic> json) {
    return UserAccountModel(
      id: _parseInt(json['id']),
      nickName: json['nickName']?.toString(),
      avatar: json['avatar']?.toString(),
      introduce: json['introduce']?.toString(),
      authType: _parseInt(json['authType']),
      sex: _parseInt(json['sex']),
      follow: _parseBool(json['follow']),
      beFollow: _parseBool(json['beFollow']),
      fansNum: _parseInt(json['fansNum']),
      starsNum: _parseInt(json['starsNum']),
      vnum: _parseInt(json['vnum']),
      pnum: _parseInt(json['pnum']),
      lastPosting: _parseInt(json['lastPosting']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'nickName': nickName,
        'avatar': avatar,
        'introduce': introduce,
        'authType': authType,
        'sex': sex,
        'follow': follow,
        'beFollow': beFollow,
        'fansNum': fansNum,
        'starsNum': starsNum,
        'vnum': vnum,
        'pnum': pnum,
        'lastPosting': lastPosting,
      };

  /// 从接口返回的任意 `data`（直接是 `List` 或包了一层 `{list: [...]}`）里
  /// 提取列表，安全地解析成 [UserAccountModel]。
  static List<UserAccountModel> listFromData(dynamic data) {
    final List? raw = data is List
        ? data
        : (data is Map ? (data['list'] as List?) : null);
    if (raw == null) return <UserAccountModel>[];
    return raw
        .whereType<Map>()
        .map((e) => UserAccountModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final s = value.toString().toLowerCase();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return null;
}
