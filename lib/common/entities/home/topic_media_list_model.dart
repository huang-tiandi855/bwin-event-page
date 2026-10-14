import 'home_media_list_models.dart';

int? _topicMediaToInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

/// `cms/vod/groups/search` 返回的单个专题分组数据。
class TopicMediaGroupModel {
  TopicMediaGroupModel({
    required this.groupId,
    this.code,
    this.message,
    this.total,
    this.result,
    this.data = const [],
  });

  factory TopicMediaGroupModel.fromJson(
    String groupId,
    Map<String, dynamic> json,
  ) {
    return TopicMediaGroupModel(
      groupId: groupId,
      code: json['code']?.toString(),
      message: json['message']?.toString(),
      total: _topicMediaToInt(json['total']),
      result: json['result'],
      data: MediaVideoModel.listFromData(json['data']),
    );
  }

  /// 外层 Map 的 key，如 `5059`。
  final String groupId;
  final String? code;
  final String? message;
  final int? total;
  final dynamic result;
  final List<MediaVideoModel> data;

  bool get isSuccess => code == '0000';

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'groupId': groupId,
      'code': code,
      'message': message,
      'total': total,
      'result': result,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }

  /// 解析接口 `data`（JSON 对象 → 分组列表）。
  static List<TopicMediaGroupModel> listFromData(dynamic data) {
    if (data == null || data is! Map) return [];
    final out = <TopicMediaGroupModel>[];
    data.forEach((key, value) {
      if (value is Map) {
        out.add(
          TopicMediaGroupModel.fromJson(
            key.toString(),
            Map<String, dynamic>.from(value),
          ),
        );
      }
    });
    return out;
  }

  /// 需要按专题 id 快速取值时可使用 Map 结构。
  static Map<String, TopicMediaGroupModel> mapFromData(dynamic data) {
    return {
      for (final item in listFromData(data)) item.groupId: item,
    };
  }
}
