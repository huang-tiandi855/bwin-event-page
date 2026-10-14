/// 金刚区按钮（`POST ads/kingKong/list`）。
///
/// 接口返回示例：
/// ```json
/// {
///   "id": 1,
///   "title": "活动",
///   "sort": 1,
///   "showType": 1,
///   "jumpType": 0,
///   "url": "https://google.com",
///   "icon": "ads/kingKong/20260522/26E0W0W460Q0359894113.jpg",
///   "status": 1
/// }
/// ```
class KingKongModel {
  /// 金刚区按钮 id
  int? id;

  /// 按钮文案
  String? title;

  /// 排序权重，值越小越靠前
  int? sort;

  /// 展示方式（由后端约定）
  int? showType;

  /// 跳转类型（由后端约定，例如 0：H5 外链）
  int? jumpType;

  /// 跳转地址
  String? url;

  /// 图标资源相对路径
  String? icon;

  /// 状态（1：上架可用）
  int? status;

  KingKongModel({
    this.id,
    this.title,
    this.sort,
    this.showType,
    this.jumpType,
    this.url,
    this.icon,
    this.status,
  });

  factory KingKongModel.fromJson(Map<String, dynamic> json) {
    return KingKongModel(
      id: _parseInt(json['id']),
      title: json['title']?.toString(),
      sort: _parseInt(json['sort']),
      showType: _parseInt(json['showType']),
      jumpType: _parseInt(json['jumpType']),
      url: json['url']?.toString(),
      icon: json['icon']?.toString(),
      status: _parseInt(json['status']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'sort': sort,
        'showType': showType,
        'jumpType': jumpType,
        'url': url,
        'icon': icon,
        'status': status,
      };

  /// 从接口 `data` 数组批量解析。
  static List<KingKongModel> listFromData(dynamic raw) {
    if (raw is! List) return const <KingKongModel>[];
    final List<KingKongModel> out = <KingKongModel>[];
    for (final dynamic e in raw) {
      if (e is Map<String, dynamic>) {
        out.add(KingKongModel.fromJson(e));
      } else if (e is Map) {
        out.add(KingKongModel.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    return out;
  }

  KingKongModel copyWith({
    int? id,
    String? title,
    int? sort,
    int? showType,
    int? jumpType,
    String? url,
    String? icon,
    int? status,
  }) {
    return KingKongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      sort: sort ?? this.sort,
      showType: showType ?? this.showType,
      jumpType: jumpType ?? this.jumpType,
      url: url ?? this.url,
      icon: icon ?? this.icon,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'KingKongModel(id: $id, title: $title, sort: $sort, '
        'showType: $showType, jumpType: $jumpType, url: $url, '
        'icon: $icon, status: $status)';
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
