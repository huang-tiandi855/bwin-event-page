import 'package:comics_app/common/entities/modules_config/module_model.dart';

class ShortVideoMainTabState {
  final ModuleModel module;
  ShortVideoMainTabState({
    required this.module,
  });

  bool get hasTabs => module.showType == 2;

  final Map<String, int> tabs = {
    '最新': 1,
    '最热': 2,
  };

  final Map<String, int> followTabs = {
    '收藏': 1,
    '历史': 2,
  };
}
