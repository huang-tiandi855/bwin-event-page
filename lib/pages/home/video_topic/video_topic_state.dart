import '../../../common/entities/feature_info.dart';
import '../../../common/widgets/pullRefreshView/pull_refresh_view.dart';

class VideoTopicState {
  PullRefreshController pullRefreshController = PullRefreshController();
  int pageNumber = 1;
  int pageSize = 10;
  List<ListElement> topicList = [];

  VideoTopicState() {
    ///Initialize variables
  }
}
