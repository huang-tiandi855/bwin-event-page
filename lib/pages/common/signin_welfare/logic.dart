import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:comics_app/common/utils/tab_controller_dispose.dart';

import 'agent_promotion/logic.dart';
import 'recommend_application/logic.dart';
import 'signin/logic.dart';
import 'state.dart';

class SigninWelfareLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  final SigninWelfareState state = SigninWelfareState();

  late final TabController tabController;

  @override
  void onInit() {
    super.onInit();
    Get.put(AgentPromotionLogic(), permanent: false);
    Get.put(SigninLogic(), permanent: false);
    Get.put(RecommendApplicationLogic(), permanent: false);
    tabController = TabController(
      length: SigninWelfareState.primaryTabs.length,
      vsync: this,
      initialIndex: state.currentTab,
    );
  }

  @override
  void onClose() {
    disposeTabControllerAfterRouteExit(tabController);
    super.onClose();
  }
}
