import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';

class TopicMoreDetailState {
  int topicId = 0;

  String topicName = '';
  int keywordType = 0;
  int videoType = 0;

  static const List<String> filterTabs = ['最多收藏', '最新上架', '最多播放'];

  /// 与 [filterTabs] 顺序一致：8、2、4
  static const List<int> sortTypes = [8, 2, 4];

  int filterTabIndex = 0;

  int get sortType => sortTypes[filterTabIndex.clamp(0, sortTypes.length - 1)];

  /// 每个 tab 一份**独立**的视频列表，索引与 [filterTabs] 对齐。
  ///
  /// 切 tab 不再共享同一份 list，避免「最多收藏 / 最新上架 / 最多播放」之间
  /// 互相覆盖。
  late final List<List<MediaVideoModel>> tabVideoItems;

  /// 每个 tab 一份**独立**的当前页码，索引与 [filterTabs] 对齐。
  late final List<int> tabPageNumbers;

  /// 每个 tab 是否已经成功加载过首屏（用于切 tab 时判定是否需要触发首次拉取）。
  late final List<bool> tabLoaded;

  /// 当前 tab 的视频列表（按 [filterTabIndex] 路由到 [tabVideoItems]）。
  List<MediaVideoModel> get videoItems =>
      tabVideoItems[filterTabIndex.clamp(0, tabVideoItems.length - 1)];
  set videoItems(List<MediaVideoModel> value) {
    tabVideoItems[filterTabIndex.clamp(0, tabVideoItems.length - 1)] = value;
  }

  /// 当前 tab 的页码（兼容旧调用方；新代码直接用 [tabPageNumbers]）。
  int get pageNumber =>
      tabPageNumbers[filterTabIndex.clamp(0, tabPageNumbers.length - 1)];
  set pageNumber(int value) {
    tabPageNumbers[filterTabIndex.clamp(0, tabPageNumbers.length - 1)] = value;
  }

  final int pageSize = 20;

  final PullRefreshController pullRefreshController = PullRefreshController();

  late final List<PullRefreshController> tabPullRefreshControllers;

  PullRefreshController get activeBodyPullRefresh =>
      tabPullRefreshControllers.isEmpty
          ? pullRefreshController
          : tabPullRefreshControllers[
              filterTabIndex.clamp(0, tabPullRefreshControllers.length - 1)];

  TopicMoreDetailState() {
    tabVideoItems = List.generate(
      filterTabs.length,
      (_) => <MediaVideoModel>[],
    );
    tabPageNumbers = List.filled(filterTabs.length, 1);
    tabLoaded = List.filled(filterTabs.length, false);
    tabPullRefreshControllers = List.generate(
      filterTabs.length,
      (i) => PullRefreshController(isRequest: i == 0),
    );
  }
}
