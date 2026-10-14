import 'post_enums.dart';

/// 帖子段落资源类型（API `sources[i].type`）。
///
/// **注意**：该枚举的值映射跟 [PostType] 不同：
/// - [PostSourceType]: 0=图片, 1=视频, 2=文本（段落级）
/// - [PostType]: 0=视频, 1=图文, 2=图片（帖子整体级）
///
/// 后端在 publish / list 接口里这两个字段是分开的两套枚举，不要混用。
enum PostSourceType {
  image(0),
  video(1),
  text(2);

  const PostSourceType(this.value);
  final int value;

  static PostSourceType? fromValue(int? v) {
    if (v == null) return null;
    for (final t in PostSourceType.values) {
      if (t.value == v) return t;
    }
    return null;
  }
}

/// 帖子内容段落（图片 / 视频 / 文字），对应 API `sources[]`。
class PostSourceItem {
  PostSourceItem({
    this.id,
    this.pid,
    this.msg,
    this.source,
    this.screen,
    this.type,
    this.wh,
    this.duration = 0,
  });

  final int? id;
  final int? pid;

  /// 段落文字内容（type=text 时有值）。
  final String? msg;

  /// 图片 / 视频地址（type=image/video 时有值；可能是相对路径，UI 渲染需自行拼 CDN）。
  final String? source;

  /// 视频段落的封面（截图）地址；后端只在 type=video 时下发。
  final String? screen;

  /// 资源类型；解析失败为 `null`。
  final PostSourceType? type;

  /// 图片宽高字符串，格式 `"WxH"`。
  final String? wh;

  /// 视频时长（秒）。
  final int duration;

  /// 宽高比 根据后端返回wh字段计算
  double? get aspectRatio => _aspectFromWh();

  double get width {
    if (_width > 0) return _width;
    _aspectFromWh();
    return _width;
  }

  double get height {
    if (_height > 0) return _height;
    _aspectFromWh();
    return _height;
  }

  double _width = 0;
  double _height = 0;

  double? _aspectFromWh() {
    String? wh = this.wh;
    if (_width > 0 && _height > 0) return _width / _height;
    if (wh == null || wh.isEmpty) return null;
    final List<String> parts = wh.toLowerCase().split('x');
    if (parts.length != 2) return null;
    _width = double.tryParse(parts[0].trim()) ?? 0;
    _height = double.tryParse(parts[1].trim()) ?? 0;
    if (_width <= 0 || _height <= 0) return null;
    return _width / _height;
  }

  factory PostSourceItem.fromJson(Map<String, dynamic> json) => PostSourceItem(
        id: _parseInt(json['id']),
        pid: _parseInt(json['pid']),
        msg: json['msg']?.toString(),
        source: json['source']?.toString(),
        screen: json['screen']?.toString(),
        type: PostSourceType.fromValue(_parseInt(json['type'])),
        wh: json['wh']?.toString(),
        duration: _parseInt(json['duration']) ?? 0,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'pid': pid,
        'msg': msg,
        'source': source,
        'screen': screen,
        'type': type?.value,
        'wh': wh,
        'duration': duration,
      };
}

/// 帖子作者简要信息（API `account` 字段）。
class PostAuthor {
  PostAuthor({
    this.id,
    this.sex,
    this.avatar = '',
    this.nickName = '',
    this.authType = 0,
    this.follow = false,
    this.fansNum = 0,
    this.starsNum = 0,
    this.beFollow,
    this.lastPosting,
    this.introduce,
    this.pnum,
    this.vnum,
  });

  final int? id;
  final int? sex;

  /// 头像路径（可能是 `/head/22.png` 这种相对路径，需自行拼 CDN）。
  final String avatar;
  final String nickName;

  /// 0 普通用户，1 认证作者。
  final int authType;
  bool follow;
  final int fansNum;
  final int starsNum;

  // 后端预留 / 详情页相关字段（列表暂不使用，保留兜底解析）。
  final dynamic beFollow;
  final dynamic lastPosting;
  final String? introduce;
  final dynamic pnum;
  final dynamic vnum;

  factory PostAuthor.fromJson(Map<String, dynamic> json) => PostAuthor(
        id: _parseInt(json['id']),
        sex: _parseInt(json['sex']),
        avatar: json['avatar']?.toString() ?? '',
        nickName: json['nickName']?.toString() ?? '',
        authType: _parseInt(json['authType']) ?? 0,
        follow: _parseBool(json['follow']) ?? false,
        fansNum: _parseInt(json['fansNum']) ?? 0,
        starsNum: _parseInt(json['starsNum']) ?? 0,
        beFollow: json['beFollow'],
        lastPosting: json['lastPosting'],
        introduce: json['introduce']?.toString(),
        pnum: json['pnum'],
        vnum: json['vnum'],
      );

  static PostAuthor? fromAny(dynamic v) {
    if (v is Map) return PostAuthor.fromJson(Map<String, dynamic>.from(v));
    return null;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'sex': sex,
        'avatar': avatar,
        'nickName': nickName,
        'authType': authType,
        'follow': follow,
        'fansNum': fansNum,
        'starsNum': starsNum,
        'beFollow': beFollow,
        'lastPosting': lastPosting,
        'introduce': introduce,
        'pnum': pnum,
        'vnum': vnum,
      };
}

/// 社区信息流卡片数据模型，字段名严格对齐后端 `posting/list` 返回结构。
///
/// 展示用的字符串（用户名 / 时间标签 / 浏览数 等）走 `display*` 系列 getter
/// 现算，不再单独存储。
class PostCardData {
  PostCardData({
    this.id = 0,
    this.aid,
    this.type,
    this.categoryId,
    this.childCategoryId,
    this.costType,
    this.createTime = 0,
    this.gold = 0,
    this.perfect = 0,
    this.sort = 0,
    this.title = '',
    this.status,
    this.msg,
    this.codeStatus,
    this.showType,
    this.auditTime,
    this.auditor,
    this.linked,
    this.reward,
    this.rewardStatus,
    this.hotTime,
    this.commentTime,
    this.initWatch,
    this.initLikeNum,
    this.initCollectNum,
    this.sources = const <PostSourceItem>[],
    this.account,
    this.needPay = false,
    this.isPerfect = false,
    this.isCollect = false,
    this.watch = 0,
    this.comments = 0,
    this.hasLinked = 0,
    this.linkedType = 0,
    this.buyNum = 0,
    this.categoryName,
    this.childCategory,
  });

  factory PostCardData.fromJson(Map<String, dynamic> json) {
    return PostCardData(
      id: _parseInt(json['id']) ?? 0,
      aid: _parseInt(json['aid']),
      type: PostType.fromValue(_parseInt(json['type'])),
      categoryId: _parseInt(json['categoryId']),
      childCategoryId: _parseInt(json['childCategoryId']),
      costType: PostCostType.fromValue(_parseInt(json['costType'])),
      createTime: _parseInt(json['createTime']) ?? 0,
      gold: _parseInt(json['gold']) ?? 0,
      perfect: _parseInt(json['perfect']) ?? 0,
      sort: _parseInt(json['sort']) ?? 0,
      title: json['title']?.toString() ?? '',
      status: _parseInt(json['status']),
      msg: json['msg']?.toString(),
      codeStatus: json['codeStatus'],
      showType: _parseInt(json['showType']),
      auditTime: _parseInt(json['auditTime']),
      auditor: json['auditor'],
      linked: json['linked'],
      reward: json['reward'],
      rewardStatus: _parseInt(json['rewardStatus']),
      hotTime: _parseInt(json['hotTime']),
      commentTime: _parseInt(json['commentTime']),
      initWatch: _parseInt(json['initWatch']),
      initLikeNum: _parseInt(json['initLikeNum']),
      initCollectNum: _parseInt(json['initCollectNum']),
      sources: _parseSources(json['sources']),
      account: PostAuthor.fromAny(json['account']),
      needPay: _parseBool(json['needPay']) ?? false,
      isPerfect: _parseBool(json['isPerfect']) ?? false,
      isCollect: _parseBool(json['isCollect']) ?? false,
      watch: _parseInt(json['watch']) ?? 0,
      comments: _parseInt(json['comments']) ?? 0,
      hasLinked: _parseInt(json['hasLinked']) ?? 0,
      linkedType: _parseInt(json['linkedType']) ?? 0,
      buyNum: _parseInt(json['buyNum']) ?? 0,
      categoryName: json['categoryName']?.toString(),
      childCategory: json['childCategory']?.toString(),
    );
  }

  static List<PostCardData> listFromData(dynamic data) {
    if (data == null) return <PostCardData>[];
    if (data is List) {
      final out = <PostCardData>[];
      for (final e in data) {
        if (e is Map) {
          out.add(PostCardData.fromJson(Map<String, dynamic>.from(e)));
        }
      }
      return out;
    }
    if (data is Map) {
      final nested = data['list'] ?? data['data'] ?? data['records'];
      if (nested != null) return listFromData(nested);
    }
    return <PostCardData>[];
  }

  /// 反向序列化为 JSON，键名与 [fromJson] 对齐，用于浏览记录等本地持久化场景。
  /// 枚举字段（[type] / [costType]）落库为 API 数字值；`account` / `sources`
  /// 走各自的 [toJson]。
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'aid': aid,
        'type': type?.value,
        'categoryId': categoryId,
        'childCategoryId': childCategoryId,
        'costType': costType?.value,
        'createTime': createTime,
        'gold': gold,
        'perfect': perfect,
        'sort': sort,
        'title': title,
        'status': status,
        'msg': msg,
        'codeStatus': codeStatus,
        'showType': showType,
        'auditTime': auditTime,
        'auditor': auditor,
        'linked': linked,
        'reward': reward,
        'rewardStatus': rewardStatus,
        'hotTime': hotTime,
        'commentTime': commentTime,
        'initWatch': initWatch,
        'initLikeNum': initLikeNum,
        'initCollectNum': initCollectNum,
        'sources': sources.map((PostSourceItem e) => e.toJson()).toList(),
        'account': account?.toJson(),
        'needPay': needPay,
        'isPerfect': isPerfect,
        'isCollect': isCollect,
        'watch': watch,
        'comments': comments,
        'hasLinked': hasLinked,
        'linkedType': linkedType,
        'buyNum': buyNum,
        'categoryName': categoryName,
        'childCategory': childCategory,
      };

  // ---------- 后端字段（与 API 同名） ----------

  final int id;
  final int? aid;

  /// 帖子整体类型（0视频 / 1图文 / 2图片）。
  final PostType? type;

  final int? categoryId;
  final int? childCategoryId;

  /// 消费类型（0免费 / 1VIP / 2金币）。
  PostCostType? costType;

  /// 创建时间，毫秒时间戳。
  final int createTime;

  /// 金币价（`costType == gold` 时有意义）。
  final int gold;

  int perfect;
  final int sort;
  final String title;

  /// 审核状态（0审核中 / 1已发布 / 2未通过；接口暂可能为 null）。
  final int? status;

  /// 后端审核 / 报错信息（成功时通常为 null）。
  final String? msg;
  final dynamic codeStatus;

  /// 帖子展示样式（0平铺 / 1九宫格；publish 时由用户选定）。
  final int? showType;

  final int? auditTime;
  final dynamic auditor;
  final dynamic linked;
  final dynamic reward;
  final int? rewardStatus;
  final int? hotTime;
  final int? commentTime;
  final int? initWatch;
  int? initLikeNum;
  int? initCollectNum;

  final List<PostSourceItem> sources;
  final PostAuthor? account;

  final bool needPay;
  bool isPerfect;
  final bool isCollect;

  /// 观看数。
  final int watch;

  /// 评论数。
  final int comments;

  final int hasLinked;
  final int linkedType;
  final int buyNum;

  final String? categoryName;
  final String? childCategory;

  // ---------- 派生数据 / 展示字段 ----------

  /// 卡片头像区显示的用户名。
  String get displayName => account?.nickName ?? '';

  /// 卡片头像区显示的相对时间（"刚刚 / X分钟前 / X小时前 / X天前 / YYYY-MM-DD"）。
  String get displayTime => _formatRelativeTime(auditTime ?? 0);

  String get displayCreateTime =>
      _formatRelativeTime(status == 1 ? (auditTime ?? 0) : createTime);

  /// 观看数格式化（≥1万 走「X.X万」）。
  String get displayViews => _formatCount(watch);

  /// 评论数格式化。
  String get displayComments => _formatCount(comments);

  /// 点赞数格式化（用 [perfect]，因接口暂未单独返回真实点赞数）。
  String get displayLikes => _formatCount(perfect);

  /// 标签展示：取 [childCategory]，没有则空串。
  String get displayTag => (childCategory != null && childCategory!.isNotEmpty)
      ? '#$childCategory'
      : '';

  /// 审核状态文案，用于卡片右上角 `_StatusChip`。
  String get displayStatusLabel => _statusLabel(status);

  // ---------- 内部解析 / 格式化工具 ----------

  static List<PostSourceItem> _parseSources(dynamic v) {
    if (v is! List) return const <PostSourceItem>[];
    final List<PostSourceItem> out = <PostSourceItem>[];
    for (final dynamic e in v) {
      if (e is Map) {
        out.add(PostSourceItem.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    return out;
  }

  static String _formatCount(int n) {
    if (n <= 0) return '0';
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}万';
    return '$n';
  }

  static String _formatRelativeTime(int ms) {
    if (ms <= 0) return '';
    final DateTime t = DateTime.fromMillisecondsSinceEpoch(ms);
    final Duration diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    final String mm = t.month.toString().padLeft(2, '0');
    final String dd = t.day.toString().padLeft(2, '0');
    return '${t.year}-$mm-$dd';
  }

  static String _statusLabel(int? status) {
    if (status == null) return '';
    switch (status) {
      case 0:
        return '审核中';
      case 1:
        return '已发布';
      case 2:
        return '未通过';
      default:
        return '';
    }
  }
}

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

bool? _parseBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString().toLowerCase();
  if (s == 'true' || s == '1' || s == 'yes') return true;
  if (s == 'false' || s == '0' || s == 'no' || s.isEmpty) return false;
  return null;
}
