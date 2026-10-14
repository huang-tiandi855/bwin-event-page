import 'dart:async';
import 'dart:io';

import 'package:comics_app/common/utils/light_model.dart';
import 'package:comics_app/common/values/address.dart';

import 'package:comics_app/common/widgets/space_widget.dart';
import 'package:device_identity/device_identity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
// import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:comics_app/common/apis/apis.dart';
import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/utils/logger.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';

import '../entities/MediaListInfo.dart';
import '../entities/announce_ment.dart';
import '../entities/modules_config/king_kong_model.dart';
import '../entities/modules_config/notice_model.dart';
import '../utils/ads_manage/ads_response_model.dart';
import '../utils/text_util.dart';
import 'dart:convert' as convert;

import '../values/config.dart';
import 'package:comics_app/pages/image/network/network_image_urls.dart';

class ConfigStore extends GetxController {
  static ConfigStore get to => Get.find();

  bool get isRelease => const bool.fromEnvironment("com.comics");
  PackageInfo? _packageInfo; // 包信息
  String get version => _packageInfo?.version ?? ""; //版本信息

  late ConfigBean configBean; //全局配置信息
  String? deviceId; //设备id(为了保证一定能取到deviceId，请通过 getUniqueId获取)

  /// 通过 [ConfigApi.getAdsList] 拉到的广告数据
  AdsResponseModel? adsResponse;

  /// 通过 [ConfigApi.getAnnounceScrollingLight] 拉到的公告 / 跑马灯列表
  List<NoticeModel> noticeList = const <NoticeModel>[];

  /// 通过 [ConfigApi.getKingKongList] 拉到的金刚区按钮列表
  List<KingKongModel> kingKongList = const <KingKongModel>[];

  Map<String?, bool?>? shortVideoLike = {};
  Map<String?, int?>? shortVideoLikeCount = {};

  List<String>? shortVideoPaied = [];

  List<String> shortVideoFollow = [];

  StreamController<bool>? showControlStreamController =
      StreamController.broadcast();

  StreamController<bool>? autoPlayStreamController =
      StreamController.broadcast();

  Announcement? homePageAnnounceMent;

  // late Mixpanel mixpanel;

  // Future<void> initMixpanel() async {
  //   mixpanel = await Mixpanel.init("914ee8b943e79d2c357256b878239093",
  //       trackAutomaticEvents: true);
  // }

  void trackData(String eventName, Map map) {
    /*Map userInfoMap = {};
    userInfoMap["用户名称"] =  UserStore.to.getUserInfoModel?.name ?? 0;
    userInfoMap["用户ID"] =  UserStore.to.getUserInfoModel?.uid ?? 0;
    userInfoMap["用户设备ID"] =  UserStore.to.getUserInfoModel?.devID ?? 0;
    userInfoMap["VIP"] =  UserStore.to.isVip();

    ConfigStore.to.mixpanel.track(eventName, properties: {
      "用户信息":
      userInfoMap,
      eventName : map,
    });

    debugPrint("埋点统计--------$map");*/
  }

  Map getClickProductInfoMap(MediaList mediaList, String? linkName) {
    Map map = {};

    map["名称"] = mediaList.title;
    map["类型"] = getProductName(mediaList.kind);
    map["价格"] = getProductPriceType(mediaList.permission ?? 0);

    map["链路"] = linkName ?? "";

    return map;
  }

  @override
  void onInit() {
    super.onInit();
    getPlatform(); //获取包信息
    // initMixpanel();
  }

  //获取包信息
  Future<PackageInfo?> getPlatform() async {
    _packageInfo = await PackageInfo.fromPlatform();
    update();
    return _packageInfo;
  }

  static const String _appConfigGroupKey = 'APP';

  /// 与后端 `config/query` 约定：同一 `key` 参数内多个配置名用英文逗号分隔。
  static const String _appConfigQueryKeySeparator = ',';

  /// `groupKey=App` 时需一并传入的配置项名列表。
  static const List<String> _appBootstrapKeys = <String>[
    'chatUrl',
    'shareUrl',
    'lastVersion',
    'videoBaseUrl',
    'picBaseUrl',
    'imageSecret',
    'payChannelCode',
    'payWaitHint',
    'uploadUrl',
    'commentLimit',
    'postingLimit',
    'msgFilter',
    'msgFilterTip',
    'maxImgSize',
    'maxVideoSize',
    'freeVipMaxDown',
    'maxImgNum',
    'freeRechargedMsg',
    'maxPositionTitleWordNum',
    'maxPostingContentWordNum',
    'maxFreeUserPlay',
    'payBackTip',
    'downTip',
    'rewardTip',
    'postingCheckingTip',
    'seeVipPostingTip',
    'addGoldPostingTip',
    'addVipPostingTip',
    'withdrawRule',
    'withdrawVideoRule',
    'withdrawInvitaRule',
    'minWithdraw',
    'minWithdrawVideo',
    'minWithdrawInvita',
    'cardGold',
    'vipCardGold',
    'payCardGold',
    'cardDemandGold',
    'payCardDemandGold',
    'homePage',
    'lastVersionA',
    'language',
    'languageUrl',
    'canTipJumpToRecharge',
    'canTipJumpToInvitation',
    'adDownloadTip',
    'iosDownloadTip',
    'maxFreeUserPlayTip',
    'canDownTipJumpToRecharge',
    'canDownTipJumpToInvitation',
    'canVipTipJumpToRecharge',
    'canVipTipJumpToInvitation',
    'show_actor',
    'game_type',
    'gameConfig',
    'colTip',
    'colLimit',
    'colLimit_vip',
    'uploadLogBaseUrl',
    'goldProductTip',
    'goldProductTipTitle',
    'jumpApi',
    'uploadPage',
    'canGoldTipJumpToRecharge',
    'canGoldTipJumpToInvitation',
    'goldTip',
    'headImgPrefix',
    'mp4Domain',
    'authTip',
    'payGoldBtnMsg',
    'maxLevelBack',
    'levelBack',
    'agentLevel',
    'newVideoBaseUrl',
    'newPicBaseUrl',
    'newVideoUrl',
    'uploadVideoUrl',
    'userUploadGoldMin',
    'userUploadGoldMax',
    'userUploadFreeVodTip',
    'userUploadFreeVipTip',
    'userUploadFreeGoldTip',
    'userUploadGoldAuthTip',
    'userUploadRule',
    'newH5ImageSecret',
    'chatUploadUrl',
    'officialUrl',
    'testJWTToken',
    'pcPlayUrl',
    'pictureUrls',
    'h5HomePage',
    'iosLastVersion',
    'pc_play_line',
    'h5_play_line',
    'todayFreeUserPlay',
    'playLinePoll',
    'chatUrlPrefix',
    'reportReason',
    'signInRule',
    'signInReward',
    'beforeUplodTip',
    'openRecommendExplore',
    'card_paySuccessTip',
    'card_unPayTip',
    'card_authTip',
    'card_home_unPayTip',
    'card_uploadUrl',
    'POSTING_HOT',
    'playLines',
    'userUploadPostingFreeTip',
    'userUploadPostingVipTip',
    'userUploadPostingGoldTip',
    'addGoldPostingLimitTip',
    'postingLinkedTip',
    'cms_preview',
    'postingAnswerTip',
    'cmsURTip',
    'ads_cc_range',
    'ads_guess_like',
    'collection',
    'collectionTip',
    'liveLinked',
    'gameTip',
    'cms_explore_ar',
    'postingGoldTip',
    'postingRequestTip',
    'withdrawAmounts',
    'withdrawAmountTip',
    'withdrawAmountRule',
    'OpenCheckCode',
    'OpenGame2',
    'withdrawalSupportType',
    'banks',
    'gameBroadcast',
    'gameBillCheckTip',
    'gameUnwithdrawTip',
    'officialCommunity',
    'businessCooperation',
    'chatDomain'
  ];

  /// 'adsSlotCode' 需要一并传入的广告位编码
  static const List<String> _adsSlotCodeKeys = <String>[
    'OpenScreen', //启动页广告
    'INDEX_TIP', //首页弹窗广告
    'INDEX_TIP_GUILD', //首页九宫格弹窗广告
    'INDEX_FIX', //首页悬浮窗广告
    'SIDE_BANNER', //侧边导航栏广告（小banner轮播广告）
    'BANNER', //主页/暗网/社区，一级分类下的广告（大banner轮播广告、双排头像广告）   导航栏
    'DB_LINE_HEAD', //主页/暗网/社区，一级分类下的广告（大banner轮播广告、双排头像广告）   双头像
    'BANNER_SEARCH', //搜索页广告（小banner轮播广告，双排头像广告）导航栏
    'DB_LINE_HEAD_SEARCH', //搜索页广告（小banner轮播广告，双排头像广告）双头像
    'BANNER_PLAY', //长视频播放页广告（小banner轮播广告，双排头像广告）导航栏
    'DB_LINE_HEAD_PLAY', //长视频播放页广告（小banner轮播广告，双排头像广告）双头像
    'BANNER_POSTING', //帖子详情页广告（小banner轮播广告，双排头像广告）导航栏
    'DB_LINE_HEAD_POSTING', //帖子详情页广告（小banner轮播广告，双排头像广告）双头像
    'BANNER_MY', //我的页面广告（小banner轮播广告，双排头像广告）导航栏
    'DB_LINE_HEAD_MY', //我的页面广告（小banner轮播广告，双排头像广告）双头像
    'BANNER_APP', //推荐应用 导航栏
    'ICON_APP', //推荐应用 应用图标
    'AI_BANNER', //AI首页顶部广告
    'GAMING_APPS', //社区-游戏-应用图标
    'YUEHUI_BANNER', //约会首页 banner
  ];

  //保存配置信息
  Future<ConfigBean> saveConfigBean() async {
    final String queryKey = _appBootstrapKeys.join(_appConfigQueryKeySeparator);
    final ConfigBean config = await ConfigApi.getConfig(
      groupKey: _appConfigGroupKey,
      key: queryKey,
    );
    await getAdsData();
    await getAnnounceData();
    await getKingKongData();
    configBean = config;
    syncAddressBaseImagePathFromConfig(config);

    if (configBean.shareUrl != null) {
      Address.shareUrlLink = configBean.shareUrl;
    }
    if (configBean.uploadUrl != null) {
      Address.uploadUrl = configBean.uploadUrl;
    }
    if (configBean.chatUploadUrl != null) {
      Address.chatUploadUrl = configBean.chatUploadUrl;
    }
    if (configBean.pictureUrlsList != null) {
      Address.pictureLines = configBean.pictureUrlsList ?? [];
      final String? selectedPictureLine = Address.pictureLine?.trim();
      if (selectedPictureLine != null &&
          selectedPictureLine.isNotEmpty &&
          Address.pictureLines!
              .any((e) => e.line?.trim() == selectedPictureLine)) {
        Address.baseImagePath = selectedPictureLine;
      } else if (Address.pictureLines!.isNotEmpty) {
        final String? firstLine = Address.pictureLines!.first.line?.trim();
        if (firstLine != null && firstLine.isNotEmpty) {
          Address.pictureLine = firstLine;
          Address.baseImagePath = firstLine;
        }
      }
    }
    if (configBean.h5PlayLineList != null) {
      Address.h5PlayLines = configBean.h5PlayLineList ?? [];
      final String? selectedLine = Address.h5PlayLine?.trim();
      if (selectedLine != null &&
          selectedLine.isNotEmpty &&
          !Address.h5PlayLines!.any((e) => e.line?.trim() == selectedLine)) {
        Address.h5PlayLine = null;
      }
    }
    if (configBean.playLinesList != null) {
      Address.qvPlayLines = configBean.playLinesList ?? [];
    }

    if (configBean.aiUndressPrice != null) {
      Config.aiUndressPrice = configBean.aiUndressPrice.toString();
    }
    if (configBean.aiChangeFaceImgPrice != null) {
      Config.aiChangeFaceImgPrice = configBean.aiChangeFaceImgPrice;
    }

    if (configBean.advanceStatus != null) {
      // PreSaleGlobalInfo().storagePreSaleInfo(configBean.advanceStatus!);
    }

    if (configBean.backgroundTheme != null) {
      Config.appTheme = configBean.backgroundTheme ?? 0;

      dynamicChangeIcon();
    }
    return config;
  }

  Future<AdsResponseModel?> getAdsData() async {
    final String adsSlotCodeKey =
        _adsSlotCodeKeys.join(_appConfigQueryKeySeparator);
    l.d('getAdsData()...request adsSlotCode=$adsSlotCodeKey', tag: 'ads');
    try {
      final BaseRespBean resp =
          await ConfigApi.getAdsList(adsSlotCode: adsSlotCodeKey);
      // 广告接口业务主数据在 `result` 字段；`data` 实际是 slotConfigs 元数据 List。
      final dynamic raw = resp.result;
      l.d(
        'getAdsData()...resp.result type=${resp.result.runtimeType}, '
        'resp.data type=${resp.data.runtimeType}, '
        'picked type=${raw.runtimeType}, '
        'keys=${raw is Map ? raw.keys.toList() : '(not a Map)'}',
        tag: 'ads',
      );

      Map<String, dynamic>? payload;
      if (raw is Map) {
        payload = Map<String, dynamic>.from(raw);
      }

      if (payload != null) {
        l.d('getAdsData()...payload top-level keys=${payload.keys.toList()}',
            tag: 'ads');
        adsResponse = AdsResponseModel.fromJson(payload);
      } else {
        l.d('getAdsData()...payload is null, use empty AdsResponseModel',
            tag: 'ads');
        adsResponse = const AdsResponseModel();
      }
      final Map<String, int> slotCounts = <String, int>{
        for (final entry in adsResponse!.slotAds.entries)
          entry.key: entry.value.length,
      };
      l.d(
        'getAdsData()...parsed adsResponse slotAds=$slotCounts, '
        'slotConfigs=${adsResponse!.slotConfigs.length}, '
        'BANNER count=${adsResponse!.getBySlotCode('BANNER').length}',
        tag: 'ads',
      );
      update();
      return adsResponse;
    } catch (e, s) {
      l.d('getAdsData()...error: $e\n$s', tag: 'ads');
      return null;
    }
  }

  /// 拉取公告 / 跑马灯数据（`ads/notice/list`），结果存入 [noticeList] 并触发 [update]。
  Future<List<NoticeModel>> getAnnounceData() async {
    noticeList = await ConfigApi.getAnnounceScrollingLight();
    update();
    return noticeList;
  }

  /// 拉取金刚区按钮（`ads/kingKong/list`），结果存入 [kingKongList] 并触发 [update]。
  Future<List<KingKongModel>> getKingKongData() async {
    kingKongList = await ConfigApi.getKingKongList();
    update();
    return kingKongList;
  }

  //获取设备信息
  Future<String> getDevType() async {
    String devType = "";
    const bool kIsWeb = identical(0, 0.0);
    try {
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      if (kIsWeb) {
        var deviceData = await deviceInfoPlugin.webBrowserInfo;
        devType = "${deviceData.appName}:${deviceData.appVersion}";
      } else {
        if (Platform.isAndroid) {
          var androidInfo = await deviceInfoPlugin.androidInfo;

          devType =
              "${androidInfo.device}:${androidInfo.version.sdkInt}:id=${androidInfo.id}";

          //devType = "${androidInfo.device}:${androidInfo.version.sdkInt}";
        } else if (Platform.isIOS) {
          var iosInfo = await deviceInfoPlugin.iosInfo;
          devType = "${iosInfo.systemName}:${iosInfo.systemVersion}";
        }
      }
    } catch (e) {
      l.d("getDevType()...error:$e", tag: "devtype");
    }
    return devType;
  }

  dynamicChangeIcon() {
    const platform = MethodChannel('samples.flutter.io/requestApi');
    platform.invokeMethod(
        'dynamicChangeIcon', {"isOriginIcon": !Config.isNewYearTheme()});
  }

  //获取设备类型
  String getSysType() {
    if (GetPlatform.isWeb) {
      return 'ios';
    } else {
      return Platform.operatingSystem;
    }
  }

  //获取设备ID
  Future<String> getUniqueId() async {
    var deviceStr = '';

    try {
      await DeviceIdentity.register();
      var plugin = DeviceInfoPlugin();
      var androidInfo = await plugin.androidInfo;
      var sdkInt = androidInfo.version.sdkInt;
      if (sdkInt >= 29) {
        deviceStr = await DeviceIdentity.oaid;
        if (deviceStr == "00000000-0000-0000-0000-000000000000" ||
            TextUtil.isEmpty(deviceStr) ||
            TextUtil.isOnlyContainZero(deviceStr)) {
          deviceStr = await getDeviceId(plugin);
        }
      } else {
        deviceStr = await DeviceIdentity.imei;
        if (deviceStr.isEmpty) {
          deviceStr = await DeviceIdentity.oaid;
        }
        if (deviceStr == "00000000-0000-0000-0000-000000000000" ||
            TextUtil.isEmpty(deviceStr) ||
            TextUtil.isOnlyContainZero(deviceStr)) {
          deviceStr = await DeviceIdentity.androidId;
        }
        if (TextUtil.isEmpty(deviceStr)) {
          deviceStr = await getDeviceId(plugin);
        }
      }
    } catch (e) {
      deviceStr = const Uuid().v4();
    }
    deviceStr = deviceStr.removeAllWhitespace;
    return 'yjmh_$deviceStr';
  }

  Future<String> getDeviceId(DeviceInfoPlugin plugin) async {
    var deviceStr = await lightKV.getString("device_id");
    if (TextUtil.isNotEmpty(deviceStr)) return deviceStr!;
    try {
      final androidInfo = await plugin.androidInfo;

      final androidid = await DeviceIdentity.androidId;

      if (TextUtil.isNotEmpty(androidid)) {
        deviceStr = "${androidInfo.brand}_$androidid";
      }
      if (TextUtil.isEmpty(deviceStr)) {
        deviceStr = const Uuid().v4();
      }
    } catch (e) {
      deviceStr = const Uuid().v4();
    }
    await lightKV.setString("device_id", deviceStr);
    return deviceStr!;
  }

  ///获取渠道
  Future<String?> getChannel() async {
    String? channel;
    if (GetPlatform.isAndroid) {
      const platform = MethodChannel("com.yaoJin/device");
      try {
        channel = await platform.invokeMethod("getChannel");
      } on PlatformException catch (e) {
        channel = "";
        debugPrint(e.toString());
      }
    }
    return channel;
  }

  Future getCutInfo() async {
    String? cutInfos = "";
    /*try {
      var channel = await getChannel();
      if (channel != null && channel != "") {
        // await showConfirm(context, title: "检测到渠道号:$channel");
        CutInfo cutInfo = CutInfo()..dc = channel;
        cutInfos = json.encode(cutInfo.toJson());
      } else {
        ClipboardData? clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
        if (TextUtil.isNotEmpty(clipboardData!.text!)) {
          cutInfos = clipboardData.text;
        }
      }

    } catch (e) {
      l.d('getChannel$e',);
    }*/
    try {
      if (kIsWeb) {
        String routePath = Get.currentRoute;
        int index = routePath.indexOf("?");
        var obj = {};
        if (index > -1) {
          String newRoutePath = routePath.substring(index + 1);
          List params = newRoutePath.split("&");
          for (var e in params) {
            obj[e.split("=")[0]] = e.split('=')[1];
          }
          cutInfos = convert.jsonEncode(obj);
          l.d("粘贴板内容: $cutInfos");
        }
      } else {
        ClipboardData? clipboardData =
            await Clipboard.getData(Clipboard.kTextPlain);
        if (TextUtil.isNotEmpty(clipboardData?.text ?? "")) {
          cutInfos = clipboardData?.text ?? "";
        }
      }
      return cutInfos;
    } catch (e) {
      return cutInfos;
    }
  }
}
