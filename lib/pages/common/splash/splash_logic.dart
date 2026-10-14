import 'dart:async';
import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/http/app_exceptions.dart';
import 'package:comics_app/common/http/detect_line_manager.dart';
import 'package:comics_app/common/http/http_request.dart';
import 'package:comics_app/common/routers/app_navigator.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/services/active_report_service.dart';
import 'package:comics_app/common/services/auth_service.dart';
import 'package:comics_app/common/services/jwt_token_service.dart';
import 'package:comics_app/common/services/module_config_service.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';
import 'package:comics_app/common/utils/text_util.dart';
import 'package:comics_app/common/values/address.dart';
import 'package:comics_app/common/values/config.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/common/widgets/common_dialog/app_upgrade_dialog.dart';
import 'package:comics_app/common/widgets/common_dialog/confirm_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'splash_state.dart';

import 'package:comics_app/common/utils/logger.dart';

class SplashLogic extends GetxController {
  final SplashState state = SplashState();

  /// 是否正处于 [_checkNetAlways] 自循环选线中。
  ///
  /// 主流程的 `_checkNetAlways` 已是「失败 → 关弹窗 → 立即重试下一轮池子」的
  /// 死循环，无须再由「切换线路」按钮触发一次新的 [_doInit]；用这个标记把
  /// [getNewDomain] 降级为「重置全局状态 + 关弹窗等待循环接管」，避免出现两条
  /// `_doInit` 并行选线、并行写 [Address.baseUrl] 的竞态。
  bool _isCheckingNet = false;

  @override
  void onInit() async {
    super.onInit();

    _doInit();
  }

  /// 「APP 线路检测失败」弹窗里「切换线路」按钮触发的重选线入口。
  ///
  /// 旧实现走一个硬编码的单域名接口拉地址 + 本地
  /// [Config.BASE_HOSTS_REPLACE] 数组旋转（删首项 / 追加新值），已与主选线
  /// 流程脱节：现在 [_checkNetAlways] 统一通过
  /// [DetectLineManager.detectLineFromPools] 拉池 + 选线，池子源由
  /// `Config.DEBUG` 在 [DetectLineManager.detectLineFromPools] 内部分流：
  /// 测试包用 [Config.BASE_HOSTS_DEBUG]、正式包用 [Config.DOMAIN_POOL_URLS]，
  /// 每轮都会覆盖 [Config.DEFAULT_BASE_HOST] / [Config.BASE_HOSTS_REPLACE]，
  /// 旧版的本地数组旋转根本不会被保留下来。
  ///
  /// 归零可能影响 ping 路径的全局状态：
  ///   * `DNS_CUSTOM` / `DNS_IP`：手动配过自定义 DNS 时 Dio 会强制把请求 IP
  ///     固定到 [Config.DNS_IP]，新池里的域名会被一起拐过去反而不可达；
  ///     用户主动切线 = 显式放弃自定义 DNS。
  ///   * `DEFAULT_BASE_HOST`：上一次刚被判失败的默认域名，留着只会让 detect
  ///     再优先 ping 一次同一条线，浪费一次超时窗口；fetchDomainPool 成功
  ///     时会被服务端最新值覆盖，所以仅在拉池失败回退到旧 pool 时生效。
  ///
  /// 如果 [_checkNetAlways] 已经在自循环中（即 [_isCheckingNet] 为 true），
  /// 这里只需重置状态、等待 `appLineDialog` 关闭后让循环自动接管下一轮，
  /// **绝对不能** 再启动一次 [_doInit]，否则会出现两条并行选线流。
  ///
  /// loading 弹窗的关闭仍走 [DetectLineManager] 在选线成功路径上的
  /// `broadcast("closeLoadingDialog")`，与冷启动选线一致；不 await 主流程，
  /// 让弹窗 handler 立即返回，不阻塞按钮点击。
  Future<void> getNewDomain() async {
    Config.DNS_CUSTOM = false;
    Config.DNS_IP = '';
    Config.DEFAULT_BASE_HOST = '';
    if (_isCheckingNet) {
      l.d('getNewDomain() _checkNetAlways 已在循环重试，跳过新一轮 _doInit',
          tag: 'selectLine');
      return;
    }
    _doInit();
  }

  void goToApplication() async {
    AppNavigator.to.go(AppRoutes.APPLICATION_PAGE, needPop: false);
  }

  //初始化数据
  void _doInit() async {
    initFreshFps();

    ///检查网络，选线
    var line = await _checkNetAlways();

    ///初始化网络层
    _initNetManager(line);

    ///文档：JwtToken 独立接口获取（不参与登录）
    await _ensureJwtToken();

    ///登录
    await _devLogin();

    ActiveReportService.instance.start();

    ///获取全局配置
    await _getConfig();

    ///获取广告
    _showAdvertise();

    ///开启广告计时
    _startTimer();

    await ModuleConfigService().getModuleList();
  }

  /// 一直检查网络直到选出可用线路才返回。
  ///
  /// 关键流程（外层 `while(true)`，**绝不空手而归**）：
  ///   1. `connectivity_plus` 检查到完全无网 → 弹 `appLineDialog` 等用户处理网络
  ///      （开 WiFi / 4G / VPN），关闭后继续下一轮，不当作选线失败提前退出。
  ///   2. 调 [DetectLineManager.detectLineFromPools] 依次轮询当前环境对应的
  ///      域名池（测试包：[Config.BASE_HOSTS_DEBUG]；正式包：
  ///      [Config.DOMAIN_POOL_URLS]）：拉到池子就立刻 ping 选线，命中即返回；
  ///      所有池子都没命中才认为本轮失败。
  ///   3. 本轮失败 → 弹 `appLineDialog`（barrierDismissible 用户可关 / 也可点
  ///      「切换线路」），弹窗关闭后立即开始下一轮。注意「切换线路」按钮在
  ///      [_isCheckingNet] 为 true 时不会再起一条新 `_doInit`，避免并行选线。
  ///   4. 任何异常（包括 [DetectLineManager] 内部未捕获 / Connectivity 抛错）
  ///      统一走「弹窗 → 下一轮」路径，loading 状态强制回正避免界面卡死。
  ///
  /// `state.isDetectLineLoading` 语义沿用：`false` = 选线进行中（splash 上
  /// 显示「线路检查中」），`true` = idle/隐藏，所以每轮 detect 前置 false、
  /// 结束（成功 / 失败 / 异常）一律拉回 true。
  Future<String> _checkNetAlways() async {
    _isCheckingNet = true;
    try {
      while (true) {
        try {
          final result = await Connectivity().checkConnectivity();
          if (result == ConnectivityResult.none) {
            state.isDetectLineLoading.value = true;
            await appLineDialog();
            continue;
          }

          state.isDetectLineLoading.value = false;
          final String line = await DetectLineManager().detectLineFromPools();
          state.isDetectLineLoading.value = true;

          if (TextUtil.isNotEmpty(line)) {
            return line;
          }
          await appLineDialog();
        } catch (e) {
          state.isDetectLineLoading.value = true;
          debugPrint('[selectLine] _checkNetAlways 异常，将重试: $e');
          await appLineDialog();
        }
      }
    } finally {
      _isCheckingNet = false;
    }
  }

  ///初始化网络层
  _initNetManager(String baseUrl) {
    Address.baseUrl = baseUrl;
    Address.baseApiPath = Address.baseUrl;
    HttpRequest.init(Address.baseApiPath);
  }

  /// 文档 GET jwt-token，Header [machineCode]；写入 [Storage.jwtToken]。
  ///
  /// 与 [HttpRespInterceptor] 1034 共用 [JwtTokenService.ensureJwtToken]，
  /// 冷启动用 force=true 保证首次必拿一次新串；service 内部做单飞，
  /// 与拦截器并发抢锁时只会发一次 jwt-token。
  Future<void> _ensureJwtToken() async {
    while (true) {
      try {
        await JwtTokenService.instance.ensureJwtToken(force: true);
        break;
      } catch (_) {
        await showConfirm("温馨提示", "获取 JwtToken 失败，是否重试?");
      }
    }
  }

  ///获取配置信息
  _getConfig() async {
    while (true) {
      try {
        state.isGetConfigLoading.value = false;
        ConfigBean configBean = await ConfigStore.to.saveConfigBean();
        checkUpgrade(configBean);
        state.isGetConfigLoading.value = true;
        break;
      } catch (e) {
        state.isGetConfigLoading.value = true;
        await showConfirm(
            "温馨提示", "获取配置信息失败${(e is ApiException) ? e.code : 1500}");
      }
    }
  }

  /// 更新本地域名列表信息
  // _updateDomainInfo(ConfigBean configBean) {
  //   List<Source> sourceList = configBean.source ?? [];
  //   for (Source source in sourceList) {
  //     switch (source.type) {
  //       case "IMAGE":
  //         Address.baseImagePath = source.domain;
  //         break;
  //       case "GROUP":
  //         Address.baseGroupUrl = source.domain;
  //         break;
  //       case "VID":
  //         if (Config.DEBUG && Config.OPEN_SOURCE) {
  //           Address.cdnAddress = Config.SOURCE_URL;
  //         } else {
  //           Address.cdnAddress = source.domain;
  //         }
  //         break;
  //       case "GUIDE":
  //         Address.groundURl = source.domain;
  //         break;
  //       case "PROXYRULE": //代理规则
  //         Address.proxyRuleUrl = source.domain;
  //         break;
  //       case "FAQ": //常见问题
  //         Address.commonQuestion = source.domain;
  //         break;
  //       case "ACT": //常见问题
  //         Address.activityUrl = source.domain;
  //         break;
  //       case "LAND": //落地页地址
  //         Address.landUrl = source.domain;
  //         break;
  //       case "AppStore": //福利中心应用中心
  //         Address.appCenterUrl = source.domain;
  //         break;
  //       case "BusinessCooperation": //商务合作
  //         Address.businessCooperation = source.domain;
  //         break;
  //       case "GROUPEMAIl": // 邮箱
  //         Address.groupEmail = source.domain;
  //         break;
  //       case "preSaleBgImg": // 预售背景
  //         if (source.domain != null) {
  //           PreSaleGlobalInfo().storagePreSaleImg(source.domain!);
  //         }
  //         break;
  //       case "AUDIO":
  //         Address.audioUrl = source.domain;
  //         break;
  //     }
  //   }

  //   Address.sourceList = configBean.sourceList;
  //   final List<SourceList>? sl = configBean.sourceList;
  //   if (sl != null) {
  //     for (final SourceList source in sl) {
  //       switch (source.type) {
  //         case "VID":
  //           final List<Domain>? domains = source.domain;
  //           if (domains != null && domains.isNotEmpty) {
  //             Address.cdnAddressLists = domains;
  //             final String? u = domains[0].url;
  //             if (u != null && u.isNotEmpty) {
  //               Address.cdnAddress = u;
  //             }
  //           }
  //           break;
  //       }
  //     }
  //   }
  // }

  ///显示广告
  _showAdvertise() {
    List<AdsInfoList> adsList = getAdsByType(AdsType.openScreen);
    state.adsList = adsList;
    update();
  }

  void initFreshFps() async {
    ///...///

    try {
      dynamic modes = await FlutterDisplayMode.supported;

      modes.forEach((e) => l.d(e.toString()));

      /// This setting is per session.
      /// Please ensure this was placed with `initState` of your root widget.
      await FlutterDisplayMode.setHighRefreshRate();

      /// On OnePlus 7 Pro:
      /// #1 1080x2340 @ 60Hz
      /// #2 1080x2340 @ 90Hz
      /// #3 1440x3120 @ 90Hz
      /// #4 1440x3120 @ 60Hz

      /// On OnePlus 8 Pro:
      /// #1 1080x2376 @ 60Hz
      /// #2 1440x3168 @ 120Hz
      /// #3 1440x3168 @ 60Hz
      /// #4 1080x2376 @ 120Hz
    } on PlatformException {
      /// e.code =>
      /// noAPI - No API support. Only Marshmallow and above.
      /// noActivity - Activity is not available. Probably app is in background
    }
  }

  void checkUpgrade(ConfigBean configBean) async {
    final CheckVersionBean? lastVersion = configBean.lastVersion;
    if (lastVersion == null ||
        lastVersion.verName == null ||
        lastVersion.verName!.isEmpty) return;

    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String version = packageInfo.version;

    if (compareVersion(version, lastVersion.verName!)) {
      final BuildContext? ctx = Get.context;
      if (ctx != null && ctx.mounted) {
        await showAppUpgradeDialog(ctx, lastVersion);
      }
    }
  }

  ///比较版本号
  bool compareVersion(String version, String newVersion) {
    bool isNeedUpdate = false;
    List localVersionArray = version.split(".");
    List newVersionArray = newVersion.split(".");
    for (int i = 0; i < newVersion.length; i++) {
      if (i > 2) {
        break;
      }

      int newVersionCode = int.parse(newVersionArray[i]);
      int compare = int.parse(localVersionArray[i]);

      if (newVersionCode > compare) {
        isNeedUpdate = true;
        break;
      } else if (newVersionCode < compare) {
        isNeedUpdate = false;
        break;
      }
    }
    return isNeedUpdate;
  }

  ///开启定时器
  _startTimer() {
    const oneSec = Duration(seconds: 1);
    state.timer = Timer.periodic(oneSec, (timer) {
      if (state.countdownTime.value == 0) {
        state.timer?.cancel();

        // if (ConfigStore.to.configBean.ver != null &&
        //     ConfigStore.to.configBean.ver!.isNotEmpty) {
        // } else {
        //   //goToApplication();
        // }
      } else {
        state.countdownTime.value = state.countdownTime.value - 1;
      }
    });
  }

  ///登录：与 HttpRespInterceptor 共用 [AuthService.ensureLogin]，
  ///本地 token 仍有效时 service 内部直接 short-circuit。
  _devLogin() async {
    while (true) {
      try {
        await AuthService.instance.ensureLogin();
        break;
      } catch (_) {
        await showConfirm("温馨提示", "登录失败，是否重试?");
      }
    }
  }

  @override
  void onClose() {
    super.onClose();
    if (state.timer != null) {
      state.timer?.cancel();
    }
  }
}
