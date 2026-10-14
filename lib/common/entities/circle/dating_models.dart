import 'package:comics_app/common/entities/circle/post_card_data.dart';

/// 约会分类：`0` 楼凤 / `1` 外围。
enum DatingCardType {
  loufeng(0),
  waiwei(1);

  const DatingCardType(this.value);
  final int value;

  static DatingCardType? fromValue(int? v) {
    if (v == null) return null;
    for (final t in DatingCardType.values) {
      if (t.value == v) return t;
    }
    return null;
  }
}

/// 列表排序（`POST /card/list` 的 `sortType`）。
enum DatingSortType {
  latest(0),
  weekHot(1),
  monthHot(2);

  const DatingSortType(this.value);
  final int value;
}

/// 举报类型（`POST /card/report` 的 `type`）。
enum DatingReportType {
  fakeInfo(0),
  imageMismatch(1),
  fraudRisk(2),
  illegal(3),
  other(4);

  const DatingReportType(this.value);
  final int value;
}

/// 金币解锁流水类型 `CARD_UNLOCK`（`t_cloud_gold_pay_record.cost_type`）。
const int kDatingGoldUnlockCostType = 80;

/// 解锁方式：`1` VIP / `2` 金币。
enum DatingUnlockType {
  vip(1),
  gold(2);

  const DatingUnlockType(this.value);
  final int value;
}

class DatingDictItem {
  const DatingDictItem({required this.value, required this.label});

  final int value;
  final String label;

  factory DatingDictItem.fromJson(Map<String, dynamic> json) {
    return DatingDictItem(
      value: _parseInt(json['value']) ?? 0,
      label: (json['label'] ?? '').toString(),
    );
  }

  static List<DatingDictItem> listFromData(dynamic data) {
    if (data is! List) return const <DatingDictItem>[];
    final out = <DatingDictItem>[];
    for (final e in data) {
      if (e is Map) {
        final item = DatingDictItem.fromJson(Map<String, dynamic>.from(e));
        if (item.label.isNotEmpty) out.add(item);
      }
    }
    return out;
  }
}

class DatingTagItem {
  const DatingTagItem({
    required this.id,
    required this.name,
    this.type,
    this.sort,
    this.status,
    this.logo,
  });

  final int id;
  final String name;
  final int? type;
  final int? sort;
  final int? status;
  final String? logo;

  factory DatingTagItem.fromJson(Map<String, dynamic> json) {
    return DatingTagItem(
      id: _parseInt(json['id']) ?? 0,
      name: (json['name'] ?? '').toString(),
      type: _parseInt(json['type']),
      sort: _parseInt(json['sort']),
      status: _parseInt(json['status']),
      logo: json['logo']?.toString(),
    );
  }

  static List<DatingTagItem> listFromData(dynamic data) {
    if (data is! List) return const <DatingTagItem>[];
    final out = <DatingTagItem>[];
    for (final e in data) {
      if (e is Map) {
        final item = DatingTagItem.fromJson(Map<String, dynamic>.from(e));
        if (item.id > 0 && item.name.isNotEmpty) out.add(item);
      }
    }
    return out;
  }
}

class DatingRegionNode {
  const DatingRegionNode({
    required this.id,
    required this.name,
    this.sort = 0,
    this.provinceId,
    this.children = const <DatingRegionNode>[],
  });

  final int id;
  final String name;
  final int sort;
  final int? provinceId;
  final List<DatingRegionNode> children;

  factory DatingRegionNode.fromJson(Map<String, dynamic> json) {
    final childrenRaw = json['children'];
    final children = <DatingRegionNode>[];
    if (childrenRaw is List) {
      for (final c in childrenRaw) {
        if (c is Map) {
          children.add(DatingRegionNode.fromJson(Map<String, dynamic>.from(c)));
        }
      }
    }
    children.sort((a, b) => a.sort.compareTo(b.sort));
    return DatingRegionNode(
      id: _parseInt(json['id']) ?? 0,
      name: (json['name'] ?? '').toString(),
      sort: _parseInt(json['sort']) ?? 0,
      provinceId: _parseInt(json['provinceId']),
      children: children,
    );
  }

  static List<DatingRegionNode> listFromData(dynamic data) {
    if (data is! List) return const <DatingRegionNode>[];
    final out = <DatingRegionNode>[];
    for (final e in data) {
      if (e is Map) {
        final item = DatingRegionNode.fromJson(Map<String, dynamic>.from(e));
        if (item.id > 0 && item.name.isNotEmpty) out.add(item);
      }
    }
    out.sort((a, b) => a.sort.compareTo(b.sort));
    return out;
  }
}

class DatingCityItem {
  const DatingCityItem({
    required this.cityId,
    required this.cityName,
    this.provinceId,
    this.provinceName,
  });

  final int cityId;
  final String cityName;
  final int? provinceId;
  final String? provinceName;

  factory DatingCityItem.fromJson(Map<String, dynamic> json) {
    return DatingCityItem(
      cityId: _parseInt(json['cityId']) ?? 0,
      cityName: (json['cityName'] ?? '').toString(),
      provinceId: _parseInt(json['provinceId']),
      provinceName: json['provinceName']?.toString(),
    );
  }
}

class DatingContactItem {
  const DatingContactItem({
    required this.type,
    this.typeName,
    this.typeLabel,
    this.value,
  });

  final int type;
  final String? typeName;
  final String? typeLabel;
  final String? value;

  String get displayLabel {
    if (typeLabel != null && typeLabel!.isNotEmpty) return typeLabel!;
    if (typeName != null && typeName!.isNotEmpty) return typeName!;
    if (type == 9) return '其他';
    return '联系方式';
  }

  factory DatingContactItem.fromJson(Map<String, dynamic> json) {
    return DatingContactItem(
      type: _parseInt(json['type']) ?? 0,
      typeName: json['typeName']?.toString(),
      typeLabel: json['typeLabel']?.toString(),
      value: json['value']?.toString(),
    );
  }
}

/// `POST /card/list` / `detail` / `unlock` 的 CardVo。
class DatingCardModel {
  DatingCardModel({
    this.id = 0,
    this.type,
    this.typeName,
    this.title = '',
    this.signature,
    this.myself,
    this.minAge,
    this.maxAge,
    this.minPrice,
    this.maxPrice,
    this.appointTime,
    this.compensate = 0,
    this.gold = 0,
    this.vipUnlock = 0,
    this.unlocked = false,
    this.needPay = false,
    this.canVipUnlock = false,
    this.displayWatch = 0,
    this.displayWeekWatch = 0,
    this.displayMonthWatch = 0,
    this.displayBuyNum = 0,
    this.updateTime = 0,
    this.cities = const <DatingCityItem>[],
    this.serviceTags = const <DatingTagItem>[],
    this.recommendTags = const <DatingTagItem>[],
    this.personalTags = const <DatingTagItem>[],
    this.tags = const <DatingTagItem>[],
    this.sources = const <PostSourceItem>[],
    this.contacts = const <DatingContactItem>[],
    List<DatingContactItem>? legacyFlatContacts,
  }) : _legacyFlatContactsStored =
            legacyFlatContacts ?? const <DatingContactItem>[];

  final List<DatingContactItem> _legacyFlatContactsStored;

  final int id;
  final int? type;
  final String? typeName;
  final String title;
  final String? signature;
  final String? myself;
  final int? minAge;
  final int? maxAge;
  final num? minPrice;
  final num? maxPrice;
  final String? appointTime;
  final int compensate;
  final int gold;
  final int vipUnlock;
  bool unlocked;
  bool needPay;
  bool canVipUnlock;
  final int displayWatch;
  final int displayWeekWatch;
  final int displayMonthWatch;
  final int displayBuyNum;
  final int updateTime;
  final List<DatingCityItem> cities;
  final List<DatingTagItem> serviceTags;
  final List<DatingTagItem> recommendTags;
  final List<DatingTagItem> personalTags;
  final List<DatingTagItem> tags;
  final List<PostSourceItem> sources;
  final List<DatingContactItem> contacts;

  String? get coverUrl {
    for (final s in sources) {
      if (s.type == PostSourceType.image && (s.source?.isNotEmpty ?? false)) {
        return s.source;
      }
    }
    for (final s in sources) {
      if (s.type == PostSourceType.video && (s.screen?.isNotEmpty ?? false)) {
        return s.screen;
      }
    }
    return null;
  }

  List<String> get imageUrls {
    final out = <String>[];
    for (final s in sources) {
      if (s.type == PostSourceType.image && (s.source?.isNotEmpty ?? false)) {
        out.add(s.source!);
      }
    }
    return out;
  }

  String get ageLabel {
    if (minAge != null && maxAge != null && minAge! > 0 && maxAge! > 0) {
      if (minAge == maxAge) return '$minAge岁';
      return '$minAge岁-$maxAge岁';
    }
    if (minAge != null && minAge! > 0) return '$minAge岁';
    if (maxAge != null && maxAge! > 0) return '$maxAge岁';
    return '';
  }

  String get priceLabel {
    if (minPrice != null && maxPrice != null) {
      if (minPrice == maxPrice) return '¥$minPrice';
      return '¥$minPrice-$maxPrice';
    }
    if (minPrice != null) return '¥$minPrice';
    if (maxPrice != null) return '¥$maxPrice';
    return '';
  }

  String get regionShortLabel {
    if (cities.isEmpty) return '';
    final c = cities.first;
    final province = c.provinceName ?? '';
    if (province.isNotEmpty) return province;
    return c.cityName;
  }

  String get regionDetailLabel {
    if (cities.isEmpty) return '';
    final c = cities.first;
    final province = c.provinceName ?? '';
    final city = c.cityName;
    if (province.isNotEmpty && city.isNotEmpty) return '$province·$city';
    return city.isNotEmpty ? city : province;
  }

  String get cityChipLabel {
    if (cities.isEmpty) return '';
    return cities.first.cityName;
  }

  bool get showCompensate => compensate == 1;

  String get vipUnlockPermissionLine1 {
    if (DatingCardType.fromValue(type) == DatingCardType.waiwei) {
      return '开通带「外围解锁」权限的 VIP';
    }
    return '开通带「楼凤解锁」权限的 VIP';
  }

  /// 已解锁联系方式：优先 `contacts`，兼容旧字段 `wechat` / `qq` 等。
  List<DatingContactItem> get effectiveContacts {
    final withValue =
        contacts.where((c) => c.value != null && c.value!.isNotEmpty).toList();
    if (withValue.isNotEmpty) return withValue;
    if (!unlocked) return const <DatingContactItem>[];
    return _legacyFlatContactsStored;
  }

  /// 约会无作者，接口 `aid` / `account` 恒为 null，客户端不展示。
  factory DatingCardModel.fromJson(Map<String, dynamic> json) {
    final unlocked = json['unlocked'] == true;
    return DatingCardModel(
      id: _parseInt(json['id']) ?? 0,
      type: _parseInt(json['type']),
      typeName: json['typeName']?.toString(),
      title: (json['title'] ?? '').toString(),
      signature: json['signature']?.toString(),
      myself: json['myself']?.toString(),
      minAge: _parseInt(json['minAge'] ?? json['age']),
      maxAge: _parseInt(json['maxAge'] ?? json['age']),
      minPrice: _parseNum(json['minPrice']),
      maxPrice: _parseNum(json['maxPrice']),
      appointTime: json['appointTime']?.toString(),
      compensate: _parseInt(json['compensate']) ?? 0,
      gold: _parseInt(json['gold']) ?? 0,
      vipUnlock: _parseInt(json['vipUnlock']) ?? 0,
      unlocked: unlocked,
      needPay: json['needPay'] == true,
      canVipUnlock: json['canVipUnlock'] == true,
      displayWatch: _parseInt(json['displayWatch']) ?? 0,
      displayWeekWatch: _parseInt(json['displayWeekWatch']) ?? 0,
      displayMonthWatch: _parseInt(json['displayMonthWatch']) ?? 0,
      displayBuyNum: _parseInt(json['displayBuyNum']) ?? 0,
      updateTime: _parseUpdateTimeMs(json['updateTime']),
      cities: _citiesFrom(json['cities']),
      serviceTags: DatingTagItem.listFromData(json['serviceTags']),
      recommendTags: DatingTagItem.listFromData(json['recommendTags']),
      personalTags: DatingTagItem.listFromData(json['personalTags']),
      tags: DatingTagItem.listFromData(json['tags']),
      sources: _sourcesFrom(json['sources']),
      contacts: _contactsFrom(json['contacts']),
      legacyFlatContacts: unlocked
          ? _legacyContactsFromFlatJson(json)
          : const <DatingContactItem>[],
    );
  }

  static List<DatingCardModel> listFromData(dynamic data) {
    if (data is! List) return const <DatingCardModel>[];
    final out = <DatingCardModel>[];
    for (final e in data) {
      if (e is Map) {
        out.add(DatingCardModel.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    return out;
  }

  static DatingCardModel? fromAny(dynamic raw) {
    if (raw is Map) {
      return DatingCardModel.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }
}

/// 列表 Query 参数（`POST /card/list`，走 ES `cloud_card`，非 JSON Body）。
class DatingListQuery {
  const DatingListQuery({
    this.page = 1,
    this.pageSize = 20,
    this.type,
    this.provinceId,
    this.cityId,
    this.sortType = DatingSortType.latest,
    this.tagId,
    this.keyword,
  });

  final int page;
  final int pageSize;
  final int? type;
  final int? provinceId;
  final int? cityId;
  final DatingSortType sortType;
  final int? tagId;

  /// 搜标题、地区文案、图文 `sourceMsg`。
  final String? keyword;

  Map<String, dynamic> toJson() {
    final out = <String, dynamic>{
      'page': page,
      'pageSize': pageSize.clamp(1, 1000),
      'sortType': sortType.value,
    };
    if (type != null) out['type'] = type;
    if (provinceId != null) out['provinceId'] = provinceId;
    if (cityId != null) out['cityId'] = cityId;
    if (tagId != null) out['tagId'] = tagId;
    if (keyword != null && keyword!.isNotEmpty) out['keyword'] = keyword;
    return out;
  }
}

class DatingListPage {
  DatingListPage({
    required this.list,
    this.total = 0,
    this.hasNextPage = false,
  });

  final List<DatingCardModel> list;
  final int total;
  final bool hasNextPage;

  factory DatingListPage.fromData(
    dynamic data, {
    required int requestedPageSize,
    int? total,
  }) {
    final list = DatingCardModel.listFromData(data);
    final t = total ?? list.length;
    final hasNext = list.length >= requestedPageSize;
    return DatingListPage(list: list, total: t, hasNextPage: hasNext);
  }
}

List<DatingCityItem> _citiesFrom(dynamic raw) {
  if (raw is! List) return const <DatingCityItem>[];
  final out = <DatingCityItem>[];
  for (final e in raw) {
    if (e is Map) {
      out.add(DatingCityItem.fromJson(Map<String, dynamic>.from(e)));
    }
  }
  return out;
}

List<PostSourceItem> _sourcesFrom(dynamic raw) {
  if (raw is! List) return const <PostSourceItem>[];
  final out = <PostSourceItem>[];
  for (final e in raw) {
    if (e is Map) {
      out.add(PostSourceItem.fromJson(Map<String, dynamic>.from(e)));
    }
  }
  return out;
}

List<DatingContactItem> _legacyContactsFromFlatJson(Map<String, dynamic> json) {
  final out = <DatingContactItem>[];
  void add(int type, String typeName, dynamic v) {
    final s = v?.toString();
    if (s != null && s.isNotEmpty) {
      out.add(DatingContactItem(type: type, typeName: typeName, value: s));
    }
  }

  add(1, '微信', json['wechat']);
  add(2, 'QQ', json['qq']);
  add(3, 'Telegram', json['telegram']);
  add(4, '手机', json['phone']);
  add(9, '其他', json['other']);
  return out;
}

List<DatingContactItem> _contactsFrom(dynamic raw) {
  if (raw is! List) return const <DatingContactItem>[];
  final out = <DatingContactItem>[];
  for (final e in raw) {
    if (e is Map) {
      out.add(DatingContactItem.fromJson(Map<String, dynamic>.from(e)));
    }
  }
  return out;
}

/// `updateTime`：毫秒时间戳，或秒级时间戳，或 `"2026-09-19 10:29:39"` 等日期字符串。
int _parseUpdateTimeMs(dynamic v) {
  if (v == null) return 0;
  if (v is int) {
    if (v > 0 && v < 100000000000) return v * 1000;
    return v;
  }
  if (v is num) {
    final n = v.toInt();
    if (n > 0 && n < 100000000000) return n * 1000;
    return n;
  }
  final s = v.toString().trim();
  if (s.isEmpty) return 0;
  final asInt = int.tryParse(s);
  if (asInt != null) {
    if (asInt > 0 && asInt < 100000000000) return asInt * 1000;
    return asInt;
  }
  try {
    return DateTime.parse(s).millisecondsSinceEpoch;
  } catch (_) {
    return 0;
  }
}

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

num? _parseNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  return num.tryParse(v.toString());
}
