import 'package:comics_app/common/entities/comment_entity.dart';
import 'package:comics_app/common/entities/post_entity.dart';
import 'package:get/get.dart';

import '../../widgets/pullRefreshView/pull_refresh_view.dart';

class CommentDetailsState {
  int pageNumber = 1;
  int pageSize = 10;
  List<CommentList> list = [];
  PostList? postItem;
  CommentList commentList = CommentList();
  String fstID = "";
  String objID = "";
  String cmtId = "";
  RxInt commCount = 0.obs;
  PullRefreshController pullRefreshController = PullRefreshController();

  CommentDetailsState() {
    var map = Get.arguments["data"];
    commentList = map?["info"] ?? CommentList();
    fstID = map?["fstID"] ?? "";
    objID = map?["objID"] ?? "";
    cmtId = map?["cmtId"] ?? "";
    postItem = map?["postItem"];
    commCount.value = map?["commCount"] ?? 0;
    ///Initialize variables
  }
}
