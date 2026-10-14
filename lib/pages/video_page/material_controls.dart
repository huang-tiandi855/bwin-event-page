// ignore_for_file: implementation_imports, depend_on_referenced_packages

import 'dart:async';

import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/chewie_progress_colors.dart';
import 'package:chewie/src/helpers/utils.dart';
import 'package:chewie/src/material/widgets/options_dialog.dart';
import 'package:chewie/src/models/option_item.dart';
import 'package:comics_app/common/res/r.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/loading_widget.dart';
import 'package:comics_app/pages/video_page/material_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
//import 'package:video_player_web_hls/video_player_web_hls.dart';
import 'package:video_player/video_player.dart';

import 'package:fbroadcast/fbroadcast.dart';
import 'package:wakelock/wakelock.dart';

import 'video_gesture_controls/video_gesture_controls.dart';

class MaterialControls extends StatefulWidget {
  const MaterialControls({
    this.showPlayButton = true,
    this.title,
    this.showBackButton = true,
    Key? key,
  }) : super(key: key);

  final bool showPlayButton;
  final String? title;
  final bool showBackButton;

  @override
  State<StatefulWidget> createState() {
    return _MaterialControlsState();
  }
}

class _MaterialControlsState extends State<MaterialControls>
    with SingleTickerProviderStateMixin {
  bool hideStuff = true;
  bool get isVertical => _latestValue.aspectRatio < 1.0;
  bool get hideHeader {
    return hideStuff && !isVertical;
  }

  double get bottom {
    if (isVertical && chewieController.isFullScreen) {
      return (MediaQuery.of(context).size.height -
                  MediaQuery.of(context).size.width /
                      _latestValue.size.aspectRatio) /
              2 -
          3;
    }
    return 0;
  }

  bool get showFullButton {
    // 非全屏以及竖屏全屏时显示全屏按钮
    return !chewieController.isFullScreen ||
        chewieController.isFullScreen && isVertical;
  }

  late VideoPlayerValue _latestValue;
  double? _latestVolume;
  Timer? _hideTimer;
  Timer? _initTimer;
  // ignore: unused_field
  Duration _subtitlesPosition = Duration.zero;
  bool _subtitleOn = false;
  Timer? _showAfterExpandCollapseTimer;
  // ignore: unused_field
  bool _displayTapped = false;
  Timer? _bufferingDisplayTimer;
  bool _displayBufferingIndicator = false;

  final GlobalKey _bottomBarKey = GlobalKey();

  final barHeight = 48.0 * 1.5;
  final marginSize = 5.0;

  late VideoPlayerController controller;
  ChewieController? _chewieController;

  // We know that _chewieController is set in didChangeDependencies
  ChewieController get chewieController => _chewieController!;

  bool showSeekTextOverlazy = false; // 是否显示进度调节UI

  @override
  void initState() {
    super.initState();

    /// 注册接收器
    /// register
    FBroadcast.instance().register("auto_pause", (value, callback) {
      _cancelAndRestartTimer();

      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          hideStuff = false;
          _hideTimer?.cancel();
          controller.pause();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (GetPlatform.isAndroid && _latestValue.hasError) {
      return chewieController.errorBuilder?.call(
            context,
            chewieController.videoPlayerController.value.errorDescription!,
          ) ??
          const Center(
            child: Icon(
              Icons.error,
              color: Colors.white,
              size: 42,
            ),
          );
    }

    return VideoGestureControls(
      showSeekTextOverlazy: showSeekTextOverlazy,
      horizontalDragAllowed: _allowHorizontalDragOutsideBottomBar,
      onTap: () {
        if (hideStuff == false) {
          _playPause();
          _cancelAndRestartTimer();
        } else {
          _cancelAndRestartTimer();
        }
      },
      onSkipBackward: () => _cancelAndRestartTimer(),
      onSkipForward: () => _cancelAndRestartTimer(),
      onDoubleTap: () => _playPause(),
      onHorizontalDragUpdate: (details) => _cancelAndRestartTimer(),
      onHorizontalDragEnd: (e) {
        if (!_latestValue.isPlaying) {
          controller.play();
        }
        _startHideTimer();
      },
      children: [
        if (_displayBufferingIndicator)
          const Center(
            child: LoadingWidget(),
          )
        else
          _buildPlayButton(
            size: adaptiveSize(48.w, 48.w, 90),
          ),
        _buildActionBar(),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Visibility(
            visible: GetPlatform.isAndroid ? true : false,
            child: AbsorbPointer(
              absorbing: hideHeader,
              child: AnimatedOpacity(
                opacity: hideHeader ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async {
                    if (chewieController.isFullScreen) {
                      chewieController.exitFullScreen();
                      Future.delayed(const Duration(milliseconds: 2000), () {
                        Wakelock.enable();
                      });
                    } else {
                      Get.back();

                      ConfigStore.to.autoPlayStreamController?.close();
                      await controller.dispose();
                      chewieController.dispose();
                      //controller = null;
                      //chewieController = null;
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: adaptiveSize(44.w, 44.w, 70),
                    padding: EdgeInsets.symmetric(
                      horizontal: adaptiveSize(10.w, 10.w, 56),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (widget.showBackButton ||
                            chewieController.isFullScreen)
                          SvgPicture.asset(
                            R.back,
                            width: adaptiveSize(20.w, 20.w, 20),
                            color: Colors.white,
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Visibility(
                            visible:
                                chewieController.isFullScreen && !isVertical
                                    ? true
                                    : false,
                            child: Text(
                              widget.title ?? "",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: bottom,
          child: _buildBottomBar(context),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideTimer?.cancel();
    _initTimer?.cancel();
    _showAfterExpandCollapseTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    final oldController = _chewieController;
    _chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;

    if (oldController != chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  double adaptiveSize(
    double size, [
    double? verticalFullScreenSize,
    double? fullScreenSize,
  ]) {
    if (chewieController.isFullScreen) {
      return isVertical
          ? verticalFullScreenSize ?? size
          : fullScreenSize ?? size;
    }
    return size;
  }

    /// 底栏区域由 [MaterialVideoProgressBar] 自行处理拖动；其余底栏区域不触发
  /// [VideoGestureControls] 的全屏横向快进/快退，避免与进度条拖动冲突。
  bool _allowHorizontalDragOutsideBottomBar(Offset globalPosition) {
    final BuildContext? bottomBarContext = _bottomBarKey.currentContext;
    if (bottomBarContext == null) {
      return true;
    }
    final RenderObject? renderObject = bottomBarContext.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return true;
    }
    final Offset topLeft = renderObject.localToGlobal(Offset.zero);
    final Offset bottomRight = renderObject.localToGlobal(
      renderObject.size.bottomRight(Offset.zero),
    );
    final Rect bottomBarRect = Rect.fromPoints(topLeft, bottomRight);
    return !bottomBarRect.contains(globalPosition);
  }

  Widget _buildActionBar() {
    return Positioned(
      top: 0,
      right: 0,
      child: SafeArea(
        child: AnimatedOpacity(
          opacity: hideStuff ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 250),
          child: Row(
            children: [
              _buildSubtitleToggle(),
              if (chewieController.showOptions) _buildOptionsButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsButton() {
    final options = <OptionItem>[
      OptionItem(
        onTap: () async {
          Navigator.pop(context);
          _onSpeedButtonTap();
        },
        iconData: Icons.speed,
        title: chewieController.optionsTranslation?.playbackSpeedButtonText ??
            'Playback speed',
      )
    ];

    if (chewieController.additionalOptions != null &&
        chewieController.additionalOptions!(context).isNotEmpty) {
      options.addAll(chewieController.additionalOptions!(context));
    }

    return AnimatedOpacity(
      opacity: hideStuff ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 250),
      child: IconButton(
        onPressed: () async {
          _hideTimer?.cancel();

          if (chewieController.optionsBuilder != null) {
            await chewieController.optionsBuilder!(context, options);
          } else {
            await showModalBottomSheet<OptionItem>(
              context: context,
              isScrollControlled: true,
              useRootNavigator: chewieController.useRootNavigator,
              builder: (context) => OptionsDialog(
                options: options,
                cancelButtonText:
                    chewieController.optionsTranslation?.cancelButtonText,
              ),
            );
          }

          if (_latestValue.isPlaying) {
            _startHideTimer();
          }
        },
        icon: const Icon(
          Icons.more_vert,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
  ) {
    return AbsorbPointer(
      absorbing: hideStuff,
      child: AnimatedOpacity(
        opacity: hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          key: _bottomBarKey,
          //color: Colors.blue,
          height: adaptiveSize(63.w, 63.w, 110),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0),
                Colors.black.withOpacity(1),
              ],
            ),
          ),
          // margin: EdgeInsets.only(bottom: widget.isShortVideo! ? 80.w : 0.w),
          padding: EdgeInsets.symmetric(
            horizontal: adaptiveSize(10.w, 10.w, 56),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: adaptiveSize(8.w, 8.w, 21)),
                height: adaptiveSize(18.w, 18.w, 20),
                child: Builder(
                  builder: (context) {
                    if (chewieController.isFullScreen && !isVertical) {
                      return SizedBox(child: _buildProgressBar());
                    }
                    return Row(
                      children: [
                        Text(
                          formatDuration(_latestValue.position),
                          style: TextStyle(
                            fontSize: adaptiveSize(12.sp, 12.sp, 16),
                            color: const Color(0xFFFFFDFF),
                          ),
                        ),
                        SizedBox(
                          width: adaptiveSize(10.w, 10.w, null),
                        ),
                        Expanded(child: _buildProgressBar()),
                        SizedBox(
                          width: adaptiveSize(10.w, 10.w, null),
                        ),
                        Text(
                          formatDuration(_latestValue.duration),
                          style: TextStyle(
                            fontSize: adaptiveSize(12.sp, 12.sp, 16),
                            color: const Color(0xFFFFFDFF),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(
                height: adaptiveSize(6.w, 6.w, 16),
              ),
              SizedBox(
                // height: adaptiveSize(14.w, 14.w, 20),
                child: Row(
                  children: [
                    _buildPlayButton(),
                    SizedBox(
                      width: adaptiveSize(14.w, 14.w, 12),
                    ),
                    // if (!chewieController.isFullScreen)
                    //   Container(
                    //     margin: EdgeInsets.only(
                    //       right: adaptiveSize(14.w, 14.w, 12),
                    //     ),
                    //     child: _buildPrevButton(),
                    //   ),
                    // Container(
                    //   margin: EdgeInsets.only(
                    //     right: adaptiveSize(14.w, 14.w, 12),
                    //   ),
                    //   child: _buildNextButton(),
                    // ),
                    if (chewieController.isFullScreen && !isVertical)
                      Text(
                        '${formatDuration(_latestValue.position)}/${formatDuration(_latestValue.duration)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFFFFFDFF),
                        ),
                      ),
                    const Spacer(),
                    _buildVolumeButton(),
                    SizedBox(width: adaptiveSize(14.w, 14.w, 16)),
                    _buildSpeedButton(),
                    SizedBox(width: adaptiveSize(14.w, 14.w, 16)),
                    _buildFullButton(),
                  ],
                ),
              ),
              // Container(
              //   //padding: const EdgeInsets.only(right: 6),
              //   margin: EdgeInsets.only(top: 10.w),
              //   alignment: Alignment.center,
              //   child: Row(
              //     children: [
              //       (widget.isShortVideo! && GetPlatform.isAndroid) ||
              //               chewieController.isFullScreen
              //           ? _buildHitArea()
              //           : Container(),
              //       getWidth(8),
              //       getWidth(8),
              //       _buildProgressBar(),
              //       getWidth(10),
              //       getWidth(10),
              //       widget.isShortVideo! ? Container() : _buildExpandButton(),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullButton() {
    if (!showFullButton) {
      return const SizedBox();
    }
    return GestureDetector(
      onTap: _onExpandCollapse,
      child: AnimatedOpacity(
        opacity: hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Image.asset(
          "assets/images/png/fullscreen_icon.png",
          height: adaptiveSize(16.w, 16.w, 12),
        ),
        /*child: Container(
          height: 21,
          margin: const EdgeInsets.only(right: 10, bottom: 10),
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
          ),
          child: Center(
            child: Icon(
              chewieController.isFullScreen
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen,
              color: Colors.white,
            ),
          ),
        ),*/
      ),
    );
  }

  Widget _buildPlayButton({
    double? size,
  }) {
    final bool showPlayButton = widget.showPlayButton && !hideStuff;
    final iconSize = size ?? adaptiveSize(16.w, 16.w, 20);
    return AnimatedOpacity(
      opacity: showPlayButton ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: controller.value.duration.inSeconds == 0
          ? Container()
          : Center(
              child: controller.value.isPlaying
                  ? GestureDetector(
                      onTap: _playPause,
                      child: Center(
                        child: Image.asset(
                          "assets/images/png/player_pause.png",
                          height: iconSize,
                          width: iconSize,
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: _playPause,
                      child: Center(
                        child: Image.asset(
                          "assets/images/png/player_play.png",
                          height: iconSize,
                          width: iconSize,
                        ),
                      ),
                    ),
            ),
    );
  }

  /// 倍速按钮：常驻底栏（非全屏 / 横屏全屏 / 竖屏全屏均显示）。
  /// 文案动态拼当前播放速度，比单独写「倍数」更直观。字号按 [adaptiveSize] 适配。
  Widget _buildSpeedButton() {
    final double speed = _latestValue.playbackSpeed;
    final String speedText = speed == speed.roundToDouble()
        ? '${speed.toInt()}x'
        : '${speed.toStringAsFixed(2)}x';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onSpeedButtonTap,
      child: AnimatedOpacity(
        opacity: hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: adaptiveSize(2.w, 2.w, 4)),
          child: Text(
            speedText,
            style: TextStyle(
              color: const Color(0xFFFFFDFF),
              fontSize: adaptiveSize(12.sp, 12.sp, 16),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// 声音按钮：常驻底栏（非全屏 / 横屏全屏 / 竖屏全屏均显示）。
  /// 点击在「静音 / 复原」之间切换，记住最后一次非零音量用于复原。
  Widget _buildVolumeButton() {
    final bool muted = _latestValue.volume == 0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _cancelAndRestartTimer();
        if (muted) {
          controller.setVolume(_latestVolume ?? 1.0);
        } else {
          _latestVolume = controller.value.volume;
          controller.setVolume(0.0);
        }
      },
      child: AnimatedOpacity(
        opacity: hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: adaptiveSize(2.w, 2.w, 4)),
          child: Icon(
            muted ? Icons.volume_off : Icons.volume_up,
            color: const Color(0xFFFFFDFF),
            size: adaptiveSize(18.w, 18.w, 22),
          ),
        ),
      ),
    );
  }

  Future<void> _onSpeedButtonTap() async {
    _hideTimer?.cancel();

    final chosenSpeed = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: chewieController.useRootNavigator,
      builder: (context) => _PlaybackSpeedSheet(
        speeds: chewieController.playbackSpeeds,
        selected: _latestValue.playbackSpeed,
      ),
    );

    if (chosenSpeed != null) {
      controller.setPlaybackSpeed(chosenSpeed);
    }

    if (_latestValue.isPlaying) {
      _startHideTimer();
    }
  }

  Widget _buildSubtitleToggle() {
    //if don't have subtitle hiden button
    if (chewieController.subtitle?.isEmpty ?? true) {
      return Container();
    }
    return GestureDetector(
      onTap: _onSubtitleTap,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(
          left: 12.0,
          right: 12.0,
        ),
        child: Icon(
          _subtitleOn
              ? Icons.closed_caption
              : Icons.closed_caption_off_outlined,
          color: _subtitleOn ? Colors.white : Colors.grey[700],
        ),
      ),
    );
  }

  void _onSubtitleTap() {
    setState(() {
      _subtitleOn = !_subtitleOn;
    });
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();

    setState(() {
      hideStuff = false;
      _displayTapped = true;
      ConfigStore.to.showControlStreamController!.add(false);
    });
  }

  Future<void> _initialize() async {
    _subtitleOn = chewieController.subtitle?.isNotEmpty ?? false;
    controller.addListener(_updateState);

    _updateState();

    if (controller.value.isPlaying || chewieController.autoPlay) {
      _startHideTimer();
    }

    if (chewieController.showControlsOnInitialize) {
      _initTimer = Timer(const Duration(milliseconds: 200), () {
        setState(() {
          hideStuff = false;
        });
      });
    }
  }

  void _onExpandCollapse() {
    setState(() {
      hideStuff = true;

      chewieController.toggleFullScreen();

      _showAfterExpandCollapseTimer =
          Timer(const Duration(milliseconds: 300), () {
        _cancelAndRestartTimer();
      });

      Future.delayed(const Duration(milliseconds: 1000), () {
        Wakelock.enable();

        /// 发送消息
        /// send message
        FBroadcast.instance().broadcast("auto_play");
      });

      Wakelock.enable();
    });
  }

  void _playPause() {
    final isFinished = _latestValue.position >= _latestValue.duration;

    setState(() {
      if (controller.value.isPlaying) {
        hideStuff = false;
        _hideTimer?.cancel();
        controller.pause();
      } else {
        _cancelAndRestartTimer();

        if (!controller.value.isInitialized) {
          controller.initialize().then((_) {
            controller.play();
          });
        } else {
          if (isFinished) {
            controller.seekTo(Duration.zero);
          }
          controller.play();
        }
      }
    });
  }

  void _startHideTimer() {
    final hideControlsTimer = chewieController.hideControlsTimer.isNegative
        ? ChewieController.defaultHideControlsTimer
        : chewieController.hideControlsTimer;
    _hideTimer = Timer(hideControlsTimer, () {
      if (mounted) {
        setState(() {
          hideStuff = true;
          ConfigStore.to.showControlStreamController?.add(true);
        });
      }
    });
  }

  void _bufferingTimerTimeout() {
    _displayBufferingIndicator = true;
    if (mounted) {
      setState(() {});
    }
  }

  void _updateState() {
    if (!mounted) return;

    // display the progress bar indicator only after the buffering delay if it has been set
    if (chewieController.progressIndicatorDelay != null) {
      if (controller.value.isBuffering) {
        _bufferingDisplayTimer ??= Timer(
          chewieController.progressIndicatorDelay!,
          _bufferingTimerTimeout,
        );
      } else {
        _bufferingDisplayTimer?.cancel();
        _bufferingDisplayTimer = null;
        _displayBufferingIndicator = false;
      }
    } else {
      _displayBufferingIndicator = controller.value.isBuffering;
    }

    setState(() {
      _latestValue = controller.value;
      _subtitlesPosition = controller.value.position;
    });
  }

  Widget _buildProgressBar() {
    return MaterialVideoProgressBar(
      controller,
      onDragStart: () {
        setState(() {
          showSeekTextOverlazy = true;
        });
        _cancelAndRestartTimer();
      },
      onDragUpdate: () {
        _cancelAndRestartTimer();
      },
      onDragEnd: () {
        setState(() {
          showSeekTextOverlazy = false;
        });
        if (!_latestValue.isPlaying) {
          controller.play();
        }
        _startHideTimer();
      },
      colors: chewieController.materialProgressColors ??
          ChewieProgressColors(
            playedColor: Colors.white,
            handleColor: Colors.white,
            bufferedColor: Colors.white.withOpacity(.3),
            backgroundColor: Colors.white.withOpacity(.1),
          ),
    );
  }
}

/// 长视频播放器的「播放速度」底部弹窗（自定义视觉，替换 chewie 默认亮色版）。
///
/// 视觉与项目深色风格对齐：
/// - 背景：[AppColor.primaryDialogBgColor]，顶部 16px 圆角；
/// - 文案：[AppColor.primaryText] / 灰色；
/// - 选中态：[AppColor.primaryButtonColor]，并展示对勾；
/// - 顶部带 `grabber` 指示可下滑关闭。
///
/// **横屏全屏适配**：
/// 项目用 `flutter_screenutil`，`.sp / .w / .h / .r` 的 scale 取决于
/// `MediaQuery.size.width / designSize.width`。竖屏 ≈ 1，**横屏 ≈ 2x**，
/// 直接套 `.sp` 会让弹窗里的字体 / 间距全被放大一倍。
/// 这里横屏时统一切到固定 logical px（与底栏 `adaptiveSize` 思路一致），
/// 保持视觉与竖屏接近。
class _PlaybackSpeedSheet extends StatelessWidget {
  const _PlaybackSpeedSheet({
    required this.speeds,
    required this.selected,
  });

  final List<double> speeds;
  final double selected;

  /// 整数显示为 `1.0x`、`2.0x`；非整数显示为去尾零的 `1.25x`、`0.5x`。
  String _formatSpeed(double s) {
    if (s == s.roundToDouble()) {
      return '${s.toStringAsFixed(1)}x';
    }
    String t = s.toStringAsFixed(2);
    if (t.endsWith('0')) t = t.substring(0, t.length - 1);
    if (t.endsWith('.')) t = t.substring(0, t.length - 1);
    return '${t}x';
  }

  @override
  Widget build(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    // 横屏全屏下高度极有限，给整个 sheet 设一个上限；超过部分由内部
    // 列表滚动消化，避免 speed 项被挤到屏幕外或触发 overflow。
    final double maxSheetHeight = MediaQuery.of(context).size.height * 0.7;
    final _SheetMetrics m = _SheetMetrics(isLandscape);
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.primaryDialogBgColor,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(m.cornerRadius)),
          ),
          padding: EdgeInsets.fromLTRB(0, m.topPadding, 0, m.bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // grabber：固定区域，不参与滚动。
              Container(
                width: m.grabberWidth,
                height: m.grabberHeight,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(m.grabberHeight / 2),
                ),
              ),
              SizedBox(height: m.titleTopGap),
              // 标题：固定区域。
              Padding(
                padding: EdgeInsets.symmetric(horizontal: m.horizontalPadding),
                child: Row(
                  children: [
                    Text(
                      '播放速度',
                      style: TextStyle(
                        color: AppColor.primaryText,
                        fontSize: m.titleFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: m.titleBottomGap),
              // 速度列表：占据剩余可用空间，超出时内部滚动。
              // 与 chewie 的默认排序一致：从大到小（最快在最上）。
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final s in speeds.reversed)
                        _SpeedRow(
                          label: _formatSpeed(s),
                          active: s == selected,
                          metrics: m,
                          onTap: () => Navigator.of(context).pop(s),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 倍速弹窗的所有尺寸 / 字号在「竖屏（[ScreenUtil]）」与「横屏（固定 logical px）」
/// 之间的统一切换。横屏 logical px 取自竖屏设计稿等价值，避免跟随 `.w/.sp` 被放大。
class _SheetMetrics {
  _SheetMetrics(this.isLandscape);

  final bool isLandscape;

  double get cornerRadius => isLandscape ? 16 : 16.r;
  double get topPadding => isLandscape ? 12 : 12.h;
  double get bottomPadding => isLandscape ? 8 : 8.h;
  double get horizontalPadding => isLandscape ? 16 : 16.w;
  double get grabberWidth => isLandscape ? 36 : 36.w;
  double get grabberHeight => isLandscape ? 4 : 4.h;
  double get titleTopGap => isLandscape ? 12 : 12.h;
  double get titleBottomGap => isLandscape ? 4 : 4.h;
  double get titleFontSize => isLandscape ? 16 : 16.sp;
  double get rowHeight => isLandscape ? 44 : 48.h;
  double get rowFontSize => isLandscape ? 15 : 15.sp;
  double get rowIconSize => isLandscape ? 20 : 20.w;
}

class _SpeedRow extends StatelessWidget {
  const _SpeedRow({
    required this.label,
    required this.active,
    required this.metrics,
    required this.onTap,
  });

  final String label;
  final bool active;
  final _SheetMetrics metrics;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: metrics.rowHeight,
        padding: EdgeInsets.symmetric(horizontal: metrics.horizontalPadding),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: active
                      ? AppColor.primaryButtonColor
                      : AppColor.primaryText,
                  fontSize: metrics.rowFontSize,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (active)
              Icon(
                Icons.check,
                color: AppColor.primaryButtonColor,
                size: metrics.rowIconSize,
              ),
          ],
        ),
      ),
    );
  }
}
