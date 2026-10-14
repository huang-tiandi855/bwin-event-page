import 'dart:math';

import 'package:chewie/chewie.dart';
import 'package:comics_app/common/entities/post_entity.dart';
import 'package:comics_app/common/widgets/common_dialog/line_switch_bottom_sheet.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/pages/home_index/topic_more_detail/topic_more_detail_route.dart';
import 'package:comics_app/common/widgets/common_dialog/share_video_dialog.dart';
import 'package:comics_app/common/widgets/item/meida_cover_item.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/utils/ads_manage/ads_banner_icon_group.dart';
import 'package:comics_app/common/utils/ads_manage/ads_info_list_extension.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';
import 'package:comics_app/common/utils/screen.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/widgets/comment/comment_view.dart';
import 'package:comics_app/common/widgets/comment/msg_send/msg_send_view.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/common/widgets/loading_widget.dart';
import 'package:comics_app/common/widgets/space_widget.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../common/entities/module_detail_model/content_model.dart';
import '../../common/values/address.dart';
import '../home/tag_detail/tag_detail_logic.dart';
// 播放器浮层组件统一收敛在 player_float 目录，避免主页面继续堆叠 UI 细节。
import 'player_code_manage.dart';
import 'player_float/gold_player_overlay.dart';
import 'player_float/movie_ticket_player_overlay.dart';
import 'player_float/player_ad_countdown_float.dart';
import 'player_float/player_history_float.dart';
import 'player_float/player_permission_badge.dart';
import 'player_float/vip_player_overlay.dart';
import 'video_page_logic.dart';
import 'video_page_state.dart';
import '../../main.dart' show routeObserver;

/// 路由 `/video_page` 的入口 Widget。
///
/// 每次进入该路由都会生成一个全局唯一的 [_logicTag]，并以这个 tag 独立注册
/// 一份 [VideoPageLogic]。这样可以避免「视频详情 → 用户中心 → 同 / 不同视频
/// 详情」等堆栈复用场景下，多个 SmartRefresher 抢同一个 RefreshController
/// 触发 `Don't use one refreshController to multiple SmartRefresher` 断言。
class VideoPagePage extends StatefulWidget {
  const VideoPagePage({Key? key}) : super(key: key);

  @override
  State<VideoPagePage> createState() => _VideoPagePageState();
}

class _VideoPagePageState extends State<VideoPagePage> with RouteAware {
  late final String _logicTag;

  @override
  void initState() {
    super.initState();
    _logicTag =
        'video_page_${identityHashCode(this)}_${DateTime.now().microsecondsSinceEpoch}';
    Get.put<VideoPageLogic>(VideoPageLogic(), tag: _logicTag);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 订阅全局 routeObserver，监听本页被其他路由覆盖 / 重新回到本页等事件。
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  /// 当前路由被新路由覆盖（例如点击头像跳到用户主页）时触发。
  ///
  /// 主动暂停长视频播放器，并通过 [VideoPageLogic.pausePlayer] 把
  /// [VideoPageState.isPageActive] 置为 false，让后续 [chewiePlay] /
  /// [startVideoPlayer] 在视频「迟到加载完成」时也跳过 play，避免用户已
  /// 离开本页后仍在后台外放音频的体验问题。
  @override
  void didPushNext() {
    super.didPushNext();
    if (Get.isRegistered<VideoPageLogic>(tag: _logicTag)) {
      Get.find<VideoPageLogic>(tag: _logicTag).pausePlayer();
    }
  }

  /// 路由从新页面回到本页时触发。
  ///
  /// 这里**不**主动恢复播放（避免突然外放），仅把 `isPageActive` 置回 true，
  /// 让后续选集 / 付费成功重启 / 用户主动点击播放等正常流程不再被
  /// `pausePlayer` 留下的标志卡住。
  @override
  void didPopNext() {
    super.didPopNext();
    if (Get.isRegistered<VideoPageLogic>(tag: _logicTag)) {
      Get.find<VideoPageLogic>(tag: _logicTag).markPageActive();
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    Get.delete<VideoPageLogic>(tag: _logicTag, force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _VideoPagePageView(logicTag: _logicTag);
  }
}

class _VideoPagePageView extends StatelessWidget {
  const _VideoPagePageView({Key? key, required this.logicTag})
      : super(key: key);

  /// 由 [_VideoPagePageState] 注入的 logic tag，所有内部 [GetBuilder] 共用。
  final String logicTag;

  bool isBeforeToday(String time) {
    if (time != "0001-01-01T00:00:00Z") {
      var startDate = time;
      var endDate = DateTime.now();
      return DateTime.parse(startDate).isBefore(endDate);
    } else {
      return true;
    }
  }

  ContentModel? _selectedContent(VideoPageState state) =>
      _contentAt(state, state.selectedEpisode);

  ContentModel? _contentAt(VideoPageState state, int index) {
    final contents = state.mediaInfo?.data?.contents;
    if (contents == null || index < 0 || index >= contents.length) {
      return null;
    }
    return contents[index];
  }

  String _videoCover(VideoPageState state) {
    final info = state.mediaInfo?.data;
    if (info == null) return '';
    if (info.autoCover.isNotEmpty) return info.autoCover;
    if (!TextUtil.isEmpty(info.horizontalCover)) {
      return info.horizontalCover ?? '';
    }
    return info.verticalCover ?? '';
  }

  Widget _buildVideoCoverPlaceholder(VideoPageState state) {
    final cover = _videoCover(state);
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        Container(color: Colors.black),
        if (!TextUtil.isEmpty(cover))
          CustomImage(
            url: cover,
            height: 212.w,
            fit: BoxFit.cover,
          ),
        const LoadingWidget(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SafeArea(
        child: GetBuilder<VideoPageLogic>(
            tag: logicTag,
            builder: (logic) {
              VideoPageState state = logic.state;
              return Theme(
                data: ThemeData(
                  bottomSheetTheme: const BottomSheetThemeData(
                      backgroundColor: Colors.transparent),
                ),
                child: state.isFullScreenAdvs!
                    ? CustomImage(
                        url: state
                            .videoAdvertisement[state.randomAds!].resourceUrl!,
                        fit: BoxFit.cover,
                        // widthAndHeightAdaptive: true,
                        width: Screen.width,
                        height: Screen.height,
                      )
                    : Scaffold(
                        backgroundColor: Colors.transparent,
                        bottomSheet: Theme(
                          data: ThemeData(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            primaryColor: AppColor.paleGrey,
                            bottomSheetTheme: const BottomSheetThemeData(
                                backgroundColor: Colors.transparent),
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                                  background: AppColor.paleGrey,
                                ),
                          ),
                          child: !state.isSendList
                              ? Container(
                                  height: 0.w,
                                  color: AppColor.paleGrey,
                                )
                              : MsgSendComponent(
                                  id: state.mediaInfo?.data?.id.toString() ??
                                      '',
                                  type: CommentType.media,
                                  isSendList: state.isSendList,
                                  commentSuccessFun: logic.commentSuc,
                                  sid: _contentAt(state, state.index)?.id,
                                ),
                        ),
                        body: Column(
                          children: [
                            state.mediaInfo == null
                                ? Container(
                                    color: Colors.black,
                                    height: 212.w,
                                    child: const LoadingWidget(),
                                  )
                                : GetBuilder<VideoPageLogic>(
                                    tag: logicTag,
                                    id: "refreshVideo",
                                    builder: (logic) {
                                      // 1008 / 1038 命中且用户持券：先用观影券浮层
                                      // 替换原 VIP / 金币浮层；浮层唯一业务动作是使用观影券。
                                      if (logic.shouldShowMovieTicketOverlay) {
                                        return MovieTicketPlayerOverlay(
                                          cover: state
                                                  .mediaInfo?.data?.autoCover ??
                                              '',
                                          remainTickets: UserStore
                                                  .to
                                                  .getUserInfoModel
                                                  ?.movieTickets ??
                                              0,
                                          onBackTap: () => Get.back(),
                                          onUseTicketTap: logic
                                              .purchaseCurrentVideoByMovieTicket,
                                        );
                                      }
                                      // code=1008：会员付费浮层。
                                      if (logic.shouldShowVipPlayerOverlay) {
                                        return VipPlayerOverlay(
                                          cover: state
                                                  .mediaInfo?.data?.autoCover ??
                                              '',
                                          onBackTap: () => Get.back(),
                                          onInviteTap: () => Get.toNamed(
                                              AppRoutes.SHARE_INVITE),
                                          onOpenMemberTap: () {
                                            Get.toNamed(
                                              AppRoutes.MEMBER_CENTER,
                                              arguments: {"initialIndex": 0},
                                            )?.then((_) {
                                              logic.startVideoPlayer(
                                                state.selectedEpisode,
                                              );
                                            });
                                          },
                                        );
                                      }
                                      // code=1038：金币付费浮层。1035 不是详情接口的返回，
                                      // 而是 videoGoldPay 接口的支付失败码，由 logic
                                      // 在扣费失败时把 state.goldOverlayInsufficient 置 true
                                      // 让浮层临时切换成「金币不足」形态。
                                      if (logic.shouldShowGoldPlayerOverlay) {
                                        final bool isInsufficientGold =
                                            state.goldOverlayInsufficient;
                                        return GoldPlayerOverlay(
                                          cover: state
                                                  .mediaInfo?.data?.autoCover ??
                                              '',
                                          priceGold:
                                              state.mediaInfo?.data?.price ?? 0,
                                          remainGold: UserStore
                                                  .to
                                                  .getUserInfoModel
                                                  ?.walletApp ??
                                              0,
                                          isInsufficientGold:
                                              isInsufficientGold,
                                          onBackTap: () => Get.back(),
                                          // 1038 → 调 [MediaApi.videoGoldPay] 扣金币，成功后内部刷详情；
                                          // 1035 → 跳钱包充值，返回后 [handleWalletPurchaseReturn]
                                          //          会按「用户金币 vs 视频金币」决定是否重拉详情 + 重启播放。
                                          onUnlockTap: () {
                                            if (isInsufficientGold) {
                                              Get.toNamed(AppRoutes.WALLET)
                                                  ?.then((_) {
                                                logic
                                                    .handleWalletPurchaseReturn();
                                              });
                                            } else {
                                              Get.toNamed(
                                                  AppRoutes.SHARE_INVITE);
                                            }
                                          },
                                          onOpenMemberTap: () {
                                            if (isInsufficientGold) {
                                              Get.toNamed(
                                                AppRoutes.MEMBER_CENTER,
                                                arguments: {"initialIndex": 0},
                                              )?.then((_) {
                                                logic.startVideoPlayer(
                                                  state.selectedEpisode,
                                                );
                                              });
                                            } else {
                                              logic
                                                  .purchaseCurrentVideoByGold();
                                            }
                                          },
                                        );
                                      }
                                      if (state.mediaInfo?.data == null) {
                                        return Container(
                                          color: Colors.black,
                                          height: 212.w,
                                          child: const LoadingWidget(),
                                        );
                                      }
                                      if (!UserStore.to.isVip()) {
                                        final selectedContent =
                                            _selectedContent(state);
                                        if (state.mediaInfo?.data != null &&
                                            selectedContent?.price != 0 &&
                                            selectedContent
                                                    ?.mediaStatus?.hasPaid ==
                                                true &&
                                            !state.isCloseAdvs!) {
                                          return SizedBox(
                                            height: 212.w,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    if (state
                                                            .chewieController !=
                                                        null) {
                                                      state.chewieController
                                                          ?.pause();
                                                      state
                                                          .videoPlayerController
                                                          ?.pause();
                                                    }

                                                    state.videoAdvertisement[state.randomAds!].jumpAdvByType(AdsType.bannerPlay);

                                                    if (state
                                                            .chewieController !=
                                                        null) {
                                                      state.chewieController!
                                                          .pause();
                                                    }
                                                  },
                                                  child: CustomImage(
                                                    url: state
                                                        .videoAdvertisement[
                                                            state.randomAds!]
                                                        .resourceUrl!,
                                                    height: 212.w,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 12,
                                                  right: 12,
                                                  child: GetBuilder<
                                                          VideoPageLogic>(
                                                      tag: logicTag,
                                                      builder: (logic) {
                                                        if (state
                                                                .countdownTime <=
                                                            0) {
                                                          return clickAds(
                                                              logic);
                                                        } else {
                                                          return PlayerAdCountdownFloat(
                                                            countdownTime: state
                                                                .countdownTime,
                                                            actionText: '关闭',
                                                            onActionTap: () =>
                                                                startPlay(
                                                                    logic),
                                                          );
                                                        }
                                                      }),
                                                ),
                                                Positioned(
                                                  top: 16,
                                                  left: 16,
                                                  child: GestureDetector(
                                                      onTap: () {
                                                        Get.back();
                                                      },
                                                      child: Image.asset(
                                                        "assets/images/png/app_back.png",
                                                        width: 24.w,
                                                        height: 24.w,
                                                      )),
                                                ),
                                              ],
                                            ),
                                          );
                                        }

                                        if (state.mediaInfo != null &&
                                            state.videoAdvertisement
                                                .isNotEmpty &&
                                            !state.isCloseAdvs!) {
                                          return SizedBox(
                                            height: 212.w,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    if (state
                                                            .chewieController !=
                                                        null) {
                                                      state.chewieController
                                                          ?.pause();
                                                      state
                                                          .videoPlayerController
                                                          ?.pause();
                                                    }

                                                    state.videoAdvertisement[state.randomAds!].jumpAdvByType(AdsType.bannerPlay);

                                                    state.isSurface = false;

                                                    if (state
                                                            .chewieController !=
                                                        null) {
                                                      state.chewieController!
                                                          .pause();
                                                    }
                                                  },
                                                  child: CustomImage(
                                                    url: state
                                                        .videoAdvertisement[
                                                            state.randomAds!]
                                                        .resourceUrl!,
                                                    height: 212.w,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 12,
                                                  right: 12,
                                                  child: GetBuilder<
                                                          VideoPageLogic>(
                                                      tag: logicTag,
                                                      builder: (logic) {
                                                        if (state
                                                                .countdownTime <=
                                                            0) {
                                                          return clickAds(
                                                              logic);
                                                        } else {
                                                          return PlayerAdCountdownFloat(
                                                            width: 170.w,
                                                            countdownTime: state
                                                                .countdownTime,
                                                            countdownSuffix:
                                                                '秒后关闭',
                                                            actionText:
                                                                'VIP跳过广告',
                                                            onActionTap: () {
                                                              if (!UserStore.to
                                                                  .isVip()) {
                                                                state.isSurface =
                                                                    false;
                                                                Get.toNamed(
                                                                  AppRoutes
                                                                      .MEMBER_CENTER,
                                                                  arguments: {
                                                                    "initialIndex":
                                                                        0
                                                                  },
                                                                )?.then(
                                                                    (value) {
                                                                  state.isSurface =
                                                                      true;
                                                                });
                                                              } else {
                                                                startPlay(
                                                                    logic);
                                                                return;
                                                              }

                                                              if (state
                                                                      .countdownTime >
                                                                  0) return;
                                                              startPlay(logic);
                                                            },
                                                          );
                                                        }
                                                      }),
                                                ),
                                                Positioned(
                                                  top: 16,
                                                  left: 16,
                                                  child: GestureDetector(
                                                      onTap: () {
                                                        Get.back();
                                                      },
                                                      child: Image.asset(
                                                        "assets/images/png/app_back.png",
                                                        width: 24.w,
                                                        height: 24.w,
                                                      )),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      } else {
                                        if (UserStore
                                                .to.getUserInfoModel?.isVip ??
                                            false) {
                                          if (!state.isCloseAdvs!) {
                                            return SizedBox(
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (state
                                                              .chewieController !=
                                                          null) {
                                                        state.chewieController
                                                            ?.pause();
                                                        state
                                                            .videoPlayerController
                                                            ?.pause();
                                                      }

                                                      state.videoAdvertisement[state.randomAds!].jumpAdvByType(AdsType.bannerPlay);

                                                      state.isSurface = false;

                                                      if (state
                                                              .chewieController !=
                                                          null) {
                                                        state.chewieController!
                                                            .pause();
                                                      }
                                                    },
                                                    child: CustomImage(
                                                      url: state
                                                          .videoAdvertisement[
                                                              state.randomAds!]
                                                          .resourceUrl!,
                                                      height: 212.w,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 12,
                                                    right: 12,
                                                    child: GetBuilder<
                                                            VideoPageLogic>(
                                                        tag: logicTag,
                                                        builder: (logic) {
                                                          if (state
                                                                  .countdownTime <=
                                                              0) {
                                                            return clickAds(
                                                                logic);
                                                          } else {
                                                            return PlayerAdCountdownFloat(
                                                              countdownTime: state
                                                                  .countdownTime,
                                                              actionText: '关闭',
                                                              onActionTap: () {
                                                                if (!UserStore
                                                                    .to
                                                                    .isVip()) {
                                                                  if (state
                                                                          .mediaInfo!
                                                                          .data!
                                                                          .contents[
                                                                              state.selectedEpisode]
                                                                          .mediaStatus
                                                                          ?.hasPaid ==
                                                                      true) {
                                                                    startPlay(
                                                                        logic);
                                                                  } else {
                                                                    showToast(
                                                                        msg:
                                                                            "VIP用户才可以关闭");
                                                                    return;
                                                                  }
                                                                } else {
                                                                  startPlay(
                                                                      logic);
                                                                  return;
                                                                }

                                                                if (state
                                                                        .countdownTime >
                                                                    0) return;
                                                                startPlay(
                                                                    logic);
                                                              },
                                                            );
                                                          }
                                                        }),
                                                  ),
                                                  Positioned(
                                                    top: 16,
                                                    left: 16,
                                                    child: GestureDetector(
                                                        onTap: () {
                                                          Get.back();
                                                        },
                                                        child: Image.asset(
                                                          "assets/images/png/app_back.png",
                                                          width: 24.w,
                                                          height: 24.w,
                                                        )),
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else {
                                            state.isAutoPlay = true;
                                            return Container(
                                              color: Colors.black,
                                              height: 212.w,
                                              child: logic.state
                                                          .chewieController ==
                                                      null
                                                  ? _buildVideoCoverPlaceholder(
                                                      state)
                                                  : Stack(
                                                      alignment:
                                                          AlignmentDirectional
                                                              .center,
                                                      children: [
                                                        VisibilityDetector(
                                                          key: Key(logic
                                                              .state
                                                              .mediaInfo!
                                                              .data!
                                                              .id!),
                                                          onVisibilityChanged:
                                                              (VisibilityInfo
                                                                  info) {
                                                            if (info.visibleFraction ==
                                                                0) {
                                                              if (state.chewieController !=
                                                                      null &&
                                                                  state.videoPlayerController !=
                                                                      null) {
                                                                state
                                                                    .chewieController!
                                                                    .pause();
                                                              }
                                                            }
                                                          },
                                                          child: Chewie(
                                                            controller: logic
                                                                .state
                                                                .chewieController!,
                                                          ),
                                                        ),
                                                        _buildVipPermissionBadge(
                                                            logic, state),
                                                        _buildGoldPermissionBadge(
                                                            logic, state),
                                                      ],
                                                    ),
                                            );
                                          }
                                        }

                                        if (state.mediaInfo != null &&
                                            state.videoAdvertisement
                                                .isNotEmpty &&
                                            state
                                                    .mediaInfo!
                                                    .data!
                                                    .contents[
                                                        state.selectedEpisode]
                                                    .mediaStatus
                                                    ?.hasPaid ==
                                                true) {
                                          if (state.timer != null) {
                                            state.timer!.cancel();
                                          }

                                          state.isAutoPlay = true;

                                          chewiePlay(state);

                                          return Container(
                                            color: Colors.black,
                                            height: 212.w,
                                            child: logic.state
                                                        .chewieController ==
                                                    null
                                                ? _buildVideoCoverPlaceholder(
                                                    state)
                                                : Stack(
                                                    alignment:
                                                        AlignmentDirectional
                                                            .center,
                                                    children: [
                                                      VisibilityDetector(
                                                        key: Key(logic
                                                            .state
                                                            .mediaInfo!
                                                            .data!
                                                            .id!),
                                                        onVisibilityChanged:
                                                            (VisibilityInfo
                                                                info) {
                                                          if (info.visibleFraction ==
                                                              0) {
                                                            if (state.chewieController !=
                                                                    null &&
                                                                state.videoPlayerController !=
                                                                    null) {
                                                              state
                                                                  .chewieController!
                                                                  .pause();
                                                            }
                                                          }
                                                        },
                                                        child: Chewie(
                                                          controller: logic
                                                              .state
                                                              .chewieController!,
                                                        ),
                                                      ),
                                                      _buildVipPermissionBadge(
                                                          logic, state),
                                                      _buildGoldPermissionBadge(
                                                          logic, state),
                                                      _buildHistoryFloat(
                                                          logic, state),
                                                    ],
                                                  ),
                                          );
                                        } else if (state.mediaInfo != null &&
                                            state.videoAdvertisement
                                                .isNotEmpty &&
                                            state
                                                    .mediaInfo!
                                                    .data!
                                                    .contents[
                                                        state.selectedEpisode]
                                                    .mediaStatus
                                                    ?.hasPaid !=
                                                true &&
                                            !state.isCloseAdvs!) {
                                          return SizedBox(
                                            height: 212.w,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    if (state
                                                            .chewieController !=
                                                        null) {
                                                      state.chewieController
                                                          ?.pause();
                                                      state
                                                          .videoPlayerController
                                                          ?.pause();
                                                    }

                                                    state.videoAdvertisement[state.randomAds!].jumpAdvByType(AdsType.bannerPlay);

                                                    state.isSurface = false;

                                                    if (state
                                                            .chewieController !=
                                                        null) {
                                                      state.chewieController!
                                                          .pause();
                                                    }
                                                  },
                                                  child: CustomImage(
                                                    url: state
                                                        .videoAdvertisement[
                                                            state.randomAds!]
                                                        .resourceUrl!,
                                                    height: 212.w,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 12,
                                                  right: 12,
                                                  child: GetBuilder<
                                                          VideoPageLogic>(
                                                      tag: logicTag,
                                                      builder: (logic) {
                                                        if (state
                                                                .countdownTime <=
                                                            0) {
                                                          return clickAds(
                                                              logic);
                                                        } else {
                                                          return PlayerAdCountdownFloat(
                                                            countdownTime: state
                                                                .countdownTime,
                                                            actionText: '关闭',
                                                            onActionTap: () {
                                                              if (!UserStore.to
                                                                  .isVip()) {
                                                                if (state
                                                                        .mediaInfo!
                                                                        .data!
                                                                        .contents[
                                                                            state.selectedEpisode]
                                                                        .mediaStatus
                                                                        ?.hasPaid ==
                                                                    true) {
                                                                  startPlay(
                                                                      logic);
                                                                } else {
                                                                  return;
                                                                }
                                                              } else {
                                                                startPlay(
                                                                    logic);
                                                                return;
                                                              }

                                                              if (state
                                                                      .countdownTime >
                                                                  0) return;
                                                              startPlay(logic);
                                                            },
                                                          );
                                                        }
                                                      }),
                                                ),
                                                Positioned(
                                                  top: 16,
                                                  left: 16,
                                                  child: GestureDetector(
                                                      onTap: () {
                                                        Get.back();
                                                      },
                                                      child: Image.asset(
                                                        "assets/images/png/app_back.png",
                                                        width: 24.w,
                                                        height: 24.w,
                                                      )),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      }
                                      return SizedBox(
                                        height: 212.w,
                                        child: logic.state.chewieController ==
                                                null
                                            ? _buildVideoCoverPlaceholder(state)
                                            : Stack(
                                                alignment:
                                                    AlignmentDirectional.center,
                                                children: [
                                                  VisibilityDetector(
                                                    key: Key(logic.state
                                                        .mediaInfo!.data!.id!),
                                                    onVisibilityChanged:
                                                        (VisibilityInfo info) {
                                                      if (info.visibleFraction ==
                                                          0) {
                                                        final state =
                                                            logic.state;
                                                        if (state.chewieController != null &&
                                                            state.videoPlayerController !=
                                                                null &&
                                                            state
                                                                    .videoPlayerController
                                                                    ?.value
                                                                    .isPlaying ==
                                                                true) {
                                                          state
                                                              .chewieController!
                                                              .pause();
                                                        }
                                                      }
                                                    },
                                                    child: Chewie(
                                                      controller: logic.state
                                                          .chewieController!,
                                                    ),
                                                  ),
                                                  _buildVipPermissionBadge(
                                                      logic, state),
                                                  _buildGoldPermissionBadge(
                                                      logic, state),
                                                  _buildHistoryFloat(
                                                      logic, state),
                                                ],
                                              ),
                                      );
                                    }),
                            _buildVideoVipBanner(),
                            _buildVideoTabHeader(context, logic, state),
                            Expanded(
                              child: _buildVideoTabBody(context, logic, state),
                            ),
                          ],
                        ),
                      ),
              );
            }),
      ),
    );
  }

  /// 视频详情顶部「VIP 卡」横幅。
  ///
  /// - 当前用户已是会员（[UserStore.isVip]）时整条横幅隐藏；
  /// - 卡名从 [VipCardModel.name] 取（`MineApis.getVipCardList` 返回列表的
  ///   第一张），由 [VideoPageLogic._loadVipBannerCard] 写入
  ///   [VideoPageState.vipBannerCardName]；接口未返回时回退到占位文案，避免
  ///   首帧空白。
  Widget _buildVideoVipBanner() {
    return GetBuilder<VideoPageLogic>(
      tag: logicTag,
      id: 'vipBanner',
      builder: (logic) {
        if (UserStore.to.isVip()) {
          return const SizedBox.shrink();
        }
        final String cardName =
            logic.state.vipBannerCardName?.trim().isNotEmpty == true
                ? logic.state.vipBannerCardName!
                : '';
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Get.toNamed(AppRoutes.MEMBER_CENTER),
          child: Container(
            height: 35.w,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetsGen.images.video.icPlayerVipBg.provider(),
                fit: BoxFit.fill,
              ),
            ),
            padding:
                EdgeInsets.symmetric(horizontal: 16.w).copyWith(left: 57.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    cardName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                3.w.horizontalSpace,
                AssetsGen.images.video.icPlayerVipEnter.image(
                  width: 78.w,
                  height: 22.w,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 播放器浮层：右上角会员权限提示。
  Widget _buildVipPermissionBadge(
    VideoPageLogic logic,
    VideoPageState state,
  ) {
    return Visibility(
      visible: PlayerCodeManage.requiresMemberPay(state.mediaInfo?.code) &&
          state.isCanPlay != true,
      child: Positioned(
        top: 11.w,
        right: 13.w,
        child: PlayerPermissionBadge(
          highlightText: '开通会员',
          highlightColor: const Color(0xfffde39c),
          onTap: logic.showVipDialog,
        ),
      ),
    );
  }

  /// 播放器浮层：右上角金豆解锁提示。
  Widget _buildGoldPermissionBadge(
    VideoPageLogic logic,
    VideoPageState state,
  ) {
    return Visibility(
      visible: PlayerCodeManage.requiresGoldPay(state.mediaInfo?.code) &&
          state.isCanPlay != true,
      child: Positioned(
        top: 11.w,
        right: 13.w,
        child: PlayerPermissionBadge(
          highlightText: '金豆解锁',
          highlightColor: const Color(0xffff8f4c),
          onTap: logic.showGoldenDialog,
        ),
      ),
    );
  }

  /// 播放器浮层：左下角历史观看进度提示。
  Widget _buildHistoryFloat(
    VideoPageLogic logic,
    VideoPageState state,
  ) {
    return PlayerHistoryFloat(
      visible: state.showHistoryDurationView(),
      timeText: state.getTime(),
      onJumpTap: logic.seekToHistory,
    );
  }

  Widget _buildVideoTabHeader(
    BuildContext context,
    VideoPageLogic logic,
    VideoPageState state,
  ) {
    return Container(
      height: 44.w,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
          color: const Color(0xFF061C1B),
          border: Border(
              bottom: BorderSide(
                  width: 1.h, color: Colors.white.withOpacity(.15)))),
      child: Row(
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              tabBarTheme: const TabBarTheme(dividerColor: Colors.transparent),
            ),
            child: SizedBox(
              width: 145.w,
              child: TabBar(
                controller: state.tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelPadding: EdgeInsets.only(right: 18.w),
                indicatorPadding: EdgeInsets.only(bottom: 3.w),
                indicator: UnderlineTabIndicator(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(10.r)),
                  borderSide: BorderSide(
                    width: 3.w,
                    color: AppColor.primaryButtonColor,
                  ),
                  insets: EdgeInsets.symmetric(horizontal: 10.w),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.5),
                labelStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
                tabs: [
                  const Tab(text: '简介'),
                  Tab(
                    child: Obx(
                      () => Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('评论'),
                          3.w.horizontalSpace,
                          Text(
                            '${state.countComment.value}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _showVideoLineSwitchSheet(context, logic, state),
            child: Row(
              children: [
                AssetsGen.images.video.icLineSwitch.image(
                  width: 14.w,
                  height: 14.w,
                ),
                10.w.horizontalSpace,
                Text(
                  '线路切换',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoTabBody(
    BuildContext context,
    VideoPageLogic logic,
    VideoPageState state,
  ) {
    final info = state.mediaInfo?.data;
    if (state.mediaInfo == null) return const LoadingWidget();
    if (info == null) {
      return Container(
        color: const Color(0xFF061C1B),
        child: const SizedBox.shrink(),
      );
    }
    return Container(
      color: const Color(0xFF061C1B),
      child: TabBarView(
        controller: state.tabController,
        children: [
          _buildVideoIntroPage(context, logic, state),
          _buildVideoCommentPage(state),
        ],
      ),
    );
  }

  Widget _buildVideoIntroPage(
    BuildContext context,
    VideoPageLogic logic,
    VideoPageState state,
  ) {
    final info = state.mediaInfo?.data;
    if (info == null) return const SizedBox.shrink();
    return PullRefreshView(
      controller: state.guessLikePullRefresh,
      onRefresh: logic.onGuessLikeRefresh,
      onLoading: logic.onGuessLikeLoadMore,
      enablePullUp: state.guessLikeList.isNotEmpty,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 28.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              info.title ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            10.w.verticalSpace,
            _buildVideoTagChips(state),
            16.w.verticalSpace,
            _buildVideoAuthorInfo(logic, state),
            16.w.verticalSpace,
            _buildVideoActionRow(context, logic, state),
            if (info.contents.length > 1) ...[
              16.w.verticalSpace,
              _buildVideoEpisodeSection(logic, state),
            ],
            16.w.verticalSpace,
            _buildNewAdBanner(state),
            16.w.verticalSpace,
            GetBuilder<VideoPageLogic>(
              tag: logicTag,
              id: 'guessLike',
              builder: (_) => _buildVideoRecommendSection(logic, state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoTagChips(VideoPageState state) {
    final tags = state.mediaInfo?.result?.vod?.tags ?? [];
    if (tags.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 4.w,
      runSpacing: 4.w,
      children: tags
          .map(
            (e) => GestureDetector(
              onTap: () async {
                // 当前 logic 实例由 _VideoPagePageState 的 dispose 负责释放。
                Get.delete<TagDetailLogic>();
                await state.chewieController?.pause();
                // 走 [TopicMoreDetailRoute.replace] 把当前视频页替换为
                // TopicMoreDetail：内部生成唯一 tag，binding 据此注册一份
                // 独立 logic 实例，栈上叠多份 TopicMoreDetail 不会互相覆盖。
                TopicMoreDetailRoute.replace(
                        topicName: e,
                        videoType: state.mediaInfo?.result?.vod?.videoType ?? 0,
                        keywordType: 1)
                    .then((value) => chewiePlay(state));
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  e,
                  style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildVideoAuthorInfo(VideoPageLogic logic, VideoPageState state) {
    final author = state.mediaInfo?.result?.author;
    final vod = state.mediaInfo?.result?.vod;
    final vodAuthorName = vod?.authorName?.trim();
    final authorName = author?.nickName?.trim().isNotEmpty == true
        ? author!.nickName
        : (vodAuthorName != null && vodAuthorName.isNotEmpty
            ? vodAuthorName
            : null);
    final int? uid = author?.id;
    // final hasFollowed = author?.follow ?? false;
    return clickButton(
      openLimit: true,
      onTap: () {
        if (uid == null || uid <= 0) {
          showToast(msg: '用户信息不存在');
          return;
        }
        Get.toNamed(
          AppRoutes.USER_CENTER,
          arguments: <String, dynamic>{
            'uid': uid,
            'author': <String, dynamic>{
              'id': author?.id,
              'avatar': author?.avatar,
              'nickName': author?.nickName,
              'follow': author?.follow,
              'fansNum': author?.fansNum,
              'vnum': author?.vnum,
              'pnum': author?.pnum,
            },
          },
        )?.then(logic.applyAuthorReturn);
      },
      child: Row(
        children: [
          ClipOval(
            child: CustomImage(
              url: author?.avatar ?? '',
              width: 40.w,
              height: 40.w,
              fit: BoxFit.cover,
            ),
          ),
          12.w.horizontalSpace,
          Expanded(
            child: Text(
              TextUtil.isEmpty(authorName) ? '创作者' : authorName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            children: [
              Text(
                '作品 ${(author?.vnum ?? 0) + (author?.pnum ?? 0)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              getSuLine(left: 10.w, right: 10.w),
              Text(
                '粉丝 ${author?.fansNum ?? 0}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          // if (uid != null && uid > 0)
          // GestureDetector(
          //   behavior: HitTestBehavior.opaque,
          //   onTap: logic.followAuthor,
          //   child: Container(
          //     alignment: Alignment.center,
          //     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
          //     decoration: BoxDecoration(
          //       color: hasFollowed
          //           ? Colors.white.withOpacity(0.1)
          //           : const Color(0xFFF92B6C),
          //       borderRadius: BorderRadius.circular(14.w),
          //     ),
          //     child: Text(
          //       hasFollowed ? '已关注' : '关注',
          //       style: TextStyle(
          //         color: hasFollowed
          //             ? Colors.white.withOpacity(0.6)
          //             : Colors.white,
          //         fontSize: 12.sp,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildVideoActionRow(
    BuildContext context,
    VideoPageLogic logic,
    VideoPageState state,
  ) {
    final info = state.mediaInfo?.data;
    final count = getShowCountStr(info?.countBrowse ?? 0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$count 观看量',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        _buildVideoIconAction(
          icon: (state.isLike ?? false)
              ? AssetsGen.images.video.icVideoLiked
              : AssetsGen.images.video.icVideoLiked,
          color: (state.isLike ?? false) ? null : Colors.white,
          text: getShowCountStr(state.countLike ?? 0),
          onTap: () => logic.likeVideo(),
        ),
        16.w.horizontalSpace,
        _buildVideoIconAction(
          icon: (state.isCollected ?? false)
              ? AssetsGen.images.video.icVideoCollected
              : AssetsGen.images.video.icVideoCollect,
          text: getShowCountStr(state.countCollect ?? 0),
          onTap: () => logic.collectVideo(),
        ),
        // VideoLoadButton(
        //   videoModel: state.mediaInfo?.data,
        //   index: state.index,
        //   pageType: 0,
        // ),
        16.w.horizontalSpace,
        _buildVideoIconAction(
          icon: AssetsGen.images.video.icVideoShare,
          text: '分享',
          onTap: () {
            final PostList item =
                PostList.fromJson(state.mediaInfo!.data!.toJson());
            item.cover = TextUtil.isEmpty(state.mediaInfo!.data!.verticalCover)
                ? state.mediaInfo!.data!.horizontalCover
                : state.mediaInfo!.data!.verticalCover;
            ShareVideoView.show(context, item.cover);
          },
        ),
      ],
    );
  }

  Widget _buildVideoIconAction({
    Color? color,
    required AssetGenImage icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon.image(width: 20.w, height: 20.w, color: color),
          4.w.horizontalSpace,
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoEpisodeSection(VideoPageLogic logic, VideoPageState state) {
    final contents = state.mediaInfo?.data?.contents ?? [];
    if (contents.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选集',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        12.w.verticalSpace,
        SizedBox(
          height: 34.w,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: contents.length,
            separatorBuilder: (_, __) => 8.w.horizontalSpace,
            itemBuilder: (context, index) {
              final selected = index == state.selectedEpisode;
              return GestureDetector(
                onTap: () {
                  initAdsTimer(logic, isSwitchVideo: true, index: index);
                  logic.startVideoPlayer(index);
                },
                child: Container(
                  width: 58.w,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColor.primaryButtonColor.withOpacity(0.18)
                        : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6.w),
                    border: Border.all(
                      color: selected
                          ? AppColor.primaryButtonColor
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    contents[index].name ?? '第${index + 1}集',
                    style: TextStyle(
                      color: selected
                          ? AppColor.primaryButtonColor
                          : Colors.white.withOpacity(0.72),
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideoRecommendSection(
      VideoPageLogic logic, VideoPageState state) {
    final items = state.guessLikeList;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40.h,
          child: Text(
            '猜你喜欢',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (items.isNotEmpty)
          GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 13.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 165 / 155,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return MediaCoverItem(
                model: item,
                displayType: MediaCoverDisplayType.landscape,
                onTap: () async {
                  await state.chewieController?.pause();
                  // 同路由跳转必须显式关掉 `preventDuplicates`，否则 GetX 判定
                  // "当前已经是 VIDEO_PAGE" 直接吞掉这次跳转，看起来像没动。
                  Get.offNamed(
                    AppRoutes.VIDEO_PAGE,
                    arguments: {'id': item.id},
                    preventDuplicates: false,
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildVideoCommentPage(VideoPageState state) {
    return Container(
      color: AppColor.scaffoldBackground,
      padding: EdgeInsets.fromLTRB(16.w, 8.w, 16.w, 92.w),
      child: CommentComponent(
        id: state.mediaInfo?.data?.id.toString() ?? '',
        isNeedInnerScroll: true,
        isShowAllCommentsTitle: false,
        type: CommentType.media,
        sId: _selectedContent(state)?.id,
      ),
    );
  }

  void _showVideoLineSwitchSheet(
    BuildContext context,
    VideoPageLogic logic,
    VideoPageState state,
  ) {
    showLineSwitchBottomSheet(
      context: context,
      title: '视频线路',
      lines: lineSwitchItemsFromPlayLines(Address.h5PlayLines ?? []),
      selectedLine: Address.h5PlayLine,
      onSelected: (item, _) {
        Address.h5PlayLine = item.line;
        logic.update();
        logic.startVideoPlayer(state.selectedEpisode);
      },
    );
  }

  //新版广告：长视频播放页 banner + icon 组合广告
  Widget _buildNewAdBanner(state) {
    return const AdsBannerIconGroup(
      // bannerType: AdsType.bannerPlay,
      iconType: AdsType.dbLineHeadPlay,
    );
  }

  /// 播放器浮层：广告倒计时结束后的关闭按钮。
  Widget clickAds(VideoPageLogic logic) {
    var state = logic.state;
    return GetBuilder<VideoPageLogic>(
      tag: logicTag,
      id: "refreshCloseButton",
      builder: (logic) {
        return PlayerAdCloseFloat(
          onCloseTap: () {
            state.isCloseAdvs = true;
            logic.update();
            logic.update(["refreshVideo"]);
            chewiePlay(state);
          },
        );
      },
    );
  }

  void initAdsTimer(VideoPageLogic logic, {bool? isSwitchVideo, int? index}) {
    var state = logic.state;
    if (state.videoAdvertisement.isNotEmpty) {
      state.randomAds = Random().nextInt(state.videoAdvertisement.length);
      logic.state.timer!.cancel();
      logic.state.isCloseAdvs = false;
      logic.state.countdownTime = ConfigStore.to.configBean.adsTimeLongVideo;
      logic.startTimer();
    }

    logic.update(["refreshVideo"]);
  }

  Future chewiePlay(state) async {
    if (state.isSurface) {
      state.chewieController?.play();
    }
  }

  void startPlay(VideoPageLogic logic) {
    var state = logic.state;
    state.isCloseAdvs = true;
    state.timer?.cancel();
    logic.update();

    chewiePlay(state);
  }
}
