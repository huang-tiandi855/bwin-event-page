import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';

class RecommendColumnTabVideoState {
  late List<String> filterTabs;

  int filterTabIndex = 0;

  /// true：双列网格；false：单列列表
  bool isGridLayout = true;

  /// 每个二级 Tab 一份**独立**的视频列表，索引与 [filterTabs] 对齐。
  ///
  /// 之前所有 tab 共用一份 [videoItems]，左右切 tab 时新 tab 还没拿到数据前
  /// 屏幕上仍是上一个 tab 的列表，等接口回来再瞬间被替换，体感闪烁；改成
  /// 每个 tab 各自维护一份后，旁边那一页一直渲染它自己的数据，切换平滑。
  late List<List<MediaVideoModel>> tabVideoItems;

  /// 每个二级 Tab 独立的当前页码，索引与 [filterTabs] 对齐。
  late List<int> tabPageNumbers;

  /// 每个二级 Tab 是否已经成功加载过首屏（用于切 tab 时判定是否触发首拉）。
  late List<bool> tabLoaded;

  /// 与二级 Tab 对应：热门推荐 1、最新上架 2、最多观看 4、最多收藏 8。
  /// 仅「无 sub tabs」回退分支使用；有 sub tabs 时由 logic 按 tabIndex 现算。
  int sortType = 1;

  final int pageSize = 20;

  /// 无二级 Tab 时列表层刷新用（与 [tabPullRefreshControllers] 二选一）。
  final PullRefreshController pullRefreshController = PullRefreshController();

  /// 每个二级 Tab 对应一个控制器：SmartRefresher 与 RefreshController 必须一一对应。
  late final List<PullRefreshController> tabPullRefreshControllers;

  /// 当前 tab 的列表（按 [filterTabIndex] 路由到 [tabVideoItems]）。
  /// 兼容旧调用方；新代码请直接走 [tabVideoItems]。
  List<MediaVideoModel> get videoItems => tabVideoItems.isEmpty
      ? const <MediaVideoModel>[]
      : tabVideoItems[filterTabIndex.clamp(0, tabVideoItems.length - 1)];
  set videoItems(List<MediaVideoModel> value) {
    if (tabVideoItems.isEmpty) return;
    tabVideoItems[filterTabIndex.clamp(0, tabVideoItems.length - 1)] = value;
  }

  /// 当前 tab 的页码（兼容旧调用方；新代码请直接走 [tabPageNumbers]）。
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

  RecommendColumnTabVideoState() {
    filterTabs = ['热门推荐', '最新上架', '最多观看', '最多收藏'];
    final int n = filterTabs.length;
    // 即便回退到「无 sub tabs」分支也至少保留一个槽位，让 [videoItems] /
    // [pageNumber] / [pullRefreshController] 这条老路径继续可用。
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
