import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/utils/toast_util.dart';

import 'package:comics_app/common/widgets/novel_card/novel_card.dart';
import 'package:comics_app/common/widgets/photo_card/photo_card.dart';
import 'package:comics_app/common/widgets/post_card/post_card.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../entities/circle/dating_models.dart';
import '../entities/circle/game_data_model.dart';
import 'mine_tab_spec.dart';

export 'mine_tab_spec.dart';

/// 删除流程占位：无选中则提示；否则打日志 → 本地移除选中项 → Toast。
///
/// 对接服务端时：在 [MineMediaListBaseLogic.applyLocalDeleteForTab] 之前调用删除接口，
/// 仅当接口成功后再执行本地移除；[moduleName] 用于 `debugPrint` 区分入口（收藏/购买等）。
Future<void> runMineMediaDelete(
  MineMediaListBaseLogic logic,
  String moduleName,
) async {
  if (logic.currentSelectionCount == 0) {
    showToast(msg: '请先选择');
    return;
  }
  debugPrint('$moduleName 删除接口 TODO');
  logic.applyLocalDeleteForTab(logic.tabIndex);
  showToast(msg: '已删除');
}

/// 我的收藏 / 购买 / 喜欢 / 历史记录 等页的共享逻辑。
///
/// 列表数据按业务维度用**单层** `List`（影片 / 抖音 / 动漫 各一份，接口可分别覆盖
/// [fetchLongVideoItems]、[fetchShortVideoItems]、[fetchAnimeItems]）。
/// 仅 [selectedPerTab] 为 `List<Set<int>>`：每个 Tab 的勾选下标互不影响。
abstract class MineMediaListBaseLogic extends GetxController {
  VoidCallback? _shellTick;

  void attachShell(VoidCallback tick) => _shellTick = tick;

  void detachShell() => _shellTick = null;

  @override
  void onClose() {
    detachShell();
    super.onClose();
  }

  @override
  void update([List<Object>? ids, bool condition = true]) {
    super.update(ids, condition);
    _shellTick?.call();
  }

  String get pageTitle;

  bool get showEditAction => true;

  List<MineMediaTabSpec> get tabs => kDefaultMineMediaTabs;

  /// 为 true 时 [MineMediaListShell] 为每个 Tab 包裹 [PullRefreshView]。
  bool get supportsPullRefresh => false;

  PullRefreshController? pullRefreshForTab(int tabIndex) => null;

  Future<void> onMineListRefresh(int tabIndex) async {}

  Future<void> onMineListLoadMore(int tabIndex) async {}

  /// 列表项点击（非编辑态）；子类可跳转详情。
  void onLongVideoItemTap(int tabIndex, int itemIndex) {}

  void onShortVideoItemTap(int tabIndex, int itemIndex) {}

  void onPostItemTap(int tabIndex, int itemIndex, PostCardData item) {}

  bool editing = false;
  int tabIndex = 0;

  /// 已经请求过数据的 Tab 索引集合，用于 [ensureTabLoaded] 去重。
  /// 仅在首次切到 / 进入某个 Tab 时拉数据；下拉刷新走 [onMineListRefresh]
  /// 不受该集合影响（要重新拉的时候由调用方自行决定是否清掉 entry）。
  final Set<int> _loadedTabs = <int>{};

  /// 影片 Tab（长视频接口）。
  List<MediaVideoModel> longVideoItems = [];

  /// 抖音 Tab（短视频接口，可与 [longVideoItems] 不同）。
  List<MediaVideoModel> shortVideoItems = [];

  /// 动漫 Tab（模型与长视频相同，页面与接口独立）。
  List<MediaVideoModel> animeItems = [];

  List<PostCardData> postItems = [];
  List<NovelCardData> comicItems = [];
  List<PhotoCardData> photoItems = [];
  List<GameDataModel> gameItems = [];
  List<DatingCardModel> datingItems = [];

  /// 各 Tab 勾选下标，外层长度 = [tabs.length]。
  late final List<Set<int>> selectedPerTab;

  @override
  void onInit() {
    selectedPerTab = List.generate(tabs.length, (_) => <int>{});
    super.onInit();
    // 首屏只触发当前 Tab，避免一进页面就并发把所有 Tab 的接口都打一遍；
    // 其它 Tab 的拉数据交给 shell 的 `ensureTabLoaded` 在切到 / 滑过时
    // 懒加载。
    ensureTabLoaded(tabIndex);
  }

  /// Shell 切 Tab 后调用：仅当 [i] 还没拉过数据时才走 [loadTab]，已加载过的
  /// Tab 命中缓存直接 no-op，避免来回切 Tab 反复请求。下拉刷新 / loadMore
  /// 走 [onMineListRefresh] / [onMineListLoadMore]，与该去重逻辑独立。
  Future<void> ensureTabLoaded(int i) async {
    if (_loadedTabs.contains(i)) return;
    _loadedTabs.add(i);
    await loadTab(i);
  }

  /// 标记某个 Tab 为「未加载」，下一次切到时会重新走 [loadTab]。
  /// 一般在数据强制失效（如用户切换账号）后调用，普通刷新不需要走这里。
  void invalidateTabLoaded(int i) => _loadedTabs.remove(i);

  Future<void> loadTab(int i) async {
    await fetchTabData(i);
    update();
  }

  /// 按当前 Tab 类型拉数；子类可只覆盖对应的 `fetch*Items` 方法。
  Future<void> fetchTabData(int tabIndex) async {
    await Future<void>.delayed(const Duration(milliseconds: 40));
    switch (tabs[tabIndex].kind) {
      case MineMediaPaneKind.longVideo:
        await fetchLongVideoItems();
        break;
      case MineMediaPaneKind.shortVideo:
        await fetchShortVideoItems();
        break;
      case MineMediaPaneKind.anime:
        await fetchAnimeItems();
        break;
      case MineMediaPaneKind.post:
        await fetchPostItems();
        break;
      case MineMediaPaneKind.comic:
        await fetchComicItems();
        break;
      case MineMediaPaneKind.gallery:
        await fetchPhotoItems();
        break;
      case MineMediaPaneKind.game:
        await fetchGameItems();
        break;
      case MineMediaPaneKind.dating:
        await fetchDatingItems();
        break;
    }
  }

  /// 默认占位；接接口时在子类中覆盖，勿调 `super` 即可。
  Future<void> fetchLongVideoItems() async {
    longVideoItems = mockVideos('影片', short: false);
    update();
  }

  Future<void> fetchShortVideoItems() async {
    shortVideoItems = mockVideos('抖音', short: true);
    update();
  }

  Future<void> fetchAnimeItems() async {
    animeItems = mockVideos('动漫', short: false);
    update();
  }

  Future<void> fetchPostItems() async {
    postItems = mockPosts('帖子');
    update();
  }

  Future<void> fetchComicItems() async {
    comicItems = mockComics('漫画');
    update();
  }

  Future<void> fetchPhotoItems() async {
    photoItems = mockPhotos('图库');
    update();
  }

  Future<void> fetchGameItems() async {
    gameItems = [];
    update();
  }

  Future<void> fetchDatingItems() async {
    datingItems = [];
    update();
  }

  /// 当前 Tab 绑定的视频列表（仅 long / short / anime）。
  List<MediaVideoModel> videoItemsForTab(int tabIndex) {
    switch (tabs[tabIndex].kind) {
      case MineMediaPaneKind.longVideo:
        return longVideoItems;
      case MineMediaPaneKind.shortVideo:
        return shortVideoItems;
      case MineMediaPaneKind.anime:
        return animeItems;
      default:
        throw StateError(
          'Tab ${tabs[tabIndex].label} 不是视频类型',
        );
    }
  }

  void _setVideoItemsForTab(int tabIndex, List<MediaVideoModel> next) {
    switch (tabs[tabIndex].kind) {
      case MineMediaPaneKind.longVideo:
        longVideoItems = next;
        break;
      case MineMediaPaneKind.shortVideo:
        shortVideoItems = next;
        break;
      case MineMediaPaneKind.anime:
        animeItems = next;
        break;
      default:
        break;
    }
  }

  int itemCountForTab(int t) => _itemCountForTab(t);

  int _itemCountForTab(int t) {
    switch (tabs[t].kind) {
      case MineMediaPaneKind.longVideo:
        return longVideoItems.length;
      case MineMediaPaneKind.shortVideo:
        return shortVideoItems.length;
      case MineMediaPaneKind.anime:
        return animeItems.length;
      case MineMediaPaneKind.post:
        return postItems.length;
      case MineMediaPaneKind.comic:
        return comicItems.length;
      case MineMediaPaneKind.gallery:
        return photoItems.length;
      case MineMediaPaneKind.game:
        return gameItems.length;
      case MineMediaPaneKind.dating:
        return datingItems.length;
    }
  }

  void setTabIndex(int i) {
    tabIndex = i;
    update();
  }

  void toggleEditing() {
    editing = !editing;
    if (!editing) {
      for (final s in selectedPerTab) {
        s.clear();
      }
    }
    update();
  }

  void toggleItemSelection(int tabIdx, int itemIdx) {
    final s = selectedPerTab[tabIdx];
    if (s.contains(itemIdx)) {
      s.remove(itemIdx);
    } else {
      s.add(itemIdx);
    }
    update();
  }

  void selectAllCurrentTab() {
    final t = tabIndex;
    final n = _itemCountForTab(t);
    selectedPerTab[t] = {for (var i = 0; i < n; i++) i};
    update();
  }

  int get currentSelectionCount => selectedPerTab[tabIndex].length;

  Future<void> deleteSelectedForCurrentTab();

  void applyLocalDeleteForTab(int t) {
    final sel = selectedPerTab[t];
    switch (tabs[t].kind) {
      case MineMediaPaneKind.longVideo:
      case MineMediaPaneKind.shortVideo:
      case MineMediaPaneKind.anime:
        final list = videoItemsForTab(t);
        _setVideoItemsForTab(t, [
          for (var i = 0; i < list.length; i++)
            if (!sel.contains(i)) list[i],
        ]);
        break;
      case MineMediaPaneKind.post:
        postItems = [
          for (var i = 0; i < postItems.length; i++)
            if (!sel.contains(i)) postItems[i],
        ];
        break;
      case MineMediaPaneKind.comic:
        comicItems = [
          for (var i = 0; i < comicItems.length; i++)
            if (!sel.contains(i)) comicItems[i],
        ];
        break;
      case MineMediaPaneKind.gallery:
        photoItems = [
          for (var i = 0; i < photoItems.length; i++)
            if (!sel.contains(i)) photoItems[i],
        ];
        break;
      case MineMediaPaneKind.game:
        gameItems = [
          for (var i = 0; i < gameItems.length; i++)
            if (!sel.contains(i)) gameItems[i],
        ];
        break;
      case MineMediaPaneKind.dating:
        datingItems = [
          for (var i = 0; i < datingItems.length; i++)
            if (!sel.contains(i)) datingItems[i],
        ];
        break;
    }
    sel.clear();
    editing = false;
    update();
  }

  static List<MediaVideoModel> mockVideos(String tag, {required bool short}) {
    return List<MediaVideoModel>.generate(
      6,
      (i) => MediaVideoModel(
        id: '${short ? 'sv' : 'lv'}_${tag}_$i',
        title: '$tag · 占位标题 $i',
        readNumber: 3600 + i * 200,
      ),
    );
  }

  static List<PostCardData> mockPosts(String tag) {
    return List<PostCardData>.generate(
      4,
      (i) => PostCardData(
        id: 9000 + i,
        title: '「$tag」示例帖子文案略长用于两行省略展示效果……',
        createTime: DateTime.now()
            .subtract(Duration(hours: 1 + i))
            .millisecondsSinceEpoch,
        account: PostAuthor(nickName: '用户${i + 1}'),
        categoryName: tag,
        // 1 = 已发布
        status: 1,
        watch: 12000,
        comments: 328,
        initLikeNum: 11000,
        // 3 张占位图触发卡片三宫格版式（PostCard._buildMedia 走「2~3 个 → 网格」分支）。
        sources: List<PostSourceItem>.generate(
          3,
          (_) => PostSourceItem(
            type: PostSourceType.image,
            source: '_placeholder_',
          ),
        ),
      ),
    );
  }

  static List<NovelCardData> mockComics(String tag) {
    return List<NovelCardData>.generate(
      9,
      (i) => NovelCardData(
        title: '$tag · 漫画占位书名 $i',
        meta: '共${12 + i}话 · 连载中',
      ),
    );
  }

  static List<PhotoCardData> mockPhotos(String tag) {
    return <PhotoCardData>[
      PhotoCardData(
        title: '$tag · 这是文案这是是这是文案这是是...',
        views: '3.6w',
        imgCount: '9',
      ),
      PhotoCardData(
        title: '$tag · 图集占位标题第二行省略',
        views: '1.2w',
        imgCount: '100',
      ),
      PhotoCardData(
        title: '$tag · 室内光影组图',
        views: '8921',
        imgCount: '100',
      ),
      PhotoCardData(
        title: '$tag · 春日外景九宫格',
        views: '6400',
        imgCount: '100',
      ),
      PhotoCardData(
        title: '$tag · 黑白人像精选',
        views: '2.1w',
        imgCount: '100',
      ),
      PhotoCardData(
        title: '$tag · 汉服外景组图',
        views: '9800',
        imgCount: '100',
      ),
    ];
  }
}
