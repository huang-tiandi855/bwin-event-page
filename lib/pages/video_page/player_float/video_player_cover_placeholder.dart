import 'package:chewie/chewie.dart';
import 'package:comics_app/common/widgets/loading_widget.dart';
import 'package:comics_app/common/utils/text_util.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

/// 长视频 Chewie 加载占位：
/// - 视频还没出第一帧前：非全屏 = 黑底 + 封面 + Loading；全屏 = 黑底 + Loading；
/// - 视频开始播放（看到第一帧 / position 推进）后：整张占位收成 [SizedBox.shrink]，
///   让 chewie 内部 letterbox 黑边交给上层 `Container(color: Colors.black)`，避免
///   播放器上下/左右黑边里透出封面图。
class VideoPlayerCoverPlaceholder extends StatefulWidget {
  const VideoPlayerCoverPlaceholder({
    super.key,
    required this.chewieControllerProvider,
    required this.coverUrl,
  });

  /// 延迟获取 [ChewieController]（创建 Chewie 时 controller 尚未赋值完成）。
  final ChewieController Function() chewieControllerProvider;
  final String coverUrl;

  @override
  State<VideoPlayerCoverPlaceholder> createState() =>
      _VideoPlayerCoverPlaceholderState();
}

class _VideoPlayerCoverPlaceholderState
    extends State<VideoPlayerCoverPlaceholder> {
  late ChewieController _chewieController;
  VideoPlayerController? _videoController;

  /// 一旦观测到视频开始播放或 position 推进过 → 永久置位，剩余生命周期不再显示占位。
  /// 不会因为「中途 pause + seek 回 0」回退到 false。
  bool _hasStartedFirstFrame = false;

  @override
  void initState() {
    super.initState();
    _attachController(widget.chewieControllerProvider());
  }

  @override
  void didUpdateWidget(covariant VideoPlayerCoverPlaceholder oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.chewieControllerProvider();
    if (!identical(next, _chewieController)) {
      _detachController();
      _hasStartedFirstFrame = false;
      _attachController(next);
    }
  }

  @override
  void dispose() {
    _detachController();
    super.dispose();
  }

  void _attachController(ChewieController c) {
    _chewieController = c;
    _chewieController.addListener(_onChewieChanged);
    _videoController = c.videoPlayerController;
    _videoController?.addListener(_onVideoChanged);
    // 进入页面时 controller 可能已经 isPlaying（autoPlay + 鉴权通过），先同步一次。
    _maybeMarkStarted();
  }

  void _detachController() {
    _chewieController.removeListener(_onChewieChanged);
    _videoController?.removeListener(_onVideoChanged);
    _videoController = null;
  }

  void _onChewieChanged() {
    if (mounted) setState(() {});
  }

  void _onVideoChanged() {
    if (_hasStartedFirstFrame) return;
    _maybeMarkStarted();
  }

  void _maybeMarkStarted() {
    final v = _videoController?.value;
    if (v == null || !v.isInitialized) return;
    // 「真的出了第一帧」的两类信号：
    // 1. position 已经走过 0（哪怕 1 毫秒），说明帧渲染过；
    // 2. isPlaying = true，下一帧马上就会出来——比单纯 isInitialized 更晚、更稳，
    //    避免 init 完成但还没真正出图就把封面藏掉，留出一段黑屏。
    final bool started = v.position > Duration.zero || v.isPlaying;
    if (!started) return;
    _hasStartedFirstFrame = true;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_hasStartedFirstFrame) {
      return const SizedBox.shrink();
    }

    if (_chewieController.isFullScreen) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: LoadingWidget()),
      );
    }

    final cover = widget.coverUrl;
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        const ColoredBox(color: Colors.black),
        if (!TextUtil.isEmpty(cover))
          CustomImage(
            url: cover,
            height: 212.w,
            fit: BoxFit.cover,
          ),
        const Center(child: LoadingWidget()),
      ],
    );
  }
}
