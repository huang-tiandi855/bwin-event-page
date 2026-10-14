/// 公告 / 跑马灯展示位（与后端 `showType` 字段约定）。
enum NoticeShowType {
  /// 0：主页
  home(0),

  /// 1：社区
  community(1),

  /// 2：公告弹窗
  notice(2);

  const NoticeShowType(this.value);

  /// 与后端约定的整型值
  final int value;
}

/// 公告 / 跑马灯条目（`POST ads/notice/list`）。
///
/// 接口返回示例：
/// ```json
/// {
///   "id": 1,
///   "title": "活动公告内容...",
///   "sort": 1,
///   "showType": 0,
///   "jumpType": 0,
///   "url": "",
///   "status": 1
/// }
/// ```
class NoticeModel {
  /// 公告 id
  int? id;

  /// 公告 / 跑马灯文本内容
  String? title;

  /// 排序权重，值越小越靠前
  int? sort;

  ///  0：首页，1:社区，2：公告弹窗
  int? showType;

  /// 跳转类型（由后端约定，例如 0：无跳转）
  int? jumpType;

  /// 点击跳转地址；`jumpType == 0` 时通常为空字符串
  String? url;

  /// 状态（1：上架可用）
  int? status;

  /// 内容
  String? content;

  NoticeModel({
    this.id,
    this.title,
    this.sort,
    this.showType,
    this.jumpType,
    this.url,
    this.status,
    this.content,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: _parseInt(json['id']),
      title: json['title']?.toString(),
      sort: _parseInt(json['sort']),
      showType: _parseInt(json['showType']),
      jumpType: _parseInt(json['jumpType']),
      url: json['url']?.toString(),
      status: _parseInt(json['status']),
      content: json['content']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'sort': sort,
        'showType': showType,
        'jumpType': jumpType,
        'url': url,
        'status': status,
        'content': content,
      };

  /// 从接口 `data` 数组批量解析。
  static List<NoticeModel> listFromData(dynamic raw) {
    if (raw is! List) return const <NoticeModel>[];
    final List<NoticeModel> out = <NoticeModel>[];
    for (final dynamic e in raw) {
      if (e is Map<String, dynamic>) {
        out.add(NoticeModel.fromJson(e));
      } else if (e is Map) {
        out.add(NoticeModel.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    return out;
  }

  NoticeModel copyWith({
    int? id,
    String? title,
    int? sort,
    int? showType,
    int? jumpType,
    String? url,
    int? status,
    String? content,
  }) {
    return NoticeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      sort: sort ?? this.sort,
      showType: showType ?? this.showType,
      jumpType: jumpType ?? this.jumpType,
      url: url ?? this.url,
      status: status ?? this.status,
      content: content ?? this.content,
    );
  }

  @override
  String toString() {
    return 'NoticeModel(id: $id, title: $title, sort: $sort, '
        'showType: $showType, jumpType: $jumpType, url: $url, status: $status,content: $content)';
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
