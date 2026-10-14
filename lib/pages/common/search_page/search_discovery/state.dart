import 'package:comics_app/common/entities/MediaListInfo.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';

class SearchDiscoveryState {
  final List<String> typeTabs = ['影片', '动漫', '漫画', '帖子', '图集'];
  final List<String> sortTabs = ['最多收藏', '最新上架', '最多播放'];

  List<MediaList> searchResultList = [];
  bool hasSearched = false;
  bool isSearching = false;
  String searchKeyword = '';
  int searchKindIndex = 0;
  int searchSortIndex = 1;

  List<MediaVideoModel> weekHotMediaList = [];

  List<MediaVideoModel> monthHotMediaList = [];

  List<MediaVideoModel> lastMonthHotMediaList = [];

  int weekHotPage = 1;

  int monthHotPage = 1;

  int lastMonthHotPage = 1;

  final List<PullRefreshController> rankPullRefreshControllers = List.generate(
    3,
    (index) => PullRefreshController(isRequest: index == 0),
  );
}
