/// `activation/signin/v2/overview` 等接口：与 `BaseRespBean.data` 一一对应
///（文档示例里的 `result` 对象即网关解密后的 `data`）。

import 'dart:convert';

int? _signInToInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

bool? _signInToBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final String s = v.toString().toLowerCase();
  if (s == 'true') return true;
  if (s == 'false') return false;
  return null;
}

Map<String, dynamic>? _asStringKeyMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return Map<String, dynamic>.from(v);
  return null;
}

/// 单日奖励配置（`freeRewards` / `memberRewards` / `vipExclusiveRewards` 元素）。
class SignInRewardItemModel {
  SignInRewardItemModel({
    this.day,
    this.rewardType,
    this.rewardPayload,
    this.iconUrl,
    this.rewardName,
  });

  factory SignInRewardItemModel.fromJson(Map<String, dynamic> json) {
    return SignInRewardItemModel(
      day: _signInToInt(json['day']),
      rewardType: json['rewardType']?.toString(),
      rewardPayload: json['rewardPayload']?.toString(),
      iconUrl: json['iconUrl']?.toString(),
      rewardName: json['rewardName']?.toString(),
    );
  }

  final int? day;

  /// 如 `POINTS`
  final String? rewardType;

  /// JSON 字符串，如 `{"amount": 1}`，业务层按需解析
  final String? rewardPayload;

  /// 奖品图标（相对路径，需要业务层拼前缀）。部分项后端会下发 null。
  final String? iconUrl;

  /// 奖品中文名（如「金币」「观影券（Movie tickets）」），可直接挂 UI 展示。
  final String? rewardName;

  /// UI 展示用的奖品文案
  String get displayLabel {
    final String type = (rewardType ?? '').toUpperCase();
    final Object? amount = _rewardAmount(rewardPayload);

    switch (type) {
      case 'POINTS':
        return amount != null ? '积分+$amount' : '积分';
      case 'COINS':
        return amount != null ? '$amount金币' : '金币';
      case 'VIP_DAY_CARD':
        return amount != null ? 'VIP$amount天' : 'VIP日卡';
      case 'MOVIE_TICKETS':
        return amount != null ? '$amount观影券' : '观影券';
      case 'AI_FACE_SWAP':
        return 'AI换脸';
      case 'AI_UNDRESS':
        return 'AI脱衣';
    }

    return '';
  }

  Object? _rewardAmount(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final Object? decoded = json.decode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded['amount'];
      }
    } catch (_) {}
    return null;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'day': day,
        'rewardType': rewardType,
        'rewardPayload': rewardPayload,
        'iconUrl': iconUrl,
        'rewardName': rewardName,
      };
}

/// 单条签到通道状态（`free` / `member` / `vipExclusive`）。
class SignInChannelOverviewModel {
  SignInChannelOverviewModel({
    this.signType,
    this.eligible,
    this.signedToday,
    this.lastingDays,
    this.vipCycleDay,
    this.lastSignOn,
  });

  factory SignInChannelOverviewModel.fromJson(Map<String, dynamic> json) {
    return SignInChannelOverviewModel(
      signType: _signInToInt(json['signType']),
      eligible: _signInToBool(json['eligible']),
      signedToday: _signInToBool(json['signedToday']),
      lastingDays: _signInToInt(json['lastingDays']),
      vipCycleDay: _signInToInt(json['vipCycleDay']),
      lastSignOn: json['lastSignOn']?.toString(),
    );
  }

  final int? signType;

  /// 是否具备该通道签到资格
  final bool? eligible;

  /// 今天是否已签到
  final bool? signedToday;

  /// 连续签到天数
  final int? lastingDays;

  /// 当前周期内「今天」是第几天；若服务端下发且大于 0，则优先于 `lastingDays` / `signedToday` 推断。
  final int? vipCycleDay;

  /// 上次签到时间（接口可为时间戳或字符串，统一成可读字符串）
  final String? lastSignOn;

  /// 当前周期内「今天」是第几天。
  /// - 优先用服务端 [vipCycleDay]（>0 时直接返回，受 [cycleCap] 截断）；
  /// - 否则按 [lastingDays] + [signedToday] 推断：今日已签 → `lasting`（至少 1）；
  ///   未签 → `lasting + 1`。
  ///
  /// 把推断收敛在 entity 上，view 不用再算「今天是第几格」。
  int? todayCycleDay(int cycleCap) {
    final int cap = cycleCap > 0 ? cycleCap : 1;
    final int? vcd = vipCycleDay;
    if (vcd != null && vcd > 0) {
      return vcd > cap ? cap : vcd;
    }
    final int ld = lastingDays ?? 0;
    final bool st = signedToday == true;
    if (st) {
      final int t = ld <= 0 ? 1 : ld;
      return t > cap ? cap : t;
    }
    final int next = ld + 1;
    return next > cap ? cap : next;
  }

  /// 周期第 [day] 天是否已签到 / 已领奖。
  /// - `lasting > 0 && day <= lasting` → 已签；
  /// - 兼容首日刚签到、`lasting` 还未累加的过渡：`signedToday && day == 1`。
  bool isDayClaimed(int? day, {bool vip = false}) {
    if (day == null) return false;
    final int lasting = (vip ? vipCycleDay : lastingDays) ?? 0;
    if (lasting > 0 && day <= lasting) return true;
    return false;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'signType': signType,
        'eligible': eligible,
        'signedToday': signedToday,
        'lastingDays': lastingDays,
        'vipCycleDay': vipCycleDay,
        'lastSignOn': lastSignOn,
      };
}

/// 签到总览（直接由 `BaseRespBean.data` 反序列化，勿再包一层 `result`）。
class SignInOverviewResultModel {
  SignInOverviewResultModel({
    this.vip,
    this.dailyCycleDays,
    this.vipExclusiveCycleDays,
    this.free,
    this.member,
    this.vipExclusive,
    this.freeRewards = const [],
    this.memberRewards = const [],
    this.vipExclusiveRewards = const [],
  });

  factory SignInOverviewResultModel.fromJson(Map<String, dynamic> json) {
    return SignInOverviewResultModel(
      vip: _signInToBool(json['vip']),
      dailyCycleDays: _signInToInt(json['dailyCycleDays']),
      vipExclusiveCycleDays: _signInToInt(json['vipExclusiveCycleDays']),
      free: _parseChannel(json['free']),
      member: _parseChannel(json['member']),
      vipExclusive: _parseChannel(json['vipExclusive']),
      freeRewards: _parseRewardList(json['freeRewards']),
      memberRewards: _parseRewardList(json['memberRewards']),
      vipExclusiveRewards: _parseRewardList(json['vipExclusiveRewards']),
    );
  }

  static SignInChannelOverviewModel? _parseChannel(dynamic v) {
    final Map<String, dynamic>? m = _asStringKeyMap(v);
    if (m == null) return null;
    return SignInChannelOverviewModel.fromJson(m);
  }

  static List<SignInRewardItemModel> _parseRewardList(dynamic v) {
    if (v is! List) return const [];
    final List<SignInRewardItemModel> out = [];
    for (final e in v) {
      final Map<String, dynamic>? m = _asStringKeyMap(e);
      if (m != null) {
        out.add(SignInRewardItemModel.fromJson(m));
      }
    }
    return out;
  }

  final bool? vip;

  /// 日签周期总天数
  final int? dailyCycleDays;

  /// 会员专享周期天数
  final int? vipExclusiveCycleDays;

  final SignInChannelOverviewModel? free;
  final SignInChannelOverviewModel? member;
  final SignInChannelOverviewModel? vipExclusive;

  final List<SignInRewardItemModel> freeRewards;
  final List<SignInRewardItemModel> memberRewards;
  final List<SignInRewardItemModel> vipExclusiveRewards;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'vip': vip,
        'dailyCycleDays': dailyCycleDays,
        'vipExclusiveCycleDays': vipExclusiveCycleDays,
        'free': free?.toJson(),
        'member': member?.toJson(),
        'vipExclusive': vipExclusive?.toJson(),
        'freeRewards': freeRewards.map((e) => e.toJson()).toList(),
        'memberRewards': memberRewards.map((e) => e.toJson()).toList(),
        'vipExclusiveRewards':
            vipExclusiveRewards.map((e) => e.toJson()).toList(),
      };
}
