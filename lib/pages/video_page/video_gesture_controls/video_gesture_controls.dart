import 'dart:async';
import 'dart:math';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/video_player.dart';

import 'video_brightness_view.dart';
import 'video_seek_text_view.dart';
import 'video_skip_view.dart';
import 'video_volume_view.dart';
import 'volume_listner.dart';

class VideoGestureControls extends StatefulWidget {
  const VideoGestureControls({
    super.key,
    this.showSeekTextOverlazy,
    this.onTap,
    this.onVerticalDragStart,
    this.onVerticalDragUpdate,
    this.onVerticalDragEnd,
    this.onVerticalDragCancel,
    this.onHorizontalDragStart,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
    this.onHorizontalDragCancel,
    this.onSkipForward,
    this.onSkipBackward,
    this.onDoubleTap,
    this.horizontalDragAllowed,
    this.children = const [],
  });

  final GestureTapCallback? onTap;
  final GestureDragStartCallback? onVerticalDragStart;
  final GestureDragUpdateCallback? onVerticalDragUpdate;
  final GestureDragEndCallback? onVerticalDragEnd;
  final GestureDragCancelCallback? onVerticalDragCancel;
  final GestureDragStartCallback? onHorizontalDragStart;
  final GestureDragUpdateCallback? onHorizontalDragUpdate;
  final GestureDragEndCallback? onHorizontalDragEnd;
  final GestureDragCancelCallback? onHorizontalDragCancel;

  /// 返回 false 时不响应横向滑动快进/快退（例如底栏非进度条区域）。
  final bool Function(Offset globalPosition)? horizontalDragAllowed;
  final List<Widget> children;
  final bool? showSeekTextOverlazy;
  final void Function()? onSkipForward;
  final void Function()? onSkipBackward;
  final void Function()? onDoubleTap;

  @override
  State<VideoGestureControls> createState() => _VideoGestureControlsState();
}

class _VideoGestureControlsState extends State<VideoGestureControls> {
  late ChewieController chewieController;

  VideoPlayerController get controller =>
      chewieController.videoPlayerController;

  late ValueNotifier<bool> showSeekTextOverlazy;

  @override
  void initState() {
    super.initState();
    FlutterVolumeController.updateShowSystemUI(false);
    showSeekTextOverlazy = ValueNotifier(widget.showSeekTextOverlazy ?? false);
  }

  @override
  void didChangeDependencies() {
    chewieController = ChewieController.of(context);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant VideoGestureControls oldWidget) {
    if (oldWidget.showSeekTextOverlazy != widget.showSeekTextOverlazy) {
      showSeekTextOverlazy.value = widget.showSeekTextOverlazy ?? false;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _skipTimer?.cancel();
    _skipTimer = null;
    super.dispose();
  }

  Duration? seekPos;

  void seekToAbsolutePosition(Offset delta) {
    if (seekPos == null || controller.value.isInitialized != true) return;
    int milliseconds = seekPos!.inMilliseconds + (800 * delta.dx).toInt();
    if (milliseconds < 0) {
      milliseconds = 0;
    } else if (milliseconds > controller.value.duration.inMilliseconds) {
      milliseconds = controller.value.duration.inMilliseconds;
    }
    seekPos = Duration(milliseconds: milliseconds);
    controller.seekTo(seekPos!);
  }

  void _onHorizontalDragStart(DragStartDetails details) async {
    if (controller.value.isInitialized != true) {
      return;
    }
    if (widget.horizontalDragAllowed != null &&
        !widget.horizontalDragAllowed!(details.globalPosition)) {
      return;
    }
    seekPos = controller.value.position;
    showSeekTextOverlazy.value = true;

    widget.onHorizontalDragStart?.call(details);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (controller.value.isInitialized != true) {
      return;
    }
    if (seekPos == null) {
      return;
    }
    seekToAbsolutePosition(details.delta);
    widget.onHorizontalDragUpdate?.call(details);
  }

  void _onHorizontalDragEnd(DragEndDetails details) async {
    if (seekPos == null) {
      widget.onHorizontalDragEnd?.call(details);
      return;
    }
    // if (seekPos != null) {
    //   await controller.seekTo(seekPos!);
    // }
    seekPos = null;
    showSeekTextOverlazy.value = false;
    widget.onHorizontalDragEnd?.call(details);
  }

  void _onHorizontalDragCancel() async {
    if (seekPos == null) {
      widget.onHorizontalDragCancel?.call();
      return;
    }
    seekPos = null;
    showSeekTextOverlazy.value = false;
    widget.onHorizontalDragCancel?.call();
  }

  Offset startPosition = Offset.zero; // 起始位置
  double movePan = 0; // 偏移量累计总和
  double layoutWidth = 0; // 组件宽度
  double layoutHeight = 0; // 组件高度
  double brightness = 0.0; //亮度
  double volume = 0.0; //亮度
  ValueNotifier<bool> showBrightnessOverlazy =
      ValueNotifier(false); // 是否显示亮度调节UI
  ValueNotifier<bool> showVolumeOverlazy = ValueNotifier(false); // 是否显示音量调节UI

  void _onVerticalDragStart(details) async {
    _reset(context);
    startPosition = details.globalPosition;
    if (startPosition.dx < (layoutWidth / 2)) {
      /// 左边触摸
      brightness = await ScreenBrightness().current;
      showBrightnessOverlazy.value = true;
    } else {
      /// 右边触摸
      volume = await FlutterVolumeController.getVolume() ?? 0.0;
      showVolumeOverlazy.value = true;
    }
    widget.onVerticalDragStart?.call(details);
  }

  void _onVerticalDragUpdate(details) async {
    if (controller.value.isInitialized != true) {
      return;
    }

    /// 累计计算偏移量(下滑减少百分比，上滑增加百分比)
    movePan += (-details.delta.dy);
    if (startPosition.dx < (layoutWidth / 2)) {
      /// 左边触摸
      ScreenBrightness().setScreenBrightness(_calcBrightness());
    } else {
      FlutterVolumeController.setVolume(_calcVolume());
    }
    widget.onVerticalDragUpdate?.call(details);
  }

  void _onVerticalDragEnd(_) async {
    _onVerticalDragCancel();
    widget.onVerticalDragEnd?.call(_);
  }

  void _onVerticalDragCancel() async {
    if (showBrightnessOverlazy.value) {
      showBrightnessOverlazy.value = false;
    }
    if (showVolumeOverlazy.value) {
      showVolumeOverlazy.value = false;
    }
    widget.onVerticalDragCancel?.call();
  }

  double _calcBrightness() {
    // 亮度百分控制
    double value =
        double.parse((movePan / layoutHeight + brightness).toStringAsFixed(2));
    return min(max(0, value), 1.0);
  }

  double _calcVolume() {
    // 声音亮度百分控制
    double value =
        double.parse((movePan / layoutHeight + volume).toStringAsFixed(2));
    return min(max(0, value), 1.0);
  }

  void _reset(BuildContext context) {
    startPosition = const Offset(0, 0);
    movePan = 0;
    layoutHeight = context.size!.height;
    layoutWidth = context.size!.width;
  }

  ValueNotifier<int> skipForward = ValueNotifier(0); // 1快进， -1 快退

  Timer? _skipTimer;

  void _skipBack() {
    widget.onSkipBackward?.call();
    skipForward.value = -1;
    _skipTimer = Timer(const Duration(seconds: 1), () {
      skipForward.value = 0;
      _skipTimer?.cancel();
      _skipTimer = null;
    });
    final skip = (controller.value.position - const Duration(seconds: 10))
        .inMilliseconds;
    controller.seekTo(Duration(milliseconds: max(skip, 0)));
  }

  void _skipForward() {
    widget.onSkipForward?.call();
    skipForward.value = 1;
    _skipTimer = Timer(const Duration(seconds: 1), () {
      skipForward.value = 0;
      _skipTimer?.cancel();
      _skipTimer = null;
    });
    final end = controller.value.duration.inMilliseconds;
    final skip = (controller.value.position + const Duration(seconds: 10))
        .inMilliseconds;
    controller.seekTo(Duration(milliseconds: min(skip, end)));
  }

  void doubleTapEvent(TapDownDetails details) {
    if (controller.value.isInitialized != true) {
      return;
    }
    if (details.globalPosition.dx > 0 &&
        details.globalPosition.dx < ScreenUtil().screenWidth / 3) {
      _skipBack();
    } else if (details.globalPosition.dx > ScreenUtil().screenWidth / 3 &&
        details.globalPosition.dx < ScreenUtil().screenWidth / 3 * 2) {
      widget.onDoubleTap?.call();
    } else {
      _skipForward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onDoubleTapDown: doubleTapEvent,
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onHorizontalDragCancel: _onHorizontalDragCancel,
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      onVerticalDragCancel: _onVerticalDragCancel,
      child: Stack(
        children: [
          ...widget.children,
          Positioned.fill(
            child: ValueListenableBuilder<int>(
              valueListenable: skipForward,
              builder: (context, value, child) {
                if (value == 0) {
                  return const SizedBox();
                }
                return VideoSkipView(
                  value: value,
                  isFullScreen: chewieController.isFullScreen,
                );
              },
            ),
          ),
          Positioned.fill(
            child: ValueListenableBuilder<bool>(
              valueListenable: showSeekTextOverlazy,
              builder: (context, value, child) {
                if (!value) {
                  return const SizedBox();
                }
                return ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: controller,
                  builder: (context, value, child) {
                    return VideoSeekTextView(
                      duration: controller.value.position,
                      totalDuration: controller.value.duration,
                    );
                  },
                );
              },
            ),
          ),
          Positioned(
            child: ValueListenableBuilder<bool>(
              valueListenable: showBrightnessOverlazy,
              builder: (context, value, child) {
                if (!value) {
                  return const SizedBox();
                }
                return StreamBuilder<double>(
                  stream: ScreenBrightness().onCurrentBrightnessChanged,
                  builder: (context, snapshot) {
                    return VideoBrightnessView(
                      brightness: snapshot.data ?? brightness,
                    );
                  },
                );
              },
            ),
          ),
          Positioned(
            child: ValueListenableBuilder<bool>(
              valueListenable: showVolumeOverlazy,
              builder: (context, value, child) {
                if (!value) {
                  return const SizedBox();
                }
                return StreamBuilder<double>(
                  stream: VolumeListener().onCurrentVolumeChanged,
                  builder: (context, snapshot) {
                    return VideoVolumeView(
                      volume: snapshot.data ?? volume,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
