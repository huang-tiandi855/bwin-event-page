import 'dart:async';
import 'dart:math';

import 'package:chewie/chewie.dart' hide MaterialControls;
import 'package:comics_app/common/apis/apis.dart';
import 'package:comics_app/common/apis/home_apis.dart';
import 'package:comics_app/common/apis/media_api.dart';
import 'package:comics_app/common/apis/mine_apis.dart';
import 'package:comics_app/common/entities/mine/vip_card_model.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/entities/media_info.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/store/event_tracking_manager.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/utils/utils.dart';
import 'package:comics_app/common/values/enum.dart';
import 'package:comics_app/common/widgets/memberPaying.dart';
import 'package:comics_app/common/widgets/space_widget.dart';
import 'package:comics_app/pages/video_page/material_controls.dart';
import 'package:comics_app/pages/video_page/player_float/video_player_cover_placeholder.dart';
import 'package:comics_app/short_video/player/short_video_player.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';
import '../../common/widgets/common_dialog/choose_audio_dialog.dart';
import 'player_code_manage.dart';
import 'video_page_state.dart';

class VideoPageLogic extends GetxController
    with GetSingleTickerProviderStateMixin, WidgetsBindingObserver {
  final VideoPageState state = VideoPageState();

  int? get _mediaAuthCode => state.mediaInfo?.code;

  bool get shouldShowVipPlayerOverlay =>
      PlayerCodeManage.requiresMemberPay(_mediaAuthCode);

  bool get shouldShowGoldPlayerOverlay =>
      PlayerCodeManage.requiresGoldPay(_mediaAuthCode);

  /// 用户当前持有的观影券数量（来自 [UserStore.getUserInfoModel.movieTickets]）。
  /// 0 / null 走原 1008 / 1038 路径。
  int get _userMovieTickets => UserStore.to.getUserInfoModel?.movieTickets ?? 0;

  /// 1008 / 1038 鉴权拦截时是否前置展示观影券浮层。
  ///
  /// 同时成立才放出来：
  /// 1. 命中 1008 / 1038（[shouldShowVipPlayerOverlay] /
  ///    [shouldShowGoldPlayerOverlay]）；
  /// 2. 用户持有观影券（`movieTickets > 0`）。
  ///
  /// 任一不满足即回退到原 [VipPlayerOverlay] / [GoldPlayerOverlay]。
  /// 浮层无 dismiss 流程 ——「跳过预览」是 UI 装饰，唯一退出路径是用券。
  bool get shouldShowMovieTicketOverlay {
    if (_userMovieTickets <= 0) return false;
    return shouldShowVipPlayerOverlay || shouldShowGoldPlayerOverlay;
  }

  void _syncCanPlayFromMediaCode() {
    state.isCanPlay = PlayerCodeManage.canPlay(_mediaAuthCode);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state1) {
    switch (state1) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed: // 应用程序可见，前台
        state.isSurface = true;

        /*if(state.chewieController != null){
          state.chewieController?.play();
        }*/

        break;
      case AppLifecycleState.paused: // 应用程序不可见，后台

        /*state.isSurface = false;

        if (state.chewieController != null) {
          state.chewieController?.pause();
          state.videoPlayerController?.pause();
        }*/

        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
    }
  }

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addObserver(this); // 添加观察者监听
    state.mediaInfoId = Get.arguments?["id"] ?? "";
    if (Get.arguments["isFreeZoneArgs"] == null) {
      state.isFreeZoneArgs = false;
    } else {
      state.isFreeZoneArgs = true;
    }
    var data = HistoryOperation.getInstance()?.queryMediaHistoryById(
        HistoryRecordType.video, state.mediaInfoId ?? "");
    printInfo(info: "data===>$data");
    if (data != null) {
      state.historyDuration = data["duration"] is int
          ? data["duration"] as int
          : int.tryParse('${data["duration"]}') ?? 0;
      state.index = state.oldEpisode = state.selectedEpisode =
          data["episode"] is int
              ? data["episode"] as int
              : int.tryParse('${data["episode"]}') ?? 0;
    }
    if (Get.arguments["selectedEpisode"] == null) {
      state.selectedEpisode = 0;
    } else {
      state.selectedEpisode = Get.arguments["selectedEpisode"];
    }

    state.isFullScreenAdvs = false;
    state.tabController =
        TabController(length: state.tabs.length, vsync: this, initialIndex: 0);
    state.tabController.addListener(() {
      state.isSendList = state.tabController.index == 1;
      update();
    });
    getAdvertisement();
    //verifyPlay();

    //_vipCutDownReq();

    getMediaInfo(state.selectedEpisode, true);

    getCountTime();

    /// 注册接收器
    ///
    /// register
    FBroadcast.instance().register("auto_play", (value, callback) {
      Wakelock.enable();
      chewiePlay();
    });

    _loadVipBannerCard();
  }

  /// 拉取会员卡列表，把首张卡的 [VipCardModel.name] 缓存到
  /// [VideoPageState.vipBannerCardName] 用于顶部 VIP 横幅展示。
  ///
  /// 失败 / 空列表时不写入，UI 层会回退到占位文案；用户已是会员
  /// （`UserStore.to.isVip()` 为 true）时横幅本身被隐藏，所以这里
  /// 即便取到值也不会展示。
  Future<void> _loadVipBannerCard() async {
    if (UserStore.to.isVip()) return;
    try {
      final List<VipCardModel> list = await MineApis.getVipCardList();
      if (list.isEmpty) return;
      final String? name = list.first.name;
      if (name == null || name.isEmpty) return;
      state.vipBannerCardName = name;
      update(['vipBanner']);
    } catch (e) {
      printInfo(info: '_loadVipBannerCard error: $e');
    }
  }

  void getCountTime() async {
    // Config.countdown = await WalletApi.vipCutDownReq();
    debugPrint("vgfheghieg");
  }

  Future<void> _reloadMediaAfterPay(int episode) async {
    final BaseRespBean resp =
        await MediaApi.getMediaInfo(state.mediaInfoId ?? '');
    await _applyMediaInfoResponse(resp, episode);
  }

  /// 把一份完整的 mediaInfo 响应应用到 state 并起播。
  ///
  /// 两个调用方：
  /// 1. [_reloadMediaAfterPay] —— 金币 / VIP 付费成功后走 [getMediaInfo] 拉
  ///    最新详情然后喂进来；
  /// 2. [purchaseCurrentVideoByMovieTicket] —— 观影券一次性票，直接拿
  ///    [MediaApi.videoTicketPay] 的响应喂进来。**绝对不能**再调
  ///    getMediaInfo 重拉，否则会被 1008/1038 拦回浮层（详见
  ///    [MediaApi.videoTicketPay] 注释）。
  Future<void> _applyMediaInfoResponse(BaseRespBean resp, int episode) async {
    state.mediaInfo = MediaInfo.fromJson(resp.toJson());
    _syncCanPlayFromMediaCode();
    state.selectedEpisode = episode;
    state.index = episode;
    if (state.isCanPlay == true) {
      await startVideoPlayer(episode);
    }
    update(['refreshVideo']);
  }

  /// 按详情接口 [MediaInfo.code] 鉴权：
  ///
  /// - 1008（[PlayerCodeManage.nonMember]）：弹「开通会员」 bottom sheet；
  /// - 1038（[PlayerCodeManage.noPay]） / 1035（[PlayerCodeManage.notEnoughGold]）：
  ///   不弹任何 bottom sheet，由 view 层 [GoldPlayerOverlay] 接管展示与按钮回调
  ///   （1038 → [purchaseCurrentVideoByGold]，1035 → [handleWalletPurchaseReturn]）；
  /// - 其它鉴权码：toast 提示并返回 false。
  Future<bool> checkPlayPermission(int index,
      [bool isSingleBuy = false]) async {
    state.index = index;
    final code = _mediaAuthCode;

    if (PlayerCodeManage.canPlay(code)) {
      state.isCanPlay = true;
      return true;
    }

    // 仅当服务端明确返回 isActive == false 时才视为「未上架」。
    // 旧写法 `content.isActive ?? false` 会把字段缺省 (null) 误判成未上架，
    // 导致接口未下发该字段时弹出错误提示。
    final content = state.mediaInfo?.data?.contents[index];
    if (content != null && content.isActive == false) {
      showToast(msg: '当前未上架');
      return false;
    }

    if (state.chewieController?.isFullScreen == true) {
      state.chewieController!.exitFullScreen();
    }

    if (code == PlayerCodeManage.nonMember) {
      EventTrackingManager().addVideoVipGraphicss(
        state.mediaInfo?.data?.id,
        state.mediaInfo?.data?.title,
        GraphicsType.vip,
      );
      final memberOk = await openMemberPaying(
        id: state.mediaInfo?.data?.id ?? '',
        title: content?.name ?? state.mediaInfo?.data?.title,
        isnovelOrComic: false,
        isShowCoupon: true,
        chatId: content?.id ?? '',
        productType: 28,
      );
      if (memberOk == PaySuccess.exchangeSuccessFullly) {
        await _reloadMediaAfterPay(index);
        return state.isCanPlay == true;
      }
      return false;
    }

    if (PlayerCodeManage.requiresGoldPay(code)) {
      // 1038 / 1035：交给 [GoldPlayerOverlay] 接管，不弹底层 bottom sheet。
      state.isCanPlay = false;
      update(['refreshVideo']);
      return false;
    }

    final tip = PlayerCodeManage.message(code);
    showToast(
      msg: tip.isNotEmpty
          ? tip
          : (state.mediaInfo?.msg ?? state.mediaInfo?.tip ?? '暂无播放权限'),
    );
    return false;
  }

  /// 长视频金币购买（对应详情 code == 1038）：
  ///
  /// - 接口成功：刷新用户金币，调 [_reloadMediaAfterPay] 重拉详情 + 起播；
  /// - 接口返回 1035（[PlayerCodeManage.notEnoughGold]）：把浮层切换到
  ///   「金币不足」形态（[VideoPageState.goldOverlayInsufficient] = true），
  ///   用户接下来点的就是「去充值」跳钱包；
  /// - 其它失败：toast 错误信息，浮层不动。
  Future<void> purchaseCurrentVideoByGold() async {
    final String? id = state.mediaInfo?.data?.id;
    if (id == null || id.isEmpty) {
      showToast(msg: '视频信息错误');
      return;
    }
    SmartDialog.showLoading();
    try {
      final BaseRespBean resp = await MediaApi.videoGoldPay(id);
      if (resp.isSuccess) {
        showToast(msg: '购买成功');
        state.goldOverlayInsufficient = false;
        await UserStore.to.refreshUser();
        await _reloadMediaAfterPay(state.selectedEpisode);
      } else if (resp.code == PlayerCodeManage.notEnoughGold) {
        // 余额不足：浮层切到「金币不足」形态，等用户「去充值」。
        state.goldOverlayInsufficient = true;
        await UserStore.to.refreshUser();
        update(['refreshVideo']);
      } else {
        showToast(msg: resp.tip ?? '购买失败');
      }
    } catch (e) {
      printInfo(info: 'purchaseCurrentVideoByGold error: $e');
      showToast(msg: '购买失败');
    } finally {
      SmartDialog.dismiss();
    }
  }

  /// 「使用观影券」按钮回调：调 [MediaApi.videoTicketPay] 扣 1 张观影券。
  ///
  /// 观影券是一次性票（详见 [MediaApi.videoTicketPay] 注释），扣券接口的
  /// 响应里**直接回写**了本次播放所需的全套 mediaInfo（含可播放的
  /// `realVideoUrl` 与可播放的 `code`）。所以这里**绝不能**走
  /// [_reloadMediaAfterPay] 那条 [getMediaInfo] 重拉的路径 —— 那条路径
  /// 会被同样的 1008/1038 鉴权码再次拦回观影券浮层，等于券白扣。
  ///
  /// 正确处理：直接把扣券响应喂给 [_applyMediaInfoResponse]，让它接管
  /// state 覆盖与起播；下次用户离开本页再进来时，[getMediaInfo] 仍然
  /// 会带回 1008/1038，符合「观影券一次只解一次」的产品约束。
  ///
  /// 不在这里处理「观影券不足」的形态切换 —— 入口处
  /// [shouldShowMovieTicketOverlay] 已经过滤掉 `movieTickets <= 0`，理论上
  /// 不会出现「打开了浮层但接口告诉你没券」的情况。如真有，按 toast 兜底。
  Future<void> purchaseCurrentVideoByMovieTicket() async {
    final String? id = state.mediaInfo?.data?.id;
    if (id == null || id.isEmpty) {
      showToast(msg: '视频信息错误');
      return;
    }
    SmartDialog.showLoading();
    try {
      final BaseRespBean resp = await MediaApi.videoTicketPay(id);
      if (resp.isSuccess) {
        showToast(msg: '解锁成功');
        await UserStore.to.refreshUser();
        await _applyMediaInfoResponse(resp, state.selectedEpisode);
      } else {
        showToast(msg: resp.tip ?? '解锁失败');
      }
    } catch (e) {
      printInfo(info: 'purchaseCurrentVideoByMovieTicket error: $e');
      showToast(msg: '解锁失败');
    } finally {
      SmartDialog.dismiss();
    }
  }

  Future<void> openDirectory() async {
    var index = await openChooseAudioItemDialog(
        info: state.mediaInfo!.data!, currentIndex: 0);
    if (index != null && index is int) {
      clickItem(index);
    }
  }

  Future<bool> clickItem(int index) async {
    bool isOk = await checkPlayPermission(index);
    if (isOk) {
      if (state.selectedEpisode != index) {
        if (state.chewieController != null) {
          state.chewieController!.dispose();
          state.chewieController = null;
        }

        if (state.videoPlayerController != null) {
          state.videoPlayerController!.dispose();
          state.videoPlayerController = null;
        }
        startVideoPlayer(index);
      }
      EventTrackingManager().addEpisodeVideoDatas(
        state.mediaInfo?.data?.id,
        state.mediaInfo?.data?.title,
      );
    }
    return isOk;
  }

  void getAdvertisement() {
    // state.videoAdvertisement = getAdsByType(AdsType.banner);
    state.videoAdvertisement = <AdsInfoList>[];

    if (state.videoAdvertisement.isNotEmpty) {
      state.randomAds = Random().nextInt(state.videoAdvertisement.length);
    } else {
      state.isCloseAdvs = true;
      state.isAutoPlay = true;
    }

    if (state.videoAdvertisement.isNotEmpty &&
        ConfigStore.to.configBean.adsTimeLongVideo != 0) {
      startTimer();
    }
  }

  void initPlayer() async {
    update();
  }

  Future verifyPlay() async {
    BaseRespBean baseRespBean = BaseRespBean(0);
    // BaseRespBean baseRespBean =
    //     await CircleApi.ticketPurchasePaying(state.mediaInfoId!);
    if (baseRespBean.isSuccess) {
      if (baseRespBean.data["isCan"] == true) {
        //state.isCanPlay = true;
      }
    }
  }

  bool isBeforeToday(String time) {
    if (time != "0001-01-01T00:00:00Z") {
      var startDate = time;
      var endDate = DateTime.now();
      return DateTime.parse(startDate).isBefore(endDate);
    } else {
      return true;
    }
  }

  String get videoCover {
    final info = state.mediaInfo?.data;
    if (info == null) return '';
    if (info.autoCover.isNotEmpty) return info.autoCover;
    if (info.horizontalCover?.isNotEmpty == true) return info.horizontalCover!;
    return info.verticalCover ?? '';
  }

  //初始化数据
  Future getMediaInfo(int episode, isNeedInit) async {
    printInfo(info: "getMediaInfo==>$episode");

    if (isNeedInit) {
      try {
        final BaseRespBean resp =
            await MediaApi.getMediaInfo(state.mediaInfoId ?? '');
        state.mediaInfo = MediaInfo.fromJson(resp.toJson());
      } catch (e) {
        printInfo(info: 'getMediaInfo error: $e');
      }
      state.isCollected = state.mediaInfo?.data?.mediaStatus?.hasCollected;
      state.isLike = state.mediaInfo?.data?.mediaStatus?.hasLiked;
      state.countLike = state.mediaInfo?.data?.countLike;
      state.countCollect = state.mediaInfo?.data?.countCollect;
      state.countComment.value = state.mediaInfo?.data?.countComment ?? 0;
      loadGuessLike(isRefresh: true);
      // 详情拉回（含鉴权 code）后立刻刷新外层 GetBuilder，避免 1008/1038 等鉴权
      // 分支早退时页面一直停在 `mediaInfo == null` 的 LoadingWidget。
      update();
    }

    _syncCanPlayFromMediaCode();
    state.selectedEpisode = episode;
    state.index = episode;

    if (PlayerCodeManage.isAuthCode(_mediaAuthCode)) {
      state.isCanPlay = false;
      state.chewieController?.dispose();
      state.chewieController = null;
      state.videoPlayerController?.dispose();
      state.videoPlayerController = null;
      update();
      update(['refreshVideo']);
      return;
    }

    // 长视频 ExoPlayer 不进短视频池；清空池槽（会回调各列表 detach）。
    await ShortVideoPlayerPool.instance.releaseAll();
    if (isClosed) return;

    state.videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(
        state.mediaInfo!.data!.contents[episode].realVideoUrl,
      ),
    );

    await state.videoPlayerController?.initialize().then((value) {
      update();
    });

    // 视频 aspect 取值：解码器报出来的 `value.size` 优先（两端 plugin 都已
    // 把 rotation 90/270 时的 width/height swap 完，所以是渲染后尺寸），后端
    // `content.ratio` 兜底，最后落到 16/9。`rotationCorrection` 仅会在视频
    // 是 180° 颠倒时出现，swap 留着保险。
    final VideoPlayerValue playerValue = state.videoPlayerController!.value;
    final Size playerSize = playerValue.size;
    final int rotation = playerValue.rotationCorrection;
    final bool swapSides = rotation == 90 || rotation == 270;
    final double effectiveWidth =
        swapSides ? playerSize.height : playerSize.width;
    final double effectiveHeight =
        swapSides ? playerSize.width : playerSize.height;
    final double playerAspect = (effectiveWidth > 0 && effectiveHeight > 0)
        ? (effectiveWidth / effectiveHeight)
        : 0;
    final double backendRatio =
        state.mediaInfo?.data?.contents[episode].ratio ?? 0;
    final bool backendRatioValid = backendRatio > 0 && backendRatio != 1.0;
    final double trueAspect = playerAspect > 0
        ? playerAspect
        : (backendRatioValid ? backendRatio : 16 / 9);

    // —— 全屏方向判定：直接看「未全屏时是否两侧黑边」——
    //
    // 未全屏的播放器是固定 `screenWidth × 212.w` 容器（设计稿 375×812 下高度
    // 就是 212 px），`containerAspect` ≈ `screenWidth / 212`。当
    // `videoAspect < containerAspect` 时，BoxFit.contain 会让视频在两侧留下
    // 黑边 —— 这种视频在视觉上偏竖向，全屏后保持竖屏；否则进横屏全屏。
    //
    // 这条规则对几种容易出错的视频更友好：
    //   * 严格竖版 (aspect < 1) → 必然两侧黑边 → 竖屏全屏 ✓
    //   * 视频文件像素 1920×1080 但内容居中竖向 + 黑边（rotation 元数据丢失）
    //     这种 `value.size` 报横向、但 backend 通常会把 `ratio` 填成视觉值，
    //     即使 backend 也错了，「容器比对」也能把它兜回竖屏。
    //   * 标准 16:9 (aspect ≈ 1.77) → 与容器贴合（差距在 0.01 之内）→ 横屏全屏 ✓
    final double containerHeight = 212.w;
    final double containerWidth = ScreenUtil().screenWidth;
    final double containerAspect =
        containerHeight > 0 ? containerWidth / containerHeight : 16 / 9;
    // 容器跟 16:9 视频的浮点误差也就 0.01，留 0.02 容差避免把 16:9 误判成竖版。
    final bool isPortraitVideo = trueAspect < containerAspect - 0.02;

    if (kDebugMode) {
      // ignore: avoid_print
      print(
        '[VideoPage] aspect → backend=$backendRatio '
        'size=${playerSize.width}x${playerSize.height} rot=$rotation '
        'video=$trueAspect container=$containerAspect portrait=$isPortraitVideo',
      );
    }

    late final ChewieController chewieController;
    chewieController = ChewieController(
      videoPlayerController: state.videoPlayerController!,
      autoPlay: state.isAutoPlay,
      looping: true,
      aspectRatio: trueAspect,
      // 全屏方向自己定，不让 chewie 默认行为再去读一次 `value.size` ——
      // 在路由 push 那一帧 size 偶发读到 0×0 时，chewie 会落到「方形」分支
      // 直接 `DeviceOrientation.values`，由于 App 进程级锁了 portrait
      // （`Injection.init` 里 `setPreferredOrientations([portraitUp])`），
      // 结果就是横版视频进全屏后仍然停在竖屏。
      deviceOrientationsOnEnterFullScreen: isPortraitVideo
          ? const [
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]
          : const [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ],
      // 退出全屏锁回竖屏，跟 [Injection.init] 启动策略对齐。chewie 默认值
      // `DeviceOrientation.values` 会把 4 方向都打开，会让长视频详情页之后
      // 的任意页面出现非预期的横屏。
      deviceOrientationsAfterFullScreen: const [DeviceOrientation.portraitUp],
      autoInitialize: true,
      placeholder: VideoPlayerCoverPlaceholder(
        chewieControllerProvider: () => chewieController,
        coverUrl: videoCover,
      ),
      customControls: MaterialControls(
        title: state.mediaInfo?.data?.title,
      ),
      allowMuting: false,
      showOptions: false,
    );
    state.chewieController = chewieController;

    if (!state.isCloseAdvs!) {
      state.chewieController?.pause();
    } else {
      chewiePlay();
    }

    state.videoPlayerController?.addListener(() async {
      if (state.videoPlayerController == null) {
        return;
      }

      // 「路由级播放守卫」：每当播放器状态变化（包括 initialize 完成、第一次
      // isPlaying=true 等），就检查当前路由是否仍是长视频详情页。
      // 用户在视频未加载完时点头像跳到用户主页 → 视频迟到加载完成自动播放，
      // 此时 [Get.currentRoute] 已不是 [AppRoutes.VIDEO_PAGE]，立刻按下 pause。
      // 同时允许 chewie 全屏路由（chewie 用未命名 MaterialPageRoute push 全屏，
      // 此时 currentRoute 不是 /video_page），因此追加 isFullScreen 兜底。
      final bool isPlayingNow =
          state.videoPlayerController?.value.isPlaying ?? false;
      if (isPlayingNow && !_isOnVideoPageRoute()) {
        await state.chewieController?.pause();
        await state.videoPlayerController?.pause();
        return;
      }

      int currentPosition =
          state.videoPlayerController!.value.position.inSeconds;

      if (state.isCanPlay!) {
        if (state.videoPlayerController!.value.position.inSeconds >
            ((state.videoPlayerController!.value.duration.inSeconds) * 0.1)) {
          EventTrackingManager().addVideoDatas(
              state.mediaInfo?.data?.id, state.mediaInfo?.data?.title);
        }

        return;
      }
      printInfo(
          info:
              "data==>duration==>${state.oldEpisode}==${state.index}====$currentPosition");
      if (state.historyDuration != null &&
          currentPosition < state.historyDuration! &&
          !state.showHistory) {
        state.showHistory = true;
        update(["refreshVideo"]);
      } else if (state.showHistory) {
        state.showHistory = false;
        update(["refreshVideo"]);
      }
    });

    Wakelock.enable();
    update();
    //update(["refreshVideo"]);
  }

  Future<void> showVipDialog() async {
    if (state.hasShowDialog == true) return;
    state.hasShowDialog = true;
    await state.chewieController?.pause();
    await checkPlayPermission(state.selectedEpisode);
    state.hasShowDialog = false;
  }

  Future<void> showGoldenDialog() async {
    if (state.hasShowDialog == true) return;
    state.hasShowDialog = true;
    await state.chewieController?.pause();
    await checkPlayPermission(state.selectedEpisode);
    state.hasShowDialog = false;
  }

  /// 用户从「金币不足」浮层「去充值」跳 [AppRoutes.WALLET] 返回后的处理：
  ///
  /// 1. 拉一次最新用户信息（金币 / VIP 等），保证浮层显示的「剩余金币数」是
  ///    充值后的最新值；
  /// 2. 比较「用户当前金币」与「视频解锁所需金币」：
  ///    - 用户金币 ≥ 视频金币：把浮层切回「金币付费」形态
  ///      （[VideoPageState.goldOverlayInsufficient] = false），等用户主动点
  ///      「{price}金币观看」时再由 [purchaseCurrentVideoByGold] 走 [videoGoldPay]
  ///      （我们故意不自动扣费，避免「跳出钱包就被扣费」的体感）；
  ///    - 用户金币 < 视频金币：保持「金币不足」形态，toast 提示。
  Future<void> handleWalletPurchaseReturn() async {
    await UserStore.to.refreshUser();
    final int userGold = UserStore.to.getUserInfoModel?.walletApp ?? 0;
    final int videoGold = state.mediaInfo?.data?.price ?? 0;
    if (userGold >= videoGold) {
      state.goldOverlayInsufficient = false;
    } else {
      showToast(msg: '金币仍不足，请充值后再试');
    }
    update(['refreshVideo']);
  }

  /// 「恢复播放」入口：被 `auto_play` 广播（全屏切换、广告关闭等）以及
  /// `startVideoPlayer` 末尾、付费成功回调 等多个场景调用。
  ///
  /// **不在这里触发付费 / 未上架等鉴权弹窗**：这些场景都不是「用户主动点击播放」，
  /// 重复走 [checkPlayPermission] 会导致全屏切换后弹「当前未上架」/ 反复弹付费框
  /// 的体验问题。真实鉴权由用户主动入口负责（[clickItem] 选集、
  /// [showVipDialog] / [showGoldenDialog]、浮层解锁按钮等）。
  Future chewiePlay() async {
    if (state.chewieController == null) return;
    if (state.isCanPlay != true) {
      await state.chewieController?.pause();
      return;
    }
    // 页面已被覆盖（用户跳到用户主页等），视频此刻才完成初始化时不要自动外放。
    if (!state.isPageActive) {
      await state.chewieController?.pause();
      return;
    }
    if (state.isSurface) {
      await state.chewieController?.play();
    }
  }

  /// 暂停当前长视频播放器（chewie / underlying VideoPlayer 都按下暂停），
  /// 并把 [VideoPageState.isPageActive] 置为 false。
  ///
  /// 由 view 端 RouteAware.didPushNext 在「页面被新路由覆盖」时调用。
  /// 之所以**同时**写入 `isPageActive = false`：用户在视频还没初始化完时点
  /// 头像跳走，[chewieController] / [videoPlayerController] 可能尚未创建，
  /// 单纯调 `pause()` 不会生效；后续 [startVideoPlayer] / [chewiePlay] 会
  /// 读 `isPageActive` 并自我跳过 play，避免视频加载完成后在后台开始外放
  /// 声音。
  Future<void> pausePlayer() async {
    state.isPageActive = false;
    try {
      await state.chewieController?.pause();
    } catch (_) {}
    try {
      if (state.videoPlayerController?.value.isPlaying == true) {
        await state.videoPlayerController?.pause();
      }
    } catch (_) {}
  }

  /// 标记页面恢复到最顶层（路由层面）。**不**主动恢复播放，避免和已有的
  /// auto_play 广播 / 付费成功后重启播放等流程打架；用户回到页面后由其自己
  /// 决定是否点击播放。
  void markPageActive() {
    state.isPageActive = true;
  }

  /// 当前路由是否仍是长视频详情页。
  ///
  /// 判定规则：
  /// 1. [Get.currentRoute] 以 [AppRoutes.VIDEO_PAGE] 开头（兼容
  ///    `/video_page?timestamp=...` 这种带参形式）；
  /// 2. 或者 chewieController 当前处于全屏态（chewie 全屏走的是匿名
  ///    MaterialPageRoute，[Get.currentRoute] 此刻不再是 `/video_page`，
  ///    需要兜底，避免「点全屏后视频被自动暂停」）。
  bool _isOnVideoPageRoute() {
    if (state.chewieController?.isFullScreen == true) return true;
    final String current = Get.currentRoute;
    return current.startsWith(AppRoutes.VIDEO_PAGE);
  }

  int? get _guessLikeGroupId {
    final id = state.mediaInfo?.result?.vod?.groups?[0];
    if (id == null) return null;
    return int.tryParse(id.toString());
  }

  Future<void> loadGuessLike({bool isRefresh = false}) async {
    if (isRefresh) {
      state.guessLikePageNumber = 1;
    }
    final groupId = _guessLikeGroupId;
    if (groupId == null) {
      _finishGuessLikePullRefresh(
        isFirstPage: state.guessLikePageNumber == 1,
        hasMore: false,
      );
      update(['guessLike']);
      return;
    }
    try {
      final List<MediaVideoModel> list = await HomeApis.getHomeMediaList(
        groupIds: groupId,
        sortType: VideoSortTypeEnum.random.value,
        videoType: state.mediaInfo?.result?.vod?.videoType ?? 0,
        pageNumber: state.guessLikePageNumber,
        pageSize: VideoPageState.guessLikePageSize,
      );
      final currentId = state.mediaInfo?.data?.id?.toString();
      final filtered =
          list.where((e) => e.id?.toString() != currentId).toList();
      if (state.guessLikePageNumber == 1) {
        state.guessLikeList = filtered;
      } else {
        state.guessLikeList = <MediaVideoModel>[
          ...state.guessLikeList,
          ...filtered,
        ];
      }
      _finishGuessLikePullRefresh(
        isFirstPage: state.guessLikePageNumber == 1,
        hasMore: list.length >= VideoPageState.guessLikePageSize,
      );
    } catch (_) {
      _finishGuessLikePullRefresh(
        isFirstPage: state.guessLikePageNumber == 1,
        hasMore: false,
      );
    }
    update(['guessLike']);
  }

  void _finishGuessLikePullRefresh({
    required bool isFirstPage,
    required bool hasMore,
  }) {
    state.guessLikePullRefresh.requestSuccess(
      isFirstPageNum: isFirstPage,
      hasMore: hasMore,
      isEmpty: false,
    );
  }

  void onGuessLikeRefresh() {
    loadGuessLike(isRefresh: true);
  }

  void onGuessLikeLoadMore() {
    state.guessLikePageNumber++;
    loadGuessLike();
  }

  void collectVideo() async {
    final bool hasCollected =
        state.mediaInfo?.data?.mediaStatus?.hasCollected ?? false;
    bool isSuccess = await UserApi.collectVideo(
        state.mediaInfo?.data?.id ?? '', hasCollected ? 0 : 1);
    if (isSuccess) {
      // 翻转「是否已收藏」状态。
      state.mediaInfo?.data?.mediaStatus?.hasCollected = !hasCollected;
      state.isCollected = !hasCollected;
      // 同步收藏数：原为已收藏 → 取消 (-1)，原为未收藏 → 收藏 (+1)。
      // 同时把 [mediaInfo.data.countCollect] 一并更新，避免后续接口刷新或
      // 跨页面读取时拿到旧值，与 [likeVideo] 的处理方式对齐。
      final int next = hasCollected
          ? (state.countCollect ?? 0) - 1
          : (state.countCollect ?? 0) + 1;
      state.countCollect = next < 0 ? 0 : next;
      state.mediaInfo?.data?.countCollect = state.countCollect;
      update();
    }
  }

  // void cancelCollectVideo() async {
  //   Map<String, dynamic> data = {
  //     "mediaID": state.mediaInfo?.data?.id,
  //     "kind": state.mediaInfo?.data?.kind,
  //   };

  //   Map<String, dynamic> mediaInfo = await UserApi.cancelCollectVideo(data);

  //   if (mediaInfo["msg"] == "success") {
  //     state.isCollected = false;

  //     state.countCollect = state.countCollect! - 1;
  //   }

  //   update();
  // }

  void likeVideo() async {
    bool isSuccess = await UserApi.likeVideo(state.mediaInfo?.data?.id ?? '',
        state.mediaInfo?.data?.mediaStatus?.hasLiked == true ? 0 : 1);

    if (isSuccess) {
      final hasLiked = state.mediaInfo?.data?.mediaStatus?.hasLiked ?? false;
      state.isLike = !hasLiked;
      state.mediaInfo?.data?.mediaStatus?.hasLiked = !hasLiked;
      state.countLike =
          hasLiked ? (state.countLike ?? 0) - 1 : (state.countLike ?? 0) + 1;
    }

    update();

    // Map map = {};

    // map["视频标题"] = state.mediaInfo!.data!.title;
    // map["视频id"] = state.mediaInfo!.data!.id;
    // map["类型"] = getProductName(state.mediaInfo!.data!.kind);
    // map["价格"] = getProductPriceType(state.mediaInfo!.data!.permission!);

    // ConfigStore.to.trackData('长视频点赞', map);
  }

  // void cancelLikeVideo() async {
  //   Map<String, dynamic> data = {
  //     "mediaID": state.mediaInfo?.data?.id,
  //     "kind": state.mediaInfo?.data?.kind,
  //   };

  //   Map<String, dynamic> mediaInfo = await UserApi.cancelLikeVideo(data);

  //   if (mediaInfo["msg"] == "success") {
  //     state.isLike = false;

  //     state.countLike = state.countLike! - 1;
  //   }

  //   update();
  // }

  Future<bool?> onLikeButtonTapped(bool isLiked) async {
    /// send your request here
    // final bool success= await sendRequest();

    /// if failed, you can do nothing
    // return success? !isLiked:isLiked;

    return !isLiked;
  }

  /// 用户中心页面返回时携带的关注状态 / 粉丝数差分，原地刷新 author 显示。
  void applyAuthorReturn(dynamic result) {
    if (result is! Map) return;
    final author = state.mediaInfo?.result?.author;
    if (author == null) return;
    final m = Map<String, dynamic>.from(result);
    final returnedUid = m['uid'];
    if (returnedUid is num &&
        author.id != null &&
        returnedUid.toInt() != author.id) {
      return;
    }
    bool dirty = false;
    final raw = m['isFollow'];
    final bool? next = raw is bool
        ? raw
        : (raw is num
            ? raw != 0
            : (raw is String ? (raw == 'true' || raw == '1') : null));
    if (next != null && next != (author.follow ?? false)) {
      author.follow = next;
      dirty = true;
    }
    final fansRaw = m['fansNum'];
    if (fansRaw is num) {
      author.fansNum = fansRaw.toInt();
      dirty = true;
    }
    if (dirty) update();
  }

  /// 关注/取关创作者，依赖 `result.author` 中的 `id` 与 `follow`。
  Future<void> followAuthor() async {
    final author = state.mediaInfo?.result?.author;
    final uid = author?.id;
    if (author == null || uid == null || uid <= 0) {
      showToast(msg: '用户信息错误');
      return;
    }
    final hasFollowed = author.follow ?? false;
    final BaseRespBean resp = hasFollowed
        ? await MediaApi.onCancleFocus(uid)
        : await MediaApi.onFocus(uid);
    if (resp.isSuccess) {
      author.follow = !hasFollowed;
      final fansNum = author.fansNum ?? 0;
      author.fansNum =
          hasFollowed ? (fansNum > 0 ? fansNum - 1 : 0) : fansNum + 1;
      showToast(msg: hasFollowed ? '取消关注' : '关注成功');
      update();
    } else {
      showToast(msg: resp.tip ?? '操作失败');
    }
  }

  Future<void> startVideoPlayer(int epsode,
      {bool isSwitchEpisode = false}) async {
    if (state.videoPlayerController == null || state.chewieController == null) {
      // If there was no controller, just create a new one

      state.isClickHotVideo = true;
      getMediaInfo(epsode, false);
    } else {
      // If there was a controller, we need to dispose of the old one first
      final oldVideoPlayerController = state.videoPlayerController;
      final oldChewiePlayerController = state.chewieController;

      // Registering a callback for the end of next frame
      // to dispose of an old controller
      // (which won't be used anymore after calling setState)
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await oldVideoPlayerController?.dispose();
        oldChewiePlayerController?.dispose();

        state.isClickHotVideo = true;
        // Initing new controller
        getMediaInfo(epsode, false);
      });

      // Making sure that controller is not used by setting it to null

      state.videoPlayerController = null;
      state.chewieController = null;

      update();
      //update(["refreshVideo"]);
    }
  }

  commentSuc() {
    state.countComment.value++;
  }

  @override
  void onClose() {
    if (state.timer != null) {
      state.timer?.cancel();
      state.timer = null;
    }

    final videoController = state.videoPlayerController;
    final mediaData = state.mediaInfo?.data;
    if (videoController != null && mediaData != null) {
      ///大于10就记录完播率
      int currentPosition = videoController.value.position.inSeconds;
      final duration = videoController.value.duration.inSeconds;

      if (currentPosition > (duration * 0.1)) {
        Map map = {};

        map["视频标题"] = mediaData.title;
        map["视频id"] = mediaData.id;
        map["类型"] = getProductName(mediaData.kind);
        map["价格"] = getProductPriceType(mediaData.permission!);

        map["标签"] = mediaData.tagNames;

        ConfigStore.to.trackData('长视频完播', map);
      } else {
        Map map = {};

        map["视频标题"] = mediaData.title;
        map["视频id"] = mediaData.id;
        map["类型"] = getProductName(mediaData.kind);
        map["价格"] = getProductPriceType(mediaData.permission!);
        map["播放进度"] = "$currentPosition秒";

        map["标签"] = mediaData.tagNames;

        ConfigStore.to.trackData('长视频播放(未完播)', map);
      }

      HistoryOperation.getInstance()?.add(
          info: state.mediaInfo,
          episode: state.selectedEpisode,
          duration: currentPosition,
          recordType: HistoryRecordType.video);
    }

    // if (GetPlatform.isWeb) {
    ConfigStore.to.autoPlayStreamController?.close();
    state.videoPlayerController?.dispose();
    state.chewieController?.dispose();
    state.videoPlayerController = null;
    state.chewieController = null;
    // }
    // 防止 PullRefreshController 持有的 RefreshController 漏掉释放
    state.guessLikePullRefresh.dispose();
    super.onClose();
  }

  Future<void> seekToHistory() async {
    await state.videoPlayerController
        ?.seekTo(Duration(seconds: state.historyDuration ?? 0));
    state.showHistory = false;
    state.historyDuration = 0;
    update(["refreshVideo"]);
  }

  ///开启定时器
  startTimer() {
    state.timer = null;

    const oneSec = Duration(seconds: 1);

    Future.delayed(const Duration(milliseconds: 500), () {
      state.timer = Timer.periodic(oneSec, (timer) async {
        if (state.countdownTime == 0) {
          state.timer?.cancel();
          //update();
          //update(["refreshVideo"]);
          update(["refreshCloseButton"]);
          //chewiePlay();
        } else {
          state.countdownTime = state.countdownTime - 1;

          update();
          //update(["refreshVideo"]);

          if (state.chewieController != null) {
            state.chewieController!.pause();
          }
        }
      });
    });
  }
}
