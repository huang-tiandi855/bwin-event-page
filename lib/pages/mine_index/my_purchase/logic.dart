import 'package:comics_app/common/apis/mine_apis.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/my_list/mine_media_paged_list_base_logic.dart';
import 'package:comics_app/common/widgets/post_card/post_card.dart';

import '../../../common/apis/dating_api.dart';
import '../../../common/apis/game_api.dart';
import '../../../common/entities/circle/dating_models.dart';
import '../../../common/entities/circle/game_data_model.dart';

/// 我的购买：影片 / 抖音走 [MineApis.getUserPays]（按 `tabType` 区分）；
/// 帖子走 [MineApis.getUserPaysPostingList]（`posting/my/pays`）。
class MyPurchaseLogic extends MineMediaPagedListBaseLogic {
  @override
  String get pageTitle => '我的购买';

  // 编辑删除接口未对齐前，先在右上角隐藏「编辑」入口，避免假删除误导用户。
  // 对接服务端真接口后去掉本覆盖即可恢复（基类默认 `showEditAction => true`）。
  @override
  bool get showEditAction => false;

  @override
  List<MineMediaTabSpec> get tabs => kMyPurchaseMineTabs;

  /// 接口 tabType：影片 1、抖音 2（帖子走独立接口 `posting/my/pays`，无 tabType）。
  int purchaseTabTypeFor(int tabIndex) => tabIndex + 1;

  @override
  Future<MineMediaPageResult> fetchPageChunk(
    int tabIndex,
    int page, {
    required bool replace,
  }) async {
    switch (tabs[tabIndex].kind) {
      case MineMediaPaneKind.post:
        final chunk = await MineApis.getUserPaysPostingList(page: page);
        postItems = replace ? chunk : <PostCardData>[...postItems, ...chunk];
        return MineMediaPageResult(
          appendedCount: chunk.length,
          hasMore: chunk.length >= pageSize,
        );
      case MineMediaPaneKind.longVideo:
      case MineMediaPaneKind.shortVideo:
        final tabType = purchaseTabTypeFor(tabIndex);
        final chunk = await MineApis.getUserPays(tabType: tabType, page: page);
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
      case MineMediaPaneKind.game:
        final List<GameDataModel> chunk = await GameApi.getMyPays(page: page);
        gameItems = replace ? chunk : <GameDataModel>[...gameItems, ...chunk];
        return MineMediaPageResult(
          appendedCount: chunk.length,
          hasMore: chunk.length >= pageSize,
        );
      case MineMediaPaneKind.dating:
        final chunk = await DatingApi.getMyPays(page: page);
        datingItems =
            replace ? chunk : <DatingCardModel>[...datingItems, ...chunk];
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
      runMineMediaDelete(this, '我的购买');
}
