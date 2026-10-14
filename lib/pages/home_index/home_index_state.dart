import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/services/module_config_service.dart';
import 'package:get/get.dart';

class HomeIndexState {
  late String title;

  /// 一级 Tab，来自 [ModuleConfigService.modules.homeModules]
  late List<ModuleModel> categoryModules;

  int primaryTabIndex = 0;

  /// 顶部栏文案与尺寸（View 中与 ScreenUtil 相乘）
  double topBarHeight = 50;
  double topBarHorizontalPadding = 16;

  HomeIndexState() {
    title = '主页';
    final dynamic args = Get.arguments;
    if (args is Map) {
      final dynamic t = args['title'];
      if (t != null && t.toString().isNotEmpty) {
        title = t.toString();
      }
    }

    categoryModules = List<ModuleModel>.from(
      ModuleConfigService.sharedInstance.homeModules.homeModules,
    );
  }
}
