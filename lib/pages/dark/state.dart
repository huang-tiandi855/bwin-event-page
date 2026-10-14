import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/services/module_config_service.dart';
import 'package:get/get.dart';

class DarkState {
  late String title;

  /// 暗网一级分类，接口接入前先使用假数据。
  List<ModuleModel> categoryModules = [];

  int primaryTabIndex = 0;

  String topBarSearchHint = '搜索你感兴趣的内容';
  double topBarHeight = 50;
  double topBarHorizontalPadding = 16;

  DarkState() {
    title = '禁区';
    final dynamic args = Get.arguments;
    if (args is Map) {
      final dynamic t = args['title'];
      if (t != null && t.toString().isNotEmpty) {
        title = t.toString();
      }
    }

    categoryModules = List<ModuleModel>.from(
      ModuleConfigService.sharedInstance.darkModules.darkModules,
    );
  }
}
