import 'package:flutter/material.dart';

import 'flutter_base.dart';


/// 安全退出页面和对话框
void safePopPage([dynamic ret]) {
  if (Navigator.of(FlutterBase.appContext!).canPop()) {
    Navigator.of(FlutterBase.appContext!).pop(ret);
  }
}
