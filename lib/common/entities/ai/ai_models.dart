import 'dart:convert';

/// AI 计费规则（`/ai/home.rules` / `/ai/rule/list`）。
class AiBillingRuleVo {
  AiBillingRuleVo({
    this.id,
    this.ruleCode,
    this.name,
    this.deductMode,
    this.deductModeName,
    this.goldPrice,
    this.aiType,
    this.defaultModel,
    this.clientIntro,
    this.status,
    this.sort,
    this.remainTimes,
  });

  final int? id;
  final String? ruleCode;
  final String? name;

  /// 1 仅金币；2 优先免费次数。
  final int? deductMode;
  final String? deductModeName;
  final int? goldPrice;

  /// 1 图 / 2 视频。
  final int? aiType;
  final String? defaultModel;
  final String? clientIntro;

  /// 1=启用。
  final int? status;
  final int? sort;

  /// 仅 deductMode=2 有意义。
  final int? remainTimes;

  AiBillingRuleVo copyWith({
    int? id,
    String? ruleCode,
    String? name,
    int? deductMode,
    String? deductModeName,
    int? goldPrice,
    int? aiType,
    String? defaultModel,
    String? clientIntro,
    int? status,
    int? sort,
    int? remainTimes,
  }) {
    return AiBillingRuleVo(
      id: id ?? this.id,
      ruleCode: ruleCode ?? this.ruleCode,
      name: name ?? this.name,
      deductMode: deductMode ?? this.deductMode,
      deductModeName: deductModeName ?? this.deductModeName,
      goldPrice: goldPrice ?? this.goldPrice,
      aiType: aiType ?? this.aiType,
      defaultModel: defaultModel ?? this.defaultModel,
      clientIntro: clientIntro ?? this.clientIntro,
      status: status ?? this.status,
      sort: sort ?? this.sort,
      remainTimes: remainTimes ?? this.remainTimes,
    );
  }

  factory AiBillingRuleVo.fromJson(Map<String, dynamic> json) {
    return AiBillingRuleVo(
      id: _aiToInt(json['id']),
      ruleCode: json['ruleCode']?.toString(),
      name: json['name']?.toString(),
      deductMode: _aiToInt(json['deductMode']),
      deductModeName: json['deductModeName']?.toString(),
      goldPrice: _aiToInt(json['goldPrice']),
      aiType: _aiToInt(json['aiType']),
      defaultModel: json['defaultModel']?.toString(),
      clientIntro: json['clientIntro']?.toString(),
      status: _aiToInt(json['status']),
      sort: _aiToInt(json['sort']),
      remainTimes: _aiToInt(json['remainTimes']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'ruleCode': ruleCode,
        'name': name,
        'deductMode': deductMode,
        'deductModeName': deductModeName,
        'goldPrice': goldPrice,
        'aiType': aiType,
        'defaultModel': defaultModel,
        'clientIntro': clientIntro,
        'status': status,
        'sort': sort,
        'remainTimes': remainTimes,
      };

  static List<AiBillingRuleVo> listFromData(dynamic data) {
    if (data == null) return const [];
    if (data is! List) return const [];
    final out = <AiBillingRuleVo>[];
    for (final e in data) {
      if (e is Map) {
        out.add(AiBillingRuleVo.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    return out;
  }
}

/// AI 首页聚合（余额 + 下载价 + 保留时长 + 规则）。
class AiClientHomeVo {
  AiClientHomeVo({
    this.goldBalance = 0,
    this.downloadCost = 2,
    this.retainHours = 24,
    this.rules = const [],
  });

  final int goldBalance;
  final int downloadCost;
  final int retainHours;
  final List<AiBillingRuleVo> rules;

  AiClientHomeVo copyWith({
    int? goldBalance,
    int? downloadCost,
    int? retainHours,
    List<AiBillingRuleVo>? rules,
  }) {
    return AiClientHomeVo(
      goldBalance: goldBalance ?? this.goldBalance,
      downloadCost: downloadCost ?? this.downloadCost,
      retainHours: retainHours ?? this.retainHours,
      rules: rules ?? this.rules,
    );
  }

  factory AiClientHomeVo.fromJson(Map<String, dynamic> json) {
    final rawRules = json['rules'];
    return AiClientHomeVo(
      goldBalance: _aiToInt(json['goldBalance']) ?? 0,
      downloadCost: _aiToInt(json['downloadCost']) ?? 2,
      retainHours: _aiToInt(json['retainHours']) ?? 24,
      rules: AiBillingRuleVo.listFromData(rawRules),
    );
  }

  AiBillingRuleVo? ruleOf(String ruleCode) {
    for (final r in rules) {
      if (r.ruleCode == ruleCode) return r;
    }
    return null;
  }

  /// 与 H5 `formatRuleCost` 对齐。
  ({String costText, String balanceText}) formatRuleCost(String ruleCode) {
    final rule = ruleOf(ruleCode);
    if (rule == null) {
      return (costText: '--', balanceText: '$goldBalance 金币');
    }
    final remain = rule.remainTimes ?? 0;
    final price = rule.goldPrice ?? 0;
    if (rule.deductMode == 2 && remain > 0) {
      return (costText: '1次', balanceText: '$remain 次');
    }
    return (costText: '$price金币', balanceText: '$goldBalance 金币');
  }
}

/// AI 任务（提交 / 进度 / 列表 / 作品）。
class AiTaskVo {
  AiTaskVo({
    this.id,
    this.taskNo,
    this.ruleCode,
    this.ruleName,
    this.type,
    this.typeName,
    this.status,
    this.statusName,
    this.refundStatus,
    this.refundStatusName,
    this.progress,
    this.prompt,
    this.negativePrompt,
    this.model,
    this.imageNum,
    this.aspectRatio,
    this.size,
    this.duration,
    this.styles,
    this.inputImages,
    this.resultUrls,
    this.coverUrl,
    this.errorMsg,
    this.userCostGold,
    this.userCostTimes,
    this.userCostDisplay,
    this.downloadCost,
    this.downloadCount,
    this.expireTime,
    this.remainSeconds,
    this.expired,
    this.createTime,
    this.updateTime,
  });

  final int? id;
  final String? taskNo;
  final String? ruleCode;
  final String? ruleName;
  final int? type;
  final String? typeName;
  final String? status;
  final String? statusName;
  final int? refundStatus;
  final String? refundStatusName;
  final int? progress;
  final String? prompt;
  final String? negativePrompt;
  final String? model;
  final int? imageNum;
  final String? aspectRatio;
  final String? size;
  final int? duration;
  final List<String>? styles;
  final List<String>? inputImages;
  final List<String>? resultUrls;
  final String? coverUrl;
  final String? errorMsg;
  final int? userCostGold;
  final int? userCostTimes;
  final String? userCostDisplay;
  final int? downloadCost;
  final int? downloadCount;
  final String? expireTime;
  final int? remainSeconds;
  final bool? expired;
  final String? createTime;
  final String? updateTime;

  bool get isProcessing =>
      status == 'pending' || status == 'processing' || status == 'decoding';

  bool get isFinished => status == 'success' || status == 'failed';

  bool get isSuccess => status == 'success';

  String get displayStatusName {
    if (status == 'failed' && refundStatus == 1) {
      return '生成失败(退款)';
    }
    final backend = statusName?.trim();
    if (backend != null && backend.isNotEmpty) return backend;

    switch (status) {
      case 'pending':
        return '等待中';
      case 'processing':
        return '生成中';
      case 'decoding':
        return '处理中';
      case 'success':
        return '已完成';
      case 'failed':
        return '生成失败';
      default:
        return '等待中';
    }
  }

  String? get displayCover {
    final cover = coverUrl?.trim();
    if (cover != null && cover.isNotEmpty) return cover;

    if (inputImages != null && inputImages!.isNotEmpty) {
      final input = inputImages!.first.trim();
      if (input.isNotEmpty) return input;
    }

    // 视频结果通常是 m3u8，不能直接作为图片封面。
    if (type != 2 &&
        status == 'success' &&
        resultUrls != null &&
        resultUrls!.isNotEmpty) {
      final result = resultUrls!.first.trim();
      if (result.isNotEmpty) return result;
    }
    return null;
  }

  factory AiTaskVo.fromJson(Map<String, dynamic> json) {
    return AiTaskVo(
      id: _aiToInt(json['id']),
      taskNo: json['taskNo']?.toString(),
      ruleCode: json['ruleCode']?.toString(),
      ruleName: json['ruleName']?.toString(),
      type: _aiToInt(json['type']),
      typeName: json['typeName']?.toString(),
      status: json['status']?.toString(),
      statusName: json['statusName']?.toString(),
      refundStatus: _aiToInt(json['refundStatus']),
      refundStatusName: json['refundStatusName']?.toString(),
      progress: _aiToInt(json['progress']),
      prompt: json['prompt']?.toString(),
      negativePrompt: json['negativePrompt']?.toString(),
      model: json['model']?.toString(),
      imageNum: _aiToInt(json['imageNum']),
      aspectRatio: json['aspectRatio']?.toString(),
      size: json['size']?.toString(),
      duration: _aiToInt(json['duration']),
      styles: _aiStringList(json['styles']),
      inputImages: _aiStringList(json['inputImages']),
      resultUrls: _aiStringList(json['resultUrls']),
      coverUrl: json['coverUrl']?.toString(),
      errorMsg: json['errorMsg']?.toString(),
      userCostGold: _aiToInt(json['userCostGold']),
      userCostTimes: _aiToInt(json['userCostTimes']),
      userCostDisplay: json['userCostDisplay']?.toString(),
      downloadCost: _aiToInt(json['downloadCost']),
      downloadCount: _aiToInt(json['downloadCount']),
      expireTime: json['expireTime']?.toString(),
      remainSeconds: _aiToInt(json['remainSeconds']),
      expired: _aiToBool(json['expired']),
      createTime: json['createTime']?.toString(),
      updateTime: json['updateTime']?.toString(),
    );
  }

  static List<AiTaskVo> listFromData(dynamic data) {
    if (data == null || data is! List) return const [];
    final out = <AiTaskVo>[];
    for (final e in data) {
      if (e is Map) {
        out.add(AiTaskVo.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    return out;
  }
}

/// 下载扣费结果。
class AiDownloadVo {
  AiDownloadVo({
    this.taskId,
    this.downloadUrl,
    this.resultUrls,
    this.costGold,
    this.goldBalance,
  });

  final int? taskId;
  final String? downloadUrl;
  final List<String>? resultUrls;
  final int? costGold;
  final int? goldBalance;

  factory AiDownloadVo.fromJson(Map<String, dynamic> json) {
    return AiDownloadVo(
      taskId: _aiToInt(json['taskId']),
      downloadUrl: json['downloadUrl']?.toString(),
      resultUrls: _aiStringList(json['resultUrls']),
      costGold: _aiToInt(json['costGold']),
      goldBalance: _aiToInt(json['goldBalance']),
    );
  }
}

/// 分页列表结果。
class AiPagedList<T> {
  const AiPagedList({this.list = const [], this.total = 0});

  final List<T> list;
  final int total;
}

int? _aiToInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

bool? _aiToBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString().trim().toLowerCase();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return null;
}

List<String>? _aiStringList(dynamic v) {
  if (v == null) return null;
  if (v is List) {
    return v.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return null;
    if (s.startsWith('[')) {
      try {
        final decoded = jsonDecode(s);
        if (decoded is List) {
          return decoded
              .map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } catch (_) {}
    }
    return s
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  return null;
}
