import 'package:comics_app/common/apis/game_api.dart';
import 'package:comics_app/common/entities/circle/gaming_models.dart';
import 'package:comics_app/common/entities/circle/post_enums.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/http/code.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/utils/history/history_operation.dart';
import 'package:comics_app/common/utils/tab_controller_dispose.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/widgets/common_dialog/need_vip_dialog.dart';
import 'package:comics_app/pages/circle/games/game_details/game_details_state.dart';
import 'package:comics_app/pages/circle/games/game_details/game_pay_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class GameDetailsLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  final GameDetailsState state = GameDetailsState();

  late final TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    final args = Get.arguments;
    state.gameId = args is Map && args['gameId'] != null
        ? int.tryParse('${args['gameId']}') ?? 0
        : 0;
    _loadDetail();
  }

  @override
  void onClose() {
    disposeTabControllerAfterRouteExit(tabController);
    state.scrollController.dispose();
    state.relatedPullController.dispose();
    super.onClose();
  }

  Future<void> _loadDetail() async {
    if (state.gameId <= 0) {
      state.loading = false;
      state.loadFailed = true;
      update();
      return;
    }

    state.loading = true;
    state.loadFailed = false;
    update();

    final List<Object?> results = await Future.wait<Object?>([
      GameApi.watch(state.gameId),
      GameApi.getDetail(state.gameId),
    ]);
    if (isClosed) return;

    final GameDataModel? vo = results[1] as GameDataModel?;
    if (vo == null) {
      state.loading = false;
      state.loadFailed = true;
      update();
      return;
    }

    _applyVo(vo);
    state.loading = false;
    update();
    _recordBrowseHistory();
    _loadRelated(vo);
  }

  void _applyVo(GameDataModel vo) {
    state.game = vo;
    state.isLike = vo.isPerfect;
    state.isCollect = vo.isCollect;
    state.gameName = vo.title;
    state.intro = vo.introText;
    state.version = vo.version;
    state.fileSize = vo.fileSize;
    state.categoryLabel = vo.categoryNames.join(',');
    state.languageLabel = vo.languageName ?? '';
    state.platforms =
        (vo.platform?.isNotEmpty ?? false) ? vo.platform!.split(',') : const [];
    state.detailTags = vo.tagNames;
    state.coverUrls = vo.coverUrls;

    if (vo.unlocked) {
      state.downloadLinks = vo.resolvedDownloads;
      state.downloadUrl = state.downloadLinks.isNotEmpty
          ? state.downloadLinks.first.url
          : (vo.downloadUrl ?? '');
      state.extractPassword = vo.extractPassword ?? '';
      state.downloadRevealed = vo.costType == PostCostType.free ? false : true;
    } else {
      state.downloadRevealed = false;
      state.downloadLinks = const <GamingDownloadItem>[];
      state.downloadUrl = '';
      state.extractPassword = '';
    }
  }

  Future<void> _loadRelated(GameDataModel vo) async {
    state.relatedCategoryId =
        vo.categoryIds.isNotEmpty ? vo.categoryIds.first : null;
    state.relatedPage = 1;
    state.relatedHasMore = true;
    state.relatedGames = <GameDataModel>[];
    state.relatedPullController.requesting();
    await loadRelatedPage(refresh: true);
  }

  /// 相关推荐分页：下拉刷新 / 上拉加载。
  Future<void> loadRelatedPage({required bool refresh}) async {
    final int page = refresh ? 1 : state.relatedPage + 1;
    final GamingListPage? result = await GameApi.getList(
      GamingListQuery(
        page: page,
        pageSize: GameDetailsState.relatedPageSize,
        categoryId: state.relatedCategoryId,
        sortType: GamingSortType.recommend,
      ),
    );
    if (isClosed) return;

    if (result == null) {
      state.relatedPullController.requestFail(isFirstPageNum: refresh);
      update(['related']);
      return;
    }

    final List<GameDataModel> chunk =
        result.list.where((e) => e.id != state.gameId).toList();
    state.relatedGames = refresh
        ? chunk
        : (List<GameDataModel>.from(state.relatedGames)..addAll(chunk));
    state.relatedPage = page;
    state.relatedHasMore = result.hasNextPage;
    state.relatedPullController.requestSuccess(
      isFirstPageNum: refresh,
      hasMore: state.relatedHasMore,
      isEmpty: state.relatedGames.isEmpty,
    );
    update(['related']);
  }

  void _recordBrowseHistory() {
    final GameDataModel? game = state.game;
    if (game == null) return;
    HistoryOperation.getInstance()?.addGame(info: game);
  }

  /// 相关推荐点击：在当前页刷新详情，不重复入栈。
  Future<void> openRelatedGame(GameDataModel item) async {
    if (item.id <= 0 || item.id == state.gameId) return;
    state.gameId = item.id;
    state.game = null;
    state.introExpanded = false;
    state.relatedGames = <GameDataModel>[];
    state.relatedPage = 1;
    state.relatedHasMore = true;
    state.relatedCategoryId = null;
    if (tabController.index != 0) {
      tabController.animateTo(0);
    }
    if (state.scrollController.hasClients) {
      state.scrollController.jumpTo(0);
    }
    await _loadDetail();
  }

  void toggleIntro() {
    state.introExpanded = !state.introExpanded;
    update(['intro']);
  }

  Future<void> onLike() async {
    final GameDataModel? game = state.game;
    if (game == null) return;
    final bool ok = await GameApi.perfect(game.id);
    if (!ok || isClosed) return;
    state.isLike = !state.isLike;
    game.isPerfect = state.isLike;
    game.perfect = state.isLike
        ? game.perfect + 1
        : (game.perfect > 0 ? game.perfect - 1 : 0);
    update(['like']);
  }

  Future<void> onCollect() async {
    final GameDataModel? game = state.game;
    if (game == null) return;
    final bool next = !state.isCollect;
    final bool ok = await GameApi.collection(
      ids: <int>[game.id],
      isCollection: next,
    );
    if (!ok || isClosed) return;
    state.isCollect = next;
    game.isCollect = next;
    game.collectNum = next ? game.collectNum + 1 : game.collectNum - 1;
    update(['collection', 'bottom_bar']);
  }

  Future<void> onSend(String result) async {
    final content = result.trim();
    if (content.isEmpty) {
      showToast(msg: '请输入评论内容');
      return;
    }
    if (state.gameId <= 0) return;
    final BaseRespBean resp = await GameApi.addComment(
      pid: state.gameId,
      content: content,
    );
    if (resp.isSuccess || resp.bizCode == Code.DOC_PENDING_AUDIT) {
      showToast(msg: '发送成功，等待审核！');
      return;
    }
    if (resp.bizCode == Code.DOC_COMMENT_COUNT_LIMIT) {
      showToast(msg: resp.msg ?? resp.tip ?? '无法评论');
      return;
    }
    showToast(msg: resp.msg ?? resp.tip ?? '发表失败');
  }

  Future<void> onUnlockTap(BuildContext context) async {
    final GameDataModel? game = state.game;
    if (game == null) return;

    if (state.downloadRevealed) {
      if (state.downloadUrl.isEmpty) {
        showToast(msg: '暂无下载地址');
        return;
      }
      await Clipboard.setData(ClipboardData(text: state.downloadUrl));
      showToast(msg: '下载地址已复制');
      return;
    }

    final PostCostType cost = game.costType ?? PostCostType.free;

    //未解锁
    switch (cost) {
      case PostCostType.free:
        await _requestUnlock();
        return;
      case PostCostType.gold:
        await showGamePayBottomSheet(
          context,
          unlockPrice: game.gold,
          coinBalance: UserStore.to.getUserInfoModel?.walletApp ?? 0,
          onUnlock: () {
            _requestUnlock();
          },
        );
        break;
      case PostCostType.vip:
        await showNeedVipDialog(
          bodyLine1: '开通带「游戏解锁」权限的 VIP',
          bodyLine2: '即可查看下载地址',
          sureText: '开通会员',
          onOpenVip: () => Get.toNamed(AppRoutes.MEMBER_CENTER),
        );
        break;
      default:
        break;
    }
  }

  Future<void> onCopyTap(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    showToast(msg: '下载地址已复制');
    return;
  }

  Future<void> _requestUnlock() async {
    final BaseRespBean resp = await GameApi.unlock(state.gameId);
    if (isClosed) return;

    if (resp.isSuccess && Code.isDocSuccess(resp.bizCode)) {
      final GamingUnlockVo? unlock = GamingUnlockVo.fromAny(resp.result);
      _applyUnlockResult(unlock);
      UserStore.to.refreshUser();
      showToast(msg: '解锁成功');
      return;
    }

    if (resp.bizCode == Code.DOC_INSUFFICIENT_GOLD) {
      showNeedVipDialog(
        bodyLine1: '金币不足',
        bodyLine2: '请前往钱包充值',
        sureText: '立即充值',
        onOpenVip: () => Get.toNamed(AppRoutes.WALLET),
      );
      return;
    }

    if (resp.bizCode == Code.DOC_LIMIT_EXCEEDED) {
      showNeedVipDialog(
        bodyLine1: '开通带「游戏解锁」权限的 VIP',
        bodyLine2: '即可查看下载地址',
        sureText: '开通会员',
        onOpenVip: () => Get.toNamed(AppRoutes.MEMBER_CENTER),
      );
      return;
    }

    showToast(msg: resp.msg ?? resp.tip ?? '解锁失败');
  }

  void _applyUnlockResult(GamingUnlockVo? unlock) {
    if (unlock == null) return;
    state.downloadLinks = unlock.resolvedDownloads;
    state.downloadRevealed = unlock.unlocked && state.downloadLinks.isNotEmpty;
    state.downloadUrl = state.downloadLinks.isNotEmpty
        ? state.downloadLinks.first.url
        : (unlock.downloadUrl ?? '');
    state.extractPassword = unlock.extractPassword ?? '';
    if (unlock.version.isNotEmpty) state.version = unlock.version;
    if (unlock.fileSize.isNotEmpty) state.fileSize = unlock.fileSize;

    final GameDataModel? game = state.game;
    if (game != null) {
      game.unlocked = unlock.unlocked;
      game.needPay = false;
      game.unlockCount = unlock.unlockCount;
      game.downloads = List<GamingDownloadItem>.from(state.downloadLinks);
      game.downloadUrl = state.downloadUrl.isEmpty ? null : state.downloadUrl;
      game.extractPassword = unlock.extractPassword;
    }
    update(['download']);
  }
}
