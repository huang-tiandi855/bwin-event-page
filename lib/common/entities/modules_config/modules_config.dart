import 'module_model.dart';

class ModulesConfig {
  /// 首页分类
  List<ModuleModel> homeModules = [];

  /// 短视频分类
  List<ModuleModel> shortModules = [];

  /// 暗网分类
  List<ModuleModel> darkModules = [];

  List<ModuleModel> get fusion => [
        ...homeModules,
        ...shortModules,
        ...darkModules,
      ];

  ModulesConfig({
    this.homeModules = const [],
    this.shortModules = const [],
    this.darkModules = const [],
  });

  @override
  String toString() {
    return 'ModulesConfig(homeModules: $homeModules, shortModules: $shortModules, darkModules: $darkModules)';
  }

  /// `cms/groups` 文档：`data` 为分组数组；历史形态为 `{ homeModules: [...] }`
  factory ModulesConfig.fromJson(
    Map<String, Object?> json, {
    int? videoType,
  }) {
    final groups = _parseHomeModules(json['groups']) ?? [];
    if (groups.isNotEmpty) {
      if (videoType == 1) {
        return ModulesConfig(shortModules: groups);
      }
      if (videoType == 2) {
        return ModulesConfig(darkModules: groups);
      }
      return ModulesConfig(homeModules: groups);
    }
    return ModulesConfig(
      homeModules: _parseHomeModules(json['homeModules']) ?? [],
      shortModules: _parseHomeModules(json['shortModules']) ?? [],
      darkModules: _parseHomeModules(json['darkModules']) ?? [],
    );
  }

  static List<ModuleModel>? _parseHomeModules(Object? raw) {
    if (raw is! List<dynamic>) return null;
    final List<ModuleModel> out = [];
    for (final dynamic e in raw) {
      if (e is Map<String, dynamic>) {
        out.add(ModuleModel.fromJson(e));
      } else if (e is Map) {
        out.add(ModuleModel.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    return out;
  }

  /// 响应根级 `data` 直接为数组时使用
  factory ModulesConfig.fromGroupList(List<dynamic> list, int videoType) {
    if (videoType == 1) {
      return ModulesConfig(shortModules: _parseHomeModules(list) ?? []);
    }
    if (videoType == 2) {
      return ModulesConfig(darkModules: _parseHomeModules(list) ?? []);
    }
    return ModulesConfig(homeModules: _parseHomeModules(list) ?? []);
  }

  Map<String, Object?> toJson() => {
        'homeModules': homeModules.map((e) => e.toJson()).toList(),
        'shortModules': shortModules.map((e) => e.toJson()).toList(),
        'darkModules': darkModules.map((e) => e.toJson()).toList(),
      };

  ModulesConfig copyWith({
    List<ModuleModel>? homeModules,
    List<ModuleModel>? shortModules,
    List<ModuleModel>? darkModules,
  }) {
    return ModulesConfig(
      homeModules: homeModules ?? this.homeModules,
      shortModules: shortModules ?? this.shortModules,
      darkModules: darkModules ?? this.darkModules,
    );
  }
}
