import 'package:comics_app/common/apis/circle_api.dart';
import 'package:comics_app/common/apis/mine_apis.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/my_list/mine_media_paged_list_base_logic.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/widgets/post_card/post_card.dart';
import 'package:flutter/foundation.dart';

import '../../../common/apis/game_api.dart';
import '../../../common/entities/circle/game_data_model.dart';

/// 我的收藏：影片 / 抖音（[MineApis.getCollectVideoList]）、帖子（[MineApis.getCollectPostList]）。
class MyCollectionLogic extends MineMediaPagedListBaseLogic {
  @override
  String get pageTitle => '我的收藏';

  // 编辑删除接口未对齐前，先在右上角隐藏「编辑」入口，避免假删除误导用户。
  // 对接服务端真接口后去掉本覆盖即可恢复（基类默认 `showEditAction => true`）。
  @override
  bool get showEditAction => false;

  @override
  List<MineMediaTabSpec> get tabs => kMyCollectionMineTabs;

  /// cms/favorites：0 影片，1 抖音。
  int favoritesVideoTypeFor(int tabIndex) => tabIndex;

  @override
  Future<MineMediaPageResult> fetchPageChunk(
    int tabIndex,
    int page, {
    required bool replace,
  }) async {
    switch (tabs[tabIndex].kind) {
      case MineMediaPaneKind.longVideo:
      case MineMediaPaneKind.shortVideo:
        final chunk = await MineApis.getCollectVideoList(
          videoType: favoritesVideoTypeFor(tabIndex),
          page: page,
          pageSize: pageSize,
        );
        if (tabs[tabIndex].kind == MineMediaPaneKind.longVideo) {
          longVideoItems =
              replace ? chunk : <MediaVideoModel>[...longVideoItems, ...chunk];
        } else {
          shortVideoItems =
              replace ? chunk : <MediaVideoModel>[...shortVideoItems, ...chunk];
        }
        return MineMediaPageResult(
          appendedCount: chunk.length,
          hasMore: chunk.length >= pageSize,
        );
      case MineMediaPaneKind.post:
        final chunk = await MineApis.getCollectPostList(
          page: page,
          pageSize: pageSize,
        );
        postItems = replace ? chunk : <PostCardData>[...postItems, ...chunk];
        return MineMediaPageResult(
          appendedCount: chunk.length,
          hasMore: chunk.length >= pageSize,
        );
      case MineMediaPaneKind.game:
        final List<GameDataModel> chunk = await GameApi.getFavorites(
          page: page,
          pageSize: pageSize,
        );
        gameItems = replace ? chunk : <GameDataModel>[...gameItems, ...chunk];
        return MineMediaPageResult(
          appendedCount: chunk.length,
          hasMore: chunk.length >= pageSize,
        );
      default:
        return const MineMediaPageResult(appendedCount: 0, hasMore: false);
    }
  }

  @override
  Future<void> deleteSelectedForCurrentTab() async {
    if (currentSelectionCount == 0) {
      showToast(msg: '请先选择');
      return;
    }
    // 帖子 Tab 走真实的批量取消收藏接口（isCollection=0），成功后再本地移除。
    // 视频 Tab 暂无对应接口，先沿用占位逻辑。
    if (tabs[tabIndex].kind == MineMediaPaneKind.post) {
      await _cancelCollectPosts();
      return;
    }
    if (tabs[tabIndex].kind == MineMediaPaneKind.game) {
      await _cancelCollectGames();
      return;
    }
    await runMineMediaDelete(this, '我的收藏');
  }

  Future<void> _cancelCollectPosts() async {
    final sel = selectedPerTab[tabIndex];
    final ids = <int>[
      for (final i in sel)
        if (i >= 0 && i < postItems.length) postItems[i].id,
    ];
    if (ids.isEmpty) {
      showToast(msg: '请先选择');
      return;
    }
    try {
      final ok = await CircleApi.postCollection(ids, 0);
      if (!ok) {
        showToast(msg: '取消收藏失败');
        return;
      }
    } catch (e, st) {
      debugPrint('my collection cancel post collection error: $e\n$st');
      showToast(msg: '取消收藏失败');
      return;
    }
    applyLocalDeleteForTab(tabIndex);
    showToast(msg: '已取消收藏');
  }

  Future<void> _cancelCollectGames() async {
    final sel = selectedPerTab[tabIndex];
    final ids = <int>[
      for (final i in sel)
        if (i >= 0 && i < gameItems.length) gameItems[i].id,
    ];
    if (ids.isEmpty) {
      showToast(msg: '请先选择');
      return;
    }
    try {
      final ok = await GameApi.collection(ids: ids, isCollection: false);
      if (!ok) {
        showToast(msg: '取消收藏失败');
        return;
      }
    } catch (e, st) {
      debugPrint('my collection cancel game collection error: $e\n$st');
      showToast(msg: '取消收藏失败');
      return;
    }
    applyLocalDeleteForTab(tabIndex);
    showToast(msg: '已取消收藏');
  }
}
