import 'dart:ui' show FlutterView;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Screen {
  static FlutterView get _view {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    assert(views.isNotEmpty, 'No FlutterView is available yet.');
    return views.first;
  }

  static MediaQueryData get _mediaQuery => MediaQueryData.fromView(_view);

  static double get width => _mediaQuery.size.width;

  static double get height => _mediaQuery.size.height;

  static double get scale => _mediaQuery.devicePixelRatio;

  /// 与系统字体缩放等价的线性系数（线性 TextScaler 下等价于旧版 MediaQuery 的字体缩放倍率）。
  static double get contentTextScale => _mediaQuery.textScaler.scale(1.0);

  static double get navigationBarHeight =>
      _mediaQuery.padding.top + kToolbarHeight;

  static double get topSafeHeight => _mediaQuery.padding.top;

  static double get bottomSafeHeight => _mediaQuery.padding.bottom;

  static double get bottomNavigationBarHeight =>
      _mediaQuery.padding.bottom + kBottomNavigationBarHeight;

  static void updateStatusBarStyle(SystemUiOverlayStyle style) {
    SystemChrome.setSystemUIOverlayStyle(style);
  }
}
