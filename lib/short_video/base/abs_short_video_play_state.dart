part of short_video_play_logic_impl;

abstract class AbsShortVideoPlayState<T extends ShortVideoModel> {
  VideoListController<T> videoListController = VideoListController();

  late PageController pageController;

  int currentIndex = 0;

  bool hasNext = true;

  bool visible = false;

  bool isShowDialog = false;

  bool isRequestFollow = false;

  bool isRequestLike = false;

  bool isRequestCollect = false;

  String? authOverlayVideoId;

  final Set<String> dismissedAuthOverlayVideoIds = <String>{};

  /// 当前展示金币付费浮层的视频 id（`needPermission == 1`）。
  String? goldOverlayVideoId;

  /// 用户主动关闭过金币付费浮层的视频 id 集合，避免反复弹出。
  final Set<String> dismissedGoldOverlayVideoIds = <String>{};

  /// 已被服务端 `videoGoldPay` 接口返回 1035（金币不足）标记过的视频 id 集合，
  /// 浮层据此切换为「金币不足」形态（标题改成「金币不足」、左按钮改为「去充值」
  /// 跳钱包）。用户从钱包返回且金币已充足后由 [AbsShortVideoPlayLogic] 移除。
  final Set<String> insufficientGoldVideoIds = <String>{};

  /// 当前展示观影券付费浮层的视频 id（命中 1008 / 1038 且用户持券）。
  ///
  /// 与 [authOverlayVideoId] / [goldOverlayVideoId] 同位面：触发鉴权浮层时由
  /// [AbsShortVideoPlayLogic.showMovieTicketOverlay] 写入。
  /// 浮层无 dismiss 流程 ——「跳过预览」是 UI 装饰，唯一退出路径是用券；
  /// 用券成功后由 [AbsShortVideoPlayLogic._refreshCurrentVideoAfterPay] 清空。
  String? movieTicketOverlayVideoId;

  String beginTime = DataFormats.getUtcDate();
}
