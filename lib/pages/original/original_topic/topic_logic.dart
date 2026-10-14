import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'topic_state.dart';

class OriginalTopicLogic extends GetxController with GetSingleTickerProviderStateMixin {
  final OriginalTopicState state = OriginalTopicState();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    state.tabController =
        TabController(length: state.tabs.length, vsync: this, initialIndex: 0);
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}
