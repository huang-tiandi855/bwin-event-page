import 'package:flutter/material.dart';

class SelectTagState {

  late TabController tabController ;
  late  List<String> tabs = [];

  SelectTagState() {
    ///Initialize variables
    tabs = ["关注", "推荐",];
  }
}
