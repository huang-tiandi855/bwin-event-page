import 'package:get/get.dart';

import '../../entities/comment/vod_comment_item_model.dart';
import '../pullRefreshView/pull_refresh_view.dart';

/// 评论列表状态。
///
/// 评论数据统一走 `MediaApi.getVodCommentList`，每一项就是 [VodCommentItemModel]，
/// 不再桥接到老的 `CommentList`（连同二级评论 / 热评 / 热搜词等都一并下线）。
class CommentState {
  PullRefreshController pullRefreshController = PullRefreshController();
  int pageNumber = 1;
  int pageSize = 10;
  RxInt total = 0.obs;
  List<VodCommentItemModel> list = [];
  String objID = "";
  CommentState();
}
