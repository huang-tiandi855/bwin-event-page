library short_video_play_logic_impl;

import 'package:comics_app/common/widgets/common_dialog/coin_dialog.dart';
import 'package:comics_app/common/apis/media_api.dart';
import 'package:comics_app/common/apis/user.dart';
import 'package:comics_app/common/apis/vid_api.dart';
import 'package:comics_app/common/entities/media_info.dart';
import 'package:comics_app/common/entities/video_model/ishort_video_model.dart';
import 'package:comics_app/common/entities/video_model/tags_model.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/store/config.dart';
import 'package:comics_app/common/store/event_tracking_manager.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/utils/date_util.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/widgets/bottom_sheet_comment.dart';
import 'package:comics_app/common/widgets/comment/comment_view.dart';
import 'package:comics_app/common/widgets/common_dialog/share_video_dialog.dart';
import 'package:comics_app/pages/home_index/topic_more_detail/topic_more_detail_route.dart';
import 'package:comics_app/pages/video_page/player_code_manage.dart';
import 'package:comics_app/short_video/player/short_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../page_view/views/short_video_reward_bottom_sheet.dart';

part 'abs_short_video_action.dart';
part 'abs_short_video_play_state.dart';
part 'short_video_action_mixin.dart';

abstract class AbsShortVideoPlayLogic<T extends ShortVideoModel>
    extends AbsShortVideoAction<T> with ShortVideoActionMixin<T> {
  final List<T> initialList;
  final int? initialIndex;
  final bool isMore;

  AbsShortVideoPlayLogic({
    this.initialList = const [],
    this.initialIndex,
    this.isMore = true,
  });

  @override
  void onInit() {
    super.onInit();
    state.currentIndex = initialIndex ?? 0;
    state.pageController = PageController(initialPage: state.currentIndex);
    state.videoListController.init(
      initialIndex: state.currentIndex,
      initialList: initialList.map(buildVideoController).toList(),
      beforeInit: beforeInit,
      addListenerCallBack: addListenerCallBack,
      videoProvider: onMore,
      isMore: isMore,
    );

    state.videoListController.addListener(_videoListListener);
    // 二级页 / 独立路由也声明前台 owner，便于从 KeepAlive 热门列表抢解码槽。
    state.videoListController.claimActiveOwner();
  }

  @override
  void onClose() {
    final player = state.videoListController.playerOfIndex(state.currentIndex);
    final videoInfo = player?.videoInfo ??
        (state.videoListController.playerList.isNotEmpty
            ? state.videoListController.currentPlayer.videoInfo
            : null);

    ///大于15秒就算完播
    if (videoInfo != null && player != null && player.hasController) {
      if (player.controller.value.position.inSeconds >
          ((player.controller.value.duration.inSeconds) * 0.1)) {
        Map map = {};

        map["视频标题"] = videoInfo.title;
        map["视频id"] = videoInfo.id;
        //map["类型"] = getProductName(videoInfo.kind);
        //map["价格"] = getProductPriceType(videoInfo.permission!);

        ConfigStore.to.trackData('短视频完播', map);
      } else {
        Map map = {};

        map["视频标题"] = videoInfo.title;
        map["视频id"] = videoInfo.id;
        map["播放进度"] =
            "${player.controller.value.position.inSeconds}秒";

        map["标签"] = videoInfo.tags;

        ConfigStore.to.trackData('短视频播放(未完播)', map);
      }
    }

    state.pageController.dispose();
    state.videoListController.removeListener(_videoListListener);
    state.videoListController.dispose();
    super.onClose();
  }

  void addListenerCallBack(
      VideoController videoController, T? videoInfo) async {
    if (!videoController.hasController) return;
    if (videoController.controller.value.isCompleted) {
      if (state.currentIndex < state.videoListController.videoCount - 1) {
        state.pageController.animateToPage(
          state.currentIndex + 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.linear,
        );
      }
      videoController.controller.seekTo(Duration.zero);
    }

    final info = videoInfo;
    if (info == null) return;

    int inSeconds = videoController.controller.value.position.inSeconds;
    final trackTime =
        (videoController.controller.value.duration.inSeconds) * 0.1;
    final track = inSeconds > trackTime;

    if (track) {
      EventTrackingManager().addVideoDatas(info.id, info.title);
    }
  }

  Future<void> Function(VideoController<T>)? beforeInit;

  Future<List<VideoController<T>>> onMore();

  VideoController<T> buildVideoController(
    T videoInfo, {
    Duration position = Duration.zero,
  }) {
    late final VideoController<T> controller;
    controller = VideoController<T>(
      videoInfo: videoInfo,
      position: position,
      builder: () {
        return VideoPlayerController.networkUrl(
          Uri.parse(controller.videoInfo.realVideoUrl),
        );
      },
    );
    return controller;
  }

  void playVideo(int index) {
    state.currentIndex = index;
    state.beginTime = DataFormats.getUtcDate();
    state.videoListController.onVideoIndexChanged(index);
  }

  Future<void> pauseCurrentVideo({
    bool showPauseIcon = false,
    bool suppressAutoPlay = false,
  }) async {
    // 即使当前 controller 还在初始化（`!hasController`），也要把
    // [VideoListController.suppressAutoPlay] 同步标记上，否则 init 完成后
    // [_initVideo] 会自动 play，而新构造的 [ShortVideoPlayer] 也会带着
    // FlickManager(autoPlay: true) 触发音频泄漏。
    if (suppressAutoPlay) {
      state.videoListController.setSuppressAutoPlay(true);
    }
    final player = state.videoListController.playerOfIndex(state.currentIndex);
    if (player == null || !player.hasController) return;
    await player.pause(showPauseIcon: showPauseIcon);
  }

  /// 与 [pauseCurrentVideo] 对称：清掉外部抑制位，并在 controller 已就绪时
  /// 显式起播。
  ///
  /// FlickManager 的 `autoPlay` 在构造期就锁死，重新开放后无法靠它再次自动
  /// 起播；这里必须手动 [VideoController.play]。
  Future<void> resumeCurrentVideo() async {
    state.videoListController.setSuppressAutoPlay(false);
    final player = state.videoListController.playerOfIndex(state.currentIndex);
    if (player == null || !player.hasController) return;
    await player.play();
  }

  /// KeepAlive / 池抢占后重建当前页，不主动 play；起播交给 [resumeCurrentVideo]。
  Future<void> rehydratePlayersAfterRelease() async {
    await state.videoListController.reinitializeAroundCurrent();
    update(['videoList']);
  }

  // Future<bool?> onTapProductPrice(T videoInfo) {
  //   // final videoInfo = state.info!;
  //   if (videoInfo.needPermission == 0 || videoInfo.needPermission == 1) {
  //     if (videoInfo.needPermission == 0) {
  //       state.isShowDialog = true;
  //       return CoinBuyService.showVipDialog(
  //         canUseCoupon: true,
  //         id: videoInfo.id!,
  //         productType: ProductType.video,
  //       ).then((success) {
  //         state.isShowDialog = false;
  //         if (success ?? false) {
  //           videoInfo.hasPaid = true;
  //           update(['videoInfo${videoInfo.id}']);
  //         }
  //         return success;
  //       });
  //     } else {
  //       state.isShowDialog = true;
  //       return CoinBuyService.showDialog(
  //         id: videoInfo.id!,
  //         coin: videoInfo.price ?? 0,
  //         title: videoInfo.title,
  //         productType: ProductType.video,
  //       ).then((success) {
  //         state.isShowDialog = false;
  //         if (success ?? false) {
  //           videoInfo.hasPaid = true;
  //           update(['videoInfo${videoInfo.id}']);
  //         }
  //         return success;
  //       });
  //     }
  //   }
  //   return Future.value(true);
  // }

  bool shouldShowAuthOverlay(T videoInfo) {
    final id = videoInfo.id;
    if (id == null) return false;
    if (state.authOverlayVideoId == id) return true;
    return videoInfo.shouldAutoShowAuthOverlay &&
        !state.dismissedAuthOverlayVideoIds.contains(id);
  }

  void showAuthOverlay(T videoInfo) {
    final id = videoInfo.id;
    if (id == null) return;
    state.dismissedAuthOverlayVideoIds.remove(id);
    state.authOverlayVideoId = id;
    pauseCurrentVideo();
    update(['videoInfo$id']);
  }

  void hideAuthOverlay(T videoInfo) {
    final id = videoInfo.id;
    if (id == null) return;
    state.dismissedAuthOverlayVideoIds.add(id);
    if (state.authOverlayVideoId == id) {
      state.authOverlayVideoId = null;
    }
    update(['videoInfo$id']);
  }

  void onTapAuthOverlayInvite() {
    Get.toNamed(AppRoutes.SHARE_INVITE);
  }

  void onTapAuthOverlayOpenMember() {
    Get.toNamed(
      AppRoutes.MEMBER_CENTER,
      arguments: {"initialIndex": 0},
    );
  }

  /// 金币付费浮层是否应展示（`needPermission == 1` 时，即 1038 / 1035）。
  ///
  /// 与 [shouldShowAuthOverlay] 类似：触发自动弹出的 id 始终展示；
  /// 用户主动关闭过的视频在当前会话内不再自动弹出。
  bool shouldShowGoldOverlay(T videoInfo) {
    final id = videoInfo.id;
    if (id == null) return false;
    if (state.goldOverlayVideoId == id) return true;
    return videoInfo.shouldAutoShowGoldOverlay &&
        !state.dismissedGoldOverlayVideoIds.contains(id);
  }

  void showGoldOverlay(T videoInfo) {
    final id = videoInfo.id;
    if (id == null) return;
    state.dismissedGoldOverlayVideoIds.remove(id);
    state.goldOverlayVideoId = id;
    pauseCurrentVideo();
    update(['videoInfo$id']);
  }

  void hideGoldOverlay(T videoInfo) {
    final id = videoInfo.id;
    if (id == null) return;
    state.dismissedGoldOverlayVideoIds.add(id);
    if (state.goldOverlayVideoId == id) {
      state.goldOverlayVideoId = null;
    }
    update(['videoInfo$id']);
  }

  /// 观影券浮层是否应展示。
  ///
  /// 同时成立才放出来：
  /// 1. `playerCode` 命中 1008（[PlayerCodeManage.nonMember]） /
  ///    1038（[PlayerCodeManage.noPay]）；
  /// 2. 用户当前持有观影券（`UserStore.movieTickets > 0`）。
  ///
  /// 任一不满足都回退到原 [shouldShowAuthOverlay] / [shouldShowGoldOverlay]。
  /// 视图层先判定本字段，命中即只渲染观影券浮层；浮层无 dismiss 流程，
  /// 「跳过预览」是 UI 装饰，唯一退出路径是用券。
  bool shouldShowMovieTicketOverlay(T videoInfo) {
    final id = videoInfo.id;
    if (id == null) return false;
    if ((UserStore.to.getUserInfoModel?.movieTickets ?? 0) <= 0) return false;
    final code = videoInfo.playerCode;
    return code == PlayerCodeManage.nonMember || code == PlayerCodeManage.noPay;
  }

  void showMovieTicketOverlay(T videoInfo) {
    final id = videoInfo.id;
    if (id == null) return;
    state.movieTicketOverlayVideoId = id;
    pauseCurrentVideo();
    update(['videoInfo$id']);
  }

  /// 「使用观影券」按钮回调：调 [MediaApi.videoTicketPay] 扣 1 张观影券。
  ///
  /// 观影券是一次性票（详见 [MediaApi.videoTicketPay] 注释），扣券接口的
  /// 响应里**直接回写**了本次播放所需的整套 mediaInfo（含可播放的
  /// `realVideoUrl` 与可播放的 `code`）。所以这里把响应作为 `prefetched`
  /// 直接喂给 [_refreshCurrentVideoAfterPay]，**绝不能**再让它走默认的
  /// [getMediaInfo] 重拉路径 —— 那条路径会被同样的 1008/1038 拦回浮层，
  /// 等于券白扣。下次用户离开本页再回来时，正常详情请求仍会带回鉴权码，
  /// 符合「观影券一次只解一次」的产品约束。
  ///
  /// - 接口成功：刷用户信息（`movieTickets - 1` 同步），把当前 id 从浮层
  ///   状态里清掉，再用 ticket pay 响应里的 mediaInfo 起播；
  /// - 接口失败：toast 错误信息，浮层不动。
  Future<void> onTapMovieTicketOverlayUse(T videoInfo) async {
    final id = videoInfo.id;
    if (id == null) return;
    state.isShowDialog = true;
    SmartDialog.showLoading();
    try {
      final BaseRespBean resp = await MediaApi.videoTicketPay(id);
      if (resp.isSuccess) {
        showToast(msg: '解锁成功');
        if (state.movieTicketOverlayVideoId == id) {
          state.movieTicketOverlayVideoId = null;
        }
        await UserStore.to.refreshUser();
        await _refreshCurrentVideoAfterPay(videoInfo, prefetched: resp);
      } else {
        showToast(msg: resp.tip ?? '解锁失败');
      }
    } catch (e) {
      showToast(msg: '解锁失败');
    } finally {
      SmartDialog.dismiss();
      state.isShowDialog = false;
    }
  }

  /// 金币付费浮层「邀请好友得VIP」按钮回调（普通态左按钮）。
  void onTapGoldOverlayInvite() {
    Get.toNamed(AppRoutes.SHARE_INVITE);
  }

  /// 金币付费浮层「{price}金币解锁」按钮回调（普通态右按钮）。
  ///
  /// 调用 [MediaApi.videoGoldPay] 扣金币：
  /// - 接口成功：刷详情拿最新播放链接 + 重建 [VideoController] 起播；
  /// - 接口返回 1035（[PlayerCodeManage.notEnoughGold]）：把当前 id 写入
  ///   [AbsShortVideoPlayState.insufficientGoldVideoIds]，浮层切到
  ///   「金币不足」形态等用户点「充值金币解锁」；
  /// - 其它失败：toast 错误信息，浮层不动。
  Future<void> onTapGoldOverlayPurchase(T videoInfo) async {
    final id = videoInfo.id;
    if (id == null) return;
    state.isShowDialog = true;
    SmartDialog.showLoading();
    try {
      final BaseRespBean resp = await MediaApi.videoGoldPay(id);
      if (resp.isSuccess) {
        showToast(msg: '购买成功');
        state.insufficientGoldVideoIds.remove(id);
        await UserStore.to.refreshUser();
        await _refreshCurrentVideoAfterPay(videoInfo);
      } else if (resp.code == PlayerCodeManage.notEnoughGold) {
        // 余额不足：浮层切到「金币不足」形态，等用户「充值金币解锁」。
        state.insufficientGoldVideoIds.add(id);
        await UserStore.to.refreshUser();
        update(['videoInfo$id']);
      } else {
        showToast(msg: resp.tip ?? '购买失败');
      }
    } catch (e) {
      showToast(msg: '购买失败');
    } finally {
      SmartDialog.dismiss();
      state.isShowDialog = false;
    }
  }

  /// 金币付费浮层「充值金币解锁」按钮回调（金币不足态左按钮）。
  ///
  /// 跳 [AppRoutes.WALLET] 充值；返回后按余额决定形态：
  /// - 用户金币 ≥ 视频金币：从 [AbsShortVideoPlayState.insufficientGoldVideoIds]
  ///   移除当前 id，浮层切回普通态等用户重新点「金币解锁」；
  /// - 用户金币 < 视频金币：保持「金币不足」形态并 toast 提示。
  Future<void> onTapGoldOverlayRecharge(T videoInfo) async {
    final id = videoInfo.id;
    if (id == null) return;
    state.isShowDialog = true;
    await Get.toNamed(AppRoutes.WALLET);
    state.isShowDialog = false;
    await UserStore.to.refreshUser();
    final int userGold = UserStore.to.getUserInfoModel?.walletApp ?? 0;
    final int videoGold = videoInfo.price ?? 0;
    if (userGold >= videoGold) {
      state.insufficientGoldVideoIds.remove(id);
    } else {
      showToast(msg: '金币仍不足，请充值后再试');
    }
    update(['videoInfo$id']);
  }

  /// 付费扣费成功后拿最新播放链接并重建当前 [VideoController] 起播。
  ///
  /// 两条调用方式：
  /// - 金币 / VIP（[onTapGoldOverlayPurchase]）：传 `prefetched: null`，
  ///   方法内自己走 [MediaApi.getMediaInfo] 拉一次详情；
  /// - 观影券（[onTapMovieTicketOverlayUse]）：必须传 `prefetched` 为
  ///   [MediaApi.videoTicketPay] 的响应。**绝不能**让方法默认走
  ///   getMediaInfo —— 详见 [MediaApi.videoTicketPay] 注释里关于「一次性
  ///   票」的说明。
  Future<void> _refreshCurrentVideoAfterPay(
    T videoInfo, {
    BaseRespBean? prefetched,
  }) async {
    final id = videoInfo.id;
    if (id == null) return;
    int? freshCode;
    String? freshVideoUrl;
    try {
      final BaseRespBean resp = prefetched ?? await MediaApi.getMediaInfo(id);
      final MediaInfo mediaInfo = MediaInfo.fromJson(resp.toJson());
      freshCode = mediaInfo.code;
      final contents = mediaInfo.data?.contents ?? [];
      if (contents.isNotEmpty) {
        freshVideoUrl = contents.first.videoUrl;
      }
    } catch (_) {
      // 拉详情失败时维持原状态，浮层保持原态。
    }
    videoInfo.playerCode = freshCode;
    if (freshVideoUrl != null && freshVideoUrl.isNotEmpty) {
      videoInfo.sourceUrl = freshVideoUrl;
      videoInfo.refreshRealVideoUrl();
    }
    if (PlayerCodeManage.canPlay(freshCode)) {
      videoInfo.hasPaid = true;
      // 解锁成功后把三类浮层状态全部清掉。原先只清 gold 是因为
      // [_refreshCurrentVideoAfterPay] 只服务于 [onTapGoldOverlayPurchase]；
      // 现在同时被 [onTapMovieTicketOverlayUse] 调用 —— 观影券能解 1008
      // 也能解 1038，必须把 auth 浮层一并清掉，否则会从下面回退到
      // [ShortVideoAuthOverlay]。
      if (state.authOverlayVideoId == id) state.authOverlayVideoId = null;
      state.dismissedAuthOverlayVideoIds.add(id);
      if (state.goldOverlayVideoId == id) state.goldOverlayVideoId = null;
      state.dismissedGoldOverlayVideoIds.add(id);
      if (state.movieTicketOverlayVideoId == id) {
        state.movieTicketOverlayVideoId = null;
      }
      await _rebuildCurrentPlayer(videoInfo);
    }
    update(['videoInfo$id']);
  }

  /// 关键：金币付费成功后必须**重建** [VideoController] —— 旧 controller 持有的是
  /// 被拦截的占位 URL，单纯 `play()` / `seekTo(0)` 不会触发新的 setDataSource。
  ///
  /// 实现：在 playerList 中替换当前 index 的 controller，跳过 `beforeInit`
  /// （我们已经手动拉过最新详情，避免重复 IO），并保留原有
  /// [VideoListController.videoAddListenerCallBack] 监听链；同步触发
  /// `update(['videoList'])` 让 PageView 重 build。
  Future<void> _rebuildCurrentPlayer(T videoInfo) async {
    final int currentIndex = state.currentIndex;
    final controller = state.videoListController.playerOfIndex(currentIndex);
    if (controller == null) return;
    final newController = buildVideoController(videoInfo);
    newController.bindPool(
      owner: state.videoListController,
      index: currentIndex,
    );
    state.videoListController.playerList[currentIndex] = newController;
    state.videoListController.controllers.remove(currentIndex);
    await controller.dispose();
    state.videoListController.claimActiveOwner();
    await newController.init(
      afterInit: (c) async {
        final cb = state.videoListController.videoAddListenerCallBack;
        if (cb != null) {
          c.controller.addListener(() => cb(c, c.videoInfo));
        }
        await c.play();
      },
    );
    state.videoListController.controllers[currentIndex] = newController;
    update(['videoList']);
  }

  void onTapGoldOverlayOpenMember() {
    Get.toNamed(
      AppRoutes.MEMBER_CENTER,
      arguments: {"initialIndex": 0},
    );
  }

  void _videoListListener() {
    update(['videoList']);
  }

  @override
  void switchLine() async {
    final list = List.from(state.videoListController.playerList).map((e) {
      e.videoInfo.refreshRealVideoUrl();
      return buildVideoController(
        e.videoInfo,
        position: e.hasController ? e.controller.value.position : Duration.zero,
      );
    }).toList();
    state.videoListController.removeListener(_videoListListener);
    await state.videoListController.dispose();

    state.videoListController = VideoListController<T>()
      ..init(
        initialList: list,
        initialIndex: state.currentIndex,
        beforeInit: beforeInit,
        addListenerCallBack: addListenerCallBack,
        videoProvider: onMore,
      );
    state.videoListController.addListener(_videoListListener);
    update(['videoList']);
  }
}
