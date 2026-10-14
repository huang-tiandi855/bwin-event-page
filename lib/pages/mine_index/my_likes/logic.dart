import 'package:comics_app/common/apis/mine_apis.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/my_list/mine_media_paged_list_base_logic.dart';
import 'package:comics_app/common/widgets/post_card/post_card.dart';

import '../../../common/apis/game_api.dart';
import '../../../common/entities/circle/game_data_model.dart';

/// 我的喜欢：影片 / 抖音（[MineApis.getLikeVideoList]）、帖子（[MineApis.getLikePostList]）。
class MyLikesLogic extends MineMediaPagedListBaseLogic {
  @override
  String get pageTitle => '我的喜欢';

  // 编辑删除接口未对齐前，先在右上角隐藏「编辑」入口，避免假删除误导用户。
  // 对接服务端真接口后去掉本覆盖即可恢复（基类默认 `showEditAction => true`）。
  @override
  bool get showEditAction => false;

  @override
  List<MineMediaTabSpec> get tabs => kMyLikesMineTabs;

  /// GET cms/favorites：0 影片，2 抖音。
  int likeVideoTypeFor(int tabIndex) => tabIndex == 0 ? 0 : 1;

  @override
  Future<MineMediaPageResult> fetchPageChunk(
    int tabIndex,
    int page, {
    required bool replace,
  }) async {
    switch (tabs[tabIndex].kind) {
      case MineMediaPaneKind.longVideo:
      case MineMediaPaneKind.shortVideo:
        final chunk = await MineApis.getLikeVideoList(
          videoType: likeVideoTypeFor(tabIndex),
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
        final chunk = await MineApis.getLikePostList(
          page: page,
          pageSize: pageSize,
        );
        postItems = replace ? chunk : <PostCardData>[...postItems, ...chunk];
        return MineMediaPageResult(
          appendedCount: chunk.length,
          hasMore: chunk.length >= pageSize,
        );
      case MineMediaPaneKind.game:
        final List<GameDataModel> chunk = await GameApi.getPerfectList(
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
  Future<void> deleteSelectedForCurrentTab() async =>
      runMineMediaDelete(this, '我的喜欢');
}
