import '../../../../../common/entities/MediaListInfo.dart';
import '../../../../../common/entities/config.dart';
import '../../../../../common/widgets/pullRefreshView/pull_refresh_view.dart';

class OriginalTopicDetailState {
  String? id;

  late PullRefreshController pullRefreshController = PullRefreshController();

  MediaListInfo? topicDetail;

  int pageNum = 1;
  int pageSize = 20;
  String title = '';
  int topicId = 0;
  late List<AdsInfoList> homePageSpecialMoreAds = [];

  late List<AdsInfoList> homePageSpecialMoreAdsHorizontal = [];

  OriginalTopicDetailState() {
    ///Initialize variables
  }
}
