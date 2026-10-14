import 'package:comics_app/common/apis/media_api.dart';
import 'package:comics_app/short_video/base/abs_short_video_play_logic.dart';
import 'package:comics_app/common/entities/media_info.dart';
import 'package:comics_app/common/entities/pagination_model.dart';
import 'package:comics_app/common/entities/video_model/ishort_video_model.dart';
import 'package:comics_app/common/entities/video_model/tags_model.dart';
import 'package:comics_app/common/entities/video_model/video_model.dart';
import 'package:comics_app/common/utils/history/history_operation.dart';
import 'package:comics_app/short_video/player/short_video_player.dart';
import 'package:get/get.dart';

import '../../video_page/player_code_manage.dart';
import 'short_video_play_state.dart';

class ShortVideoPlayLogic extends AbsShortVideoPlayLogic {
  static final Set<String> _activeTags = <String>{};

  /// 全局自动播放抑制位：用于「底部一级 tab 切走 Douyin」的场景。
  ///
  /// 单纯靠 [pauseAllActive] 解决不了「leave Douyin 时 ShortVideoPlayLogic
  /// 还没注册（首屏 HTTP 还在飞）」的赛跑：等 logic 注册起来 [onInit] 触发
  /// `_initVideo`，控制器初始化完成会自动 play 把音频带出来。这里把抑制位
  /// 提到 *static* 层，新建的实例在 [onInit] 入口读一次，决定是否要把
  /// [VideoListController.setSuppressAutoPlay] 同步置上。
  ///
  /// 仅作用于「带 [controllerTag]」的实例（即 [ShortVideoVerticalTabView] 这
  /// 种生命周期跟 Douyin tab 绑定的列表），独立路由打开的 [ShortVideoPlayPage]
  /// 不受影响 —— 否则用户从主页点开短视频会黑屏不响。
  static bool _globalSuppressAutoPlay = false;

  /// 「跨底部一级 tab 回到抖音」时是否需要自动恢复播放的 gating 谓词。
  ///
  /// 单纯靠 [_globalSuppressAutoPlay] 解决不了「抖音内子 tab 切到关注/发现后
  /// 又跨底部 tab 出去再回来」的场景：此时热门子 tab 上的 [ShortVideoPlayLogic]
  /// 仍在 [_activeTags] 里活着，[resumeAllActive] 会把它一并起播，但用户当前
  /// 看到的是关注/发现 sub-tab —— 视频不可见但音频已经出来了。
  ///
  /// 这里把判断委托给 [ShortVideoMainLogic]：它在 [onInit] 注册回调，根据
  /// 当前 `tabController.index` 对应的 sub-tab type 决定 —— 命中
  /// [ShortVideoPrimaryTabType.hot] 才返回 true。`null` 视为「没有 gating」，
  /// 兼容 [ShortVideoMainLogic] 还没注册的早期场景（此时 [_activeTags] 也必然
  /// 为空，行为一致）。
  static bool Function()? _shouldAutoResumeOnReturn;

  static void setShouldAutoResumeOnReturn(bool Function()? predicate) {
    _shouldAutoResumeOnReturn = predicate;
  }

  static Future<void> pauseAllActive({bool showPauseIcon = false}) async {
    for (final tag in List<String>.from(_activeTags)) {
      if (!Get.isRegistered<ShortVideoPlayLogic>(tag: tag)) continue;
      await Get.find<ShortVideoPlayLogic>(tag: tag)
          .pauseCurrentVideo(showPauseIcon: showPauseIcon);
    }
  }

  /// 恢复所有活跃实例的自动播放。配合 [pauseAndSuppressAll] / 全局抑制位使用。
  ///
  /// gating：[_shouldAutoResumeOnReturn] 返回 false 时整段短路。当前唯一的
  /// 调用方是 [resumeAndAllowAll]（跨底部 tab 切回抖音）；子 tab 切换有自己
  /// 的 [pauseAllActive]，不走这里。
  static Future<void> resumeAllActive() async {
    if (_shouldAutoResumeOnReturn != null && !_shouldAutoResumeOnReturn!()) {
      return;
    }
    for (final tag in List<String>.from(_activeTags)) {
      if (!Get.isRegistered<ShortVideoPlayLogic>(tag: tag)) continue;
      final logic = Get.find<ShortVideoPlayLogic>(tag: tag);
      final player = logic.state.videoListController
          .playerOfIndex(logic.state.currentIndex);
      // 槽位可能已被全局池其它 owner 抢走，先重建再起播。
      if (player == null || !player.hasController) {
        await logic.rehydratePlayersAfterRelease();
      }
      await logic.resumeCurrentVideo();
    }
  }

  /// 「离开 Douyin 底部 tab」专用入口：
  /// - 置全局抑制位（让之后才注册的 logic 也能在 [onInit] 拿到正确状态）；
  /// - 对当前所有活跃实例走带抑制位的 pause（即使 `!hasController` 也会把
  ///   per-instance 的抑制位标记上，防止初始化完成后自动 play）。
  static Future<void> pauseAndSuppressAll() async {
    _globalSuppressAutoPlay = true;
    for (final tag in List<String>.from(_activeTags)) {
      if (!Get.isRegistered<ShortVideoPlayLogic>(tag: tag)) continue;
      await Get.find<ShortVideoPlayLogic>(tag: tag)
          .pauseCurrentVideo(suppressAutoPlay: true);
    }
  }

  /// 「回到 Douyin 底部 tab」专用入口：与 [pauseAndSuppressAll] 对称。
  static Future<void> resumeAndAllowAll() async {
    _globalSuppressAutoPlay = false;
    await resumeAllActive();
  }

  final Future<PaginationModel<VideoModel>> Function()? videoProvider;
  final String? controllerTag;

  ShortVideoPlayLogic({
    int? initialIndex,
    List<VideoModel> initialList = const [],
    this.videoProvider,
    this.controllerTag,
  }) : super(
          initialList: initialList.map((e) {
            return ShortVideoModel.fromVideoModel(e);
          }).toList(),
          initialIndex: initialIndex,
          isMore: videoProvider != null,
        );

  final _state = ShortVideoPlayState<ShortVideoModel>();

  @override
  void onInit() {
    if (controllerTag != null) {
      _activeTags.add(controllerTag!);
      // 仅 Douyin 一级 tab 内部的实例（带 controllerTag）才受全局抑制约束。
      // 必须在 super.onInit() *之前* 把抑制位落到 VideoListController：
      // super.onInit() 会同步触发 `videoListController.init(...)` → `_initVideo`
      // 的异步链，里面的 `await _initializeControllerAtIndex` 一旦 resolve
      // 就会走 `_playControllerAtIndex` —— 那时再设置就来不及了。
      if (_globalSuppressAutoPlay) {
        state.videoListController.setSuppressAutoPlay(true);
      }
    }
    super.onInit();
    // 成为前台 owner，可从池中抢占其它不可见列表的槽。
    state.videoListController.claimActiveOwner();
  }

  @override
  void onClose() {
    if (controllerTag != null) {
      _activeTags.remove(controllerTag);
    }
    super.onClose();
  }

  @override
  ShortVideoPlayState<ShortVideoModel> get state => _state;

  @override
  Future<void> Function(VideoController<ShortVideoModel>) get beforeInit =>
      getVideoInfo;

  Future<void> getVideoInfo(VideoController<ShortVideoModel> controller) async {
    try {
      final oldVideoInfoId = controller.videoInfo.id;
      final resp = await MediaApi.getMediaInfo(controller.videoInfo.id!);
      final isAuthCode = PlayerCodeManage.isAuthCode(resp.code);
      if (resp.isSuccess || isAuthCode) {
        final mediaInfo = MediaInfo.fromJson(resp.toJson());
        final videoInfo = _shortVideoFromMediaInfo(
          mediaInfo,
          controller.videoInfo,
          isAuthCode: isAuthCode,
        );
        videoInfo.playerCode = resp.code;
        _syncAuthOverlayState(videoInfo);
        if (videoInfo.realVideoUrl.isEmpty) {
          controller.videoInfo = videoInfo;
          HistoryOperation.getInstance()?.addShortVideoModel(info: mediaInfo);
          _updateVideoInfo(oldVideoInfoId, controller.videoInfo.id);
          // beforeInit 阶段尚无池内解码器，不能碰 .controller getter。
          if (!isAuthCode) {
            controller.markInitError('short video realVideoUrl is empty');
          }
          return;
        }
        controller.videoInfo = videoInfo;
        HistoryOperation.getInstance()?.addShortVideoModel(info: mediaInfo);
        _updateVideoInfo(oldVideoInfoId, controller.videoInfo.id);
      } else {
        controller.markInitError('视频信息加载错误');
      }
    } catch (e) {
      controller.markInitError('视频信息加载错误');
    }
  }

  void _syncAuthOverlayState(ShortVideoModel videoInfo) {
    final id = videoInfo.id;
    if (id == null) return;
    if (videoInfo.shouldAutoShowAuthOverlay &&
        !state.dismissedAuthOverlayVideoIds.contains(id)) {
      state.authOverlayVideoId = id;
    } else if (videoInfo.shouldAutoShowGoldOverlay &&
        !state.dismissedGoldOverlayVideoIds.contains(id)) {
      state.goldOverlayVideoId = id;
    }
  }

  void _updateVideoInfo(String? oldId, String? newId) {
    final ids = <String>[
      if (oldId != null) 'videoInfo$oldId',
      if (newId != null) 'videoInfo$newId',
    ];
    update(ids.toSet().toList());
  }

  ShortVideoModel _shortVideoFromMediaInfo(
    MediaInfo mediaInfo,
    ShortVideoModel old, {
    bool isAuthCode = false,
  }) {
    final info = mediaInfo.data;
    final content =
        info?.contents.isNotEmpty == true ? info!.contents.first : null;
    final author = mediaInfo.result?.author;
    final cover = _pickNonEmpty([
      info?.autoCover,
      info?.horizontalCover,
      info?.verticalCover,
      old.cover,
    ]);

    return ShortVideoModel(
      id: info?.id ?? content?.mediaId ?? old.id,
      title: _pickNonEmpty([info?.title, content?.name, old.title]) ?? '',
      cover: cover,
      sourceUrl: content?.videoUrl ?? old.sourceUrl,
      realVideoUrl: isAuthCode
          ? content?.realVideoUrl ?? ''
          : content?.realVideoUrl ?? old.realVideoUrl,
      permission:
          content?.listenPermission ?? info?.permission ?? old.permission,
      hasPaid: content?.mediaStatus?.hasPaid ??
          info?.mediaStatus?.hasPaid ??
          old.hasPaid,
      price: content?.price ?? info?.price ?? old.price,
      hasFollowed: author?.follow ?? info?.hasFollow ?? old.hasFollowed,
      authorUid: author?.id ?? old.authorUid,
      authorAvatar: _pickNonEmpty([author?.avatar, old.authorAvatar]),
      authorName: _pickNonEmpty([author?.nickName, old.authorName]),
      authorFansNum: author?.fansNum ?? old.authorFansNum,
      authorPostNum: author?.pnum ?? old.authorPostNum,
      authorWorksNum: author?.vnum ?? old.authorWorksNum,
      hasLiked: info?.mediaStatus?.hasLiked ??
          content?.mediaStatus?.hasLiked ??
          old.hasLiked,
      likeCount: info?.countLike ?? content?.countLike ?? old.likeCount,
      hasCollected: info?.mediaStatus?.hasCollected ??
          content?.mediaStatus?.hasCollected ??
          old.hasCollected,
      collectCount:
          info?.countCollect ?? content?.countCollect ?? old.collectCount,
      commentCount:
          info?.countComment ?? content?.countComment ?? old.commentCount,
      playCount: info?.countBrowse ?? content?.countBrowse ?? old.playCount,
      shareCount: old.shareCount,
      playerCode: mediaInfo.code ?? old.playerCode,
      newsType: old.newsType,
      tags: _parseTags(
        mediaInfo.result?.vod?.tags ?? info?.tags ?? info?.tagNames,
      ),
    );
  }

  String? _pickNonEmpty(List<String?> values) {
    for (final value in values) {
      final text = value?.trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }

  List<TagsModel> _parseTags(dynamic raw) {
    if (raw == null) return const [];
    if (raw is String) {
      final name = raw.trim();
      if (name.isEmpty) return const [];
      return [
        TagsModel.fromJson({'name': name})
      ];
    }
    if (raw is! List) return const [];

    return raw.map((item) {
      if (item is Map) {
        return TagsModel.fromJson(Map<String, dynamic>.from(item));
      }
      return TagsModel.fromJson({'name': item.toString()});
    }).toList();
  }

  @override
  Future<List<VideoController<ShortVideoModel>>> onMore() {
    if (!state.hasNext || videoProvider == null) {
      return Future.value([]);
    }
    return videoProvider!.call().then((value) {
      state.hasNext = value.hasNext;
      return value.list.map((e) {
        final videoInfo = ShortVideoModel.fromVideoModel(e);
        return buildVideoController(videoInfo);
      }).toList();
    });
  }
}
