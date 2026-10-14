import 'package:comics_app/short_video/base/abs_short_video_play_logic.dart';

import '../../../common/entities/moreVideo.dart';
import '../../../common/entities/post_entity.dart';
import '../../../common/entities/video_model/ishort_video_model.dart';

class ShortVideoState<T extends ShortVideoModel>
    extends AbsShortVideoPlayState<T> {
  bool isFromUserHome = false; //是否来自用户主页
  bool isMore = true; // 是否请求更多
  List<PostList> videoList = [];
  PostList? videoInfo;
  int curIdx = 0;
  int pageNumber = 0;
  int pageSize = 10;
  late MoreVideo moreVideo;
}
