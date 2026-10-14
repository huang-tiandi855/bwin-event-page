import 'package:comics_app/common/entities/circle/post_card_data.dart';
import 'package:comics_app/common/entities/media_info.dart';
import 'package:comics_app/common/my_list/mine_media_list_base_logic.dart';
import 'package:comics_app/common/utils/history/history_display_mapper.dart';
import 'package:comics_app/common/utils/history/history_operation.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/widgets/item/home_topic_widget.dart';

import '../../../common/entities/circle/game_data_model.dart';

class MineHistoryRecordLogic extends MineMediaListBaseLogic {
  /// 帖子 Tab 当前展示的 [PostCardData] 列表，与 [postItems] 一一对应；
  /// 点击 / 删除按下标走该数组取真实数据。
  final List<PostCardData> _postRecords = <PostCardData>[];

  @override
  String get pageTitle => '历史记录';

  // 按业务要求暂时隐藏右上角「编辑」入口；与「我的收藏 / 购买 / 喜欢」一起
  // 先收掉编辑态，删除接口 / 交互对齐后去掉本覆盖即可恢复
  // （基类默认 `showEditAction => true`，本地真删流程 [deleteSelectedForCurrentTab]
  // 与 [HistoryOperation.delete] 都已保留，不需要再补回业务代码）。
  @override
  bool get showEditAction => false;

  @override
  List<MineMediaTabSpec> get tabs => kMyHistoryMineTabs;

  // 删除原本的 `onReady` 全 Tab 预加载循环：首屏由
  // [MineMediaListBaseLogic.onInit] 仅加载当前 Tab，其余 Tab 由
  // shell 的 `ensureTabLoaded` 在切到 / 滑过时懒加载。

  @override
  Future<void> fetchTabData(int tabIndex) async {
    switch (tabs[tabIndex].kind) {
      case MineMediaPaneKind.longVideo:
        await _loadVideoHistory(HistoryRecordType.video, longVideo: true);
        break;
      case MineMediaPaneKind.shortVideo:
        await _loadVideoHistory(HistoryRecordType.short, longVideo: false);
        break;
      case MineMediaPaneKind.post:
        await _loadPostHistory();
        break;
      case MineMediaPaneKind.game:
        await _loadGameHistory();
        break;
      default:
        break;
    }
    update();
  }

  Future<void> _loadVideoHistory(
    HistoryRecordType type, {
    required bool longVideo,
  }) async {
    final records = HistoryOperation.getInstance()?.getMediaInfoHistory(type) ??
        <MediaInfo>[];
    final items =
        records.map(HistoryDisplayMapper.fromMediaInfo).toList(growable: false);
    if (longVideo) {
      longVideoItems = items;
    } else {
      shortVideoItems = items;
    }
  }

  Future<void> _loadGameHistory() async {
    gameItems = List<GameDataModel>.from(
      HistoryOperation.getInstance()?.getGameHistory() ??
          const <GameDataModel>[],
    );
  }

  Future<void> _loadPostHistory() async {
    _postRecords
      ..clear()
      ..addAll(
        HistoryOperation.getInstance()?.getPostCardHistory() ??
            const <PostCardData>[],
      );
    // PostCardData 自身就是 PostCard 的数据源，不再需要中间 mapper。
    postItems = List<PostCardData>.from(_postRecords);
  }

  HistoryRecordType? _recordTypeForTab(int tabIndex) {
    switch (tabs[tabIndex].kind) {
      case MineMediaPaneKind.longVideo:
        return HistoryRecordType.video;
      case MineMediaPaneKind.shortVideo:
        return HistoryRecordType.short;
      case MineMediaPaneKind.post:
        return HistoryRecordType.post;
      case MineMediaPaneKind.game:
        return HistoryRecordType.game;
      default:
        return null;
    }
  }

  @override
  void onLongVideoItemTap(int tabIndex, int itemIndex) {
    if (itemIndex < 0 || itemIndex >= longVideoItems.length) return;
    final id = longVideoItems[itemIndex].id;
    if (id == null || id.isEmpty) return;
    jumpMediaPlay(id);
  }

  /// 抖音 Tab 点击 → 与「我的收藏 / 我的喜欢」等保持一致，走垂直滑动播放页
  /// [jumpShortMediaPlay]：传整份 [shortVideoItems] + 命中 [itemIndex]，
  /// 进 [ShortVideoPlayPage] 后即可在历史记录范围内上下滑切集。
  ///
  /// 历史记录为本地全量数据、无分页接口，因此不接 `videoProvider`，
  /// 滑到底就停在最后一条。
  @override
  void onShortVideoItemTap(int tabIndex, int itemIndex) {
    if (itemIndex < 0 || itemIndex >= shortVideoItems.length) return;
    jumpShortMediaPlay(
      mediaList: shortVideoItems,
      index: itemIndex,
    );
  }

  @override
  Future<void> deleteSelectedForCurrentTab() async {
    if (currentSelectionCount == 0) {
      showToast(msg: '请先选择');
      return;
    }
    final t = tabIndex;
    final type = _recordTypeForTab(t);
    if (type == null) return;

    final indices = selectedPerTab[t].toList()..sort((a, b) => b.compareTo(a));
    final op = HistoryOperation.getInstance();
    if (op == null) return;

    for (final i in indices) {
      op.delete(type, i);
    }

    selectedPerTab[t].clear();
    editing = false;
    await fetchTabData(t);
  }
}
