import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:comics_app/common/values/varibel_config.dart';
import 'package:comics_app/pages/loading/loading_center_widget.dart';
import 'package:comics_app/pages/mine_index/lock_screen_pattern/cold_start.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/router_report.dart';
import 'package:wakelock/wakelock.dart';
import 'common/Injection/Injection.dart';
import 'common/routers/app_pages.dart';
import 'common/routers/app_routes.dart';
import 'common/store/config.dart';
import 'common/style/style.dart';
import 'common/utils/logger.dart';
import 'common/utils/system_ui_util.dart';
import 'common/websocket/ws_listen.dart';
import 'common/websocket/ws_service.dart';

///上报错误和日志逻辑
void reportErrorAndLog(FlutterErrorDetails details) {
  l.p(details.toString());
}

/// 构建错误信息
FlutterErrorDetails makeDetails(Object obj, StackTrace stack) {
  FlutterErrorDetails flutterErrorDetails =
      FlutterErrorDetails(exception: obj, stack: stack);
  return flutterErrorDetails;
}

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    var onError = FlutterError.onError;

    FlutterError.onError = (FlutterErrorDetails details) {
      onError?.call(details);
      reportErrorAndLog(details);
    };

    await Injection.init();
    await SpUtil.getInstance();

    PaintingBinding.instance.imageCache.maximumSize = 4000;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 900 << 20;

    Wakelock.enable();
    LogUtil.init(isDebug: true);

    final needPatternVerify =
        SpUtil.getBool(VariableConfig.lockScreen, defValue: false)! &&
            (SpUtil.getString(VariableConfig.lockScreenPassword) ?? '')
                .trim()
                .isNotEmpty;
    PatternLockColdStart.pendingVerifyThenSplash = needPatternVerify;

    runApp(
      DevicePreview(
        enabled: false,
        builder: (context) => const MyApp(),
      ),
    );
  }, (error, stack) {
    var details = makeDetails(error, stack);
    reportErrorAndLog(details);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    restoreDefaultSystemUi();

    final isLockPassword =
        SpUtil.getBool(VariableConfig.lockScreen, defValue: false)!;
    final patternRaw =
        SpUtil.getString(VariableConfig.lockScreenPassword) ?? '';
    final hasPattern = patternRaw.trim().isNotEmpty;
    final needPatternVerify = isLockPassword && hasPattern;

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      ensureScreenSize: true,
      builder: (BuildContext context, child) => GetMaterialApp(
        color: AppColor.scaffoldBackground,
        theme: AppTheme.light.copyWith(
          scaffoldBackgroundColor: AppColor.scaffoldBackground,
          canvasColor: AppColor.scaffoldBackground,
          textTheme: AppTheme.light.textTheme.apply(
            bodyColor: AppColor.primaryText,
            displayColor: AppColor.primaryText,
          ),
          primaryTextTheme: AppTheme.light.primaryTextTheme.apply(
            bodyColor: AppColor.primaryText,
            displayColor: AppColor.primaryText,
          ),
        ),
        defaultTransition: Transition.rightToLeftWithFade,
        enableLog: true,
        builder: FlutterSmartDialog.init(
          builder: (context, child) {
            final Widget botToastChild = BotToastInit()(context, child);
            return ColoredBox(
              color: AppColor.scaffoldBackground,
              child: DefaultTextStyle(
                style: TextStyle(
                  color: AppColor.primaryText,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
                child: botToastChild,
              ),
            );
          },
          loadingBuilder: (p0) => const LoadingCenterWidget(),
        ),
        debugShowCheckedModeBanner: true,
        getPages: AppPages.routes,
        initialRoute: needPatternVerify
            ? AppRoutes.LOCK_SCREEN_PATTERN
            : AppRoutes.SPLASH,
        navigatorObservers: [
          routeObserver,
          GetXRouterObserver(),
          FlutterSmartDialog.observer,
          BotToastNavigatorObserver(),
        ],
        initialBinding: InitialBinding(),
      ),
    );
  }
}

class GetXRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    RouterReportManager.reportCurrentRoute(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    RouterReportManager.reportRouteDispose(route);
    super.didPop(route, previousRoute);
  }
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AppLifecycleManager());
  }
}

class AppLifecycleManager extends GetxService with WidgetsBindingObserver{
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    super.onClose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        l.d('onAppResumed');
        restoreDefaultSystemUi();
        if(!WSService.instance.isConnected) {
          final url = ConfigStore.to.configBean.chatDomain ?? '';
          if(url.isNotEmpty) {
            WSService.instance.connect(url);
            WSListen.instance.listen();
          }
        }
        break;
      case AppLifecycleState.paused:
        l.d('onAppPaused');
        break;
      case AppLifecycleState.inactive:
        l.d('onAppInactive');
        break;
      case AppLifecycleState.detached:
        l.d('onAppDetached');
        break;
      case AppLifecycleState.hidden:
        l.d('onAppHidden');
        break;
      default:
        break;
    }
  }

}
