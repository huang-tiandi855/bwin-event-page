import 'package:comics_app/common/utils/event_bus/event_bus_util.dart';

import 'module_model.dart';

extension ModuleModelExtension on ModuleModel {
  JumpModuleType? get jumpModuleType {
    switch (moduleType) {
      case 1:
      case 2:
      case 3:
        return JumpModuleType.home;
      case 4:
      case 5:
        return JumpModuleType.community;
      case 6:
        return JumpModuleType.dark;
      case 7:
      case 8:
      case 9:
        return JumpModuleType.douyin;
      default:
        return null;
    }
  }

  AbsJumpModuleEvent? generateJumpEvent(String id) {
    switch (jumpModuleType) {
      case JumpModuleType.home:
        return HomeJumpModuleEvent(
          id: id,
          subModuleType: moduleType,
        );
      case JumpModuleType.douyin:
        return DouYinJumpModuleEvent(id: id);
      case JumpModuleType.dark:
        return DarkJumpModuleEvent(id: id);
      case JumpModuleType.community:
        return CommunityJumpModuleEvent(id: id);
      case JumpModuleType.ai:
        return AiJumpModuleEvent(id: id);
      case JumpModuleType.mine:
        return MineJumpModuleEvent(id: id);
      default:
        return null;
    }
  }
}
