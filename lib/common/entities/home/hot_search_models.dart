/// `getHotSearchList` 返回的搜索页热搜词数据。

int? _hotSearchToInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

/// 单个热搜词（`tagList` 元素）。
class HotSearchTagModel {
  const HotSearchTagModel({
    this.id,
    this.tag,
    this.typeId,
    this.recommend,
  });

  factory HotSearchTagModel.fromJson(Map<String, dynamic> json) {
    return HotSearchTagModel(
      id: _hotSearchToInt(json['id']),
      tag: json['tag']?.toString(),
      typeId: _hotSearchToInt(json['typeId']),
      recommend: _hotSearchToInt(json['recommend']),
    );
  }

  final int? id;

  /// 热搜词文案。
  final String? tag;

  final int? typeId;

  /// 后端常用 0/1 表示是否推荐。
  final int? recommend;

  bool get isRecommend => recommend == 1;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'tag': tag,
      'typeId': typeId,
      'recommend': recommend,
    };
  }
}

/// 热搜词分组（接口 `data` 数组中的单项）。
class HotSearchGroupModel {
  const HotSearchGroupModel({
    this.id,
    this.siteId,
    this.typeName,
    this.position,
    this.tagList = const [],
  });

  factory HotSearchGroupModel.fromJson(Map<String, dynamic> json) {
    final tags = <HotSearchTagModel>[];
    final raw = json['tagList'];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          tags.add(
            HotSearchTagModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return HotSearchGroupModel(
      id: _hotSearchToInt(json['id']),
      siteId: _hotSearchToInt(json['siteId']),
      typeName: json['typeName']?.toString(),
      position: json['position'],
      tagList: tags,
    );
  }

  final int? id;
  final int? siteId;
  final String? typeName;
  final dynamic position;

  /// 搜索页热搜词列表。
  final List<HotSearchTagModel> tagList;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'siteId': siteId,
      'typeName': typeName,
      'position': position,
      'tagList': tagList.map((e) => e.toJson()).toList(),
    };
  }

  /// 解析接口 `data`（JSON 数组 -> 分组列表）。
  static List<HotSearchGroupModel> listFromData(dynamic data) {
    if (data == null || data is! List) return [];
    final out = <HotSearchGroupModel>[];
    for (final item in data) {
      if (item is Map) {
        out.add(
          HotSearchGroupModel.fromJson(Map<String, dynamic>.from(item)),
        );
      }
    }
    return out;
  }

  /// 直接取扁平化热搜词列表。
  static List<HotSearchTagModel> tagsFromData(dynamic data) {
    return listFromData(data).expand((group) => group.tagList).toList();
  }

  /// 直接取非空热搜词文案列表。
  static List<String> keywordsFromData(dynamic data) {
    return tagsFromData(data)
        .map((item) => item.tag?.trim())
        .whereType<String>()
        .where((tag) => tag.isNotEmpty)
        .toList();
  }
}
