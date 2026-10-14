import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';

class FilmSearchResultState {
  static const List<String> sortTabs = ['最多收藏', '最新上架', '最多播放'];

  /// 与 [sortTabs] 顺序一致
  static const List<int> sortTypes = [8, 2, 4];

  final int videoType;

  String? keyword;

  int filterTabIndex = 1;

  int get sortType => sortTypes[filterTabIndex.clamp(0, sortTypes.length - 1)];

  final int pageSize = 20;

  late final List<List<MediaVideoModel>> tabVideoItems;
  late final List<int> tabPageNumbers;
  late final List<PullRefreshController> tabPullRefreshControllers;

  PullRefreshController get activePullRefresh => tabPullRefreshControllers[
      filterTabIndex.clamp(0, tabPullRefreshControllers.length - 1)];

  List<MediaVideoModel> get activeVideoItems =>
      tabVideoItems[filterTabIndex.clamp(0, tabVideoItems.length - 1)];

  FilmSearchResultState({required this.videoType}) {
    tabVideoItems = List.generate(sortTabs.length, (_) => []);
    tabPageNumbers = List.generate(sortTabs.length, (_) => 1);
    tabPullRefreshControllers = List.generate(
      sortTabs.length,
      (i) => PullRefreshController(isRequest: i == 0),
    );
  }
}
