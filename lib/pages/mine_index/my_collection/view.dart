import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:comics_app/common/my_list/mine_media_list_shell.dart';
import 'logic.dart';

class MyCollectionPage extends GetView<MyCollectionLogic> {
  const MyCollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MineMediaListShell(logic: controller);
  }
}
