import '../../../common/entities/media_list_entity.dart';
import '../../../common/values/enum.dart';
import '../../../common/widgets/pullRefreshView/pull_refresh_view.dart';

class ComicsItemState {
  MediaKind kind = MediaKind.mediaKindComics;
  PullRefreshController pullRefreshController = PullRefreshController();
  int pageNumber = 1;
  int pageSize = 12;
  bool isCollectionEmpty = false;
  int wantPageNumber = 1;
  int wantPageSize = 6;
  List<MediaListMediaList> list = [];
  List<MediaListMediaList> wantToSeeList = [];

  ComicsItemState() {
    ///Initialize variables
  }
}
