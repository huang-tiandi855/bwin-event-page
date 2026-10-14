/// 服务端聊天记录 / 即时消息推送的统一响应体（对应文档 `UserChatReordDto`）。
///
/// 触发场景：
/// 1. 拉取聊天记录（mt=800001）→ 返回多条 `UserChatRecordDto`，**实测 `mt` 为 `0`**
/// 2. 对端实时发来的消息（mt=200001~200004）→ 服务端转发包同形态，`mt` 与原消息一致
/// 3. 拉取官方推送（mt=800003）→ 同样以这套结构推送
///
/// 由于 `mt` 在不同场景下取值不同，业务侧识别此结构应当采用「结构判断」
/// （是否含有 `chatRecord` 字段）而不是 mt 白名单匹配。
class UserChatRecordDto {
  UserChatRecordDto({
    this.mt = 0,
    this.contactInfo,
    this.contactAvatar,
    this.chatRecord = const <ChatRecordItem>[],
    this.noReadCount = 0,
    this.lastChatTime,
    this.total = 0,
    this.t,
  });

  /// 业务消息号；拉取记录场景下实测为 0
  final int mt;

  /// 联系人信息（脱敏后的 `TCloudAccount`）
  final ContactInfo? contactInfo;

  /// 联系人头像
  final ContactAvatar? contactAvatar;

  /// 本次返回的聊天记录列表（按时间升序还是降序由服务端决定，UI 侧自行排序）
  final List<ChatRecordItem> chatRecord;

  /// 当前未读数
  final int noReadCount;

  /// 最后一次聊天时间（毫秒）
  final int? lastChatTime;

  /// 总条数（用于分页判断是否还有下一页）
  final int total;

  /// 服务端响应时间戳（毫秒）
  final int? t;

  /// 是否携带聊天记录（用于上层结构性判断）
  bool get hasRecords => chatRecord.isNotEmpty;

  factory UserChatRecordDto.fromJson(Map<String, dynamic> json) {
    return UserChatRecordDto(
      mt: (json['mt'] as num?)?.toInt() ?? 0,
      contactInfo: json['contactInfo'] is Map
          ? ContactInfo.fromJson(
              Map<String, dynamic>.from(json['contactInfo'] as Map))
          : null,
      contactAvatar: json['contactAvatar'] is Map
          ? ContactAvatar.fromJson(
              Map<String, dynamic>.from(json['contactAvatar'] as Map))
          : null,
      chatRecord: (json['chatRecord'] as List?)
              ?.whereType<Map>()
              .map((e) => ChatRecordItem.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const <ChatRecordItem>[],
      noReadCount: (json['noReadCount'] as num?)?.toInt() ?? 0,
      lastChatTime: (json['lastChatTime'] as num?)?.toInt(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      t: (json['t'] as num?)?.toInt(),
    );
  }

  /// 从「实时推送」消息构造 dto（mt=200001~200004 的根字段格式）。
  ///
  /// 实时推送里没有 `chatRecord` 包装，字段全在根上（`from`/`to`/`msg`/`nickName`/`avatar` 等）。
  /// 这里把它折叠成一条 [ChatRecordItem] + `contactInfo`/`contactAvatar`（取自发送方），
  /// 方便消息中心按联系人维度统一展示。
  ///
  /// 当 data 本身就带 `chatRecord` 列表（少数服务端会做包裹），直接走 [UserChatRecordDto.fromJson]。
  factory UserChatRecordDto.fromRealtimePush(
    Map<String, dynamic> data, {
    int? defaultType,
  }) {
    if (data['chatRecord'] is List) {
      return UserChatRecordDto.fromJson(data);
    }
    final fields = Map<String, dynamic>.from(data);
    if (defaultType != null) fields['type'] ??= defaultType;
    final record = ChatRecordItem.fromJson(fields);

    final int fromIdInt = int.tryParse(record.from) ?? 0;
    final String? nickName = data['nickName']?.toString();
    final String? avatarUrl = data['avatar']?.toString();

    return UserChatRecordDto(
      mt: (data['mt'] as num?)?.toInt() ?? 0,
      contactInfo: (nickName != null && nickName.isNotEmpty) || fromIdInt > 0
          ? ContactInfo(id: fromIdInt, nickName: nickName)
          : null,
      contactAvatar: (avatarUrl != null && avatarUrl.isNotEmpty) || fromIdInt > 0
          ? ContactAvatar(id: fromIdInt, url: avatarUrl)
          : null,
      chatRecord: <ChatRecordItem>[record],
      lastChatTime: record.crtDate > 0 ? record.crtDate : null,
      t: (data['t'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mt': mt,
      'contactInfo': contactInfo?.toJson(),
      'contactAvatar': contactAvatar?.toJson(),
      'chatRecord': chatRecord.map((e) => e.toJson()).toList(),
      'noReadCount': noReadCount,
      'lastChatTime': lastChatTime,
      'total': total,
      't': t,
    };
  }
}

/// 单条聊天记录（对应文档 `TCloudChatRecord`）
class ChatRecordItem {
  ChatRecordItem({
    required this.id,
    required this.type,
    required this.from,
    required this.to,
    required this.msg,
    this.duration = 0,
    required this.crtDate,
    this.isRead = false,
    this.isOfficialPush = false,
    this.sendDel = false,
    this.recieverDel = false,
  });

  /// 雪花 id（字符串保存，避免 JS 端精度问题）
  final String id;

  /// 与 mt 同号的消息类型；如 200001=文本、200002=图片、200003=视频、200004=语音
  final int type;

  /// 发送方 uid
  final String from;

  /// 接收方 uid
  final String to;

  /// 文本：内容；图片/视频/语音：URL
  final String msg;

  /// 视频/语音时长（秒）
  final int duration;

  /// 创建时间（毫秒）
  final int crtDate;

  /// 是否已读
  final bool isRead;

  /// 是否官方推送
  final bool isOfficialPush;

  /// 发送方已删除
  final bool sendDel;

  /// 接收方已删除
  final bool recieverDel;

  factory ChatRecordItem.fromJson(Map<String, dynamic> json) {
    return ChatRecordItem(
      id: json['id']?.toString() ?? '',
      type: int.tryParse(json['type']?.toString() ?? '') ?? 0,
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      msg: json['msg']?.toString() ?? '',
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      crtDate: _parseTimestamp(json['crtDate']) ?? 0,
      isRead: json['isRead'] == true,
      isOfficialPush: json['isOfficialPush'] == true,
      sendDel: json['sendDel'] == true,
      recieverDel: json['recieverDel'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'from': from,
      'to': to,
      'msg': msg,
      'duration': duration,
      'crtDate': crtDate,
      'isRead': isRead,
      'isOfficialPush': isOfficialPush,
      'sendDel': sendDel,
      'recieverDel': recieverDel,
    };
  }

  /// crtDate 兼容毫秒数字 / 数字字符串 / ISO 时间字符串
  static int? _parseTimestamp(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    final s = v.toString();
    final n = num.tryParse(s);
    if (n != null) return n.toInt();
    final dt = DateTime.tryParse(s);
    return dt?.millisecondsSinceEpoch;
  }
}

/// 联系人基础信息（脱敏后的 `TCloudAccount`，按需补字段）
class ContactInfo {
  ContactInfo({
    required this.id,
    this.nickName,
    this.authType,
    this.filter,
  });

  /// 联系人 uid
  final int id;

  /// 昵称
  final String? nickName;

  /// 认证类型
  final int? authType;

  /// 过滤标记
  final int? filter;

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nickName: json['nickName']?.toString(),
      authType: (json['authType'] as num?)?.toInt(),
      filter: (json['filter'] as num?)?.toInt(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickName': nickName,
      'authType': authType,
      'filter': filter,
    };
  }
}

/// 联系人头像（独立结构，URL 通常是相对路径 CDN）
class ContactAvatar {
  ContactAvatar({required this.id, this.url});

  final int id;
  final String? url;

  factory ContactAvatar.fromJson(Map<String, dynamic> json) {
    return ContactAvatar(
      id: (json['id'] as num?)?.toInt() ?? 0,
      url: json['url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
    };
  }
}

class ChatLoaclRecordItem {
  //发送方uid
  String? from;
  UserChatRecordDto? message;

  ChatLoaclRecordItem({
    this.from,
    this.message,
  });

  factory ChatLoaclRecordItem.fromJson(Map<String, dynamic> json) {
    return ChatLoaclRecordItem(
      from: json['from']?.toString(),
      message: json['message'] is Map
          ? UserChatRecordDto.fromJson(
              Map<String, dynamic>.from(json['message'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'message': message?.toJson(),
    };
  }
}
