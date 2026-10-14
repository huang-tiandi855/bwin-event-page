import 'package:comics_app/common/apis/media_api.dart';
import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/entities/module_detail_model/content_model.dart';
import 'package:comics_app/common/entities/module_detail_model/content_model_extension.dart';
import 'package:comics_app/common/extension/int_extension.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/utils/debug_log.dart';
import 'package:comics_app/common/utils/history_record_util.dart';
import 'package:comics_app/common/values/config.dart';
import 'package:comics_app/common/values/enum.dart';
import 'package:comics_app/common/values/varibel_config.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/common/widgets/empty_widget.dart';
import 'package:comics_app/common/widgets/memberPaying.dart';
import 'package:comics_app/common/widgets/new_gold_paying.dart';
import 'package:comics_app/short_video/player/short_video_player.dart';
import 'package:comics_app/common/values/address.dart';
import 'package:comics_app/common/widgets/common_dialog/line_switch_bottom_sheet.dart';
import 'package:comics_app/generated/assets.dart';
import 'package:comics_app/pages/loading/loading_center_widget.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'media_episode_widget.dart';
import 'short_media_play_controller.dart';

class ShortMediaPlayPage extends StatelessWidget {
  const ShortMediaPlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ShortMediaPlayController>(
        init: ShortMediaPlayController(),
        builder: (_) {
          if (_.isLoading) {
            return Container(
              color: Colors.black,
              child: const LoadingCenterWidget(),
            );
          }

          return Stack(
            alignment: Alignment.centerRight,
            children: [
              Container(
                color: Colors.black,
                child: PageView.builder(
                  scrollDirection: Axis.vertical,
                  controller: _.playerPageController,
                  physics: const ClampingScrollPhysics(),
                  // allowImplicitScrolling: true,
                  itemCount: _.caculateTotalCount(),
                  itemBuilder: (__, index) {
                    final media = _.getPlayerData(index);
                    if (media == null) return const EmptyWidget();
                    return MediaPlayerWidget(media, fatherM: _.currentMedia!);
                  },
                ),
              ),
              Positioned(
                bottom: 185.w,
                child: StreamBuilder<AllMediaInfoModel?>(
                  stream: _.currentMediaInfo.stream,
                  builder: (__, data) => Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: _.visible
                        ? Column(
                            children: [
                              _buildButton(
                                icon: Assets.svgIcNotVisible,
                                onTap: () {
                                  _.onTapVisible();
                                },
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildButton(
                                icon: Assets.svgIcLike,
                                iconColor:
                                    (data.data?.mediaStatus?.hasLiked ?? false)
                                        ? const Color(0xFFF92B6C)
                                        : null,
                                text:
                                    (data.data?.countLike ?? 0).humanizeFormat,
                                onTap: _.likeOrDislikeMedia,
                              ),
                              20.verticalSpaceFromWidth,
                              _buildButton(
                                icon: Assets.svgShortCollect,
                                iconColor:
                                    (data.data?.mediaStatus?.hasCollected ??
                                            false)
                                        ? const Color(0xffF25477)
                                        : null,
                                text: (data.data?.mediaStatus?.hasCollected ??
                                        false)
                                    ? '已收藏'
                                    : '收藏',
                                onTap: _.collectMedia,
                              ),
                              20.verticalSpaceFromWidth,
                              _buildButton(
                                icon: Assets.svgIcComment,
                                text: '评论',
                                onTap: _.onTapComment,
                              ),
                              20.verticalSpaceFromWidth,
                              GestureDetector(
                                onTap: () {
                                  showLineSwitchBottomSheet(
                                    context: context,
                                    lines: lineSwitchItemsFromCdnDomains(
                                      Address.cdnAddressLists,
                                    ),
                                    selectedLine: Address.h5PlayLine,
                                    onSelected: (item, _) {
                                      Address.h5PlayLine = item.line;
                                      FBroadcast.instance().broadcast(
                                        Config.SWITCH_CDN_ADDRESS,
                                      );
                                    },
                                  );
                                },
                                child: _buildButton(
                                  icon: Assets.svgIcVideoLine,
                                  text: '线路',
                                ),
                              ),
                              20.verticalSpaceFromWidth,
                              _buildButton(
                                icon: Assets.svgIcVisible,
                                onTap: () {
                                  _.onTapVisible();
                                },
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildButton({
    required String icon,
    Color? iconColor,
    String? text,
    void Function()? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            icon,
            width: 30.w,
            color: iconColor,
          ),
          if (text?.isNotEmpty == true)
            Container(
              margin: EdgeInsets.only(top: 5.w),
              child: Text(
                text!,
                style: TextStyle(
                  color: AppColor.white,
                  fontSize: 12.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MediaPlayerWidget extends StatefulWidget {
  final ContentModel media;
  final AllMediaInfoModel fatherM;
  const MediaPlayerWidget(this.media, {super.key, required this.fatherM});

  @override
  State<MediaPlayerWidget> createState() => _MediaPlayerWidgetState();
}

class _MediaPlayerWidgetState extends State<MediaPlayerWidget> {
  VideoPlayerController? controller;
  VideoController<ContentModel>? videoController;
  ContentModel? _mediaModel;
  ContentModel get _media => _mediaModel!;
  bool isShowDialog = false;

  @override
  void initState() {
    super.initState();
    _mediaModel = widget.media;
    _initVideoPlayer();
    FBroadcast.instance()
        .register(Config.SWITCH_CDN_ADDRESS, _switchLineRefreshVideo);
  }

  @override
  void didUpdateWidget(covariant MediaPlayerWidget oldWidget) {
    if (oldWidget.media.id != widget.media.id) {
      _mediaModel = widget.media;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() async {
    MediaPlayRecord().insertSkits(
      model: widget.fatherM,
      episode: _media.episodeNumber != null ? _media.episodeNumber! - 1 : 0,
      position: controller?.value.position ?? Duration.zero,
    );

    controller?.pause();
    controller?.removeListener(_listener);
    videoController?.dispose();
    FBroadcast.instance()
        .remove(_switchLineRefreshVideo, key: Config.SWITCH_CDN_ADDRESS);
    super.dispose();
  }

  void _switchLineRefreshVideo(context, value) {
    final position = controller?.value.position ?? Duration.zero;
    controller?.pause();
    controller?.removeListener(_listener);
    videoController?.dispose();
    _initVideoPlayer(position);
  }

  //permission 0-会员视频 1-金币视频 2-免费视频
  checkAndShowDialog() async {
    ContentModel mediaContent = _media;

    if (mediaContent.needPermission == 0 || mediaContent.needPermission == 1) {
      onTapProductPrice().then((value) async {
        if (value == PaySuccess.exchangeSuccessFullly ||
            value == PaySuccess.successfulPurchase) {
          final controller = Get.find<ShortMediaPlayController>();
          await controller.updateMediaData();
          _mediaModel = controller.getPlayerData(controller.selectIndex);
          if (_media.canPlayShortMedia) {
            videoController?.play();
          }
        }
      });
      return;
    }
  }

  Future<dynamic> onTapProductPrice() {
    if (isShowDialog) {
      return Future.value(null);
    }
    // final videoInfo = state.info!;
    if (_media.needPermission == 0 || _media.needPermission == 1) {
      if (_media.needPermission == 0) {
        isShowDialog = true;
        return openMemberPaying(
          isShowCoupon: true,
          id: widget.fatherM.id,
          chatId: _media.id,
          productType: 28,
        ).then((value) {
          isShowDialog = false;
          return value;
        });
      } else {
        isShowDialog = true;
        return openNewGoldBeanPaying(
          info: widget.fatherM,
          currentIndex:
              _media.episodeNumber != null ? _media.episodeNumber! - 1 : 0,
          productType: 28,
        ).then((value) {
          isShowDialog = false;
          return value;
        });
      }
    }
    return Future.value(null);
  }

  _initVideoPlayer([Duration? position]) async {
    try {
      controller =
          VideoPlayerController.networkUrl(Uri.parse(_media.getRealVideoUrl));
      controller?.addListener(_listener);
      videoController = VideoController<ContentModel>(
        videoInfo: _media,
        builder: () => controller!,
        position: position ?? Duration.zero,
      );
      await videoController?.init(
        afterInit: (controller) async {
          if (_media.canPlayShortMedia) {
            controller.play();
          } else {
            checkAndShowDialog();
          }
        },
      );
    } catch (e) {
      debugLog("视频初始化失败：$e");
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _listener() async {
    if (!mounted) {
      return;
    }
    if (videoController == null) {
      return;
    }

    // print('chewieController ${chewieController?.isPlaying}');
    final isPlaying = controller?.value.isPlaying ?? false;
    if (!_media.canPlayShortMedia && isPlaying) {
      checkAndShowDialog();
      videoController?.pause();
    }
    if ((controller?.value.isCompleted ?? false)) {
      final controller = Get.find<ShortMediaPlayController>();
      controller.playerPageController.nextPage(
          duration: const Duration(milliseconds: 100), curve: Curves.linear);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (controller?.value.isPlaying ?? false) {
          videoController?.pause();
        } else {
          videoController?.play();
        }
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            // child: AspectRatio(
            //   aspectRatio: (_media.weight ?? 1280) / (_media.height ?? 720), // ?? resolutionSize?.aspectRatio ?? 1,
            //   child: ,
            // ),
            child: videoController == null
                ? const LoadingCenterWidget()
                : ShortVideoPlayer(
                    key: ValueKey(videoController.hashCode),
                    // cover: widget.fatherM.autoCover,
                    videoController: videoController!,
                    progressBarMarginBottom: 84.w,
                    loadingFallback: () {
                      return Center(
                        child: AspectRatio(
                          aspectRatio: (_media.weight ?? 1280) /
                              (_media.height ??
                                  720), // ?? resolutionSize?.aspectRatio ?? 1,
                          child: Stack(
                            children: [
                              CustomImage(
                                url: widget.fatherM.autoCover,
                                fit: BoxFit.fitWidth,
                              ),
                              const LoadingCenterWidget()
                            ],
                          ),
                        ),
                      );
                    }),
          ),
          MeadiaInfoWidget(
            _media,
            father: widget.fatherM,
            controller: controller,
          ),

          // if (chewieController?.isPlaying??false)
        ],
      ),
    );
  }
}

class MeadiaInfoWidget extends StatelessWidget {
  ContentModel model;
  AllMediaInfoModel father;
  VideoPlayerController? controller;
  MeadiaInfoWidget(this.model,
      {super.key, required this.father, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (controller != null)
            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: controller!,
              builder: (_, value, __) {
                final totalSecend = value.duration.inSeconds;
                final currentPosition = value.position.inSeconds;
                final diff = totalSecend - currentPosition;
                if (diff <= 5 && diff > 0) {
                  return Container(
                    height: 25,
                    width: 160,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.1),
                        borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '$diff秒后自动播放下一集',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          Row(
            children: [
              Text(
                '@${father.title ?? ''}',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500),
              ),
              12.horizontalSpace,
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: showTotalEpisode,
                child: Row(
                  children: [
                    Text(
                      '第${model.episodeNumber ?? 0}集',
                      style: TextStyle(
                          color: AppColor.primaryColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500),
                    ),
                    SvgPicture.asset(
                      Assets.svgIcArrowRight,
                      width: 14.w,
                      color: AppColor.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          12.verticalSpaceFromWidth,
          Text(
            father.summary ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400),
          ),

          // ShortProgressWidget(
          //   controller: controller,
          //   // key: logic.progressKey,
          // ),
          53.verticalSpaceFromWidth,
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: showTotalEpisode,
            child: Container(
              height: 42.w,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: ShapeDecoration(
                color: Colors.white.withOpacity(.1),
                shape: const StadiumBorder(),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    Assets.svgSmallTv,
                    width: 20.w,
                  ),
                  6.horizontalSpace,
                  Text(
                    '《${father.title ?? ''}》共${father.totalEpisode ?? 0}集',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  SvgPicture.asset(
                    Assets.svgIcArrowRight,
                    width: 18.w,
                  ),
                ],
              ),
            ),
          ),
          36.verticalSpaceFromWidth,
        ],
      ),
    );
  }

  showTotalEpisode() async {
    final index = model.episodeNumber ?? 0;
    final contents = father.contents;
    final shouldLoad = contents.length < (father.totalEpisode ?? 0);
    if (shouldLoad) {
      final resp = await MediaApi.getMediaInfo(father.id ?? '');
      if (resp.isSuccess) {
        father = AllMediaInfoModel.fromJson(resp.data);
      }
    }

    List<String>? lists = SpUtil.getStringList(VariableConfig.shortVideoRecord);
    if (lists!.isNotEmpty) {
      for (ContentModel mediaContent in contents) {
        for (String id in lists) {
          if (id == mediaContent.id) {
            mediaContent.isPlayed = true;
          }
        }
      }
    }

    ///短剧底部弹窗
    Get.bottomSheet(
      MediaTotalEpisodeBottomSheet(
        father,
        index: index,
      ),
      isScrollControlled: true,
    );
  }
}

class MediaTotalEpisodeBottomSheet extends StatelessWidget {
  final AllMediaInfoModel model;
  final int index;

  const MediaTotalEpisodeBottomSheet(
    this.model, {
    super.key,
    this.index = 0,
  });

  @override
  build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      constraints: BoxConstraints(maxHeight: Get.height / 2 + 100),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xff262626).withOpacity(.9),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10.r),
        ),
      ),
      child: SingleChildScrollView(
        // controller: controller,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 500.sizeBoxH,
            18.verticalSpaceFromWidth,
            Text(
              model.title ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            18.verticalSpaceFromWidth,
            MediaEpisodeWidget(
              model,
              selectEpisode: index,
              choseCallBack: (index) {
                // 这里需要去获取一下播放器的ctr
                if (Get.isRegistered<ShortMediaPlayController>()) {
                  final controller = Get.find<ShortMediaPlayController>();
                  controller.choseEpisode(model, index);
                  RecordEpisode(index);
                }
              },
            ),
            133.verticalSpaceFromWidth,
          ],
        ),
      ),
    );
  }

  void RecordEpisode(int index) {
    List<String>? listsRecord =
        SpUtil.getStringList(VariableConfig.shortVideoRecord);

    String id = model.contents[index].id ?? "";

    List<String>? lists = [id];

    lists.addAll(listsRecord!);

    SpUtil.putStringList(VariableConfig.shortVideoRecord, lists);
  }
}
