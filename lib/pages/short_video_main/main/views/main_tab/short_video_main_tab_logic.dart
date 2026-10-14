import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:get/get.dart';

import 'short_video_main_tab_state.dart';

class ShortVideoMainTabLogic extends GetxController with GetSingleTickerProviderStateMixin {
  final ModuleModel module;

  ShortVideoMainTabLogic({required this.module});

  late final state = ShortVideoMainTabState(module: module);

  // @override
  // void onInit() {
  //   super.onInit();
  //   if (state.hasTabs) {
  //     state.tabController = TabController(
  //       length: state.tabs.length,
  //       vsync: this,
  //     )..addListener(onChangeTab);
  //   }
  // }

  // // 监听tab切换
  // void onChangeTab() {
  //   if (state.tabIndex != state.tabController!.index) {
  //     state.tabIndex = state.tabController!.index;
  //     refreshHJNavigate();
  //   }
  // }

  // void refreshHJNavigate() {
  //   update(['HJNavigate']);
  // }

  // @override
  // void onClose() {
  //   state.tabController?.removeListener(onChangeTab);
  //   state.tabController?.dispose();
  //   super.onClose();
  // }
}
