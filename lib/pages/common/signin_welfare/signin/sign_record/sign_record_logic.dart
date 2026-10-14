import 'package:comics_app/common/apis/signin_apis.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/utils/tab_controller_dispose.dart';
import 'package:comics_app/common/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'sign_record_state.dart';

class SignRecordLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  final SignRecordState state = SignRecordState();

  TabController? tabController;

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    int initialIndex = 0;
    if (args is Map && args['initialIndex'] is int) {
      initialIndex = args['initialIndex'] as int;
    }
    initialIndex = initialIndex.clamp(0, SignRecordState.tabs.length - 1);
    tabController = TabController(
      length: SignRecordState.tabs.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    getSignInData();
  }

  Future<void> getSignInData() async {
    try {
      state.overview = await SignInApis.getSignInData();
    } finally {
      update();
    }
  }

  void onTapUpgradeMember() {
    AppNavigator.to.go(AppRoutes.MEMBER_CENTER);
  }

  @override
  void onClose() {
    disposeTabControllerAfterRouteExit(tabController);
    super.onClose();
  }
}
