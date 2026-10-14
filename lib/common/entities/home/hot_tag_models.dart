/// `getHotTag` 接口返回的 `data`：分组列表，每组含维度信息与 `tagList`。

int? _hotTagToInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

/// 单个热门标签（`tagList` 元素）。
class HotTagItemModel {
  HotTagItemModel({
    this.id,
    this.tag,
    this.typeId,
    this.recommend,
  });

  factory HotTagItemModel.fromJson(Map<String, dynamic> json) {
    return HotTagItemModel(
      id: _hotTagToInt(json['id']),
      tag: json['tag']?.toString(),
      typeId: _hotTagToInt(json['typeId']),
      recommend: _hotTagToInt(json['recommend']),
    );
  }

  final int? id;

  /// 标签展示文案
  final String? tag;

  final int? typeId;

  /// 后端常用 0/1 表示是否推荐
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

/// 热门标签分组（`data` 数组中的单项）。
class HotTagGroupModel {
  HotTagGroupModel({
    this.id,
    this.siteId,
    this.typeName,
    this.position,
    this.tagList = const [],
  });

  factory HotTagGroupModel.fromJson(Map<String, dynamic> json) {
    final List<HotTagItemModel> tags = [];
    final raw = json['tagList'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          tags.add(HotTagItemModel.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return HotTagGroupModel(
      id: _hotTagToInt(json['id']),
      siteId: _hotTagToInt(json['siteId']),
      typeName: json['typeName']?.toString(),
      position: json['position'],
      tagList: tags,
    );
  }

  final int? id;
  final int? siteId;

  /// 分组名称，如「主题」
  final String? typeName;

  /// 可为 null，类型与后端保持一致
  final dynamic position;

  final List<HotTagItemModel> tagList;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'siteId': siteId,
      'typeName': typeName,
      'position': position,
      'tagList': tagList.map((e) => e.toJson()).toList(),
    };
  }

  /// 解析接口 `data`（JSON 数组 → 模型列表）。
  static List<HotTagGroupModel> listFromData(dynamic data) {
    if (data == null || data is! List) return [];
    final out = <HotTagGroupModel>[];
    for (final e in data) {
      if (e is Map) {
        out.add(HotTagGroupModel.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    return out;
  }
}
