part of short_video_player;

/// 短视频播放器可选倍速档位（与长视频播放器保持一致）。
const List<double> _kShortVideoPlaybackSpeeds = <double>[
  0.5,
  0.75,
  1.0,
  1.25,
  1.5,
  1.75,
  2.0,
];

class LandscapePlayerControls extends StatelessWidget {
  const LandscapePlayerControls({
    Key? key,
    this.iconSize = 20,
    this.fontSize = 12,
    this.progressBarMarginBottom = 0,
    this.pageType = ShortVideoPlayerPageType.secondary,
  }) : super(key: key);
  final double iconSize;
  final double fontSize;
  final double progressBarMarginBottom;
  final ShortVideoPlayerPageType pageType;

  @override
  Widget build(BuildContext context) {
    FlickVideoManager videoManager = Provider.of<FlickVideoManager>(context);
    final FlickProgressBarSettings progressBarSettings =
        FlickProgressBarSettings(
      // padding 会计入 FlickVideoProgressBar 的 GestureDetector 命中区域；
      // 视觉条保持轻量，但手指可拖拽范围更大。
      padding: EdgeInsets.symmetric(vertical: 16.w),
      height: 3.w,
      handleRadius: 4.w,
      bufferedColor: Colors.white.withOpacity(0.5),
      backgroundColor: Colors.white.withOpacity(0.15),
      playedColor: AppColor.primaryButtonColor,
      handleColor: AppColor.primaryButtonColor,
    );
    return Stack(
      children: <Widget>[
        const FlickShowControlsAction(
          child: FlickSeekVideoAction(
            child: Center(
              child: FlickVideoBuffer(
                bufferingChild: LoadingWidget(),
                child: FlickAutoHideChild(
                  showIfVideoNotInitialized: false,
                  child: LandscapePlayToggle(),
                ),
              ),
            ),
          ),
        ),
        videoManager.isVideoInitialized
            ? Positioned.fill(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      height: 40.w,
                      // decoration: BoxDecoration(
                      //   gradient: LinearGradient(
                      //     begin: Alignment.topCenter,
                      //     end: Alignment.bottomCenter,
                      //     colors: [
                      //       Colors.black.withOpacity(0),
                      //       Colors.black.withOpacity(0.4),
                      //     ],
                      //   ),
                      // ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          FlickCurrentPosition(
                            fontSize: fontSize,
                          ),
                          10.horizontalSpace,
                          Expanded(
                            child: FlickVideoProgressBar(
                              flickProgressBarSettings: progressBarSettings,
                            ),
                          ),
                          10.horizontalSpace,
                          FlickTotalDuration(
                            fontSize: fontSize,
                          ),
                          10.horizontalSpace,
                          _buildSpeedButton(context, videoManager),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: progressBarMarginBottom,
                    ),
                  ],
                ),
              )
            : Container(),
        if (pageType == ShortVideoPlayerPageType.secondary)
          Positioned(
            top: Screen.topSafeHeight,
            left: 0,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: commonBack(
                color: AppColor.white,
                padding: EdgeInsets.only(left: 10.w),
                constraints: BoxConstraints.tightFor(
                  width: 44.w,
                  height: 44.w,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 倍速按钮：显示当前播放速度，点击弹出选档面板。
  ///
  /// 当前速度从 [FlickVideoManager.videoPlayerValue] 读取，外层 Provider 已
  /// 订阅 manager 的 `notifyListeners`，速度变化会自动重建。
  Widget _buildSpeedButton(BuildContext context, FlickVideoManager manager) {
    final double speed = manager.videoPlayerValue?.playbackSpeed ?? 1.0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showSpeedSheet(context, manager),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Text(
          _formatSpeedShort(speed),
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 底栏倍速文案：整数 → `1x`；非整数 → 去尾零的 `1.5x` / `1.25x`。
  static String _formatSpeedShort(double s) {
    if (s == s.roundToDouble()) {
      return '${s.toInt()}x';
    }
    String t = s.toStringAsFixed(2);
    if (t.endsWith('0')) t = t.substring(0, t.length - 1);
    if (t.endsWith('.')) t = t.substring(0, t.length - 1);
    return '${t}x';
  }

  Future<void> _showSpeedSheet(
    BuildContext context,
    FlickVideoManager manager,
  ) async {
    final double current = manager.videoPlayerValue?.playbackSpeed ?? 1.0;
    final double? chosen = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ShortVideoSpeedSheet(
        speeds: _kShortVideoPlaybackSpeeds,
        selected: current,
      ),
    );
    if (chosen != null) {
      await manager.videoPlayerController?.setPlaybackSpeed(chosen);
    }
  }
}

/// 短视频倍速选择面板（参考长视频 `_PlaybackSpeedSheet` 的视觉，但短视频
/// 仅在竖屏使用，省去横屏适配；与项目其它 sheet 保持深色 + 顶部 grabber 样式）。
class _ShortVideoSpeedSheet extends StatelessWidget {
  const _ShortVideoSpeedSheet({
    required this.speeds,
    required this.selected,
  });

  final List<double> speeds;
  final double selected;

  /// 列表项倍速文案：整数显示为 `1.0x`，非整数去尾零 → `1.25x` / `0.5x`。
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
    final double maxSheetHeight = MediaQuery.of(context).size.height * 0.7;
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.primaryDialogBgColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          padding: EdgeInsets.fromLTRB(0, 12.h, 0, 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(2.h),
                ),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Text(
                      '播放速度',
                      style: TextStyle(
                        color: AppColor.primaryText,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final s in speeds.reversed)
                        _ShortVideoSpeedRow(
                          label: _formatSpeed(s),
                          active: s == selected,
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

class _ShortVideoSpeedRow extends StatelessWidget {
  const _ShortVideoSpeedRow({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: active
                      ? AppColor.primaryButtonColor
                      : AppColor.primaryText,
                  fontSize: 15.sp,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (active)
              Icon(
                Icons.check,
                color: AppColor.primaryButtonColor,
                size: 20.w,
              ),
          ],
        ),
      ),
    );
  }
}
