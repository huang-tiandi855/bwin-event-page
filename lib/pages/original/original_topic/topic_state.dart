
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OriginalTopicState {
  String? id;

  String? zone;

  String title = '';

  late List<String> tabs = [];

  late List<Widget> tabsWidget = [];

  late TabController tabController;

  OriginalTopicState() {
    ///Initialize variables
    id = Get.arguments["id"];
    zone = Get.arguments["zone"];
    title = Get.arguments["title"] ?? '';
    tabs = [
      "最新",
      "推荐",
      "逛逛",
      "热榜",
    ];
    tabsWidget = tabs
        .map((e) => Text(
              e,
            ))
        .toList();
  }
}
