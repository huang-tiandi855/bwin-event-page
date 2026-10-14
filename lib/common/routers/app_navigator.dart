import 'package:comics_app/common/apis/config.dart';
import 'package:comics_app/common/apis/user.dart';
import 'package:comics_app/common/entities/MediaListInfo.dart';
import 'package:comics_app/common/entities/media_list_entity.dart';
import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/routers/app_pages.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/store/event_tracking_manager.dart';
import 'package:comics_app/common/utils/const.dart';
import 'package:comics_app/common/utils/logger.dart';
import 'package:comics_app/common/utils/short_media_util.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/values/enum.dart';
import 'package:comics_app/common/widgets/fullLoading.dart';
import 'package:comics_app/pages/application/application_logic.dart';
import 'package:comics_app/pages/bookshelf/novel_details/novel_details_logic.dart';
import 'package:comics_app/pages/home_index/home_index_logic.dart';
import 'package:comics_app/pages/home_index/widgets/home_navigation_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../pages/circle/circle_logic.dart';
import '../entities/user/user_account_model.dart';

/// 外链链接（`proxinner://xxx`）→ 应用内路由的统一约定。
///
/// **命名约定**：除「需要在页面内定位特定区域 / 打开抽屉」一类外，所有外链
/// host 段都与 [AppRoutes] 中的常量名（去掉前导 `/`）一致，因此 [innerJump]
/// 默认直接把 host 当成路由名透传给 [jumpPage]，**不再需要在中间维护别名表**。
///
/// ### 直接走 [jumpPage] 的常规外链
/// - `proxinner://search_page`               → [AppRoutes.SEARCH_PAGE]
/// - `proxinner://video_page?id=`            → [AppRoutes.VIDEO_PAGE]
/// - `proxinner://rank_detail`               → [AppRoutes.RANK_DETAIL]
/// - `proxinner://signin_welfare`            → [AppRoutes.SIGNIN_WELFARE]
/// - `proxinner://mine_share_invite`         → [AppRoutes.SHARE_INVITE]
/// - `proxinner://setting_center`            → [AppRoutes.SETTING_CENTER]
/// - `proxinner://member_center`             → [AppRoutes.MEMBER_CENTER]
/// - `proxinner://wallet`                    → [AppRoutes.WALLET]
/// - `proxinner://signin_exchange_records`   → [AppRoutes.SIGNIN_EXCHANGE_RECORDS]
/// - `proxinner://history_record`            → [AppRoutes.HISTORY_RECORD]
/// - `proxinner://mine_my_collection`        → [AppRoutes.MINE_MY_COLLECTION]
///
/// ### 需要在 [innerJump] 里单独拦截的特殊外链
/// 这些不是「跳到独立路由页」而是「跳到某页内部的特定位置 / UI 组件」，
/// 无法用 [jumpPage] 表达：
/// - `proxinner://home_navigation_drawer`        → 首页 + 打开侧边导航抽屉
/// - `proxinner://home_modules?moduleId=`        → 首页 + 定位到指定模块 tab
/// - `proxinner://signin_welfare_task`           → 福利中心首页 + 滚到「福利任务」区
/// - `proxinner://signin_welfare_reward`         → 福利中心首页 + 滚到「奖品兑换」区

/// 福利中心首页（[AppRoutes.SIGNIN_WELFARE]）内部可滚动到的锚点区域。
///
/// 由 [AppNavigator._jumpSigninWelfareAnchor] 在跳转时通过路由 arguments
/// 的 `welfareAnchor` 字段透传，福利中心页面消费该字段决定初始滚动位置。
enum SigninWelfareAnchor {
  /// 「福利任务」区域。
  task,

  /// 「奖品兑换」区域。
  reward,
}

class AppNavigator {
  AppNavigator._();

  static final AppNavigator to = AppNavigator._();

  /// 外链 host → 应用内路由名的「别名兜底表」。
  ///
  /// 仅当外链 host 段与 [AppRoutes] 中的常量名不一致时才需要在此登记一行，
  /// 否则 [innerJump] 会直接把 host 当成路由名透传给 [jumpPage]，无需登记。
  /// 当前所有合法外链 host 与路由名都已对齐，因此为空。
  static const Map<String, String> _innerRouteMap = <String, String>{};

  /// 通用跳转入口。
  ///
  /// 支持:
  /// - `http/https` 外部浏览器
  /// - `proxinner://xxx` 内部链接
  /// - `/route` GetX 本地路由
  /// - `route?key=value` 自动补 `/` 后匹配路由
  Future go(
    String? url, {
    bool needPop = true,
    dynamic page,
    int? pageId,
    bool preventDuplicates = false,
    Map<String, dynamic>? arguments,
    int moduleType = 1,
  }) async {
    final String rawUrl = url?.trim() ?? '';
    if (rawUrl.isEmpty) return;

    final Uri? uri = Uri.tryParse(rawUrl);
    final Map<String, dynamic> args = _mergeQueryArguments(rawUrl, arguments);

    if (uri?.scheme == 'proxinner') {
      return innerJump(
        rawUrl.replaceFirst('proxinner://', ''),
        moduleType: moduleType,
        arguments: args,
        needPop: needPop,
        pageId: pageId,
        page: page,
        preventDuplicates: preventDuplicates,
      );
    }

    if (uri?.scheme == 'http' || uri?.scheme == 'https') {
      if (!needPop && Get.isOverlaysOpen) {
        Get.back();
      }
      return launchWebUrl(rawUrl);
    }

    return jumpPage(
      rawUrl,
      needPop: needPop,
      pageId: pageId,
      page: page,
      preventDuplicates: preventDuplicates,
      arguments: args,
    );
  }

  /// 跳转本地路由页面。会校验 [AppPages.routes]，避免未注册路由导致异常。
  Future jumpPage(
    String host, {
    bool needPop = true,
    dynamic page,
    int? pageId,
    Map<String, dynamic>? arguments,
    bool preventDuplicates = false,
  }) async {
    final String routeName = _normalizeRouteName(host);
    if (!_isRegisteredRoute(routeName)) {
      showToast(msg: '路由不存在: $routeName');
      return;
    }

    if (preventDuplicates && page != null) {
      final String tag = (pageId ?? 0).toString();
      return Get.to(page, routeName: '$routeName$tag');
    }

    if (needPop) {
      return Get.toNamed(
        routeName,
        arguments: arguments,
        id: pageId,
        preventDuplicates: preventDuplicates,
      );
    }
    return Get.offAllNamed(routeName, arguments: arguments, id: pageId);
  }

  /// 浏览器跳转
  launchWebUrl(String url, {String? tip}) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      l.d("launchWebUrl-error:$e");
      showToast(msg: '无效链接');
    }
  }

  /// 跳转详情页码
  Future jumpDetails(
    int? kind,
    String id, {
    int? selectedEpisode,
    List<MediaListMediaList>? portrayList,
    List<MediaList>? mediaList,
    int? index,
    bool? isOff,
    List<AllMediaInfoModel>? modelList,
    bool? isFreeZone,
  }) async {
    final MediaKind? detailKind = _detailMediaKind(kind);
    if (detailKind != null) {
      final arguments = {"id": id, "type": detailKind};
      if (kind == KindConst.NOVELKIND) {
        Get.delete<NovelDetailsLogic>();
      }
      if (isOff == true) {
        return await Get.offAndToNamed(
          AppRoutes.NOVEL_DETAILS_PAGE,
          arguments: arguments,
        );
      }
      return await Get.toNamed(
        AppRoutes.NOVEL_DETAILS_PAGE,
        arguments: arguments,
        preventDuplicates: kind == KindConst.NOVELKIND ? false : true,
      );
    } else if (kind == KindConst.PORTRAYKIND) {
      List<MediaList>? mediaLists = mediaList ??
          portrayList?.map((e) => MediaList.fromJson(e.toJson())).toList();
      if (mediaLists?.isNotEmpty != true && modelList?.isNotEmpty == true) {
        mediaLists =
            modelList!.map((e) => MediaList.fromJson(e.toJson())).toList();
      }
      return Get.toNamed(AppRoutes.PORTRAY, arguments: {
        "id": id,
        "imageList": mediaLists,
        "index": index,
      });
    } else if (kind == KindConst.JUCHANGKIND) {
      ShortMediaUtil.jumpBySingleMediaId(id);
    } else {
      if (isOff == true) {
        return await Get.offNamed(AppRoutes.VIDEO_PAGE, arguments: {
          "id": id,
          "selectedEpisode": selectedEpisode ?? 0,
          "isFreeZone": isFreeZone
        });
      } else {
        return await Get.toNamed(AppRoutes.VIDEO_PAGE, arguments: {
          "id": id,
          "selectedEpisode": selectedEpisode ?? 0,
          "isFreeZone": isFreeZone
        });
      }
    }
  }

  /// 公用方法进入在线客服
  void commonToCustomerService() async {
    FullLoading.getInstance().show();
    List<UserAccountModel>? userList = await UserApi.onlineServiceReq();
    FullLoading.getInstance().hide();
    if (userList?.isNotEmpty == true) {
      final UserAccountModel user = userList!.first;
      Get.toNamed(AppRoutes.CHAT, arguments: {
        "otherId": user.id ?? 0,
        "nickName": user.nickName ?? '',
        "avatar": user.avatar ?? '',
        'isOnlineService': true,
      });
    } else {
      showToast(msg: '当前客服繁忙，请稍后再试，我们会尽快为您服务。');
    }
  }

  /// 统一链接跳转。
  /// 跳转广告请使用jumpAdv方法
  jumpUrl({
    required String? url,
    int moduleType = 1,
    int linkType = 2,
    String? id,
    String? title,
  }) {
    return _jumpLink(
      url: url,
      moduleType: moduleType,
      reportClick: id != null && title != null,
      id: id,
      title: title,
      forceWeb: linkType == 1,
      planId: "",
      slotCode: "",
    );
  }

  /// 跳转广告。
  jumpAdv({
    required String? url,
    int moduleType = 1,
    bool isStatistics = true,
    String? id,
    String? title,
    required String planId,
    required String slotCode,
  }) {
    return _jumpLink(
      url: url,
      moduleType: moduleType,
      reportClick: isStatistics && id != null && title != null,
      id: id,
      title: title,
      trackMemberBanner: true,
      externalWhenNotInner: true,
      externalTip: '前往失败',
      planId: planId,
      slotCode: slotCode,
    );
  }

  /// 内部跳转。
  ///
  /// `url` 形如 `host?key=value` 的不带 scheme 的内部链接（[go] 在派发前已经
  /// 把 `proxinner://` 前缀剥掉）。处理流程：
  /// 1. 切出 `host` 与 query 参数（query 与外部传入的 [arguments] 合并）；
  /// 2. 对 4 个「页内定位 / 抽屉」类特殊外链单独 dispatch；
  /// 3. 其余 host 直接当作 [AppRoutes] 路由名透传给 [jumpPage]
  ///    （命名约定见 [AppNavigator] 顶部注释），如未来 host 与路由名出现
  ///    分歧再在 [_innerRouteMap] 登记别名兜底。
  innerJump(
    String url, {
    int moduleType = 1,
    Map<String, dynamic>? arguments,
    bool needPop = true,
    dynamic page,
    int? pageId,
    bool preventDuplicates = false,
  }) {
    final int urlIndex = url.indexOf('?');
    final String host = urlIndex == -1 ? url : url.substring(0, urlIndex);
    final Map<String, dynamic> args = _mergeQueryArguments(url, arguments);

    switch (host) {
      case 'home_navigation_drawer':
        return _jumpHomeNavigationDrawer(args);
      case 'home_modules':
        return _jumpHomeModules(args);
      case 'ai_modules':
        return _jumpAiModules(args);
      case 'signin_welfare_task':
        return _jumpSigninWelfareAnchor(
          SigninWelfareAnchor.task,
          args,
        );
      case 'signin_welfare_reward':
        return _jumpSigninWelfareAnchor(
          SigninWelfareAnchor.reward,
          args,
        );
      case 'post_modules':
        return _jumpPostModules(args);
      case 'customer_service':
        return commonToCustomerService();
    }

    final String target = _innerRouteMap[host] ?? host;
    return jumpPage(
      target,
      arguments: args,
      needPop: needPop,
      pageId: pageId,
      page: page,
      preventDuplicates: preventDuplicates,
    );
  }

  /// 跳「首页 + 打开侧边导航抽屉」。
  Future<void> _jumpHomeNavigationDrawer(Map<String, dynamic> args) async {
    Get.until((Route<dynamic> route) {
      return route is GetPageRoute &&
          route.settings.name == AppRoutes.APPLICATION_PAGE;
    });

    if (Get.isRegistered<ApplicationLogic>()) {
      Get.find<ApplicationLogic>().handleNavBarTap(0);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? ctx = Get.context;
      if (ctx != null) {
        showHomeNavigationDrawer(ctx);
      }
    });
  }

  /// 跳「AI + 定位到指定 `moduleId` 的一级分类 Tab」。
  Future<void> _jumpAiModules(Map<String, dynamic> args) async {
    Get.until((Route<dynamic> route) {
      return route is GetPageRoute &&
          route.settings.name == AppRoutes.APPLICATION_PAGE;
    });

    if (Get.isRegistered<ApplicationLogic>()) {
      Get.find<ApplicationLogic>().handleNavBarTap(2);
    }
  }

  /// 跳「首页 + 定位到指定 `moduleId` 的一级分类 Tab」。
  Future<void> _jumpHomeModules(Map<String, dynamic> args) async {
    Get.until((Route<dynamic> route) {
      return route is GetPageRoute &&
          route.settings.name == AppRoutes.APPLICATION_PAGE;
    });

    if (Get.isRegistered<ApplicationLogic>()) {
      Get.find<ApplicationLogic>().handleNavBarTap(0);
    }

    final String moduleId = args['moduleId']?.toString().trim() ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Get.isRegistered<HomeIndexLogic>()) return;
      final HomeIndexLogic homeLogic = Get.find<HomeIndexLogic>();
      if (homeLogic.state.categoryModules.isEmpty) return;
      // 未传 moduleId 或 moduleId 在当前分类列表中不存在（外链写了过期 id）
      // 时统一回落到第 0 个分类，与抽屉里点「主页」首项的行为一致。
      int idx = moduleId.isEmpty
          ? 0
          : homeLogic.state.categoryModules
              .indexWhere((m) => m.id?.toString() == moduleId);
      if (idx < 0) idx = 0;
      homeLogic.setPrimaryTab(idx);
      homeLogic.update();
    });
  }

  /// 跳「福利中心首页 + 滚到指定区域」。
  ///
  /// 福利中心首页（[AppRoutes.SIGNIN_WELFARE]）的「签到 Tab」末尾有
  /// 「福利任务 / 积分兑换」两个 segment。这里通过 `arguments` 透传
  /// `welfareAnchor=${anchor.name}`（`task` / `reward`），由
  /// `SigninLogic` 在 `onInit` 读取并暂存，`SigninPage` 首帧建好后调用
  /// `consumePendingAnchor`：先切到对应 segment，再用挂在
  /// `_WelfarePointsBlock` 上的 `GlobalKey` 走 `Scrollable.ensureVisible`
  /// 把外层 `SingleChildScrollView` 滚到该区域。
  ///
  /// 注意：`SigninWelfareState` 默认 `currentTab = 1`（签到 Tab），因此
  /// 不必再额外透传 `index`；如果未来该默认值变化，需要在 args 里补
  /// `'index': 1`，保证 anchor 触发时一定落在「签到」Tab。
  Future<dynamic> _jumpSigninWelfareAnchor(
    SigninWelfareAnchor anchor,
    Map<String, dynamic> args,
  ) {
    return jumpPage(
      AppRoutes.SIGNIN_WELFARE,
      arguments: <String, dynamic>{
        ...args,
        'welfareAnchor': anchor.name,
      },
    );
  }

  /// 跳「社区 + 定位到指定 `moduleId` 的一级分类 Tab」。
  ///proxinner://post_modules?moduleId=&showPostAlert=
  /////跳到社区showPostAlert:0 不弹发贴翻窗 1弹出发帖弹窗
  Future<void> _jumpPostModules(Map<String, dynamic> args) async {
    Get.until((Route<dynamic> route) {
      return route is GetPageRoute &&
          route.settings.name == AppRoutes.APPLICATION_PAGE;
    });

    if (Get.isRegistered<ApplicationLogic>()) {
      Get.find<ApplicationLogic>().handleNavBarTap(4);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final moduleId = int.tryParse(args['moduleId'] ?? '0');
      final showPostAlert = int.tryParse(args['showPostAlert'] ?? '0') ?? 0;
      final CircleLogic circleLogic = Get.find<CircleLogic>();
      circleLogic.jumpToPosting(moduleId, showPostAlert == 1);
    });
  }

  /// 获取参数。
  String? getUrlParam(String url, String name) =>
      Uri.tryParse(url)?.queryParameters[name];

  Future pushToPage(BuildContext context, Widget page,
      {bool opaque = false}) async {
    return Navigator.push(context, MaterialPageRoute(builder: (context) {
      return page;
    }));
  }

  MediaKind? _detailMediaKind(int? kind) {
    switch (kind) {
      case KindConst.NOVELKIND:
        return MediaKind.mediaKindRealFiction;
      case KindConst.AUDIOKIND:
        return MediaKind.mediaKindAudio;
      case KindConst.COMMICKIND:
        return MediaKind.mediaKindComics;
      default:
        return null;
    }
  }

  Map<String, dynamic> _mergeQueryArguments(
    String url,
    Map<String, dynamic>? arguments,
  ) {
    return <String, dynamic>{
      ...?arguments,
      ...?Uri.tryParse(url)?.queryParameters,
    };
  }

  dynamic _jumpLink({
    required String? url,
    required int moduleType,
    bool reportClick = true,
    String? id,
    required String planId,
    required String slotCode,
    String? title,
    bool forceWeb = false,
    bool trackMemberBanner = false,
    bool externalWhenNotInner = false,
    String? externalTip,
  }) {
    final String rawUrl = url?.trim() ?? '';
    if (rawUrl.isEmpty) {
      showToast(msg: '无效链接');
      return;
    }

    if (reportClick &&
        id != null &&
        title != null &&
        planId.isNotEmpty &&
        slotCode.isNotEmpty) {
      ConfigApi.adClickReport(id, planId, slotCode);
    }

    if (forceWeb) {
      return launchWebUrl(rawUrl, tip: externalTip);
    }

    if (trackMemberBanner) {
      _trackMemberBanner(rawUrl);
    }

    if (externalWhenNotInner && !rawUrl.contains('proxinner')) {
      return launchWebUrl(rawUrl, tip: externalTip);
    }

    return go(rawUrl, moduleType: moduleType);
  }

  void _trackMemberBanner(String url) {
    if (url == "proxinner://member_centre") {
      EventTrackingManager().addBannerVipGraphicss(GraphicsType.vip);
    }

    if (url.contains("member_centre?initIndex=1")) {
      EventTrackingManager().addBannerVipGraphicss(GraphicsType.coin);
    }
  }

  String _normalizeRouteName(String host) {
    final Uri? uri = Uri.tryParse(host);
    final String route = uri == null || uri.path.isEmpty ? host : uri.path;
    if (route.startsWith('/')) return route;
    return '/$route';
  }

  bool _isRegisteredRoute(String host) {
    final String routeName = _normalizeRouteName(host);
    return AppPages.routes.any((element) => element.name == routeName);
  }
}
