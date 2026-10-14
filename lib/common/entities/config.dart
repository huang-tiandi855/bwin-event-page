import 'dart:convert';

import 'package:comics_app/common/entities/config_query_models.dart';

import 'group_model.dart';

export 'config_query_models.dart';

int? _coerceConfigInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.round();
  return int.tryParse(v.toString());
}

DateTime? _coerceDateTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  final String s = v.toString().trim();
  if (s.isEmpty) return null;
  try {
    return DateTime.parse(s);
  } catch (_) {
    return null;
  }
}

/// 文档「全局配置」：`GET …/config/query?groupKey=…&key=…`，成功时 `result` 为若干 **key → value**（value 多为 JSON 字符串）。
/// `key` 可为多个配置名拼在同一字符串内（如逗号分隔），由后端解析。
///
/// 本类以 `result` 展平后的键值表为唯一数据源；构造时会将 **以 `{` / `[` 开头的 JSON 字符串**
/// 自动解成 [Map] / [List]，其余仍为 [String]。复杂字段请用 [mapOf] / [listOf] 或下方类型化 getter。
class ConfigBean {
  ConfigBean({
    this.groupKey,
    this.queryKey,
    Map<String, dynamic>? entries,
  }) : _entries = _normalizeResultValues(
          Map<String, dynamic>.from(entries ?? const {}),
        );

  /// 请求参数中的分组，目前启动配置只拉取 `App`。
  final String? groupKey;

  /// 请求参数中的配置项 key（可为单个名，或多个名按后端约定分隔拼在同一字符串）。
  final String? queryKey;

  final Map<String, dynamic> _entries;

  static final Object _jsonDecodeFailed = Object();

  /// 原始配置表（**key → 动态值**，多为 `String`）。
  Map<String, dynamic> get entries =>
      Map<String, dynamic>.unmodifiable(_entries);

  /// 从接口业务体解析：支持已是 `result` map，或外层仍包一层 `result`。
  factory ConfigBean.fromJson(Map<String, dynamic> json,
      {String? groupKey, String? queryKey}) {
    return ConfigBean(
      groupKey: groupKey,
      queryKey: queryKey,
      entries: _extractResultEntries(json),
    );
  }

  /// 从 [HttpRequest] / [BaseRespBean.data] 的 `dynamic` 解析（可能为 `Map` 或 JSON 字符串）。
  factory ConfigBean.fromResponse(
    dynamic data, {
    String? groupKey,
    String? queryKey,
  }) {
    if (data is Map<String, dynamic>) {
      return ConfigBean.fromJson(data, groupKey: groupKey, queryKey: queryKey);
    }
    if (data is Map) {
      return ConfigBean.fromJson(
        Map<String, dynamic>.from(data),
        groupKey: groupKey,
        queryKey: queryKey,
      );
    }
    if (data is String) {
      final String s = data.trim();
      if (s.isEmpty) {
        return ConfigBean(
            groupKey: groupKey, queryKey: queryKey, entries: const {});
      }
      try {
        final dynamic decoded = json.decode(s);
        if (decoded is Map) {
          return ConfigBean.fromJson(
            Map<String, dynamic>.from(decoded),
            groupKey: groupKey,
            queryKey: queryKey,
          );
        }
      } catch (_) {}
    }
    return ConfigBean(
        groupKey: groupKey, queryKey: queryKey, entries: const {});
  }

  static Map<String, dynamic> _extractResultEntries(Map<String, dynamic> json) {
    final dynamic nested = json['result'];
    if (nested is Map) {
      return Map<String, dynamic>.from(nested);
    }
    final Map<String, dynamic> copy = Map<String, dynamic>.from(json);
    copy.remove('code');
    copy.remove('message');
    copy.remove('msg');
    copy.remove('tip');
    copy.remove('time');
    copy.remove('hash');
    return copy;
  }

  /// `config/query` 的 `result` 里值**全部是字符串**时，其中 JSON 对象/数组会以 `{` `[` 开头；
  /// 构造 [ConfigBean] 时自动 [json.decode]，便于 [mapOf] / [listOf] 直接使用。
  static Map<String, dynamic> _normalizeResultValues(Map<String, dynamic> raw) {
    final Map<String, dynamic> out = <String, dynamic>{};
    raw.forEach((String k, dynamic v) {
      out[k] = _unwrapJsonStringValue(v);
    });
    return out;
  }

  static dynamic _unwrapJsonStringValue(dynamic v) {
    if (v is String) {
      final String s = v.trim();
      if (s.isNotEmpty && (s.startsWith('{') || s.startsWith('['))) {
        final dynamic decoded = _tryDecodeConfigJson(s);
        if (!identical(decoded, _jsonDecodeFailed)) {
          return decoded;
        }
      }
      return v;
    }
    return v;
  }

  static dynamic _tryDecodeConfigJson(String value) {
    try {
      return json.decode(value);
    } catch (_) {
      final String normalized = _normalizeJsonQuotationMarks(value);
      if (normalized == value) {
        return _jsonDecodeFailed;
      }
      try {
        return json.decode(normalized);
      } catch (_) {
        return _jsonDecodeFailed;
      }
    }
  }

  static String _normalizeJsonQuotationMarks(String value) {
    return value
        .replaceAll('\u201c', '"')
        .replaceAll('\u201d', '"')
        .replaceAll('\u201e', '"')
        .replaceAll('\u201f', '"');
  }

  bool containsKey(String k) => _entries.containsKey(k);

  /// 原始值（不转字符串）。
  dynamic raw(String key) => _entries[key];

  /// 配置值转字符串（`null` 则返回 `null`）。
  /// 若该 key 已被 [_normalizeResultValues] 解成 [Map] / [List]，则返回 [json.encode] 结果。
  String? stringOf(String key) {
    final dynamic v = _entries[key];
    if (v == null) {
      return null;
    }
    if (v is String) {
      return v;
    }
    if (v is Map || v is List) {
      try {
        return json.encode(v);
      } catch (_) {
        return v.toString();
      }
    }
    return v.toString();
  }

  /// 将配置值解析为整数（文档中多为数字或数字字符串）。
  int? intOf(String key) {
    final dynamic v = _entries[key];
    if (v == null) {
      return null;
    }
    if (v is int) {
      return v;
    }
    if (v is num) {
      return v.round();
    }
    return int.tryParse(v.toString());
  }

  /// 将字符串型 JSON 解析为对象；已是 `Map` / `List` 则直接返回。
  dynamic jsonDecodeOf(String key) {
    final dynamic v = _entries[key];
    if (v == null) {
      return null;
    }
    if (v is Map || v is List) {
      return v;
    }
    if (v is String) {
      final String s = v.trim();
      if (s.isEmpty) {
        return null;
      }
      final dynamic decoded = _tryDecodeConfigJson(s);
      return identical(decoded, _jsonDecodeFailed) ? v : decoded;
    }
    return v;
  }

  /// 读取已解包后的 JSON 对象（`result` 里原为 JSON 字符串的字段）。
  Map<String, dynamic>? mapOf(String key) {
    final dynamic v = _entries[key];
    if (v is Map<String, dynamic>) {
      return v;
    }
    if (v is Map) {
      return Map<String, dynamic>.from(v);
    }
    return null;
  }

  /// 读取已解包后的 JSON 数组（`result` 里原为 JSON 字符串的字段）。
  List<dynamic>? listOf(String key) {
    final dynamic v = _entries[key];
    if (v is List) {
      return v;
    }
    return null;
  }

  T? _modelFromKey<T>(
    String key,
    T Function(Map<String, dynamic>) parse,
  ) {
    final dynamic v = _entries[key];
    if (v == null) {
      return null;
    }
    try {
      if (v is Map<String, dynamic>) {
        return parse(v);
      }
      if (v is Map) {
        return parse(Map<String, dynamic>.from(v));
      }
      if (v is String && v.trim().isNotEmpty) {
        final dynamic d = _tryDecodeConfigJson(v.trim());
        if (d is Map) {
          return parse(Map<String, dynamic>.from(d));
        }
      }
    } catch (_) {}
    return null;
  }

  List<T>? _listFromKey<T>(
    String key,
    T Function(Map<String, dynamic>) parseItem,
  ) {
    final dynamic decoded = jsonDecodeOf(key);
    if (decoded is! List) {
      return null;
    }
    final List<T> out = <T>[];
    for (final dynamic e in decoded) {
      if (e is Map<String, dynamic>) {
        try {
          out.add(parseItem(e));
        } catch (_) {}
      } else if (e is Map) {
        try {
          out.add(parseItem(Map<String, dynamic>.from(e)));
        } catch (_) {}
      }
    }
    return out;
  }

  // --- 与历史 UI 兼容：若后端在 `result` 中仍以 JSON 字符串下发整块结构，则仍可解析 ---

  List<Source>? get source {
    final dynamic decoded = jsonDecodeOf('source');
    if (decoded is! List) {
      return null;
    }
    final List<Source> out = <Source>[];
    for (final dynamic e in decoded) {
      if (e is Map) {
        try {
          out.add(Source.fromJson(Map<String, dynamic>.from(e)));
        } catch (_) {}
      }
    }
    return out;
  }

  List<SourceList>? get sourceList {
    final dynamic decoded = jsonDecodeOf('sourceList');
    if (decoded is! List) {
      return null;
    }
    final List<SourceList> out = <SourceList>[];
    for (final dynamic e in decoded) {
      if (e is Map) {
        try {
          out.add(SourceList.fromJson(Map<String, dynamic>.from(e)));
        } catch (_) {}
      }
    }
    return out;
  }

  dynamic get domain => _entries['domain'];

  List<SystemConfigList>? get systemConfigList =>
      _listFromKey('systemConfigList', SystemConfigList.fromJson);

  int? get totalWatch => intOf('totalWatch');

  CheckVersionBean? get lastVersion {
    final dynamic version = jsonDecodeOf('lastVersion');

    if (version is Map) {
      final Map<String, dynamic> m = Map<String, dynamic>.from(version);
      final dynamic need = m['forceUpdate'];
      final bool forced = need == 1 || need == '1';
      final versionName = m['version']?.toString() ?? '';
      final varName = versionName.startsWith('v') ? versionName.substring(1) : versionName;
      return CheckVersionBean.fromMap(<String, dynamic>{
        'verName': varName,
        'url': m['downUrl']?.toString(),
        'description': m['releaseNotes']?.toString(),
        'forcedUpdate': forced,
        'platform': m['platform']?.toString() ?? 'android',
        'size': m['packageSize']?.toString(),
      });
    }
    return null;
  }

  List<int>? get rewardMoney {
    final dynamic decoded = jsonDecodeOf('rewardMoney');
    if (decoded is! List) {
      return null;
    }
    return decoded
        .map((dynamic e) {
          if (e == null) return null;
          if (e is int) return e;
          if (e is num) return e.round();
          return int.tryParse(e.toString());
        })
        .whereType<int>()
        .toList();
  }

  List<int>? get releaseMoney {
    final dynamic decoded = jsonDecodeOf('releaseMoney');
    if (decoded is! List) {
      return null;
    }
    return decoded
        .map((dynamic e) {
          if (e == null) return null;
          if (e is int) return e;
          if (e is num) return e.round();
          return int.tryParse(e.toString());
        })
        .whereType<int>()
        .toList();
  }

  List<UserAwards>? get userAwards =>
      _listFromKey('userAwards', UserAwards.fromJson);

  int? get dfFreetime => intOf('dfFreetime');

  String get louFengH5 => stringOf('louFengH5') ?? '';

  String get dataBuriedPoint => stringOf('dataBuriedPoint') ?? '';

  List<OfficialConfigApp>? get officialConfigApps =>
      _listFromKey('officialConfigApps', OfficialConfigApp.fromJson);

  JingangArea? get jingangArea =>
      _modelFromKey('jingangArea', JingangArea.fromJson);

  int get adsTimeLongVideo => intOf('adsTimeLongVideo') ?? 0;

  int? get aiUndressPrice => intOf('aiUndressPrice');

  int? get aiChangeFaceImgPrice => intOf('aiChangeFaceImgPrice');

  int? get backgroundTheme => intOf('backgroundTheme');

  String? get activityImg => stringOf('activityImg');

  String? get active_2023_url => stringOf('active_2023_url');

  AdvanceStatus? get advanceStatus =>
      _modelFromKey('advanceStatus', AdvanceStatus.fromJson);

  // --- App：字符串类（文案、URL、HTML 模板等，见《接口文档》）---
  /// 客服聊天地址。
  String? get chatUrl => stringOf('chatUrl');

  /// 分享落地地址。
  String? get shareUrl => stringOf('shareUrl');

  /// OTA 版本配置原始串（常与 [ver] getter 联用解析）。
  String? get lastVersionRaw => stringOf('lastVersion');

  /// 视频 CDN/相对路径前缀（旧版）。
  String? get videoBaseUrl => stringOf('videoBaseUrl');

  /// 图片 CDN/相对路径前缀（旧版）。
  String? get picBaseUrl => stringOf('picBaseUrl');

  /// 图片是否加密：`0` 否，`1` 是。
  String? get imageSecret => stringOf('imageSecret');

  /// 支付通道：`alipay` / `bankcard` 等。
  String? get payChannelCode => stringOf('payChannelCode');

  /// 支付等待页提示。
  String? get payWaitHint => stringOf('payWaitHint');

  /// 通用上传接口地址。
  String? get uploadUrl => stringOf('uploadUrl');

  /// 评论/发帖等内容过滤字符集。
  String? get msgFilter => stringOf('msgFilter');

  /// 命中过滤词时的提示。
  String? get msgFilterTip => stringOf('msgFilterTip');

  /// 免费用户充值弹窗文案。
  String? get freeRechargedMsg => stringOf('freeRechargedMsg');

  /// 帖子标题最大字数（配置 key 以服务端为准）。
  String? get maxPositionTitleWordNum => stringOf('maxPositionTitleWordNum');

  /// 帖子正文最大字数。
  String? get maxPostingContentWordNum => stringOf('maxPostingContentWordNum');

  /// 支付完成返回提示。
  String? get payBackTip => stringOf('payBackTip');

  /// 下载相关提示。
  String? get downTip => stringOf('downTip');

  /// 打赏提示。
  String? get rewardTip => stringOf('rewardTip');

  /// 帖子审核中提示。
  String? get postingCheckingTip => stringOf('postingCheckingTip');

  /// 非 VIP 查看 VIP 帖提示。
  String? get seeVipPostingTip => stringOf('seeVipPostingTip');

  /// 非认证用户发金币帖提示。
  String? get addGoldPostingTip => stringOf('addGoldPostingTip');

  /// 非 VIP 发会员帖提示。
  String? get addVipPostingTip => stringOf('addVipPostingTip');

  /// 帖子收益提现规则（HTML，含占位符）。
  String? get withdrawRule => stringOf('withdrawRule');

  /// 视频金币提现规则。
  String? get withdrawVideoRule => stringOf('withdrawVideoRule');

  /// 邀请收益提现规则。
  String? get withdrawInvitaRule => stringOf('withdrawInvitaRule');

  /// 发帖收益最低提现额度。
  String? get minWithdraw => stringOf('minWithdraw');

  /// 视频收益最低提现额度。
  String? get minWithdrawVideo => stringOf('minWithdrawVideo');

  /// 邀请收益最低提现额度。
  String? get minWithdrawInvita => stringOf('minWithdrawInvita');

  /// 普通用户新建楼凤费用（金币）。
  String? get cardGold => stringOf('cardGold');

  /// 官方认证用户新建楼凤费用。
  String? get vipCardGold => stringOf('vipCardGold');

  /// 解锁楼凤收取金币。
  String? get payCardGold => stringOf('payCardGold');

  /// 发送楼凤需求所需金币。
  String? get cardDemandGold => stringOf('cardDemandGold');

  /// 解锁楼凤需求收取金币。
  String? get payCardDemandGold => stringOf('payCardDemandGold');

  /// App 「回家」落地页/官网跳转。
  String? get homePage => stringOf('homePage');

  /// 安卓 A 包 OTA JSON 字符串（versionCode/downUrl/updateInfo/need）。
  String? get lastVersionA => stringOf('lastVersionA');

  /// 多语言包下载基址，文件命名 `language_{lg}_{v}.lg`。
  String? get languageUrl => stringOf('languageUrl');

  /// 弹窗是否引导充值：`0` 否 `1` 是。
  String? get canTipJumpToRecharge => stringOf('canTipJumpToRecharge');

  /// 弹窗是否引导邀请。
  String? get canTipJumpToInvitation => stringOf('canTipJumpToInvitation');

  /// 安卓下载列表跑马灯文案。
  String? get adDownloadTip => stringOf('adDownloadTip');

  /// iOS 下载列表跑马灯。
  String? get iosDownloadTip => stringOf('iosDownloadTip');

  /// 超过免费观影次数提示。
  String? get maxFreeUserPlayTip => stringOf('maxFreeUserPlayTip');

  /// 下载弹窗是否引导充值。
  String? get canDownTipJumpToRecharge => stringOf('canDownTipJumpToRecharge');

  /// 下载弹窗是否引导邀请。
  String? get canDownTipJumpToInvitation =>
      stringOf('canDownTipJumpToInvitation');

  /// 观看 VIP 弹窗是否引导充值。
  String? get canVipTipJumpToRecharge => stringOf('canVipTipJumpToRecharge');

  /// 观看 VIP 弹窗是否引导邀请。
  String? get canVipTipJumpToInvitation =>
      stringOf('canVipTipJumpToInvitation');

  /// 是否展示演员信息：`0` 否 `1` 是。
  String? get show_actor => stringOf('show_actor');

  /// 游分类原始 JSON 数组。
  List<dynamic>? get game_type => listOf('game_type');

  /// 游分类强类型列表（见 [GameTypeConfigItem]）。
  List<GameTypeConfigItem>? get gameTypeItems =>
      _listFromKey('game_type', GameTypeConfigItem.fromJson);

  /// 收藏提示，`{a}` 当前收藏数 `{b}` 剩余额度。
  String? get colTip => stringOf('colTip');

  /// 普通用户收藏上限。
  String? get colLimit => stringOf('colLimit');

  /// VIP 收藏上限。
  String? get colLimit_vip => stringOf('colLimit_vip');

  /// 客户端日志上报域名。
  String? get uploadLogBaseUrl => stringOf('uploadLogBaseUrl');

  /// 充值金币说明文案。
  String? get goldProductTip => stringOf('goldProductTip');

  /// 充值金币标题。
  String? get goldProductTipTitle => stringOf('goldProductTipTitle');

  /// 业务跳转用 API/域名。
  String? get jumpApi => stringOf('jumpApi');

  /// 用户上传 H5 页地址。
  String? get uploadPage => stringOf('uploadPage');

  /// Gold 观影弹窗是否引导充值。
  String? get canGoldTipJumpToRecharge => stringOf('canGoldTipJumpToRecharge');

  /// Gold 观影弹窗是否引导邀请。
  String? get canGoldTipJumpToInvitation =>
      stringOf('canGoldTipJumpToInvitation');

  /// 金币相关弹窗提示。
  String? get goldTip => stringOf('goldTip');

  /// 头像 URL 前缀。
  String? get headImgPrefix => stringOf('headImgPrefix');

  /// MP4 播放/下载域名。
  String? get mp4Domain => stringOf('mp4Domain');

  /// 用户认证/保证金提示。
  String? get authTip => stringOf('authTip');

  /// 金币视频受限时支付按钮文案。
  String? get payGoldBtnMsg => stringOf('payGoldBtnMsg');

  /// 等级差返利最大档。
  String? get maxLevelBack => stringOf('maxLevelBack');

  /// 等级差返利比例 JSON（key 价差 value 百分比）。
  String? get levelBack => stringOf('levelBack');

  /// 代理等级数组 JSON 字符串。
  String? get agentLevel => stringOf('agentLevel');

  /// 新版视频播放基址。
  String? get newVideoBaseUrl => stringOf('newVideoBaseUrl');

  /// 新版图片基址。
  String? get newPicBaseUrl => stringOf('newPicBaseUrl');

  /// 新版视频业务地址。
  String? get newVideoUrl => stringOf('newVideoUrl');

  /// 用户上传视频接口说明（含 uid/fileName 等参数说明，文档）。
  String? get uploadVideoUrl => stringOf('uploadVideoUrl');

  /// 用户上传金币视频最低价。
  String? get userUploadGoldMin => stringOf('userUploadGoldMin');

  /// 用户上传金币视频最高价。
  String? get userUploadGoldMax => stringOf('userUploadGoldMax');

  /// 上传免费视频提示。
  String? get userUploadFreeVodTip => stringOf('userUploadFreeVodTip');

  /// 上传 VIP 视频提示。
  String? get userUploadFreeVipTip => stringOf('userUploadFreeVipTip');

  /// 上传金币视频提示。
  String? get userUploadFreeGoldTip => stringOf('userUploadFreeGoldTip');

  /// 上传金币视频未官方授权提示。
  String? get userUploadGoldAuthTip => stringOf('userUploadGoldAuthTip');

  /// 上传须知（支持 `\n` 换行）。
  String? get userUploadRule => stringOf('userUploadRule');

  /// 新 H5 图片是否加密。
  String? get newH5ImageSecret => stringOf('newH5ImageSecret');

  /// 聊天模块上传地址。
  String? get chatUploadUrl => stringOf('chatUploadUrl');

  /// 官网地址。
  String? get officialUrl => stringOf('officialUrl');

  /// 联调用测试 JWT。
  String? get testJWTToken => stringOf('testJWTToken');

  /// PC 端播放页地址。
  String? get pcPlayUrl => stringOf('pcPlayUrl');

  /// H5 回家地址，逗号分隔多地址。
  String? get h5HomePage => stringOf('h5HomePage');

  /// iOS 升级信息 Map（原始）。
  Map<String, dynamic>? get iosLastVersion => mapOf('iosLastVersion');

  /// iOS 升级信息（强类型，见 [IosStoreVersionConfig]）。
  IosStoreVersionConfig? get iosLastVersionConfig =>
      _modelFromKey('iosLastVersion', IosStoreVersionConfig.fromJson);

  /// 每日免费用户可播放次数配置。
  String? get todayFreeUserPlay => stringOf('todayFreeUserPlay');

  /// 轮询线路 JSON 字符串（与 [playLinePollList] 同数据源）。
  String? get playLinePoll => stringOf('playLinePoll');

  /// 聊天多媒体资源 URL 前缀。
  String? get chatUrlPrefix => stringOf('chatUrlPrefix');

  /// 举报理由 Map（原始，按业务分 key）。
  Map<String, dynamic>? get reportReason => mapOf('reportReason');

  /// 举报理由（强类型，见 [ReportReasonConfig]）。
  ReportReasonConfig? get reportReasonConfig =>
      _modelFromKey('reportReason', ReportReasonConfig.fromJson);

  /// 签到规则说明。
  String? get signInRule => stringOf('signInRule');

  /// 签到奖励 JSON 字符串。
  String? get signInReward => stringOf('signInReward');

  /// 连续签到奖励档位列表。
  List<SignInRewardItem>? get signInRewardItems =>
      _listFromKey('signInReward', SignInRewardItem.fromJson);

  /// 发布视频前提示文案。
  String? get beforeUplodTip => stringOf('beforeUplodTip');

  /// 首页推荐是否展示「探索」视频。
  String? get openRecommendExplore => stringOf('openRecommendExplore');

  /// 约啪：解锁帖子成功文案。
  String? get card_paySuccessTip => stringOf('card_paySuccessTip');

  /// 约啪：未解锁帖子文案。
  String? get card_unPayTip => stringOf('card_unPayTip');

  /// 约啪：认证提示。
  String? get card_authTip => stringOf('card_authTip');

  /// 约啪：主页未解锁文案。
  String? get card_home_unPayTip => stringOf('card_home_unPayTip');

  /// 约啪：上传接口地址。
  String? get card_uploadUrl => stringOf('card_uploadUrl');

  /// 帖子热门搜索 JSON 数组原始串。
  String? get POSTING_HOT => stringOf('POSTING_HOT');

  /// 帖子热门搜索关键词列表。
  List<String>? get postingHotKeywords {
    final List<dynamic>? r = listOf('POSTING_HOT');
    if (r == null) return null;
    return r.map((dynamic e) => e.toString()).toList();
  }

  /// 用户上传免费帖子提示。
  String? get userUploadPostingFreeTip => stringOf('userUploadPostingFreeTip');

  /// 用户上传 VIP 帖子提示。
  String? get userUploadPostingVipTip => stringOf('userUploadPostingVipTip');

  /// 用户上传金币帖子提示。
  String? get userUploadPostingGoldTip => stringOf('userUploadPostingGoldTip');

  /// 发金币帖条件不足提示。
  String? get addGoldPostingLimitTip => stringOf('addGoldPostingLimitTip');

  /// 帖子添加链接说明 JSON 串。
  String? get postingLinkedTip => stringOf('postingLinkedTip');

  /// 预览时长分档 JSON 串。
  String? get cms_preview => stringOf('cms_preview');

  /// 预览时长分档（强类型）。
  List<CmsPreviewRangeItem>? get cmsPreviewItems =>
      _listFromKey('cms_preview', CmsPreviewRangeItem.fromJson);

  /// 帖子回答提示。
  String? get postingAnswerTip => stringOf('postingAnswerTip');

  /// 用户上传自定义推荐文案提示。
  String? get cmsURTip => stringOf('cmsURTip');

  /// 精选「最新」广告位加载区间。
  String? get ads_cc_range => stringOf('ads_cc_range');

  /// 猜你喜欢广告加载区间。
  String? get ads_guess_like => stringOf('ads_guess_like');

  /// 收藏/下载相关地址。
  String? get collection => stringOf('collection');

  /// 收藏下载提示（含 `%s` 占位符）。
  String? get collectionTip => stringOf('collectionTip');

  /// 直播入口链接。
  String? get liveLinked => stringOf('liveLinked');

  /// 游/平台公告文案。
  String? get gameTip => stringOf('gameTip');

  /// 探索流广告加载区间。
  String? get cms_explore_ar => stringOf('cms_explore_ar');

  /// 发金币帖提示。
  String? get postingGoldTip => stringOf('postingGoldTip');

  /// 发求片帖提示。
  String? get postingRequestTip => stringOf('postingRequestTip');

  /// 提现额度档位原始列表。
  List<dynamic>? get withdrawAmounts => listOf('withdrawAmounts');

  /// 提现额度档位（强类型）。
  List<WithdrawAmountItem>? get withdrawAmountItems =>
      _listFromKey('withdrawAmounts', WithdrawAmountItem.fromJson);

  /// 提现额度说明。
  String? get withdrawAmountTip => stringOf('withdrawAmountTip');

  /// 提现额度规则。
  String? get withdrawAmountRule => stringOf('withdrawAmountRule');

  /// 是否开启验证码：`1` 开 `0` 关。
  String? get OpenCheckCode => stringOf('OpenCheckCode');

  /// 是否开启游模块：`1` 开 `0` 关。
  String? get OpenGame2 => stringOf('OpenGame2');

  /// 支持提现类型 JSON 串（见 [withdrawalSupportTypeModel]）。
  String? get withdrawalSupportType => stringOf('withdrawalSupportType');

  /// 各提现类型下可选支付方式（银行卡/USDT/支付宝）。
  WithdrawalSupportTypeConfig? get withdrawalSupportTypeModel => _modelFromKey(
      'withdrawalSupportType', WithdrawalSupportTypeConfig.fromJson);

  /// 提现银行列表原始数据。
  List<dynamic>? get banks => listOf('banks');

  /// 提现银行列表（强类型）。
  List<BankConfigItem>? get bankItems =>
      _listFromKey('banks', BankConfigItem.fromJson);

  /// 游广播文案。
  String? get gameBroadcast => stringOf('gameBroadcast');

  /// 游提现稽核提示。
  String? get gameBillCheckTip => stringOf('gameBillCheckTip');

  /// 游余额不足不可提现提示。
  String? get gameUnwithdrawTip => stringOf('gameUnwithdrawTip');

  // --- App：数值类配置（文档多为整数，接口可能以字符串下发）---
  /// 评论最大字数。
  int? get commentLimit => intOf('commentLimit');

  /// 帖子最大字数。
  int? get postingLimit => intOf('postingLimit');

  /// 单图最大体积（MB，以文档为准）。
  int? get maxImgSize => intOf('maxImgSize');

  /// 单视频最大体积（MB）。
  int? get maxVideoSize => intOf('maxVideoSize');

  /// 赠送会员每日最大下载次数。
  int? get freeVipMaxDown => intOf('freeVipMaxDown');

  /// 单次最多上传图片张数。
  int? get maxImgNum => intOf('maxImgNum');

  /// 普通用户每日免费播放部数。
  int? get maxFreeUserPlay => intOf('maxFreeUserPlay');

  // --- App：已 unwrap 的 JSON（多语言/游配置/线路）---
  /// 多语言列表（原始 [List]）。
  List<dynamic>? get language => listOf('language');

  /// 多语言列表（强类型 [AppLanguageItem]）。
  List<AppLanguageItem>? get languageItems =>
      _listFromKey('language', AppLanguageItem.fromJson);

  /// 游配置（原始 Map）。
  Map<String, dynamic>? get gameConfig => mapOf('gameConfig');

  /// 游配置（强类型 [GameConfigApp]）。
  GameConfigApp? get gameConfigApp =>
      _modelFromKey('gameConfig', GameConfigApp.fromJson);

  /// PC 播放线路（原始）。
  List<dynamic>? get pc_play_line => listOf('pc_play_line');

  /// H5 播放线路（原始）。
  List<dynamic>? get h5_play_line => listOf('h5_play_line');

  /// qv1 播放线路（原始）。
  List<dynamic>? get playLines => listOf('playLines');

  /// 封面图/CDN 线路（原始 JSON 数组，接口字段 `pictureUrls`）。
  List<dynamic>? get pictureUrls => listOf('pictureUrls');

  /// PC 播放线路（强类型 [PlayLineConfig]）。
  List<PlayLineConfig>? get pcPlayLineList =>
      _listFromKey('pc_play_line', PlayLineConfig.fromJson);

  /// H5 播放线路（强类型）。
  List<PlayLineConfig>? get h5PlayLineList =>
      _listFromKey('h5_play_line', PlayLineConfig.fromJson);

  /// qv1 播放线路（强类型）。
  List<PlayLineConfig>? get playLinesList =>
      _listFromKey('playLines', PlayLineConfig.fromJson);

  /// 封面图/CDN 线路（强类型，与 [playLinesList] 同为 `name` + `line`）。
  List<PlayLineConfig>? get pictureUrlsList =>
      _listFromKey('pictureUrls', PlayLineConfig.fromJson);

  /// 轮询用线路列表（强类型，同 `playLinePoll`）。
  List<PlayLineConfig>? get playLinePollList =>
      _listFromKey('playLinePoll', PlayLineConfig.fromJson);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(_entries);

  ///官方社群
  List<GroupModel>? get officialCommunity =>
      _listFromKey('officialCommunity', GroupModel.fromJson);

  ///商务合作
  List<GroupModel>? get businessCooperation =>
      _listFromKey('businessCooperation', GroupModel.fromJson);

  ///聊天域名
  String? get chatDomain => stringOf('chatDomain');
}

/// 单条广告数据模型
///
/// 与后端 `/ads/fetch/batch` 接口返回的单个广告 item 结构对齐。
class AdsInfoList {
  String? id;
  String? planId;
  int? advertiserId;

  /// 广告资源地址（图片/视频路径）
  String? resourceUrl;

  /// 资源类型，1=图片 等
  int? resourceType;

  String? title;
  String? description;

  /// 广告点击外链
  String? externalLink;

  /// 点击动作类型
  int? actionType;

  /// 状态
  int? status;

  /// 是否需要用户登录态
  int? needUserToken;

  /// 是否全屏展示
  int? fullScreen;

  /// 结束时间
  String? endTime;

  AdsInfoList({
    this.id,
    this.planId,
    this.advertiserId,
    this.resourceUrl,
    this.resourceType,
    this.title,
    this.description,
    this.externalLink,
    this.actionType,
    this.status,
    this.needUserToken,
    this.fullScreen,
    this.endTime,
  });

  AdsInfoList.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    planId = json['planId']?.toString();
    advertiserId = _asInt(json['advertiserId']);
    resourceUrl = json['resourceUrl']?.toString();
    resourceType = _asInt(json['resourceType']);
    title = json['title']?.toString();
    description = json['description']?.toString();
    externalLink = json['externalLink']?.toString();
    actionType = _asInt(json['actionType']);
    status = _asInt(json['status']);
    needUserToken = _asInt(json['needUserToken']);
    fullScreen = _asInt(json['fullScreen']);
    endTime = json['endTime']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['planId'] = planId;
    data['advertiserId'] = advertiserId;
    data['resourceUrl'] = resourceUrl;
    data['resourceType'] = resourceType;
    data['title'] = title;
    data['description'] = description;
    data['externalLink'] = externalLink;
    data['actionType'] = actionType;
    data['status'] = status;
    data['needUserToken'] = needUserToken;
    data['fullScreen'] = fullScreen;
    data['endTime'] = endTime;
    return data;
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  @override
  String toString() {
    return 'AdsInfoList{id: $id, planId: $planId, advertiserId: $advertiserId, '
        'resourceUrl: $resourceUrl, resourceType: $resourceType, '
        'title: $title, description: $description, '
        'externalLink: $externalLink, actionType: $actionType, '
        'status: $status, needUserToken: $needUserToken, '
        'fullScreen: $fullScreen, endTime: $endTime}';
  }
}

class Source {
  String? id;
  String? domain;
  bool? isActive;
  String? type;

  Source({this.id, this.domain, this.isActive, this.type});

  Source.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    domain = json['domain'];
    isActive = json['isActive'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['domain'] = domain;
    data['isActive'] = isActive;
    data['type'] = type;
    return data;
  }
}

class SourceList {
  String? id;
  List<Domain>? domain;
  bool? isActive;
  String? type;

  SourceList({this.id, this.domain, this.isActive, this.type});

  SourceList.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    domain = _parseDomainList(json['domain']);
    isActive = json['isActive'] as bool?;
    type = json['type']?.toString();
  }

  static List<Domain>? _parseDomainList(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) {
      final String s = raw.trim();
      if (s.isEmpty) return null;
      try {
        final dynamic d = json.decode(s);
        return _parseDomainList(d);
      } catch (_) {
        return null;
      }
    }
    if (raw is! List) return null;
    final List<Domain> out = <Domain>[];
    for (final dynamic v in raw) {
      if (v is Map) {
        try {
          out.add(Domain.fromJson(Map<String, dynamic>.from(v)));
        } catch (_) {}
      }
    }
    return out.isEmpty ? null : out;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (domain != null) {
      data['domain'] = domain!.map((v) => v.toJson()).toList();
    }
    data['isActive'] = isActive;
    data['type'] = type;
    return data;
  }
}

class Domain {
  int? weight;
  String? url;
  int? status;
  String? desc;

  Domain({this.weight, this.url, this.status, this.desc});

  Domain.fromJson(Map<String, dynamic> json) {
    weight = json['weight'];
    url = json['url'];
    status = json['status'];
    desc = json['desc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['weight'] = weight;
    data['url'] = url;
    data['status'] = status;
    data['desc'] = desc;
    return data;
  }
}

class SystemConfigList {
  String? id;
  int? type;
  int? location;
  String? content;
  bool? isActive;
  String? createdAt;
  String? updatedAt;

  SystemConfigList(
      {this.id,
      this.type,
      this.location,
      this.content,
      this.isActive,
      this.createdAt,
      this.updatedAt});

  SystemConfigList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    location = json['location'];
    content = json['content'];
    isActive = json['isActive'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['location'] = location;
    data['content'] = content;
    data['isActive'] = isActive;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class UserAwards {
  int? number;
  String? desc;
  String? imgUrl;

  UserAwards({this.number, this.desc, this.imgUrl});

  UserAwards.fromJson(Map<String, dynamic> json) {
    number = json['number'];
    desc = json['desc'];
    imgUrl = json['imgUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['number'] = number;
    data['desc'] = desc;
    data['imgUrl'] = imgUrl;
    return data;
  }
}

class CheckVersionBean {
  String? description;
  bool? forcedUpdate;
  String? platform;
  String? url;
  String? verName;
  int? code;

  /// 安装包大小（后端可能下发 `size` 或 `packageSize`，已格式化的字符串如
  /// `"68.90MB"`，也可能是字节数字符串）；为空时升级弹窗会隐藏该字段。
  String? size;

  static CheckVersionBean fromMap(Map<String, dynamic> map) {
    CheckVersionBean checkVersionBean = CheckVersionBean();
    checkVersionBean.description = map['description'];
    checkVersionBean.forcedUpdate = map['forcedUpdate'];
    checkVersionBean.platform = map['platform'];
    checkVersionBean.url = map['url'];
    checkVersionBean.verName = map['verName'];
    checkVersionBean.code = map['Code'];
    final dynamic rawSize = map['size'] ?? map['packageSize'];
    checkVersionBean.size = rawSize == null ? null : rawSize.toString();
    return checkVersionBean;
  }

  static List<CheckVersionBean> toList(List<dynamic> mapList) {
    final List<CheckVersionBean> list = <CheckVersionBean>[];
    for (final dynamic e in mapList) {
      if (e is Map) {
        try {
          list.add(fromMap(Map<String, dynamic>.from(e)));
        } catch (_) {}
      }
    }
    return list;
  }

  Map toJson() => {
        "description": description,
        "forcedUpdate": forcedUpdate,
        "platform": platform,
        "url": url,
        "verName": verName,
        "Code": code,
        "size": size,
      };
}

/// 将 [IosStoreVersionConfig] 转为现有升级弹窗使用的 [CheckVersionBean]（iOS 平台）。
extension IosStoreVersionConfigCompat on IosStoreVersionConfig {
  CheckVersionBean toCheckVersionBean() {
    final bool forced = need == 1 || need?.toString() == '1';
    return CheckVersionBean.fromMap(<String, dynamic>{
      'verName': versionCode,
      'url': downUrl,
      'description': updateInfo,
      'forcedUpdate': forced,
      'platform': 'ios',
    });
  }
}

class OfficialConfigApp {
  OfficialConfigApp({
    this.officialName,
    this.officialDesc,
    this.officialImg,
    this.officialUrl,
    this.officialType,
    this.sortNum,
  });

  String? officialName;
  String? officialDesc;
  String? officialImg;
  String? officialUrl;
  String? officialType;
  int? sortNum;

  factory OfficialConfigApp.fromJson(Map<String, dynamic> json) =>
      OfficialConfigApp(
        officialName: json["officialName"]?.toString(),
        officialDesc: json["officialDesc"]?.toString(),
        officialImg: json["officialImg"]?.toString(),
        officialUrl: json["officialUrl"]?.toString(),
        officialType: json["officialType"]?.toString(),
        sortNum: _coerceConfigInt(json["sortNum"]),
      );

  Map<String, dynamic> toJson() => {
        "officialName": officialName,
        "officialDesc": officialDesc,
        "officialImg": officialImg,
        "officialUrl": officialUrl,
        "officialType": officialType,
        "sortNum": sortNum,
      };
}

JingangArea jingangAreaFromJson(String str) =>
    JingangArea.fromJson(json.decode(str));

String jingangAreaToJson(JingangArea data) => json.encode(data.toJson());

class JingangArea {
  JingangArea({
    this.list,
  });

  List<ListElementTemp>? list;

  factory JingangArea.fromJson(Map<String, dynamic> json) {
    final dynamic raw = json["list"];
    if (raw is! List) {
      return JingangArea(list: null);
    }
    final List<ListElementTemp> items = <ListElementTemp>[];
    for (final dynamic x in raw) {
      if (x is Map) {
        try {
          items.add(ListElementTemp.fromJson(Map<String, dynamic>.from(x)));
        } catch (_) {}
      }
    }
    return JingangArea(list: items.isEmpty ? null : items);
  }

  Map<String, dynamic> toJson() => {
        "list": List<dynamic>.from(
            (list ?? <ListElementTemp>[]).map((x) => x.toJson())),
      };
  List<ListElementTemp>? get acgList =>
      list?.where((element) => element.type == 1).toList();
}

class ListElementTemp {
  ListElementTemp(
      {this.id,
      this.name,
      this.img,
      this.desc,
      this.linkType,
      this.linkUrl,
      this.sort,
      this.type,
      this.status,
      this.createdAt,
      this.updatedAt});

  String? id;
  String? name;
  String? img;
  String? desc;
  int? linkType;
  String? linkUrl;
  int? sort;
  int? type;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory ListElementTemp.fromJson(Map<String, dynamic> json) =>
      ListElementTemp(
        id: json["id"]?.toString(),
        name: json["name"]?.toString(),
        img: json["img"]?.toString(),
        desc: json["desc"]?.toString(),
        linkType: _coerceConfigInt(json["link_type"] ?? json["linkType"]),
        linkUrl: json["link_url"]?.toString() ?? json["linkUrl"]?.toString(),
        sort: _coerceConfigInt(json["sort"]),
        status: _coerceConfigInt(json["status"]),
        type: _coerceConfigInt(json['type']),
        createdAt: _coerceDateTime(json["createdAt"]),
        updatedAt: _coerceDateTime(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "img": img,
        "desc": desc,
        "link_type": linkType,
        "link_url": linkUrl,
        "sort": sort,
        "type": type,
        "status": status,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class AdvanceStatus {
  bool? activityStatus;
  bool? balancePayment;
  int? balanceAmount;
  int? advanceAmount;
  int? status;
  String? startTime;
  String? endTime;

  AdvanceStatus(
      {this.activityStatus,
      this.balancePayment,
      this.balanceAmount,
      this.status,
      this.startTime,
      this.endTime,
      this.advanceAmount});

  factory AdvanceStatus.fromJson(Map<String, dynamic> json) => AdvanceStatus(
        activityStatus: json["activityStatus"],
        balancePayment: json["balancePayment"],
        balanceAmount: json["balanceAmount"],
        advanceAmount: json["advanceAmount"],
        status: json["status"],
        startTime: json["startTime"],
        endTime: json["endTime"],
      );

  Map<String, dynamic> toJson() => {
        "activityStatus": activityStatus,
        "balancePayment": balancePayment,
        "balanceAmount": balanceAmount,
        "advanceAmount": advanceAmount,
        "status": status,
        "startTime": startTime,
        "endTime": endTime,
      };
}
