import 'package:comics_app/common/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FullLoading {
  static FullLoading? _instance;

  // 私有的命名构造函数
  FullLoading._internal();

  static FullLoading getInstance() {
    _instance ??= FullLoading._internal();
    return _instance!;
  }

  show() {
    Get.dialog(const Scaffold(
        backgroundColor: Colors.transparent,
        body: PopScope(
          canPop: false,
          child: Center(
            child: LoadingWidget(),
          ),
        )));
  }

  hide() {
    Get.back();
  }
}
