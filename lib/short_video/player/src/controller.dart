part of short_video_player;

typedef LoadMoreVideo<T> = Future<List<VideoController<T>>> Function();

/// VideoListController是一系列视频的控制器，内部管理了视频控制器数组
/// 提供了预加载/释放/加载更多功能。
///
/// 真正的 [VideoPlayerController] 一律经 [ShortVideoPlayerPool] 分配，
/// App 内短视频正片最多同时存活 [ShortVideoPlayerPool.maxCapacity] 路。
class VideoListController<T> extends ChangeNotifier {
  VideoListController({
    this.loadMoreCount = 2,
  }) {
    ShortVideoPlayerPool.instance.attachOwner(
      this,
      onEvicted: handlePoolEviction,
    );
  }

  Function(VideoController<T> vpVideoController, T? videoInfo)?
      videoAddListenerCallBack;
  Future<void> Function(VideoController<T>)? beforeInit;

  /// 到第几个触发预加载，例如：1:最后一个，2:倒数第二个
  final int loadMoreCount;

  Map<int, VideoController<T>> controllers = {};

  /// 提供视频的builder
  LoadMoreVideo<T>? _videoProvider;

  /// 目前的视频序号
  ValueNotifier<int> index = ValueNotifier<int>(0);

  /// 视频列表
  List<VideoController<T>> playerList = [];

  /// 当前播放器
  VideoController<T> get currentPlayer => playerList[index.value];

  /// 递增以作废进行中的 [_initializeControllerAtIndex]。
  int _initGeneration = 0;

  /// 是否抑制自动播放：用于「用户已离开当前可见页（例如切换底部一级 tab）」
  /// 但 [VideoController.init] 仍在异步初始化时，避免后续两条自动起播路径
  /// 把音频带出来：
  ///   1. [_initVideo] / [_playNext] / [_playPrevious] / [_playControllerAtIndex]
  ///      在 init 完成后默认会调 `controller.play()`；
  ///   2. [ShortVideoPageView] 重 build 时新建的 `FlickManager(autoPlay: true)`
  ///      在 `_changeVideo` 里直接 `play()`（这条由调用方读取本字段透传给
  ///      `ShortVideoPlayer.autoPlay`，而不是控制器内部判断）。
  ///
  /// 由 [setSuppressAutoPlay] 切换；用户主动切页 / 翻页（`onVideoIndexChanged`）
  /// 视为显式起播意图，会自动把抑制位清掉。
  bool _suppressAutoPlay = false;

  bool get suppressAutoPlay => _suppressAutoPlay;

  /// 池槽被其它 owner 抢占后回调：清掉本地引用并刷新封面占位。
  void handlePoolEviction(int index) {
    final VideoController<T>? controller =
        controllers.remove(index) ?? playerOfIndex(index);
    controller?.detachAfterPoolEviction();
    log('🚀🚀🚀 POOL EVICTED $index', name: runtimeType.toString());
    notifyListeners();
  }

  /// 声明自己为前台短视频列表，后续 acquire 可抢占其它 owner。
  void claimActiveOwner() {
    ShortVideoPlayerPool.instance.setActiveOwner(this);
  }

  /// 设置是否抑制自动播放。置 `true` 时同步把所有已经初始化好的控制器 pause
  /// 一遍（防止 FlickManager.autoPlay 已经触发 play 的情况下还在响），并通过
  /// [notifyListeners] 让 [ShortVideoPageView] 重 build —— 重 build 时新构造的
  /// FlickManager 会读取最新的 `autoPlay` 参数，避免重新自动播放。
  void setSuppressAutoPlay(bool value) {
    if (_suppressAutoPlay == value) return;
    _suppressAutoPlay = value;
    if (value) {
      for (final c in controllers.values) {
        if (c.hasController) {
          c.controller.pause();
        }
      }
    }
    notifyListeners();
  }

  _initVideo() async {
    claimActiveOwner();
    await _initializeControllerAtIndex(index.value);

    if (!_suppressAutoPlay) {
      _playControllerAtIndex(index.value);
    }

    notifyListeners();
  }

  onVideoIndexChanged(int target, {bool allowAutoPlay = true}) {
    // 用户主动滑到新页 = 显式起播意图，把外部抑制位清掉，否则切页后整页停在
    // 封面态。注意必须放在 [_playNext] / [_playPrevious] 之前。
    if (allowAutoPlay) {
      _suppressAutoPlay = false;
    }

    var oldIndex = index.value;
    var newIndex = target;

    if (newIndex > oldIndex) {
      _playNext(newIndex);
    } else {
      _playPrevious(newIndex);
    }
    if (playerList.length - newIndex <= loadMoreCount + 1) {
      _videoProvider?.call().then(
        (list) async {
          playerList.addAll(list);
          notifyListeners();
        },
      );
    }

    index.value = target;

    notifyListeners();
  }

  VideoController<T>? playerOfIndex(int index) {
    if (index < 0 || index > playerList.length - 1) {
      return null;
    }
    return playerList[index];
  }

  int get videoCount => playerList.length;

  init({
    int initialIndex = 0,
    required List<VideoController<T>> initialList,
    required LoadMoreVideo<T> videoProvider,
    Function(VideoController<T> videoController, T? videoInfo)?
        addListenerCallBack,
    Future<void> Function(VideoController<T>)? beforeInit,
    bool? isMore,
  }) async {
    index.value = initialIndex;
    playerList = [];
    playerList.addAll(initialList);
    _videoProvider = videoProvider;
    this.beforeInit = beforeInit;
    claimActiveOwner();
    _initVideo();
    videoAddListenerCallBack = addListenerCallBack;
    notifyListeners();

    if (isMore ?? true) {
      _videoProvider?.call().then(
        (list) async {
          playerList.addAll(list);
          // 暂停预加载下一条详情：beforeInit 会调用 cms/vod/detail，
          // 可能提前消耗用户免费次数。需要恢复预加载时再打开。
          // if (ShortVideoPlayerPool.instance.windowCapacity >= 2) {
          //   _initializeControllerAtIndex(index.value + 1);
          // }
          notifyListeners();
        },
      );
    }
  }

  void _playNext(int index) {
    _stopControllerAtIndex(index - 1);
    _disposeControllerAtIndex(index - 2);
    // 窗口容量为 2（视频前贴片占一路）时不保留上一页解码器。
    if (ShortVideoPlayerPool.instance.windowCapacity <= 2) {
      _disposeControllerAtIndex(index - 1);
    }

    _playControllerAtIndex(index);
    // 暂停预加载下一条详情：beforeInit 会调用 cms/vod/detail，
    // 可能提前消耗用户免费次数。需要恢复预加载时再打开。
    // _initializeControllerAtIndex(index + 1);
  }

  void _playPrevious(int index) {
    _stopControllerAtIndex(index + 1);
    _disposeControllerAtIndex(index + 2);
    if (ShortVideoPlayerPool.instance.windowCapacity <= 2) {
      _disposeControllerAtIndex(index + 1);
    }

    _playControllerAtIndex(index);
    _initializeControllerAtIndex(index - 1);
  }

  /// 前贴片视频广告出现/结束时调整窗口，并丢掉超出预算的相邻页。
  Future<void> applyWindowCapacity(int capacity) async {
    ShortVideoPlayerPool.instance.setWindowCapacity(capacity);
    final int current = index.value;
    if (capacity <= 2) {
      final toDrop = controllers.keys
          .where((i) => i != current)
          .toList(growable: false);
      for (final i in toDrop) {
        await _disposeControllerAtIndexAsync(i);
      }
    }
    notifyListeners();
  }

  Future _initializeControllerAtIndex(int index) async {
    if (playerList.length > index && index >= 0) {
      final int generation = _initGeneration;
      final VideoController<T> vpVideoController = playerList[index];
      vpVideoController.bindPool(owner: this, index: index);
      controllers[index] = vpVideoController;
      await vpVideoController.init(
        beforeInit: beforeInit,
        afterInit: (controller) async {
          if (videoAddListenerCallBack != null) {
            controller.controller.addListener(() {
              videoAddListenerCallBack!(controller, controller.videoInfo);
            });
          }
        },
      );

      if (generation != _initGeneration) {
        log('🚀🚀🚀 INITIALIZE CANCELLED $index', name: runtimeType.toString());
        if (identical(controllers[index], vpVideoController)) {
          controllers.remove(index);
        }
        await vpVideoController.dispose();
        return;
      }

      // 被其它 owner 抢占后可能已 detach。
      if (!vpVideoController.hasController) {
        controllers.remove(index);
        return;
      }

      log('🚀🚀🚀 INITIALIZED $index', name: runtimeType.toString());
      // init 完成后必须 notify，否则 PageView 那边的封面占位（依据
      // `!hasController` 判定，见 ShortVideoPageView.itemBuilder）不会切到
      // 真正的 [ShortVideoPlayer]。
      notifyListeners();
    }
  }

  void _playControllerAtIndex(int index) {
    if (index < 0 || index >= playerList.length) return;
    if (_suppressAutoPlay) return;

    final VideoController<T>? controller = controllers[index];
    if (controller == null || !controller.hasController) {
      // 兜底：跳页（PageView 弹性 fling 跨 >1 页）或 videoProvider 尚未
      // 完成时，目标 [index] 可能还没经过 [_initializeControllerAtIndex]。
      _initializeControllerAtIndex(index).then((_) {
        if (this.index.value != index) return;
        if (_suppressAutoPlay) return;
        controllers[index]?.play();
        log('🚀🚀🚀 PLAYING $index (after lazy init)',
            name: runtimeType.toString());
      });
      return;
    }

    controller.play();
    log('🚀🚀🚀 PLAYING $index', name: runtimeType.toString());
  }

  void _stopControllerAtIndex(int index) {
    if (index < 0 || index >= playerList.length) return;

    final VideoController<T>? controller = controllers[index];
    if (controller == null || !controller.hasController) return;

    controller.pause();
    controller.controller.seekTo(Duration.zero);
    log('🚀🚀🚀 STOPPED $index', name: runtimeType.toString());
  }

  void _disposeControllerAtIndex(int index) {
    if (playerList.length > index && index >= 0) {
      final VideoController<T>? controller = controllers[index];
      controller?.dispose();
      if (controller != null) {
        controllers.remove(index);
      }
      log('🚀🚀🚀 DISPOSED $index', name: runtimeType.toString());
    }
  }

  Future<void> _disposeControllerAtIndexAsync(int index) async {
    if (playerList.length > index && index >= 0) {
      final VideoController<T>? controller = controllers.remove(index);
      await controller?.dispose();
      log('🚀🚀🚀 DISPOSED $index', name: runtimeType.toString());
    }
  }

  /// 池抢占 / 回前台后，按当前页重建当前 +（容量允许时）相邻预加载。
  Future<void> reinitializeAroundCurrent() async {
    claimActiveOwner();
    final int current = index.value;
    await _initializeControllerAtIndex(current);
    // 与 [_playNext] 一致：暂不预加载下一条，避免 beforeInit 提前耗免费次数。
    // if (ShortVideoPlayerPool.instance.windowCapacity >= 2) {
    //   await _initializeControllerAtIndex(current + 1);
    // }
  }

  @override
  Future<void> dispose() async {
    _initGeneration++;
    for (var player in playerList) {
      player.showPauseIcon.dispose();
      player.detachAfterPoolEviction();
    }
    playerList = [];
    controllers = {};
    await ShortVideoPlayerPool.instance.releaseOwner(this);
    ShortVideoPlayerPool.instance.detachOwner(this);
    super.dispose();
  }
}

typedef ControllerSetter<T> = Future<void> Function(T controller);
typedef ControllerBuilder<T> = T Function();

/// 抽象类，作为视频控制器必须实现这些方法
abstract class IVideoController {
  /// 获取当前的控制器实例
  VideoPlayerController? get controller;

  /// 是否显示暂停按钮
  ValueNotifier<bool> get showPauseIcon;

  /// 加载视频，在init后，应当开始下载视频内容
  Future<void> init();

  /// 视频销毁，在dispose后，应当释放任何内存资源
  Future<void> dispose();

  /// 播放
  Future<void> play();

  /// 暂停
  Future<void> pause({bool showPauseIcon = false});
}

class VideoController<T> extends IVideoController {
  VideoPlayerController? _controller;
  final ValueNotifier<bool> _showPauseIcon = ValueNotifier<bool>(false);

  T videoInfo;

  Duration position;

  final ControllerBuilder<VideoPlayerController> _builder;

  Object? _poolOwner;
  int? _poolIndex;

  /// beforeInit 失败时不占池槽，把错误记在这里供 UI / 线路弹窗使用。
  String? _initError;

  /// 每次 [dispose] / detach 递增；进行中的 [init] 发现 token 变化后立刻停手。
  int _lifecycleToken = 0;

  VideoController({
    required this.videoInfo,
    required ControllerBuilder<VideoPlayerController> builder,
    this.position = Duration.zero,
  }) : _builder = builder;

  void bindPool({required Object owner, required int index}) {
    _poolOwner = owner;
    _poolIndex = index;
  }

  /// 池已 dispose 原生 controller 后，只清本地引用。
  void detachAfterPoolEviction() {
    _lifecycleToken++;
    _controller = null;
  }

  /// 标记初始化失败且不创建解码器（供 [beforeInit] 使用）。
  void markInitError(String message) {
    _initError = message;
  }

  String? get initError => _initError;

  @override
  VideoPlayerController get controller {
    final VideoPlayerController? c = _controller;
    if (c == null) {
      throw StateError(
        'VideoController has no pooled VideoPlayerController; '
        'check hasController before access',
      );
    }
    return c;
  }

  bool get hasController => _controller != null;

  @override
  Future<void> dispose({
    Future<void> Function(VideoController<T> controller)? beforeDispose,
  }) async {
    _lifecycleToken++;
    final Object? owner = _poolOwner;
    final int? index = _poolIndex;
    final VideoPlayerController? existing = _controller;
    _controller = null;
    try {
      await beforeDispose?.call(this);
    } catch (_) {}
    if (owner != null && index != null) {
      await ShortVideoPlayerPool.instance.releaseSlot(owner, index);
    } else if (existing != null) {
      await existing.dispose();
    }
  }

  @override
  Future<void> init({
    Future<void> Function(VideoController<T> controller)? beforeInit,
    Future<void> Function(VideoController<T> controller)? afterInit,
  }) async {
    final int token = _lifecycleToken;
    _initError = null;
    try {
      await beforeInit?.call(this);
      if (token != _lifecycleToken) return;
      if (_initError != null) {
        log('init aborted: $_initError', name: runtimeType.toString());
        return;
      }

      final Object? owner = _poolOwner;
      final int? index = _poolIndex;
      if (owner == null || index == null) {
        throw StateError('VideoController.bindPool must be called before init');
      }

      _controller = await ShortVideoPlayerPool.instance.acquire(
        owner: owner,
        index: index,
        create: _builder,
      );
      if (token != _lifecycleToken) {
        await dispose();
        return;
      }

      await _controller!.initialize();
      if (token != _lifecycleToken) {
        await dispose();
        return;
      }
      if (_controller!.value.hasError) {
        return;
      }
      await _controller!.setLooping(false);
      if (token != _lifecycleToken) {
        await dispose();
        return;
      }
      afterInit?.call(this);
      if (position != Duration.zero) {
        await _controller!.seekTo(position);
        position = Duration.zero;
      }
    } catch (e) {
      if (token != _lifecycleToken) return;
      log("$e", name: runtimeType.toString());
      _initError = '$e';
      if (_controller != null && !_controller!.value.hasError) {
        _controller!.value = VideoPlayerValue.erroneous('$e');
      }
    }
  }

  @override
  Future<void> pause({bool showPauseIcon = false}) async {
    if (!hasController) return;
    await controller.pause();
    _showPauseIcon.value = true;
  }

  @override
  Future<void> play() async {
    if (!hasController) return;
    await controller.play();
    _showPauseIcon.value = false;
  }

  @override
  ValueNotifier<bool> get showPauseIcon => _showPauseIcon;
}
