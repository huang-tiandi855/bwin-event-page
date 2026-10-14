import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookshelfState extends GetxController
    with GetSingleTickerProviderStateMixin {
  late List<String> tabValues;
  late RxBool isEdit = true.obs; //编辑状态]
  late TabController tabController;

  BookshelfState() {
    ///Initialize variables
    tabValues = [
      '动漫',
      '漫画',
      // 'COS',
      '真人',
      '写真',
      '小说',
      '剧场',
    ];

    tabController = TabController(length: tabValues.length, vsync: this);
  }
}
