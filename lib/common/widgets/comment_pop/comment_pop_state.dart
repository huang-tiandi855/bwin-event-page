import 'package:get/get.dart';

import '../../entities/comment/vod_comment_item_model.dart';
import '../pullRefreshView/pull_refresh_view.dart';

/// 评论弹层状态，结构同 [CommentState]，区别仅在宿主控件（弹层 vs 内嵌）。
class CommentPopState {
  PullRefreshController pullRefreshController = PullRefreshController();
  int pageNumber = 1;
  int pageSize = 10;
  RxInt total = 0.obs;
  List<VodCommentItemModel> list = [];
  String objID = "";
  CommentPopState();
}
