import 'dart:async';

import 'package:chewie/chewie.dart' hide MaterialControls;
import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/common/entities/media_info.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoPageState {
  VideoPlayerController? videoPlayerController;

  ChewieController? chewieController;

  String? mediaInfoId;
  RxInt countComment = 0.obs;
  MediaInfo? mediaInfo;

  late TabController tabController;
  late List<String> tabs = [];

  /// 猜你喜欢
  static const int guessLikePageSize = 20;
  int guessLikePageNumber = 1;
  List<MediaVideoModel> guessLikeList = [];
  final PullRefreshController guessLikePullRefresh =
      PullRefreshController(isRequest: false);

  int selectedEpisode = 0;
  int currentTabIndex = 0;
  int? historyDuration = 0;
  int oldEpisode = 0;
  bool? isCollected;

  int index = 0;

  bool? isLike;
  bool isSendList = false;

  bool? isCanPlay = false;

  int? countLike;
  int? countCollect;

  bool showHistory = true;

  late List<AdsInfoList> banner = [];

  late List<AdsInfoList> videoAdvertisement = [];

  ///广告时间
  int countdownTime = ConfigStore.to.configBean.adsTimeLongVideo;

  ///定时器
  Timer? timer;

  bool? isCloseAdvs = false;

  bool? isFullScreenAdvs = true;

  bool? isFreeZoneArgs = false;

  bool? hasShowDialog = false;

  /// 金币付费浮层是否当前展示为「金币不足」形态。
  ///
  /// 详情接口（[MediaApi.getMediaInfo]）只会返回 1038（[PlayerCodeManage.noPay]）
  /// 让浮层先以「金币付费」形态展示，用户点击「{price}金币观看」后由
  /// [VideoPageLogic.purchaseCurrentVideoByGold] 调 [MediaApi.videoGoldPay]，
  /// 接口返回 1035（[PlayerCodeManage.notEnoughGold]）时再切到本字段，
  /// 浮层据此把标题换成「金币不足」、左按钮换成「去充值」并跳钱包。
  bool goldOverlayInsufficient = false;

  bool? isClickHotVideo = false;

  bool isSurface = true;

  /// 当前路由页是否仍在「最顶层」展示中。
  ///
  /// 通过 [RouteAware.didPushNext] / [RouteAware.didPopNext] 维护：被新路由
  /// 覆盖时置为 false，回到本页时置为 true。供 [VideoPageLogic.chewiePlay]
  /// / [VideoPageLogic.startVideoPlayer] 判断「视频在用户离开本页期间加载
  /// 完成时不要自动外放声音」。
  bool isPageActive = true;

  int? randomAds;

  bool isAutoPlay = false;

  bool? cutDownState = false;

  /// 视频详情页顶部「VIP 横幅」展示的会员卡名称，来自 [MineApis.getVipCardList]
  /// 返回列表的第一张卡。
  ///
  /// 数据未到 / 接口失败时为 null，UI 层自行回退到占位文案。
  String? vipBannerCardName;

  VideoPageState() {
    cutDownState = false;

    ///Initialize variables
    tabs = [
      "简介",
      "评论",
    ];
  }

  String getTime() {
    return Duration(seconds: historyDuration ?? 0).toString().split('.').first;
  }

  bool showHistoryDurationView() {
    return historyDuration != null &&
        historyDuration! > 0 &&
        oldEpisode == index &&
        showHistory;
  }
}
