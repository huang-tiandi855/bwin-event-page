import 'package:comics_app/short_video/player/short_video_player.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../base/abs_short_video_play_logic.dart';
import 'views/short_video_auth_overlay.dart';
import 'views/short_video_button_view.dart';
import 'views/short_video_gold_overlay.dart';
import 'views/short_video_info_view.dart';
import 'views/short_video_movie_ticket_overlay.dart';

class ShortVideoPageView<T extends AbsShortVideoPlayLogic>
    extends StatelessWidget {
  const ShortVideoPageView({
    super.key,
    required this.tag,
    this.bottomOverlayHeight = 0,
    this.playerPageType = ShortVideoPlayerPageType.secondary,
  });

  T get logic => Get.find<T>(tag: tag);

  AbsShortVideoPlayState get state => logic.state;

  final String tag;
  final double bottomOverlayHeight;
  final ShortVideoPlayerPageType playerPageType;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<T>(
      id: 'videoList',
      tag: tag,
      builder: (logic) {
        return PageView.builder(
          controller: state.pageController,
          scrollDirection: Axis.vertical,
          itemCount: state.videoListController.videoCount,
          onPageChanged: (index) {
            if (state.currentIndex != index) {
              logic.playVideo(index);
            }
          },
          itemBuilder: (context, i) {
            VideoController videoController =
                state.videoListController.playerOfIndex(i)!;
            return GetBuilder<T>(
              id: 'videoInfo${videoController.videoInfo.id}',
              tag: tag,
              builder: (logic) {
                final bottomInset =
                    playerPageType == ShortVideoPlayerPageType.primary
                        ? bottomOverlayHeight
                        : 30.0;

                // 未就绪（`!hasController`）时强制走封面占位，等
                // [VideoListController._initializeControllerAtIndex] 把
                // `beforeInit`（拉真 URL）+ `controller.initialize()` 串完，
                // notifyListeners 触发 GetBuilder('videoList') 重 build，
                // 再切到真正的 [ShortVideoPlayer]。
                //
                // 这步不能省：[VideoController.controller] 是懒求值的，
                // [AbsShortVideoPlayLogic.buildVideoController] 的 builder
                // 读的是「当前」`videoInfo.realVideoUrl`。入口列表（收藏 /
                // 历史 等）给的初始 realVideoUrl 是占位地址（基于
                // `vodSerialNumber` 拼的），如果 PageView 在 beforeInit 之前
                // 就同步访问 `.controller`，`_controller` 会被占位 URL 缓存
                // 死，后续真 URL 灌进来也没用——ExoPlayer 直接 Source error。
                final bool useCoverPlaceholder =
                    videoController.videoInfo.shouldUseCoverPlaceholder ||
                        !videoController.hasController;
                // 用户已经离开当前页时（[VideoListController.suppressAutoPlay]
                // 为 true），把 [ShortVideoPlayer.autoPlay] 关掉。这是阻断
                // FlickManager 在构造期 `_changeVideo` 中自动 play() 的唯一手段
                // —— FlickManager 把 autoPlay 锁在构造期，事后改没用。
                final bool autoPlay =
                    !state.videoListController.suppressAutoPlay;
                return Stack(
                  children: [
                    Positioned.fill(
                      bottom: bottomInset,
                      child: useCoverPlaceholder
                          ? CustomImage(
                              url: videoController.videoInfo.cover,
                              fit: BoxFit.fitWidth,
                            )
                          : ShortVideoPlayer(
                              key: ValueKey(videoController.hashCode),
                              cover: videoController.videoInfo.cover,
                              videoController: videoController,
                              pageType: playerPageType,
                              autoPlay: autoPlay,
                            ),
                    ),
                    Positioned(
                      bottom: bottomInset + 83.w,
                      right: 16.w,
                      child: ShortVideoButtonView<T>(
                        videoInfo: videoController.videoInfo,
                        tag: tag,
                      ),
                    ),
                    Positioned(
                      bottom: bottomInset + 36.w,
                      left: 16.w,
                      right: 16.w * 2 + 44.w,
                      child: ShortVideoInfoView<T>(
                        videoInfo: videoController.videoInfo,
                        tag: tag,
                      ),
                    ),
                    if (logic.shouldShowMovieTicketOverlay(
                        videoController.videoInfo))
                      Positioned.fill(
                        bottom: bottomInset,
                        child: ShortVideoMovieTicketOverlay(
                          videoInfo: videoController.videoInfo,
                          onUseTicketTap: () =>
                              logic.onTapMovieTicketOverlayUse(
                                  videoController.videoInfo),
                        ),
                      )
                    else if (logic
                        .shouldShowAuthOverlay(videoController.videoInfo))
                      Positioned.fill(
                        bottom: bottomInset,
                        child: ShortVideoAuthOverlay(
                          videoInfo: videoController.videoInfo,
                          onDismiss: () =>
                              logic.hideAuthOverlay(videoController.videoInfo),
                          onInviteTap: logic.onTapAuthOverlayInvite,
                          onOpenMemberTap: logic.onTapAuthOverlayOpenMember,
                        ),
                      )
                    else if (logic
                        .shouldShowGoldOverlay(videoController.videoInfo))
                      Builder(builder: (_) {
                        // 1035（金币不足）来源于支付接口而不是详情接口，
                        // 因此「金币不足」形态由 logic 内部 state 标志驱动，
                        // 不能直接从 videoInfo.playerCode 派生。
                        final bool isInsufficientGold = state
                            .insufficientGoldVideoIds
                            .contains(videoController.videoInfo.id);
                        return Positioned.fill(
                          bottom: bottomInset,
                          child: ShortVideoGoldOverlay(
                            videoInfo: videoController.videoInfo,
                            isInsufficientGold: isInsufficientGold,
                            onDismiss: () => logic
                                .hideGoldOverlay(videoController.videoInfo),
                            // 按钮交换语义对齐长视频 GoldPlayerOverlay：
                            // - 普通态：左「邀请」/ 右「金币解锁」
                            // - 不足态：左「充值金币解锁」/ 右「升级会员免费看」
                            onUnlockTap: () {
                              if (isInsufficientGold) {
                                logic.onTapGoldOverlayRecharge(
                                  videoController.videoInfo,
                                );
                              } else {
                                logic.onTapGoldOverlayInvite();
                              }
                            },
                            onOpenMemberTap: () {
                              if (isInsufficientGold) {
                                logic.onTapGoldOverlayOpenMember();
                              } else {
                                logic.onTapGoldOverlayPurchase(
                                  videoController.videoInfo,
                                );
                              }
                            },
                          ),
                        );
                      }),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
