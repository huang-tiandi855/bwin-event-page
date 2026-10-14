import 'package:comics_app/common/entities/ai/ai_models.dart';
import 'package:comics_app/common/values/address.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/pages/ai_index/widgets/ai_gen_style.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../common/entities/ai/ai_task_time.dart';
import 'logic.dart';

/// AI「我的生成」。
class AIRecordPage extends GetView<AiRecordLogic> {
  const AIRecordPage({super.key});

  static const Color _tipBg = Color(0xFF221D11);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        controller.backToAiHome();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AiGenStyle.background,
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            toolbarHeight: 44.w,
            backgroundColor: AiGenStyle.background,
            surfaceTintColor: AiGenStyle.background,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            leadingWidth: 54.w,
            leading: GestureDetector(
              onTap: controller.backToAiHome,
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: SvgPicture.asset(
                  AssetsGen.images.ai.aiBack,
                  width: 24.w,
                  height: 24.w,
                ),
              ),
            ),
            title: Text(
              '我的生成',
              style: TextStyle(
                height: 1,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          body: GetBuilder<AiRecordLogic>(
            builder: (_) {
              final list = controller.state.records;
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(15.w, 15.w, 15.w, 0),
                    child: _buildTipBanner(controller.state.tipText),
                  ),
                  Expanded(
                    child: PullRefreshView(
                      controller: controller.state.refreshController,
                      enablePullDown: true,
                      onRefresh: () async => controller.onRefresh(),
                      onLoading: () async => controller.onLoadMore(),
                      retryOnTap: () async => controller.onRefresh(),
                      emptyWidget: Center(
                        child: Text(
                          '这里空空如也～',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AiGenStyle.muted,
                          ),
                        ),
                      ),
                      child: GridView.builder(
                        padding: EdgeInsets.fromLTRB(15.w, 15.w, 15.w, 16.w),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 11.w,
                          crossAxisSpacing: 11.w,
                          childAspectRatio: 167 / 208,
                        ),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final item = list[index];
                          return _RecordCard(
                            item: item,
                            onTap: () => _showWorkDetailDialog(context, item),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showWorkDetailDialog(BuildContext context, AiTaskVo item) {
    Get.dialog<void>(
      _WorkDetailDialog(
        item: item,
        onDownload: (index) => controller.onDownload(
          item,
          resultIndex: index,
        ),
        onViewDetail: (index) {
          Get.back<void>();
          Future<void>.delayed(Duration.zero, () {
            controller.onItemTap(item, initialIndex: index);
          });
        },
      ),
      barrierColor: Colors.black54,
    );
  }

  Widget _buildTipBanner(String text) {
    return Container(
      width: double.infinity,
      height: 42.w,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: _tipBg,
        borderRadius: BorderRadius.circular(49.5.r),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            AssetsGen.images.ai.aiProgressTip,
            width: 16.w,
            height: 16.w,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AiGenStyle.accent,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkDetailDialog extends StatefulWidget {
  const _WorkDetailDialog({
    required this.item,
    required this.onDownload,
    required this.onViewDetail,
  });

  final AiTaskVo item;
  final ValueChanged<int> onDownload;
  final ValueChanged<int> onViewDetail;

  @override
  State<_WorkDetailDialog> createState() => _WorkDetailDialogState();
}

class _WorkDetailDialogState extends State<_WorkDetailDialog> {
  late final List<String> _imageUrls;
  PageController? _imagePageController;
  int _currentIndex = 0;

  bool get _canOpen => widget.item.isSuccess && widget.item.expired != true;

  @override
  void initState() {
    super.initState();
    final urls = normalizeAiResultUrls(widget.item.resultUrls).toList();
    final cover = widget.item.displayCover?.trim() ?? '';
    if (widget.item.type != 2 && urls.isEmpty && cover.isNotEmpty) {
      urls.add(cover);
    }
    _imageUrls = List<String>.unmodifiable(urls);
    if (widget.item.type != 2) {
      _imagePageController = PageController();
    }
  }

  @override
  void dispose() {
    _imagePageController?.dispose();
    super.dispose();
  }

  void _onImageChanged(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 0.w),
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 0.w),
        decoration: BoxDecoration(
          color: AiGenStyle.surface,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 67.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      '作品详情',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 21.w,
                    right: 22.w,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Get.back<void>(),
                      child: Icon(
                        Icons.cancel_outlined,
                        size: 23.w,
                        color: AiGenStyle.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: AiGenStyle.divider),
            Padding(
              padding: EdgeInsets.fromLTRB(22.w, 14.w, 22.w, 12.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DialogMediaPreview(
                    item: widget.item,
                    imageUrls: _imageUrls,
                    imagePageController: _imagePageController,
                    currentIndex: _currentIndex,
                    onImageChanged: _onImageChanged,
                    onOpenVideo: () => widget.onViewDetail(_currentIndex),
                  ),
                  SizedBox(height: 16.w),
                  _DetailInfoRow(
                    label: '类型',
                    value: widget.item.ruleName ?? widget.item.typeName ?? '作品',
                  ),
                  SizedBox(height: 12.w),
                  _DetailInfoRow(
                    label: '时间',
                    value: formatAiTaskDateTime(widget.item.createTime),
                  ),
                  SizedBox(height: 28.w),
                  Row(
                    children: [
                      Expanded(
                        child: _DialogActionButton(
                          text: '下载',
                          color: _canOpen
                              ? AiGenStyle.accent
                              : const Color(0xFF3F3F46),
                          textColor: _canOpen
                              ? AiGenStyle.buttonEnabledText
                              : AiGenStyle.muted,
                          onTap: () => widget.onDownload(_currentIndex),
                        ),
                      ),
                      SizedBox(width: 20.w),
                      Expanded(
                        child: _DialogActionButton(
                          text: '查看详情',
                          color: const Color(0xFF3F3F46),
                          textColor: Colors.white,
                          onTap: () => widget.onViewDetail(_currentIndex),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.w),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogMediaPreview extends StatelessWidget {
  const _DialogMediaPreview({
    required this.item,
    required this.imageUrls,
    required this.imagePageController,
    required this.currentIndex,
    required this.onImageChanged,
    required this.onOpenVideo,
  });

  final AiTaskVo item;
  final List<String> imageUrls;
  final PageController? imagePageController;
  final int currentIndex;
  final ValueChanged<int> onImageChanged;
  final VoidCallback onOpenVideo;

  @override
  Widget build(BuildContext context) {
    final cover = item.displayCover;
    return ClipRRect(
      borderRadius: BorderRadius.circular(9.r),
      child: item.type == 2
          ? _VideoPreview(
              item: item,
              cover: cover,
              onOpenVideo: onOpenVideo,
            )
          : AspectRatio(
              aspectRatio: 351 / 242,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrls.isNotEmpty)
                    PageView.builder(
                      controller: imagePageController,
                      physics: imageUrls.length > 1
                          ? const PageScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      itemCount: imageUrls.length,
                      onPageChanged: onImageChanged,
                      itemBuilder: (context, index) => CustomImage(
                        url: imageUrls[index],
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    AssetsGen.images.ai.aiModelBg.image(fit: BoxFit.cover),
                  if (imageUrls.length > 1)
                    Positioned(
                      right: 9.w,
                      bottom: 8.w,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 43.w),
                        height: 27.w,
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${currentIndex + 1}/${imageUrls.length}',
                          style: TextStyle(
                            color: AiGenStyle.accent,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _VideoPreview extends StatefulWidget {
  const _VideoPreview({
    required this.item,
    required this.cover,
    required this.onOpenVideo,
  });

  final AiTaskVo item;
  final String? cover;
  final VoidCallback onOpenVideo;

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  VideoPlayerController? _controller;
  bool _loading = true;
  bool _muted = false;
  String? _error;
  int _lastPositionSecond = -1;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final List<String> urls = widget.item.resultUrls ?? const <String>[];
    final String rawUrl = urls.isEmpty ? '' : urls.first.trim();
    if (rawUrl.isEmpty) {
      setState(() {
        _loading = false;
        _error = '暂无视频地址';
      });
      return;
    }

    final String url = Address.buildH5VideoUrl(rawUrl, withCdn: false);
    VideoPlayerController? controller;
    try {
      controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      _controller = controller;
      _controller!.addListener(_onPlayerChanged);
      setState(() => _loading = false);
    } catch (_) {
      await controller?.dispose();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '视频加载失败';
      });
    }
  }

  void _onPlayerChanged() {
    final VideoPlayerController? controller = _controller;
    if (!mounted || controller == null) return;
    final int second = controller.value.position.inSeconds;
    if (_lastPositionSecond == second) return;
    _lastPositionSecond = second;
    setState(() {});
  }

  Future<void> _togglePlay() async {
    final VideoPlayerController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      if (controller.value.position >= controller.value.duration) {
        await controller.seekTo(Duration.zero);
      }
      await controller.play();
    }
    if (mounted) setState(() {});
  }

  Future<void> _toggleMute() async {
    final VideoPlayerController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    _muted = !_muted;
    await controller.setVolume(_muted ? 0 : 1);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onPlayerChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerValue? value = _controller?.value;
    final bool ready = value?.isInitialized == true;
    final bool isPlaying = value?.isPlaying == true;
    final Duration position = value?.position ?? Duration.zero;
    final Duration duration =
        ready ? value!.duration : Duration(seconds: widget.item.duration ?? 0);

    return AspectRatio(
      aspectRatio: 367 / 246,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: Colors.black),
                if (ready)
                  Center(
                    child: AspectRatio(
                      aspectRatio: value!.aspectRatio,
                      child: VideoPlayer(_controller!),
                    ),
                  )
                else if (widget.cover != null && widget.cover!.isNotEmpty)
                  CustomImage(url: widget.cover, fit: BoxFit.cover)
                else
                  AssetsGen.images.ai.aiModelBg.image(fit: BoxFit.cover),
                Container(color: const Color(0x14000000)),
                if (_loading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                else if (_error != null)
                  Center(
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                    ),
                  )
                else
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _togglePlay,
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: isPlaying ? 0 : 1,
                        duration: const Duration(milliseconds: 150),
                        child: Container(
                          width: 58.w,
                          height: 58.w,
                          decoration: BoxDecoration(
                            color: const Color(0x66000000),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white70, width: 1),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.play_arrow_rounded,
                            size: 42.w,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            height: 40.w,
            color: AiGenStyle.background,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              children: [
                GestureDetector(
                  onTap: ready ? _togglePlay : null,
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 24.w,
                    color: AiGenStyle.muted,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '${_formatDuration(position)} / ${_formatDuration(duration)}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AiGenStyle.muted,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: ready ? _toggleMute : null,
                  child: Icon(
                    _muted
                        ? Icons.volume_off_outlined
                        : Icons.volume_up_outlined,
                    size: 20.w,
                    color: AiGenStyle.muted,
                  ),
                ),
                SizedBox(width: 18.w),
                GestureDetector(
                  onTap: widget.onOpenVideo,
                  child: Icon(
                    Icons.fullscreen_rounded,
                    size: 22.w,
                    color: AiGenStyle.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration value) {
    final int total = value.inSeconds < 0 ? 0 : value.inSeconds;
    final minutes = total ~/ 60;
    final rest = total % 60;
    return '$minutes:${rest.toString().padLeft(2, '0')}';
  }
}

class _DetailInfoRow extends StatelessWidget {
  const _DetailInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 52.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              color: AiGenStyle.muted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  const _DialogActionButton({
    required this.text,
    required this.color,
    required this.onTap,
    this.textColor = Colors.white,
  });

  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 49.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24.5.w),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.item,
    required this.onTap,
  });

  final AiTaskVo item;
  final VoidCallback onTap;

  Color get statusColor {
    switch (item.status) {
      case 'success':
        return const Color(0xFF42A52A);
      case 'failed':
        return const Color(0xFF777777);
      case 'decoding':
        return AiGenStyle.accent;
      case 'pending':
      case 'processing':
      default:
        return const Color(0x99000000);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cover = item.displayCover;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (cover != null && cover.isNotEmpty)
              CustomImage(url: cover, fit: BoxFit.cover)
            else
              AssetsGen.images.ai.aiModelBg.image(
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            Positioned(
              top: 10.w,
              left: 10.w,
              child: Container(
                constraints: BoxConstraints(maxWidth: 105.w),
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.w),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  item.displayStatusName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0.w,
              right: 0.w,
              bottom: 0.w,
              child: Container(
                height: 85.w,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0x00000000),
                      Color(0xFF000000),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10.w,
              right: 10.w,
              bottom: 14.w,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.ruleName ?? item.typeName ?? '作品',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 20.5.w,
                    height: 20.5.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFB815FF), Color(0xFF611EFF)],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 16.w,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
