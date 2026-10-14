import 'package:comics_app/common/entities/circle/game_data_model.dart';
import 'package:comics_app/common/entities/circle/post_enums.dart';

export 'package:comics_app/common/entities/circle/game_data_model.dart';

/// 游戏列表排序（`gaming/list` 的 `sortType`）。
enum GamingSortType {
  /// 0：发布时间
  publishTime(0),

  /// 1：推荐（运营 sort）
  recommend(1),

  /// 2：最多评论
  comments(2),

  /// 3：最多点赞
  perfect(3),

  /// 4：最新回复
  commentTime(4),

  /// 5：最多观看
  watch(5),

  /// 6：最多收藏
  collect(6),

  /// 7：解锁次数
  unlockCount(7);

  const GamingSortType(this.value);
  final int value;
}

/// 字典项：分类 / 平台 / 语言 / 标签（`id` + `name` + 可选 `pnums`）。
class GamingDictItem {
  const GamingDictItem({
    required this.id,
    required this.name,
    this.parentId,
    this.pnums,
    this.showIcon,
  });

  final int id;
  final String name;
  final int? parentId;
  final int? pnums;
  final int? showIcon;

  factory GamingDictItem.fromJson(Map<String, dynamic> json) {
    return GamingDictItem(
      id: _parseInt(json['id']) ?? 0,
      name: (json['name'] ?? json['groupName'] ?? '').toString(),
      parentId: _parseInt(json['parentId']),
      pnums: _parseInt(json['pnums']),
      showIcon: _parseInt(json['showIcon']),
    );
  }

  static List<GamingDictItem> listFromData(dynamic data) {
    if (data is! List) return const <GamingDictItem>[];
    final out = <GamingDictItem>[];
    for (final e in data) {
      if (e is Map) {
        final item = GamingDictItem.fromJson(Map<String, dynamic>.from(e));
        if (item.id > 0 && item.name.isNotEmpty) out.add(item);
      }
    }
    return out;
  }
}

/// `POST /gaming/list` 查询参数（form / query，非 JSON Body）。
class GamingListQuery {
  const GamingListQuery({
    this.page = 1,
    this.pageSize = 20,
    this.keyword,
    this.categoryId,
    this.categoryIds,
    this.tagId,
    this.tagIds,
    this.platformId,
    this.languageId,
    this.costType,
    this.sortType,
    this.sortAsc,
    this.hasVideo,
    this.id,
    this.ids,
  });

  final int page;
  final int pageSize;
  final String? keyword;
  final int? categoryId;
  final List<int>? categoryIds;
  final int? tagId;
  final List<int>? tagIds;
  final int? platformId;
  final int? languageId;
  final PostCostType? costType;
  final GamingSortType? sortType;
  final bool? sortAsc;
  final bool? hasVideo;
  final int? id;
  final List<int>? ids;

  Map<String, dynamic> toJson() {
    final out = <String, dynamic>{
      'page': page,
      'pageSize': pageSize.clamp(1, 20),
    };
    if (keyword != null && keyword!.isNotEmpty) out['keyword'] = keyword;
    if (categoryId != null) out['categoryId'] = categoryId;
    if (categoryIds != null && categoryIds!.isNotEmpty) {
      out['categoryIds'] = categoryIds;
    }
    if (tagId != null) out['tagId'] = tagId;
    if (tagIds != null && tagIds!.isNotEmpty) out['tagIds'] = tagIds;
    if (platformId != null) out['platformId'] = platformId;
    if (languageId != null) out['languageId'] = languageId;
    if (costType != null) out['costType'] = costType!.value;
    if (sortType != null) out['sortType'] = sortType!.value;
    if (sortAsc != null) out['sortAsc'] = sortAsc;
    if (hasVideo != null) out['hasVideo'] = hasVideo;
    if (id != null) out['id'] = id;
    if (ids != null && ids!.isNotEmpty) out['ids'] = ids;
    return out;
  }

  GamingListQuery copyWith({
    int? page,
    int? pageSize,
    String? keyword,
    int? categoryId,
    List<int>? categoryIds,
    int? tagId,
    List<int>? tagIds,
    int? platformId,
    int? languageId,
    PostCostType? costType,
    GamingSortType? sortType,
    bool? sortAsc,
    bool? hasVideo,
    int? id,
    List<int>? ids,
  }) {
    return GamingListQuery(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      keyword: keyword ?? this.keyword,
      categoryId: categoryId ?? this.categoryId,
      categoryIds: categoryIds ?? this.categoryIds,
      tagId: tagId ?? this.tagId,
      tagIds: tagIds ?? this.tagIds,
      platformId: platformId ?? this.platformId,
      languageId: languageId ?? this.languageId,
      costType: costType ?? this.costType,
      sortType: sortType ?? this.sortType,
      sortAsc: sortAsc ?? this.sortAsc,
      hasVideo: hasVideo ?? this.hasVideo,
      id: id ?? this.id,
      ids: ids ?? this.ids,
    );
  }
}

/// `gaming/list` 分页结果。
class GamingListPage {
  GamingListPage({
    required this.list,
    this.total = 0,
    this.hasNextPage = false,
  });

  final List<GameDataModel> list;
  final int total;
  final bool hasNextPage;

  factory GamingListPage.empty() => GamingListPage(list: const []);

  factory GamingListPage.fromData(
    dynamic data, {
    required int requestedPageSize,
    int? total,
  }) {
    final List<GameDataModel> list = GameDataModel.listFromData(data);
    final int t = total ?? list.length;
    final bool hasNext = list.length >= requestedPageSize;
    return GamingListPage(list: list, total: t, hasNextPage: hasNext);
  }
}

/// `POST /gaming/unlock` 的 `result`。
class GamingUnlockVo {
  const GamingUnlockVo({
    this.id = 0,
    this.version = '',
    this.fileSize = '',
    this.publishTimeMs = 0,
    this.costType,
    this.gold = 0,
    this.unlockCount = 0,
    this.unlocked = false,
    this.downloadUrl,
    this.downloads = const <GamingDownloadItem>[],
    this.extractPassword,
  });

  final int id;
  final String version;
  final String fileSize;
  final int publishTimeMs;
  final PostCostType? costType;
  final int gold;
  final int unlockCount;
  final bool unlocked;
  final String? downloadUrl;
  final List<GamingDownloadItem> downloads;
  final String? extractPassword;

  List<GamingDownloadItem> get resolvedDownloads {
    if (downloads.isNotEmpty) return downloads;
    final url = downloadUrl;
    if (url != null && url.isNotEmpty) {
      return [GamingDownloadItem(platform: '下载链接', url: url)];
    }
    return const <GamingDownloadItem>[];
  }

  factory GamingUnlockVo.fromJson(Map<String, dynamic> json) {
    return GamingUnlockVo(
      id: _parseInt(json['id']) ?? 0,
      version: json['version']?.toString() ?? '',
      fileSize: json['fileSize']?.toString() ?? '',
      publishTimeMs: _parseTimeMs(json['publishTime']),
      costType: PostCostType.fromValue(_parseInt(json['costType'])),
      gold: _parseInt(json['gold']) ?? 0,
      unlockCount: _parseInt(json['unlockCount']) ?? 0,
      unlocked: _parseBool(json['unlocked']) ?? false,
      downloadUrl: json['downloadUrl']?.toString(),
      downloads: GamingDownloadItem.listFromData(json['downloads']),
      extractPassword: json['extractPassword']?.toString(),
    );
  }

  static GamingUnlockVo? fromAny(dynamic v) {
    if (v is Map) return GamingUnlockVo.fromJson(Map<String, dynamic>.from(v));
    return null;
  }
}

/// 兼容旧名：列表 / 详情 VO 即 [GameDataModel]。
typedef GamingVo = GameDataModel;

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
  if (v == null) return 0;
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
  if (s.isEmpty) return 0;
  final asInt = int.tryParse(s);
  if (asInt != null) {
    if (asInt > 0 && asInt < 100000000000) return asInt * 1000;
    return asInt;
  }
  try {
    return DateTime.parse(s).millisecondsSinceEpoch;
  } catch (_) {
    return 0;
  }
}
