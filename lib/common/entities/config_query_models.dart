/// 全局配置接口 `config/query` 返回的 **result** 中，JSON 对象/数组对应的强类型模型。
///
/// 字段含义以项目《接口文档》「常用配置」表为准；服务端通常以 **JSON 字符串** 下发，
/// [ConfigBean] 构造时会自动解包为 [Map]/[List] 后再映射到本文件中的类型。

/// 将动态值安全转为 [int]（用于文档中可能是数字或数字字符串的字段）。
int? _cfgInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.round();
  return int.tryParse(v.toString());
}

// --- APP.language：多语言种类 ---

/// 多语言条目（接口文档 APP.language）。
///
/// 用于展示可选语言及下载 `language_{lg}_{v}.lg` 等逻辑。
class AppLanguageItem {
  AppLanguageItem({
    this.name,
    this.lg,
    this.tl,
    this.v,
    this.d,
  });

  /// 显示给用户的语言名称（如「中文」）。
  final String? name;

  /// language：内部语言标识（如 `chinese`）。
  final String? lg;

  /// translate：翻译/BCP47 类语言码（如 `zh-CN`）。
  final String? tl;

  /// 该语言配置的版本号，用于与 [languageUrl] 下载文件版本对齐。
  final int? v;

  /// 是否默认语言：`0` 否，`1` 是。
  final int? d;

  factory AppLanguageItem.fromJson(Map<String, dynamic> json) {
    return AppLanguageItem(
      name: json['name']?.toString(),
      lg: json['lg']?.toString(),
      tl: json['tl']?.toString(),
      v: _cfgInt(json['v']),
      d: _cfgInt(json['d']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'lg': lg,
        'tl': tl,
        'v': v,
        'd': d,
      };
}

// --- APP.gameConfig：游（游戏）SDK/ H5 接入参数 ---

/// 游配置（接口文档 APP.gameConfig）。
///
/// 对接游模块的 baseUri、渠道号、token 等，字段名在接口中为短键 `b`/`c`/`t`。
class GameConfigApp {
  GameConfigApp({this.baseUri, this.channelId, this.token});

  /// 接口字段 `b`：游资源/接口 **baseUri**。
  final String? baseUri;

  /// 接口字段 `c`：**channelId** 渠道 ID。
  final String? channelId;

  /// 接口字段 `t`：鉴权用 **token**。
  final String? token;

  factory GameConfigApp.fromJson(Map<String, dynamic> json) {
    return GameConfigApp(
      baseUri: json['b']?.toString(),
      channelId: json['c']?.toString(),
      token: json['t']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'b': baseUri,
        'c': channelId,
        't': token,
      };
}

// --- 播放线路：pc_play_line / h5_play_line / playLines / playLinePoll ---

/// 单条播放线路（名称 + 播放域名/地址）。
///
/// 用于 PC/H5/qv1 等多端线路切换与展示；`APP.pictureUrls` 封面/CDN 线路亦为同结构。
class PlayLineConfig {
  PlayLineConfig({this.name, this.line});

  /// 线路展示名（如「国内线路」「快线1」）。
  final String? name;

  /// 该线路对应的播放或网关 **URL**。
  final String? line;

  factory PlayLineConfig.fromJson(Map<String, dynamic> json) {
    return PlayLineConfig(
      name: json['name']?.toString(),
      line: json['line']?.toString(),
    );
  }

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'name': name, 'line': line};
}

// --- APP.iosLastVersion：iOS 包升级 ---

/// iOS App Store / 企业包 **OTA 升级**配置（接口文档 APP.iosLastVersion）。
///
/// 与安卓 [lastVersionA] 语义类似，用于弹窗提示与跳转下载。
class IosStoreVersionConfig {
  IosStoreVersionConfig({
    this.versionCode,
    this.downUrl,
    this.updateInfo,
    this.tftime,
    this.need,
  });

  /// 新版本号（展示与比对）。
  final String? versionCode;

  /// 安装包 **下载地址**。
  final String? downUrl;

  /// 更新说明文案。
  final String? updateInfo;

  /// TestFlight 等场景的 **到期时间**说明（文档字段 `tftime`）。
  final String? tftime;

  /// 是否 **强更**：`0` 否，`1` 是。
  final int? need;

  factory IosStoreVersionConfig.fromJson(Map<String, dynamic> json) {
    return IosStoreVersionConfig(
      versionCode: json['versionCode']?.toString(),
      downUrl: json['downUrl']?.toString(),
      updateInfo: json['updateInfo']?.toString(),
      tftime: json['tftime']?.toString(),
      need: _cfgInt(json['need']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'versionCode': versionCode,
        'downUrl': downUrl,
        'updateInfo': updateInfo,
        'tftime': tftime,
        'need': need,
      };
}

// --- APP.reportReason：举报理由 ---

/// 举报时可选项文案（接口文档 APP.reportReason）。
///
/// 按业务类型分桶：如作者、聊天、视频、帖子等；与举报接口 `type` 联动。
class ReportReasonConfig {
  ReportReasonConfig({required this.byCategory});

  /// 业务分类 key → 该分类下可选理由文案列表（接口为动态 key，不限于下方 getter）。
  final Map<String, List<String>> byCategory;

  factory ReportReasonConfig.fromJson(Map<String, dynamic> json) {
    final Map<String, List<String>> out = <String, List<String>>{};
    json.forEach((String k, dynamic v) {
      if (v is List) {
        out[k] = v.map((dynamic e) => e.toString()).toList();
      }
    });
    return ReportReasonConfig(byCategory: out);
  }

  /// 指定分类下的理由列表（如 `author`、`video`）。
  List<String>? reasonsFor(String category) => byCategory[category];

  /// 举报 **作者/用户** 类理由。
  List<String>? get author => byCategory['author'];

  /// 举报 **聊天** 类理由。
  List<String>? get chat => byCategory['chat'];

  /// 举报 **视频** 类理由。
  List<String>? get video => byCategory['video'];

  /// 举报 **帖子** 类理由。
  List<String>? get posting => byCategory['posting'];
}

// --- APP.withdrawAmounts：提现额度 ---

/// 单笔提现额度档位（接口文档 APP.withdrawAmounts，具体字段以服务端为准）。
///
/// [raw] 保留完整 JSON，便于扩展；[amount]/[label] 为常见字段的兼容读取。
class WithdrawAmountItem {
  WithdrawAmountItem(this.raw);

  /// 服务端返回的原始键值，便于读取未建模字段。
  final Map<String, dynamic> raw;

  factory WithdrawAmountItem.fromJson(Map<String, dynamic> json) {
    return WithdrawAmountItem(Map<String, dynamic>.from(json));
  }

  /// 额度数值（尝试 `amount` / `value` / `v`）。
  num? get amount =>
      raw['amount'] as num? ??
      raw['value'] as num? ??
      raw['v'] as num? ??
      num.tryParse(raw['amount']?.toString() ?? raw['value']?.toString() ?? '');

  /// 展示文案（尝试 `label` / `name` / `desc`）。
  String? get label =>
      raw['label']?.toString() ??
      raw['name']?.toString() ??
      raw['desc']?.toString();

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}

// --- APP.banks：银行列表 ---

/// 提现可选银行（接口文档 APP.banks）。
class BankConfigItem {
  BankConfigItem({this.bank, this.icon});

  /// 银行名称。
  final String? bank;

  /// 银行图标资源路径或 URL。
  final String? icon;

  factory BankConfigItem.fromJson(Map<String, dynamic> json) {
    return BankConfigItem(
      bank: json['bank']?.toString(),
      icon: json['icon']?.toString(),
    );
  }

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'bank': bank, 'icon': icon};
}

// --- APP.game_type：游分类 ---

/// 游（游戏）**分类/ Tab** 一项（接口文档 APP.game_type）。
///
/// 用于底部分类、列表 id 与选中/未选中图标等。
class GameTypeConfigItem {
  GameTypeConfigItem({
    this.id,
    this.type,
    this.pid,
    this.platformId,
    this.name,
    this.active,
    this.idle,
  });

  /// 分类 id。
  final String? id;

  /// 分类类型。
  final String? type;

  /// 父级/关联列表 id（文档 `pid`：游列表 id）。
  final String? pid;

  /// 平台侧 id（文档 `platform_id`）。
  final String? platformId;

  /// 分类展示名称。
  final String? name;

  /// **选中**态图片 URL。
  final String? active;

  /// **未选中**态图片 URL。
  final String? idle;

  factory GameTypeConfigItem.fromJson(Map<String, dynamic> json) {
    return GameTypeConfigItem(
      id: json['id']?.toString(),
      type: json['type']?.toString(),
      pid: json['pid']?.toString(),
      platformId: json['platform_id']?.toString(),
      name: json['name']?.toString(),
      active: json['active']?.toString(),
      idle: json['idle']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'type': type,
        'pid': pid,
        'platform_id': platformId,
        'name': name,
        'active': active,
        'idle': idle,
      };
}

// --- CHAT：rechargeMsg / linkedMsg / chatMsg ---

/// 客服文案条目（接口文档 CHAT.rechargeMsg / linkedMsg / chatMsg）。
///
/// 每项通常为 `{"val":"..."}`，用于展示充值说明、链接说明等。
class ChatValItem {
  ChatValItem({this.val});

  /// 展示用文案内容。
  final String? val;

  factory ChatValItem.fromJson(Map<String, dynamic> json) {
    return ChatValItem(val: json['val']?.toString());
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'val': val};
}

// --- CHAT：rechargeImg ---

/// 充值收款码（接口文档 CHAT.rechargeImg）。
///
/// [name] 为渠道说明，[val] 一般为相对路径，需与资源域名拼接。
class ChatRechargeImageItem {
  ChatRechargeImageItem({this.name, this.val});

  /// 收款方式名称（如「微信01」）。
  final String? name;

  /// 图片相对路径或完整 URL。
  final String? val;

  factory ChatRechargeImageItem.fromJson(Map<String, dynamic> json) {
    return ChatRechargeImageItem(
      name: json['name']?.toString(),
      val: json['val']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'name': name, 'val': val};
}

// --- APP.signInReward：签到奖励 ---

/// 连续签到奖励档位（接口文档 APP.signInReward）。
class SignInRewardItem {
  SignInRewardItem({this.day, this.viph});

  /// 连续签到 **天数** 门槛。
  final String? day;

  /// 达成后奖励 **VIP 小时数**（文档字段 `viph`）。
  final String? viph;

  factory SignInRewardItem.fromJson(Map<String, dynamic> json) {
    return SignInRewardItem(
      day: json['day']?.toString(),
      viph: json['viph']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'day': day, 'viph': viph};
}

// --- APP.cms_preview：预览时长分档 ---

/// 视频预览时长规则中的一档（接口文档 APP.cms_preview）。
///
/// 表示视频时长落在 \[min, max\] 区间时，允许预览 preview 秒。
class CmsPreviewRangeItem {
  CmsPreviewRangeItem({this.min, this.max, this.preview});

  /// 区间下限（秒）。
  final int? min;

  /// 区间上限（秒）。
  final int? max;

  /// 该档允许的 **预览时长**（秒）。
  final int? preview;

  factory CmsPreviewRangeItem.fromJson(Map<String, dynamic> json) {
    return CmsPreviewRangeItem(
      min: _cfgInt(json['min']),
      max: _cfgInt(json['max']),
      preview: _cfgInt(json['preview']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'min': min,
        'max': max,
        'preview': preview,
      };
}

// --- APP.withdrawalSupportType ---

/// 各提现类型下 **允许的提现方式**（接口文档 APP.withdrawalSupportType）。
///
/// - Map 的 **key**：提现类型字符串，`0` 常表示 APP 收益，`1` 常表示余额等（以文档为准）。
/// - Map 的 **value**：方式列表，`1` 银行卡、`2` USDT、`3` 支付宝。
class WithdrawalSupportTypeConfig {
  WithdrawalSupportTypeConfig({required this.channelsByWithdrawType});

  /// key：提现类型；value：该类型下可选的支付方式编码列表。
  final Map<String, List<int>> channelsByWithdrawType;

  factory WithdrawalSupportTypeConfig.fromJson(Map<String, dynamic> json) {
    final Map<String, List<int>> out = <String, List<int>>{};
    json.forEach((String k, dynamic v) {
      if (v is List) {
        out[k] = v
            .map((dynamic e) {
              if (e is int) return e;
              return int.tryParse(e.toString());
            })
            .whereType<int>()
            .toList();
      }
    });
    return WithdrawalSupportTypeConfig(channelsByWithdrawType: out);
  }
}
