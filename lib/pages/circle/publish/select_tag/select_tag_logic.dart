import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'select_tag_state.dart';

class SelectTagLogic extends GetxController with GetSingleTickerProviderStateMixin {

  final SelectTagState state = SelectTagState();

  @override
  void onInit() {
    // TODO: implement onInit

    super.onInit();

    state.tabController = TabController(length: state.tabs.length, vsync: this,initialIndex: 0);

    state.tabController.addListener(() {

    });

  }
}
