library short_video_player;

import 'dart:async';
import 'dart:developer';

import 'package:comics_app/common/res/r.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/screen.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/common/widgets/loading_widget.dart';
import 'package:flutter/material.dart';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

part 'src/short_video_player_pool.dart';
part 'src/controller.dart';
part 'src/landscape_player_controls.dart';
part 'src/landscape_player_toggle_button.dart';

enum ShortVideoPlayerPageType {
  primary,
  secondary,
}

class ShortVideoPlayer<T> extends StatelessWidget {
  const ShortVideoPlayer({
    super.key,
    this.cover,
    this.loadingFallback,
    required this.videoController,
    this.progressBarMarginBottom = 0,
    this.pageType = ShortVideoPlayerPageType.secondary,
    this.autoPlay = true,
  });

  final String? cover;
  final Widget Function()? loadingFallback;
  final VideoController<T> videoController;
  final double progressBarMarginBottom;
  final ShortVideoPlayerPageType pageType;

  /// 是否在 [FlickManager] 第一次构造时自动起播。
  ///
  /// `FlickManager` 内部把 `autoPlay` 锁在构造期（`_changeVideo` 只跑一次），
  /// 所以这个值只在「[ShortVideoPlayer] 首次进入树（即 `hasController` 第一次
  /// 变 true 时）」起效；之后即便外部把 `autoPlay` 改成 `true` 也不会再触发，
  /// 此时需走 [VideoController.play] 显式恢复。
  ///
  /// 用于覆盖：用户已经离开当前页（例如底部一级 tab 已切走）但视频还在
  /// 后台 `controller.initialize()` 的赛跑场景 —— 不抑制 FlickManager 的
  /// autoPlay，初始化完成那一刻就会把音频带出来。
  final bool autoPlay;

  @override
  Widget build(BuildContext context) {
    return FlickVideoPlayer(
      flickVideoWithControls: FlickVideoWithControls(
        backgroundColor: AppColor.scaffoldBackground,
        controls: LandscapePlayerControls(
          progressBarMarginBottom: progressBarMarginBottom,
          pageType: pageType,
        ),
        videoFit: BoxFit.fitWidth,
        playerLoadingFallback: loadingFallback != null
            ? loadingFallback!.call()
            : Center(
                child: Stack(
                  children: [
                    CustomImage(
                      url: cover,
                      fit: BoxFit.fitWidth,
                    ),
                    const LoadingWidget()
                  ],
                ),
              ),
      ),
      flickManager: FlickManager(
        autoInitialize: false,
        autoPlay: autoPlay,
        videoPlayerController: videoController.controller,
      ),
    );
  }
}
