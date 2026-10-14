/// 邀请收益汇总（POST `/income/list/invite` 的 `result` 字段）
///
/// 金币字段后端会下发 null（表示尚未产生收益），保留可空类型；邀请人数为
/// 数值，缺省按 0 处理。
class InviteIncomeSummaryModel {
  InviteIncomeSummaryModel({
    this.allGold,
    this.todayGold,
    this.thisMonthGold,
    this.todayInvite = 0,
    this.thisMonthInvite = 0,
    this.totalInvite = 0,
    this.totalInviteRecharge = 0,
  });

  /// 累计金币
  double? allGold;

  /// 今日金币
  double? todayGold;

  /// 本月金币
  double? thisMonthGold;

  /// 今日邀请人数
  int todayInvite;

  /// 本月邀请人数
  int thisMonthInvite;

  /// 累计邀请人数
  int totalInvite;

  /// 累计邀请充值人数
  int totalInviteRecharge;

  factory InviteIncomeSummaryModel.fromJson(Map<String, dynamic> json) {
    return InviteIncomeSummaryModel(
      allGold: _parseDoubleOrNull(json['allGold']),
      todayGold: _parseDoubleOrNull(json['todayGold']),
      thisMonthGold: _parseDoubleOrNull(json['thisMonthGold']),
      todayInvite: _parseInt(json['todayInvite']) ?? 0,
      thisMonthInvite: _parseInt(json['thisMonthInvite']) ?? 0,
      totalInvite: _parseInt(json['totalInvite']) ?? 0,
      totalInviteRecharge: _parseInt(json['totalInviteRecharge']) ?? 0,
    );
  }

  /// 接口失败 / 无数据的兜底实例
  factory InviteIncomeSummaryModel.empty() => InviteIncomeSummaryModel();

  Map<String, dynamic> toJson() => <String, dynamic>{
        'allGold': allGold,
        'todayGold': todayGold,
        'thisMonthGold': thisMonthGold,
        'todayInvite': todayInvite,
        'thisMonthInvite': thisMonthInvite,
        'totalInvite': totalInvite,
        'totalInviteRecharge': totalInviteRecharge,
      };
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _parseDoubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
