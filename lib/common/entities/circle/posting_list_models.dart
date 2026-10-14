import 'package:comics_app/common/entities/circle/post_card_data.dart';
import 'package:comics_app/common/entities/circle/post_enums.dart';

export 'package:comics_app/common/entities/circle/post_card_data.dart';
export 'package:comics_app/common/entities/circle/post_enums.dart';

/// `posting/list` 请求参数容器。
///
/// 设计：
/// - `page` / `pageSize` 有默认值，其它字段全部可选；
/// - [toJson] 会跳过 `null` / 空列表，避免把无意义键塞进 query；
/// - [copyWith] 方便筛选切换 / 翻页：`query.copyWith(page: query.page + 1)`。
class PostingListQuery {
  const PostingListQuery({
    this.page = 1,
    this.pageSize = 10,
    this.categoryId,
    this.childCategoryId,
    this.costType,
    this.id,
    this.ids,
    this.keyword,
    this.nickName,
    this.sortType,
    this.type,
    this.uid,
    this.uids,
    this.hasVideo,
  });

  /// 页码，从 1 开始。
  final int page;

  /// 单页条数。
  final int pageSize;

  /// 一级分类 id。
  final int? categoryId;

  /// 二级分类 id。
  final int? childCategoryId;

  /// 消费类型筛选。
  final PostCostType? costType;

  /// 单条帖子 id（拉详情列表场景）。
  final int? id;

  /// 帖子 id 列表（批量场景）。
  final List<int>? ids;

  /// 标题关键字。
  final String? keyword;

  /// 作者昵称关键字。
  final String? nickName;

  /// 排序方式。
  final PostSortType? sortType;

  /// 帖子媒体类型筛选。
  final PostType? type;

  /// 作者 id。
  final int? uid;

  /// 作者 id 列表。
  final List<int>? uids;

  /// 是否视频贴子。
  final bool? hasVideo;

  /// 转成接口 body。`null` / 空列表都会被剔除。
  Map<String, dynamic> toJson() {
    final out = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (categoryId != null) out['categoryId'] = categoryId;
    if (childCategoryId != null) out['childCategoryId'] = childCategoryId;
    if (costType != null) out['costType'] = costType!.value;
    if (id != null) out['id'] = id;
    if (ids != null && ids!.isNotEmpty) out['ids'] = ids;
    if (keyword != null && keyword!.isNotEmpty) out['keyword'] = keyword;
    if (nickName != null && nickName!.isNotEmpty) out['nickName'] = nickName;
    if (sortType != null) out['sortType'] = sortType!.value;
    if (type != null) out['type'] = type!.value;
    if (uid != null) out['uid'] = uid;
    if (uids != null && uids!.isNotEmpty) out['uids'] = uids;
    if (hasVideo != null) out['hasVideo'] = hasVideo;
    return out;
  }

  /// 部分字段更新（沿用 Dart 习惯的 copyWith）。
  ///
  /// 注意：要把可空字段重置为 `null`，请新建一个 `PostingListQuery(...)` 而不是
  /// 调 `copyWith` —— 这里没有提供「显式置空」的 marker，避免增加复杂度。
  PostingListQuery copyWith({
    int? page,
    int? pageSize,
    int? categoryId,
    int? childCategoryId,
    PostCostType? costType,
    int? id,
    List<int>? ids,
    String? keyword,
    String? nickName,
    PostSortType? sortType,
    PostType? type,
    int? uid,
    List<int>? uids,
    bool? hasVideo,
  }) {
    return PostingListQuery(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      categoryId: categoryId ?? this.categoryId,
      childCategoryId: childCategoryId ?? this.childCategoryId,
      costType: costType ?? this.costType,
      id: id ?? this.id,
      ids: ids ?? this.ids,
      keyword: keyword ?? this.keyword,
      nickName: nickName ?? this.nickName,
      sortType: sortType ?? this.sortType,
      type: type ?? this.type,
      uid: uid ?? this.uid,
      uids: uids ?? this.uids,
      hasVideo: hasVideo ?? this.hasVideo,
    );
  }
}

/// `posting/list` 分页响应。
///
/// 兼容两种后端格式：
/// 1. **扁平数组**（当前后端 `posting/list` 的实际格式）：`data: [{...}, ...]`，
///    顶层 `total` 字段；这里没有 PageHelper 字段，[hasNextPage] 用「条数 ≥ 请求页长」
///    的启发式估算（需要传 [PostingListPage.fromData] 的 `requestedPageSize`）。
/// 2. **PageHelper 对象**：`data: { list, total, pageNum, pageSize, hasNextPage }`，
///    各字段按文档解析。
///
/// 只展开常用字段；其它分页指标如果以后需要再补，不影响这里的对外 API。
class PostingListPage {
  PostingListPage({
    required this.list,
    this.pageNum = 0,
    this.pageSize = 0,
    this.total = 0,
    this.hasNextPage = false,
  });

  /// 当前页的帖子数据。
  final List<PostCardData> list;

  /// 当前页码（后端值，可能 0 或 1 起算，看 PageHelper 配置）。
  final int pageNum;

  /// 单页条数。
  final int pageSize;

  /// 总条数。
  final int total;

  /// 是否还有下一页（load more 判断用）。
  final bool hasNextPage;

  /// 空数据兜底，请求失败 / 数据缺失时使用。
  factory PostingListPage.empty() => PostingListPage(list: const []);

  /// 解析接口 `data` 字段。
  ///
  /// - 扁平数组：`requestedPageSize` 用于「条数 ≥ 请求页长则可能还有下一页」的启发式判断。
  /// - PageHelper Map：直接用其 `hasNextPage` 字段，[requestedPageSize] 忽略。
  factory PostingListPage.fromData(
    dynamic data, {
    int? requestedPageSize,
  }) {
    if (data == null) return PostingListPage.empty();
    if (data is List) {
      final list = PostCardData.listFromData(data);
      final bool hasMore =
          requestedPageSize != null && list.length >= requestedPageSize;
      return PostingListPage(list: list, hasNextPage: hasMore);
    }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      return PostingListPage(
        list: PostCardData.listFromData(map['list'] ?? map['data']),
        pageNum: _asInt(map['pageNum']),
        pageSize: _asInt(map['pageSize']),
        total: _asInt(map['total']),
        hasNextPage: _asBool(map['hasNextPage']),
      );
    }
    return PostingListPage.empty();
  }
}

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}

bool _asBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v?.toString().toLowerCase();
  return s == 'true' || s == '1';
}
