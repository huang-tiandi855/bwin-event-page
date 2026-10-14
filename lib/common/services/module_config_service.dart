import 'package:comics_app/common/apis/module_api.dart';
import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/entities/modules_config/modules_config.dart';

class ModuleConfigService {
  factory ModuleConfigService() {
    _instance ??= ModuleConfigService._();
    return _instance!;
  }

  static ModuleConfigService get sharedInstance => ModuleConfigService();

  static ModuleConfigService? _instance;

  ModuleConfigService._();

  late ModulesConfig homeModules = ModulesConfig();
  late ModulesConfig shortModules = ModulesConfig();
  late ModulesConfig darkModules = ModulesConfig();

  List<ModuleModel> get fusion => [
        ...homeModules.homeModules,
        ...shortModules.shortModules,
        ...darkModules.darkModules,
      ];

  Future<void> getModuleList() async {
    homeModules = await ModuleApi.getHomeModuleList(0);
    shortModules = await ModuleApi.getHomeModuleList(1);
    darkModules = await ModuleApi.getHomeModuleList(2);
    
  }

  List<ModuleModel> get shortVideoTabs {
    return [
      // 短视频
      if (shortModules.shortModules.isNotEmpty) shortModules.shortModules.first,
      // 短剧
      if (shortModules.shortModules.length > 1) shortModules.shortModules[1],
    ];
  }

  ModuleModel? get shortVideoRootModule {
    if (shortModules.shortModules.isEmpty) return null;
    return shortModules.shortModules.first;
  }

  int get discoverModuleId {
    return shortVideoRootModule?.id ?? 0;
  }

  List<ModuleModel> get discoverSecondTabs {
    return shortVideoRootModule?.childGroups ?? [];
  }
}
