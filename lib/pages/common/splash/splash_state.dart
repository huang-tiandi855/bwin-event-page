import 'dart:async';

import 'package:comics_app/common/entities/config.dart';
import 'package:get/get.dart';

class SplashState {
  ///选线loading
  RxBool isDetectLineLoading = true.obs;

  ///获取配置loading
  RxBool isGetConfigLoading = true.obs;

  ///启动页广告
  List<AdsInfoList>? adsList;

  ///广告时间
  RxInt countdownTime = 6.obs;

  ///定时器
  Timer? timer;

  SplashState() {
    ///Initialize variables
  }
}
