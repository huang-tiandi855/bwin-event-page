/// 影视分类（`GET cms/group(s)`）分组模型，字段与接口文档一致。
///
/// 兼容旧版 CMS：若 JSON 仍含 `moduleName` / `moduleType` / `showType` / `permission`，会一并解析。
class ModuleModel {
  /// 分类 id（接口多为数值，统一存字符串便于与跳转参数对比）
  int? id;

  int? siteId;

  int? parentId;

  /// 分组名称（文档字段 `groupName`）
  String? groupName;

  String? name;

  /// 热门分类 0，非热门 1，热门
  int? hot;

  int? status;

  /// 是否显示在主页，1 是
  int? home;

  /// 是否显示在片库，1 是
  int? pianku;

  /// 封面布局（文档示例如 1111；注释：1 大，0 小）
  int? guild;

  ///  专题类型，1～8
  int? guildType;

  String? imageUrl;

  List<ModuleModel> childGroups;

  /// 旧版 CMS 字段（文档未列出时可为 null；后端若返回仍可读）
  int? permission;

  /// 视频类型：0，普通视频 1，短视频 2，暗网视频
  int? videoType;

  int? moduleType;

  /// 1 组合样式 · 2 列表 · 3 图集 · 4 单个专题 · 5 专题合集 · 6 所有专题 · 7 社区样式
  int? showType;

  /// 是否显示导航 banner。1 显示；0 / null 不显示
  int? showBanner;

  /// 是否显示 icon 区域。1 显示；0 / null 不显示
  int? showIcon;

  /// 是否显示通知 / 公告跑马灯。1 显示；0 / null 不显示
  int? showNotice;

  /// 帖子数量
  int? pnums;

  ModuleModel({
    this.id,
    this.siteId,
    this.parentId,
    this.groupName,
    this.name,
    this.status,
    this.home,
    this.pianku,
    this.guild,
    this.guildType,
    this.hot,
    this.imageUrl,
    List<ModuleModel>? childGroups,
    this.permission,
    this.videoType,
    this.moduleType,
    this.showType,
    this.showBanner,
    this.showIcon,
    this.showNotice,
    this.pnums,
  }) : childGroups = childGroups ?? [];

  /// 与旧代码 [moduleName] 一致，指向 [groupName]
  String? get moduleName => groupName;

  /// 是否展示导航 banner（null 视为 0 / 不展示）
  bool get isShowBanner => (showBanner ?? 0) == 1;

  /// 是否展示 icon 区域（null 视为 0 / 不展示）
  bool get isShowIcon => (showIcon ?? 0) == 1;

  /// 是否展示通知 / 公告跑马灯（null 视为 0 / 不展示）
  bool get isShowNotice => (showNotice ?? 0) == 1;

  @override
  String toString() {
    return 'ModuleModel(id: $id, groupName: $groupName, name: $name, parentId: $parentId, '
        'home: $home, pianku: $pianku, guild: $guild,guildType: $guildType,hot: $hot, imageUrl: $imageUrl, '
        'childGroups: ${childGroups.length}, videoType: $videoType, moduleType: $moduleType, showType: $showType, '
        'showBanner: $showBanner, showIcon: $showIcon, showNotice: $showNotice)';
  }

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawGroupName = json['groupName'] ?? json['moduleName'];
    return ModuleModel(
      id: _parseId(json['id']),
      siteId: _parseInt(json['siteId']),
      parentId: _parseInt(json['parentId']),
      groupName: rawGroupName?.toString(),
      name: json['name'],
      status: _parseInt(json['status']),
      home: _parseInt(json['home']),
      pianku: _parseInt(json['pianku']),
      guild: _parseInt(json['guild']),
      guildType: _parseInt(json['guildType']),
      hot: _parseInt(json['hot']),
      imageUrl: json['imageUrl'],
      childGroups: _parseChildGroups(json['childGroups'] ?? json['children']),
      permission: _parseInt(json['permission']),
      videoType: _parseInt(json['videoType']),
      moduleType: _parseInt(json['moduleType']),
      showType: _parseInt(json['showType']),
      showBanner: _parseInt(json['showBanner']),
      showIcon: _parseInt(json['showIcon']),
      showNotice: _parseInt(json['showNotice']),
      pnums: _parseInt(json['pnums']),
    );
  }

  static List<ModuleModel> listFromData(dynamic data) {
    if (data == null || data is! List) return [];
    final List<ModuleModel> out = [];
    for (final dynamic e in data) {
      out.add(ModuleModel.fromJson(Map<String, dynamic>.from(e)));
    }
    return out;
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'siteId': siteId,
        'parentId': parentId,
        'groupName': groupName,
        'name': name,
        'status': status,
        'home': home,
        'pianku': pianku,
        'guild': guild,
        'guildType': guildType,
        'hot': hot,
        'imageUrl': imageUrl,
        'childGroups': childGroups.map((e) => e.toJson()).toList(),
        if (permission != null) 'permission': permission,
        if (videoType != null) 'videoType': videoType,
        if (moduleType != null) 'moduleType': moduleType,
        if (showType != null) 'showType': showType,
        if (showBanner != null) 'showBanner': showBanner,
        if (showIcon != null) 'showIcon': showIcon,
        if (showNotice != null) 'showNotice': showNotice,
        if (pnums != null) 'pnums': pnums,
      };

  ModuleModel copyWith({
    int? id,
    int? siteId,
    int? parentId,
    String? groupName,
    String? name,
    int? status,
    int? home,
    int? pianku,
    int? hot,
    int? guild,
    int? guildType,
    String? imageUrl,
    List<ModuleModel>? childGroups,
    int? permission,
    int? videoType,
    int? moduleType,
    int? showType,
    int? showBanner,
    int? showIcon,
    int? showNotice,
  }) {
    return ModuleModel(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      parentId: parentId ?? this.parentId,
      groupName: groupName ?? this.groupName,
      name: name ?? this.name,
      status: status ?? this.status,
      home: home ?? this.home,
      pianku: pianku ?? this.pianku,
      hot: hot ?? this.hot,
      guild: guild ?? this.guild,
      guildType: guildType ?? this.guildType,
      imageUrl: imageUrl ?? this.imageUrl,
      childGroups: childGroups ?? List<ModuleModel>.from(this.childGroups),
      permission: permission ?? this.permission,
      videoType: videoType ?? this.videoType,
      moduleType: moduleType ?? this.moduleType,
      showType: showType ?? this.showType,
      showBanner: showBanner ?? this.showBanner,
      showIcon: showIcon ?? this.showIcon,
      showNotice: showNotice ?? this.showNotice,
    );
  }

  static int? _parseId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static List<ModuleModel> _parseChildGroups(dynamic value) {
    if (value is! List<dynamic>) return [];
    final List<ModuleModel> out = [];
    for (final dynamic e in value) {
      if (e is Map<String, dynamic>) {
        out.add(ModuleModel.fromJson(e));
      } else if (e is Map) {
        out.add(ModuleModel.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    return out;
  }
}
