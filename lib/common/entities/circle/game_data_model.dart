import 'package:comics_app/common/entities/circle/post_card_data.dart';
import 'package:comics_app/common/entities/circle/post_enums.dart';
import 'package:comics_app/common/extension/int_extension.dart';

/// `downloads[]` 单项：平台名 + 链接 + 提取码（非解压密码）。
class GamingDownloadItem {
  const GamingDownloadItem({
    this.platform = '',
    this.url = '',
    this.extractCode,
  });

  final String platform;
  final String url;
  final String? extractCode;

  factory GamingDownloadItem.fromJson(Map<String, dynamic> json) {
    return GamingDownloadItem(
      platform: (json['platform'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      extractCode: _nullableString(json['extractCode']),
    );
  }

  static List<GamingDownloadItem> listFromData(dynamic data) {
    if (data is! List) return const <GamingDownloadItem>[];
    final out = <GamingDownloadItem>[];
    for (final e in data) {
      if (e is Map) {
        final item =
            GamingDownloadItem.fromJson(Map<String, dynamic>.from(e));
        if (item.url.isNotEmpty) out.add(item);
      }
    }
    return out;
  }
}

/// 游戏标签（`tags[]`：`{ id, name, ... }`）。
class GameTagItem {
  const GameTagItem({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory GameTagItem.fromJson(Map<String, dynamic> json) {
    return GameTagItem(
      id: _parseInt(json['id']) ?? 0,
      name: (json['name'] ?? '').toString(),
    );
  }
}

/// 游戏一级分类（`categories[]`：`{ id, name, ... }`）。
class GameCategoryItem {
  const GameCategoryItem({
    required this.id,
    required this.name,
    this.parentId,
    this.showIcon,
  });

  final int id;
  final String name;
  final int? parentId;
  final int? showIcon;

  factory GameCategoryItem.fromJson(Map<String, dynamic> json) {
    return GameCategoryItem(
      id: _parseInt(json['id']) ?? 0,
      name: (json['name'] ?? '').toString(),
      parentId: _parseInt(json['parentId']),
      showIcon: _parseInt(json['showIcon']),
    );
  }
}

/// `gaming/list` / 详情 / 收藏 / 点赞 / 购买 共用的游戏数据模型。
///
/// 字段对齐后端 `GamingVo` 实际返回（见 `client_api.md` + 联调样例）。
class GameDataModel {
  GameDataModel({
    this.id = 0,
    this.type,
    this.categoryId,
    this.platformId,
    this.languageId,
    this.tagIds = const <int>[],
    this.categoryIds = const <int>[],
    this.version = '',
    this.fileSize = '',
    this.downloadUrl,
    this.downloads = const <GamingDownloadItem>[],
    this.extractPassword,
    this.publishTime = 0,
    this.unlockCount = 0,
    this.costType,
    this.createTime = 0,
    this.gold = 0,
    this.perfect = 0,
    this.sort = 0,
    this.title = '',
    this.msg,
    this.auditTime,
    this.rewardStatus,
    // this.initWatch,
    // this.initLikeNum,
    // this.initCollectNum,
    this.sources = const <PostSourceItem>[],
    this.needPay = false,
    this.isPerfect = false,
    this.isCollect = false,
    this.watch = 0,
    this.comments = 0,
    this.buyNum = 0,
    this.collectNum = 0,
    this.platform,
    this.languageName,
    this.tags = const <GameTagItem>[],
    this.categories = const <GameCategoryItem>[],
    this.unlocked = false,
  });

  final int id;

  /// 整体类型（样例为 `2` 图片向；游戏侧可不强依赖）。
  final PostType? type;

  final int? categoryId;
  final int? platformId;
  final int? languageId;
  final List<int> tagIds;
  final List<int> categoryIds;

  final String version;
  final String fileSize;
  String? downloadUrl;
  List<GamingDownloadItem> downloads;
  String? extractPassword;

  /// 发布时间（毫秒）。
  final int publishTime;

  int unlockCount;
  PostCostType? costType;
  final int createTime;
  final int gold;
  int perfect;
  final int sort;
  final String title;
  final String? msg;
  final int? auditTime;
  final int? rewardStatus;
  // final int? initWatch;
  // final int? initLikeNum;
  // final int? initCollectNum;
  final List<PostSourceItem> sources;

  ///仅金币且未付时为 `true`
  bool needPay;
  bool isPerfect;
  bool isCollect;
  final int watch;
  final int comments;
  final int buyNum;
  int collectNum;

  final String? platform;
  final String? languageName;
  final List<GameTagItem> tags;
  final List<GameCategoryItem> categories;

  ///当前用户是否已解锁
  bool unlocked;

  /// 优先 `downloads[]`；兼容旧字段 `downloadUrl`。
  List<GamingDownloadItem> get resolvedDownloads {
    if (downloads.isNotEmpty) return downloads;
    final url = downloadUrl;
    if (url != null && url.isNotEmpty) {
      return [GamingDownloadItem(platform: '下载链接', url: url)];
    }
    return const <GamingDownloadItem>[];
  }

  factory GameDataModel.fromJson(Map<String, dynamic> json) {
    final parsedDownloads = GamingDownloadItem.listFromData(json['downloads']);
    return GameDataModel(
      id: _parseInt(json['id']) ?? 0,
      type: PostType.fromValue(_parseInt(json['type'])),
      categoryId: _parseInt(json['categoryId']),
      platformId: _parseInt(json['platformId']),
      languageId: _parseInt(json['languageId']),
      tagIds: _intList(json['tagIds']),
      categoryIds: _intList(json['categoryIds']),
      version: json['version']?.toString() ?? '',
      fileSize: json['fileSize']?.toString() ?? '',
      downloadUrl: _nullableString(json['downloadUrl']),
      downloads: parsedDownloads,
      extractPassword: _nullableString(json['extractPassword']),
      publishTime: _parseTimeMs(json['publishTime'] ?? json['createTime']),
      unlockCount: _parseInt(json['unlockCount']) ?? 0,
      costType: PostCostType.fromValue(_parseInt(json['costType'])),
      createTime: _parseTimeMs(json['createTime']),
      gold: _parseInt(json['gold']) ?? 0,
      perfect: _parseInt(json['perfect']) ?? 0,
      sort: _parseInt(json['sort']) ?? 0,
      title: json['title']?.toString() ?? '',
      msg: json['msg']?.toString(),
      auditTime: _parseTimeMsOrNull(json['auditTime']),
      rewardStatus: _parseInt(json['rewardStatus']),
      // initWatch: _parseInt(json['initWatch']),
      // initLikeNum: _parseInt(json['initLikeNum']),
      // initCollectNum: _parseInt(json['initCollectNum']),
      sources: _parseSources(json['sources']),
      needPay: _parseBool(json['needPay']) ?? false,
      isPerfect: _parseBool(json['isPerfect']) ?? false,
      isCollect: _parseBool(json['isCollect']) ?? false,
      watch: _parseInt(json['watch']) ?? 0,
      comments: _parseInt(json['comments']) ?? 0,
      buyNum: _parseInt(json['buyNum']) ?? 0,
      collectNum: _parseInt(json['collectNum']) ?? 0,
      platform: _nullableString(json['platform']),
      languageName: _nullableString(json['languageName']),
      tags: _parseTags(json['tags']),
      categories: _parseCategories(json['categories']),
      unlocked: _parseBool(json['unlocked']) ?? false,
    );
  }

  static List<GameDataModel> listFromData(dynamic data) {
    if (data == null) return <GameDataModel>[];
    if (data is List) {
      final out = <GameDataModel>[];
      for (final e in data) {
        if (e is Map) {
          out.add(GameDataModel.fromJson(Map<String, dynamic>.from(e)));
        }
      }
      return out;
    }
    if (data is Map) {
      final nested = data['list'] ?? data['data'] ?? data['records'];
      if (nested != null) return listFromData(nested);
    }
    return <GameDataModel>[];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'type': type?.value,
        'categoryId': categoryId,
        'platformId': platformId,
        'languageId': languageId,
        'tagIds': tagIds,
        'categoryIds': categoryIds,
        'version': version,
        'fileSize': fileSize,
        'downloadUrl': downloadUrl,
        'extractPassword': extractPassword,
        'publishTime': publishTime,
        'unlockCount': unlockCount,
        'costType': costType?.value,
        'createTime': createTime,
        'gold': gold,
        'perfect': perfect,
        'sort': sort,
        'title': title,
        'msg': msg,
        'auditTime': auditTime,
        'rewardStatus': rewardStatus,
        // 'initWatch': initWatch,
        // 'initLikeNum': initLikeNum,
        // 'initCollectNum': initCollectNum,
        'sources': sources.map((e) => e.toJson()).toList(),
        'needPay': needPay,
        'isPerfect': isPerfect,
        'isCollect': isCollect,
        'watch': watch,
        'comments': comments,
        'buyNum': buyNum,
        'collectNum': collectNum,
        'platform': platform,
        'languageName': languageName,
        'tags': [
          for (final t in tags) <String, dynamic>{'id': t.id, 'name': t.name},
        ],
        'categories': [
          for (final c in categories)
            <String, dynamic>{
              'id': c.id,
              'name': c.name,
              'parentId': c.parentId,
              'showIcon': c.showIcon,
            },
        ],
        'unlocked': unlocked,
      };

  // ---------- 展示派生 ----------

  /// 列表色标签：语言 / 平台 / 一级分类（对齐 Figma 三色）。
  List<String> get chipTags => <String>[
        if ((languageName ?? '').isNotEmpty) languageName!,
        if ((platform ?? '').isNotEmpty) platform!,
        if (categories.isNotEmpty) categories.first.name,
      ];

  /// 标签名列表。
  List<String> get tagNames =>
      tags.map((e) => e.name).where((e) => e.isNotEmpty).toList();

  /// 分类名列表。
  List<String> get categoryNames =>
      categories.map((e) => e.name).where((e) => e.isNotEmpty).toList();

  /// 简介：取第一条 text source，否则 `msg`。
  String get introText {
    for (final s in sources) {
      if (s.type == PostSourceType.text && (s.msg?.isNotEmpty ?? false)) {
        return s.msg!;
      }
    }
    return msg ?? '';
  }

  /// 图片封面 URL 列表。
  List<String> get coverUrls => <String>[
        for (final s in sources)
          if (s.type == PostSourceType.image && (s.source?.isNotEmpty ?? false))
            s.source!,
      ];

  /// 展示用时间戳：优先审核时间，否则发布时间。
  int get displayTimeMs {
    final int? a = auditTime;
    if (a != null && a > 0) return a;
    if (publishTime > 0) return publishTime;
    return createTime;
  }

  String get displayViews => _formatCount(watch);

  String get displayLikes => _formatCount(perfect);

  /// 收藏数：优先 `initCollectNum`。

  String get displayCollect => _formatCount(collectNum);

  /// 销售 / 解锁次数展示。
  String get displayUnlock => _formatCount(unlockCount);

  static String _formatCount(int n) {
    return n.humanizeFormat;
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

int _parseTimeMs(dynamic v) {
  return _parseTimeMsOrNull(v) ?? 0;
}

int? _parseTimeMsOrNull(dynamic v) {
  if (v == null) return null;
  if (v is int) {
    if (v > 0 && v < 100000000000) return v * 1000;
    return v;
  }
  if (v is num) {
    final n = v.toInt();
    if (n > 0 && n < 100000000000) return n * 1000;
    return n;
  }
  final s = v.toString().trim();
  if (s.isEmpty) return null;
  final asInt = int.tryParse(s);
  if (asInt != null) {
    if (asInt > 0 && asInt < 100000000000) return asInt * 1000;
    return asInt;
  }
  try {
    return DateTime.parse(s).millisecondsSinceEpoch;
  } catch (_) {
    return null;
  }
}

String? _nullableString(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  if (s.isEmpty || s == 'null') return null;
  return s;
}

List<int> _intList(dynamic v) {
  if (v is! List) return const <int>[];
  final out = <int>[];
  for (final e in v) {
    final n = _parseInt(e);
    if (n != null) out.add(n);
  }
  return out;
}

List<GameTagItem> _parseTags(dynamic v) {
  if (v is! List) return const <GameTagItem>[];
  final out = <GameTagItem>[];
  for (final e in v) {
    if (e is Map) {
      final item = GameTagItem.fromJson(Map<String, dynamic>.from(e));
      if (item.name.isNotEmpty) out.add(item);
    } else if (e != null) {
      final name = e.toString();
      if (name.isNotEmpty) out.add(GameTagItem(id: 0, name: name));
    }
  }
  return out;
}

List<GameCategoryItem> _parseCategories(dynamic v) {
  if (v is! List) return const <GameCategoryItem>[];
  final out = <GameCategoryItem>[];
  for (final e in v) {
    if (e is Map) {
      final item = GameCategoryItem.fromJson(Map<String, dynamic>.from(e));
      if (item.name.isNotEmpty) out.add(item);
    } else if (e != null) {
      final name = e.toString();
      if (name.isNotEmpty) {
        out.add(GameCategoryItem(id: 0, name: name));
      }
    }
  }
  return out;
}

List<PostSourceItem> _parseSources(dynamic v) {
  if (v is! List) return const <PostSourceItem>[];
  final out = <PostSourceItem>[];
  for (final e in v) {
    if (e is Map) {
      out.add(PostSourceItem.fromJson(Map<String, dynamic>.from(e)));
    }
  }
  return out;
}
