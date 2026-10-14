import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'topic_state.dart';

class TopicLogic extends GetxController with GetSingleTickerProviderStateMixin {
  final TopicState state = TopicState();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    state.tabController =
        TabController(length: state.tabs.length, vsync: this, initialIndex: 1);
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
