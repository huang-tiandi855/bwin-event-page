import 'package:comics_app/common/utils/text_util.dart';

/// `activation/welfare/center`（[SignInApis.getWelfaretaskList]）成功时 `BaseRespBean.data` 对象。

int? _welfareInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

double? _welfareDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

bool _welfareBool(dynamic v, {bool fallback = false}) {
  if (v == null) return fallback;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final String s = v.toString().toLowerCase();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return fallback;
}

Map<String, dynamic>? _welfareAsMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return Map<String, dynamic>.from(v);
  return null;
}

/// 单条福利任务（`tasks` 数组元素）。
class WelfareTaskItemModel {
  WelfareTaskItemModel({
    this.id,
    this.taskCode,
    this.title,
    this.description,
    this.rewardType,
    this.rewardAmount,
    this.taskFrequency,
    this.jumpUrl,
    this.iconUrl,
    this.completed = false,
  });

  factory WelfareTaskItemModel.fromJson(Map<String, dynamic> json) {
    return WelfareTaskItemModel(
      id: _welfareInt(json['id']),
      taskCode: json['taskCode']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      rewardType: json['rewardType']?.toString(),
      rewardAmount: _welfareDouble(json['rewardAmount']),
      taskFrequency: _welfareInt(json['taskFrequency']),
      jumpUrl: json['jumpUrl']?.toString(),
      iconUrl: json['iconUrl']?.toString(),
      completed: _welfareBool(json['completed']),
    );
  }

  final int? id;

  /// 如 `ANY_RECHARGE`、`POST_COMMENT`
  final String? taskCode;
  final String? title;
  final String? description;

  /// 如 `POINTS`
  final String? rewardType;
  final double? rewardAmount;

  /// 任务频次类型（与后端约定，如 1 / 2）
  final int? taskFrequency;

  final String? jumpUrl;
  final String? iconUrl;
  final bool completed;

  /// 列表右侧展示的奖励文案（如 `积分+20`）。
  String get rewardDisplayLabel {
    return TextUtil.formatReward(rewardType,
        rewardAmount: rewardAmount, type: 1);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'taskCode': taskCode,
        'title': title,
        'description': description,
        'rewardType': rewardType,
        'rewardAmount': rewardAmount,
        'taskFrequency': taskFrequency,
        'jumpUrl': jumpUrl,
        'iconUrl': iconUrl,
        'completed': completed,
      };

  static List<WelfareTaskItemModel> listFromJson(dynamic raw) {
    if (raw is! List) return const [];
    final List<WelfareTaskItemModel> out = [];
    for (final dynamic e in raw) {
      final Map<String, dynamic>? m = _welfareAsMap(e);
      if (m != null) {
        out.add(WelfareTaskItemModel.fromJson(m));
      }
    }
    return out;
  }
}

/// 福利中心任务区整包数据。
class WelfareTaskCenterModel {
  WelfareTaskCenterModel({
    this.myPoints = 0,
    this.inviteCount = 0,
    this.tasks = const [],
  });

  factory WelfareTaskCenterModel.fromJson(Map<String, dynamic> json) {
    return WelfareTaskCenterModel(
      myPoints: _welfareInt(json['myPoints']) ?? 0,
      inviteCount: _welfareInt(json['inviteCount']) ?? 0,
      tasks: WelfareTaskItemModel.listFromJson(json['tasks']),
    );
  }

  final int myPoints;
  final int inviteCount;
  final List<WelfareTaskItemModel> tasks;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'myPoints': myPoints,
        'inviteCount': inviteCount,
        'tasks': tasks.map((WelfareTaskItemModel e) => e.toJson()).toList(),
      };

  static WelfareTaskCenterModel? tryFromData(dynamic data) {
    final Map<String, dynamic>? m = _welfareAsMap(data);
    if (m == null) return null;
    return WelfareTaskCenterModel.fromJson(m);
  }
}
