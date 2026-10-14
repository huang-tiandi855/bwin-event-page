library flutter_base;

import 'package:flutter/material.dart';

// export 'package:flutter_app/common/image/image_loader.dart';


//player

class FlutterBase {
  static bool isRelease = true;
  static const String basePkgName = "flutter_base";
  static bool proxyEnable = false;
  //"PROXY 192.168.1.150:8888"
  static String proxyUrl = "";
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


  /// 获取顶层BuildContext
  static BuildContext? get appContext => navigatorKey.currentState?.overlay?.context;

  ///[url] "PROXY 192.168.1.150:8888"
  static setDioProxy(bool enable, String url) {
    proxyEnable = enable;
    proxyUrl = url;
  }
}
