import 'dart:convert';

import 'package:get/get.dart';

/// 文本处理工具类
class TextUtil {
  ///特殊字符验证
  static bool isSpecialChar(String str) {
    if (str.isEmpty) return false;
    return RegExp(
            r"[_`~!@#$%^&*()+=|{}':;',\[\].<>/?~！@#￥%……&*（）——+|{}【】‘；：”“’。，、？]|\n|\r|\t|\s")
        .hasMatch(str);
  }

  ///手机号验证
  static bool isChinaPhoneLegal(String str) {
    if (str.isEmpty) return false;
    return RegExp(r"^1[3-9]\d{9}$").hasMatch(str);
  }

  ///短信验证码验证
  static bool isSMSCode(String str) {
    if (str.isEmpty) return false;
    return RegExp(r"^\d{6}$").hasMatch(str);
  }

  ///字符串截断
  static String truncate(String value, int remain) {
    if (value.isEmpty) return '';
    return ((value).length >= remain)
        ? ('${value.substring(0, remain)}...')
        : value;
  }

  static bool isEmpty(String? text) {
    return (null == text || text.isEmpty);
  }

  static bool isOnlyContainZero(String input) {
    final regexp = RegExp(r'^[0-]+$');
    return regexp.hasMatch(input.removeAllWhitespace);
  }

  static bool isNotEmpty(String? text) {
    return (null != text && text.isNotEmpty);
  }

  ///验证手机号11位
  static bool isPhone(String str) {
    if (TextUtil.isEmpty(str)) {
      return false;
    }
    RegExp exp = RegExp(r'^1\d{10}$');
    return exp.hasMatch(str);
  }

  ///邮箱验证
  static bool isEmail(String str) {
    if (TextUtil.isEmpty(str)) {
      return false;
    }
    return RegExp(r"^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$")
        .hasMatch(str);
  }

  static bool isNumeric(String str) {
    if (str.isEmpty) return false;
    try {
      double.parse(str);
      return true;
    } on FormatException {
      return false;
    }
  }

  static bool isChinese(String str) {
    RegExp reg = RegExp(r"[\u4e00-\u9fa5]+");
    return reg.hasMatch(str);
  }

  static String moreThan1wIndent(int num) {
    if (num > 10000) {
      return '${(num / 10000).toStringAsFixed(0)}w';
    }
    return '$num';
  }

  static String moreThan1wIndent1(int num) {
    if (num > 10000) {
      return '${(num / 10000).toStringAsFixed(0)}w';
    }
    return '$num';
  }

  /// 把后端的 `rewardType` + `rewardPayload` 拼成展示用的奖品文案。
  ///
  /// - 需要数量的奖品（积分 / 金币 / VIP 日卡 / 观影券）从 [rewardPayload]
  ///   里读 `amount` 拼到 label 后面，输出形如 "金币1" / "观影券1"；
  /// - 不需要数量的奖品（AI 换脸 / AI 脱衣）只返回 label，输出形如
  ///   "AI换脸"。即使 payload 里带 `amount` 也忽略——避免误展示成
  ///   "AI换脸1次" 这类后端尚未约定的格式。
  ///
  /// 兜底策略（不抛错，便于直接挂在 UI 上）：
  /// - [rewardType] 空 → 返回 ''；
  /// - [rewardType] 不在已知列表中 → 原样返回 [rewardType]，方便联调时
  ///   一眼看到后端新加但前端还没补的类型；
  /// - [rewardPayload] 不是合法 JSON / 缺 `amount` 字段 → 仅返回 label，
  ///   不拼数量。
  /// [type] 显示类型，目前定义：0兑换奖品，1，任务奖品 2，签到奖品
  static String formatReward(String? rewardType,
      {String? rewardPayload, double? rewardAmount, int type = 0}) {
    if (rewardType == null || rewardType.isEmpty) return '';
    final spec = _rewardSpecs[rewardType];
    if (spec == null) return rewardType;
    if (!spec.needAmount) {
      if (type == 0) {
        return spec.label;
      } else if (type == 1) {
        return '+${spec.label}';
      } else {
        return spec.label;
      }
    }
    final amount = rewardAmount?.toInt() ?? _extractRewardAmount(rewardPayload);
    if (type == 0) {
      return spec.label;
    } else if (type == 1) {
      return amount == null ? '+${spec.label}' : '+$amount${spec.label}';
    } else {
      return amount == null ? spec.label : '${spec.label}+$amount';
    }
  }

  /// 从 [rewardPayload]（约定为 `{"amount":N}` 的 JSON 字符串）里取
  /// `amount` 字段；兼容服务端偶发把 amount 落成字符串 / 浮点数的情况。
  static int? _extractRewardAmount(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final dynamic decoded = jsonDecode(payload);
      if (decoded is! Map) return null;
      final raw = decoded['amount'];
      if (raw is int) return raw;
      if (raw is num) return raw.toInt();
      if (raw is String) return int.tryParse(raw);
      return null;
    } catch (_) {
      // 服务端偶发返回非法 JSON 时退化成"无数量"展示，不影响外层 UI。
      return null;
    }
  }
}

/// 奖品类型对应的 label 与是否需要拼数量。集中在此处便于后端新增类型时
/// 一处维护——只动 [_rewardSpecs] 即可。
class _RewardSpec {
  const _RewardSpec(this.label, {required this.needAmount});
  final String label;
  final bool needAmount;
}

const Map<String, _RewardSpec> _rewardSpecs = <String, _RewardSpec>{
  'POINTS': _RewardSpec('积分', needAmount: true),
  'COINS': _RewardSpec('金币', needAmount: true),
  'VIP_DAY_CARD': _RewardSpec('VIP日卡', needAmount: true),
  'MOVIE_TICKETS': _RewardSpec('观影券', needAmount: true),
  'AI_FACE_SWAP': _RewardSpec('AI视频', needAmount: false),
  'AI_UNDRESS': _RewardSpec('AI图文', needAmount: false),
};

/// 获取个性化数量显示
String getShowCountStr(int number, {int count = 1}) {
  String numStr = "";
  if (number > 100000000) {
    // ignore: no_leading_underscores_for_local_identifiers
    num _num = number / 100000000;
    _num = num.parse(_num.toStringAsFixed(count));

    numStr = "$_num亿";
  } else if (number > 10000) {
    // ignore: no_leading_underscores_for_local_identifiers
    num _num = number / 10000;
    _num = num.parse(_num.toStringAsFixed(1));
    numStr = "${_num}w";
  } else {
    numStr = number.toString();
  }
  return numStr;
}
