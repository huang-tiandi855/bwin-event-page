import 'package:comics_app/common/entities/video_model/video_model.dart';
import 'package:get/get.dart';

import '../../../common/entities/media_list_entity.dart';
import '../../../common/values/enum.dart';
import '../../../common/widgets/pullRefreshView/pull_refresh_view.dart';

class PhotoItemState {
  MediaKind kind = MediaKind.mediaKindRealPhoto;
  PullRefreshController pullRefreshController = PullRefreshController();
  int pageNumber = 1;
  int pageSize = 12;
  bool isCollectionEmpty = false;
  int wantPageNumber = 1;
  int wantPageSize = 6;
  late RxBool isEdit = true.obs; //编辑状态]
  List<VideoModel> list = [];
  List<MediaListMediaList> wantToSeeList = [];
  PhotoItemState() {
    ///Initialize variables
  }
}
