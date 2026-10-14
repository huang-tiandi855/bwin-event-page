import 'package:comics_app/common/services/storage.dart';
import 'package:comics_app/common/store/config.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/store/wallet.dart';
import 'package:comics_app/common/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

///初始化时进行依赖注入，可全局使用
class Injection {
  static Future<void> init() async {
    l.d("服务开始初始化...", tag: 'Injection');
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    await Get.putAsync<StorageService>(() => StorageService().init());
    Get.put<ConfigStore>(ConfigStore());
    Get.put<UserStore>(UserStore());
    Get.put<WalletStore>(WalletStore());
    l.d("所有服务初始化完成", tag: 'Injection');
  }
}
