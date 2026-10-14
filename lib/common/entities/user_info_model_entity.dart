import 'dart:convert';

import '../store/config.dart';

/// 当前登录用户聚合资料（`/user/profile` → `UserProfileBundleVO`）。
///
/// 嵌套对象 `account`（`CloudAccountVO`）解析为下列 Dart 命名：
/// `accessToken`→[token]、`phone`→[mobile]、`nickName`→[name]、`avatar`→[portrait]、
/// `sex`→[gender]、`invitationCode`→[promotionCode]；其余与 JSON 键一致。
class UserInfoModelEntity {
  // --- CloudAccountVO：JSON 键 `account`，当前登录用户资料 ---

  /// 访问令牌；JSON `account.accessToken`。
  String? token;

  /// 登录账号；JSON `account.account`。
  String? account;

  /// 账号等级；JSON `account.accountLevel`。
  int? accountLevel;

  /// 代理等级；JSON `account.agentLevel`。
  int? agentLevel;

  /// 认证类型；JSON `account.authType`。
  int? authType;

  /// `account.avatar`，与评论 / 帖子等接口里他人 `account.avatar` 同种形态
  /// （一般是 `/head/{n}.png` 之类的相对路径，由 CDN 拼接）。
  ///
  /// 与顶层 [avatarUrl] 区别：
  /// - [avatarUrl]：聚合自 `/user/avatarUrl` 接口的结果，可能为空；
  /// - [portrait]：始终来自 `/user/profile` 的 `account.avatar`，作为本人头像
  ///   的兜底。统一显示请用 [bestAvatar]。
  String? portrait;

  /// 绑定状态；JSON `account.bindStatus`。
  ///  //绑定状态   0 未绑定，  1 绑定手机
  int? bindStatus;

  /// 渠道编号；JSON `account.channelCode`。
  String? channelCode;

  /// 注册时间（`$date-time`）；JSON `account.createDate`。
  String? createDate;

  /// 粉丝数；JSON `account.fans`。
  int? fans;

  /// 剩余金币数（应用侧）；JSON `account.gold`。
  int? gold;

  /// 用户主键 ID；JSON `account.id`。
  int? uid;

  /// 个人介绍/签名；JSON `account.introduce`。
  String? introduce;

  /// 邀请码；JSON `account.invitationCode`。
  String? invitationCode;

  /// 是否新用户；JSON `account.newUser`。
  bool? newUser;

  /// 昵称；JSON `account.nickName`。
  String? name;

  /// 手机号（明文，脱敏策略由服务端控制）；JSON `account.phone`。
  String? mobile;

  /// 性别；JSON `account.sex`。
  ///  0女 ，1男
  int? gender;

  /// 关注数；JSON `account.stars`。
  int? stars;

  /// 令牌失效时间（`$date-time`）；JSON `account.tokenValidDate`。
  String? tokenValidDate;

  /// 脱敏/编码后的手机号展示；JSON `account.tphone`。
  String? tphone;

  /// VIP 类型；JSON `account.vipType`。
  /// 0:普通vip 2:暗网  3:全网 与vipValidDate配合使用
  int? vipType;

  /// VIP 到期时间（`$date-time`）；JSON `account.vipValidDate`。
  String? vipValidDate;

  // --- UserProfileBundleVO 聚合字段（与 `account` 同级）---

  /// AI 换脸可用次数，对应 `TCloudWallet.aiFaceSwapTimes`。
  int? aiFaceSwapTimes;

  /// AI 脱衣可用次数，对应 `TCloudWallet.aiUndressTimes`。
  int? aiUndressTimes;

  /// 与 GET `/user/avatar` 的 result 一致，无头像时为 null。
  String? avatarBase64;

  /// 与 GET `/user/avatarUrl` 的 result 一致。
  String? avatarUrl;

  /// 与 GET `/user/invite/count` 的 data 一致，无邀请时可能为 null。
  int? inviteCount;

  /// 当前展示用会员卡名称（服务端解析 VIP 类型与有效期等）；无有效卡时为 null。
  String? membershipCardName;

  /// 观影券次数，对应 `TCloudWallet.movieTickets`。
  int? movieTickets;

  /// 新人免费次数。
  int? maxFreeUserPlay;

  /// 新人 24 小时权益到期时间(毫秒时间戳)；无权益时为 null。
  String? newUser24HourExpireAt;

  /// **应用侧金币余额**，对应 `TCloudWallet.app`。
  ///
  /// 全应用「展示/扣减用户金币」的统一参数，与 [walletCoins]（云钱包 coins）
  /// 区分开：金币 overlay、付费弹窗、钱包页等读取的"剩余金币"全部使用
  /// 本字段，避免再用旧的 `account.gold` 兜底导致数值口径不一致。
  int? walletApp;

  /// 钱包用户金币余额，对应 `TCloudWallet.coins`。
  int? walletCoins;

  /// 钱包用户积分，对应 `TCloudWallet.points`。
  int? walletPoints;

  /// 是否已关注（业务占位）；JSON 顶层 `isFollow`，后端暂未返回时为 null。
  bool? isFollow;

  /// 当前用户最优头像：优先 [avatarUrl]（聚合接口的成品 URL），为空时回退到
  /// [portrait]（`account.avatar`，与他人评论里的头像同形态）。
  ///
  /// 任何"渲染本人头像 / 把本人头像拼进列表项"的场景统一走这个 getter，避免
  /// 因为 `/user/avatarUrl` 没及时拉到导致占位。
  String? get bestAvatar {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) return avatarUrl;
    if (portrait != null && portrait!.isNotEmpty) return portrait;
    return null;
  }

//是否是vip
  bool get isVip {
    if (vipType == null || vipValidDate == null || vipValidDate!.isEmpty) {
      return false;
    }
    if (vipType == 0 || vipType == 2 || vipType == 3) {
      return DateTime.fromMillisecondsSinceEpoch(int.parse(vipValidDate!))
          .isAfter(DateTime.now());
    }
    return false;
  }

  bool get isNormalVip {
    if (vipType == null || vipValidDate == null || vipValidDate!.isEmpty) {
      return false;
    }
    if (vipType == 0) {
      return DateTime.fromMillisecondsSinceEpoch(int.parse(vipValidDate!))
          .isAfter(DateTime.now());
    }
    return false;
  }

  bool get isDarkVip {
    if (vipType == null || vipValidDate == null || vipValidDate!.isEmpty) {
      return false;
    }
    if (vipType == 3 || vipType == 2) {
      return DateTime.fromMillisecondsSinceEpoch(int.parse(vipValidDate!))
          .isAfter(DateTime.now());
    }
    return false;
  }

  bool get isAllVip {
    if (vipType == null || vipValidDate == null || vipValidDate!.isEmpty) {
      return false;
    }
    if (vipType == 3) {
      return DateTime.fromMillisecondsSinceEpoch(int.parse(vipValidDate!))
          .isAfter(DateTime.now());
    }
    return false;
  }

  /// 默认构造，字段由 [fromJson] 填充。
  UserInfoModelEntity();

  /// 解析 `/user/profile` 返回体：读取 `account` 子对象及顶层聚合字段。
  factory UserInfoModelEntity.fromJson(Map<String, dynamic> json) {
    final e = UserInfoModelEntity();
    final acc = _readAccountMap(json);
    if (acc != null) {
      e.token = _asString(acc['accessToken']);
      e.account = _asString(acc['account']);
      e.accountLevel = _asInt(acc['accountLevel']);
      e.agentLevel = _asInt(acc['agentLevel']);
      e.authType = _asInt(acc['authType']);
      e.portrait = _asString(acc['avatar']);
      e.bindStatus = _asInt(acc['bindStatus']);
      e.channelCode = _asString(acc['channelCode']);
      e.createDate = _asString(acc['createDate']);
      e.fans = _asInt(acc['fans']);
      e.gold = _asInt(acc['gold']);
      e.uid = _asInt(acc['id']);
      e.introduce = _asString(acc['introduce']);
      e.invitationCode = _asString(acc['invitationCode']);
      e.newUser = _asBool(acc['newUser']);
      e.name = _asString(acc['nickName']);
      e.mobile = _asString(acc['phone']);
      e.gender = _asInt(acc['sex']);
      e.stars = _asInt(acc['stars']);
      e.tokenValidDate = _asString(acc['tokenValidDate']);
      e.tphone = _asString(acc['tphone']);
      e.vipType = _asInt(acc['vipType']);
      e.vipValidDate = _asString(acc['vipValidDate']);
    }

    e.aiFaceSwapTimes = _asInt(json['aiFaceSwapTimes']);
    e.aiUndressTimes = _asInt(json['aiUndressTimes']);
    e.avatarBase64 = _asString(json['avatarBase64']);
    e.avatarUrl = _asString(json['avatarUrl']);
    e.inviteCount = _asInt(json['inviteCount']);
    e.membershipCardName = _asString(json['membershipCardName']);
    e.movieTickets = _asInt(json['movieTickets']);
    e.maxFreeUserPlay = _asInt(json['maxFreeUserPlay']);
    e.newUser24HourExpireAt = _asString(json['newUser24HourExpireAt']);
    e.walletApp = _asInt(json['walletApp']);
    e.walletCoins = _asInt(json['walletCoins']);
    e.walletPoints = _asInt(json['walletPoints']);
    e.isFollow = _asBool(json['isFollow']);

    return e;
  }

  /// 序列化为接口形状：`account` 内使用后端原始键名（与 [fromJson] 对称）。
  Map<String, dynamic> toJson() => {
        'account': {
          'accessToken': token,
          'account': account,
          'accountLevel': accountLevel,
          'agentLevel': agentLevel,
          'authType': authType,
          'avatar': portrait,
          'bindStatus': bindStatus,
          'channelCode': channelCode,
          'createDate': createDate,
          'fans': fans,
          'gold': gold,
          'id': uid,
          'introduce': introduce,
          'invitationCode': invitationCode,
          'newUser': newUser,
          'nickName': name,
          'phone': mobile,
          'sex': gender,
          'stars': stars,
          'tokenValidDate': tokenValidDate,
          'tphone': tphone,
          'vipType': vipType,
          'vipValidDate': vipValidDate,
        },
        'aiFaceSwapTimes': aiFaceSwapTimes,
        'aiUndressTimes': aiUndressTimes,
        'avatarBase64': avatarBase64,
        'avatarUrl': avatarUrl,
        'inviteCount': inviteCount,
        'membershipCardName': membershipCardName,
        'movieTickets': movieTickets,
        'maxFreeUserPlay': maxFreeUserPlay,
        'newUser24HourExpireAt': newUser24HourExpireAt,
        'walletApp': walletApp,
        'walletCoins': walletCoins,
        'walletPoints': walletPoints,
        'isFollow': isFollow,
      };

  /// 取出 JSON 中的 `account` Map，缺省或类型不符时返回 null。
  static Map<String, dynamic>? _readAccountMap(Map<String, dynamic> json) {
    final raw = json['account'];
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  /// 宽松转为 [String]；null 返回 null。
  static String? _asString(dynamic v) {
    if (v == null) return null;
    return v is String ? v : v.toString();
  }

  /// 宽松转为 [int]；支持 [num] 与数字字符串。
  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  /// 宽松转为 [bool]；数字非 0 视为 true。
  static bool? _asBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is num) return v != 0;
    return null;
  }

  /// JSON 字符串表示（与 [toJson] 一致）。
  @override
  String toString() => jsonEncode(toJson());

  String get shareUrl {
    final baseUrl = ConfigStore.to.configBean.shareUrl?.trim() ?? "";
    final code = invitationCode?.trim() ?? "";
    if (baseUrl.isEmpty || code.isEmpty) return baseUrl;

    final uri = Uri.tryParse(baseUrl);
    if (uri == null) {
      return '$baseUrl?code=${Uri.encodeQueryComponent(code)}';
    }
    return uri.replace(
      queryParameters: <String, String>{
        ...uri.queryParameters,
        'code': code,
      },
    ).toString();
  }
}
