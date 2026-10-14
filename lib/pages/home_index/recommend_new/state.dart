import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';

class RecommendNewState {
  late List<String> filterTabs;

  int filterTabIndex = 0;

  /// true：双列网格；false：单列列表
  bool isGridLayout = true;

  /// 每个二级 Tab 一份**独立**的视频列表，索引与 [filterTabs] 对齐。
  ///
  /// 之前所有 tab 共用一份 [videoItems]，切 tab 时旁边那一页会先看到当前
  /// tab 的数据再被新数据替换；改为每个 tab 各自一份后，切 tab 互不影响。
  late List<List<MediaVideoModel>> tabVideoItems;

  /// 每个二级 Tab 独立的当前页码，索引与 [filterTabs] 对齐。
  late List<int> tabPageNumbers;

  /// 每个二级 Tab 是否已经成功加载过首屏（切 tab 时判定是否触发首拉）。
  late List<bool> tabLoaded;

  final int pageSize = 20;

  final PullRefreshController pullRefreshController = PullRefreshController();

  late final List<PullRefreshController> tabPullRefreshControllers;

  /// 当前 tab 的视频列表（按 [filterTabIndex] 路由到 [tabVideoItems]）。
  /// 兼容旧调用方；新代码直接走 [tabVideoItems]。
  List<MediaVideoModel> get videoItems => tabVideoItems.isEmpty
      ? const <MediaVideoModel>[]
      : tabVideoItems[filterTabIndex.clamp(0, tabVideoItems.length - 1)];
  set videoItems(List<MediaVideoModel> value) {
    if (tabVideoItems.isEmpty) return;
    tabVideoItems[filterTabIndex.clamp(0, tabVideoItems.length - 1)] = value;
  }

  /// 当前 tab 的页码（兼容旧调用方；新代码直接走 [tabPageNumbers]）。
  int get pageNumber => tabPageNumbers.isEmpty
      ? 1
      : tabPageNumbers[filterTabIndex.clamp(0, tabPageNumbers.length - 1)];
  set pageNumber(int value) {
    if (tabPageNumbers.isEmpty) return;
    tabPageNumbers[filterTabIndex.clamp(0, tabPageNumbers.length - 1)] = value;
  }

  PullRefreshController get activeBodyPullRefresh =>
      tabPullRefreshControllers.isEmpty
          ? pullRefreshController
          : tabPullRefreshControllers[
              filterTabIndex.clamp(0, tabPullRefreshControllers.length - 1)];

  RecommendNewState() {
    filterTabs = ['今日最新', '本周最热', '本月收藏'];
    final int n = filterTabs.length;
    // 即便回退到「无 sub tabs」分支也至少留一个槽位，让 [pageNumber] /
    // [videoItems] / [pullRefreshController] 老路径继续可用。
    final int slot = n == 0 ? 1 : n;
    tabVideoItems = List.generate(slot, (_) => <MediaVideoModel>[]);
    tabPageNumbers = List.filled(slot, 1);
    tabLoaded = List.filled(slot, false);
    tabPullRefreshControllers = n == 0
        ? <PullRefreshController>[]
        : List.generate(
            n,
            (i) => PullRefreshController(isRequest: i == 0),
          );
  }
}
