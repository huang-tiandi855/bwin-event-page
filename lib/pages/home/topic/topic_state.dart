import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopicState {
  String? id;

  String? zone;

  String title = '';

  late List<String> tabs = [];

  late List<Widget> tabsWidget = [];

  late TabController tabController;

  int? kind;

  bool isJinGangQu = false;

  bool isSkits = false;

  TopicState() {
    ///Initialize variables
    id = Get.arguments["id"];
    zone = Get.arguments["zone"];

    kind = Get.arguments["kind"];

    title = Get.arguments["title"] ?? '';

    isJinGangQu = Get.arguments?["isJinGangZone"] ?? false;

    isSkits = Get.arguments?["isSkits"] ?? false;

    tabs = [
      "最新",
      "最热",
    ];
    tabsWidget = tabs
        .map((e) => Text(
              e,
            ))
        .toList();
  }
}
