import 'package:comics_app/common/apis/media_api.dart';
import 'package:comics_app/common/entities/comment/vod_comment_item_model.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:get/get.dart';

import '../comment/comment_view.dart';
import 'comment_pop_state.dart';

/// 评论列表（弹层版）业务逻辑，与 [CommentLogic] 同义，区别仅在宿主控件。
class CommentPopLogic extends GetxController {
  final CommentPopState state = CommentPopState();
  String id;
  CommentType commentType;

  CommentPopLogic(this.id, this.commentType);

  @override
  void onInit() {
    super.onInit();
    state.objID = id;
    getData();
  }

  Future<void> getData() async {
    final int? vid = int.tryParse(id);
    if (vid == null) {
      state.pullRefreshController.requestSuccess(
        isFirstPageNum: state.pageNumber == 1,
        hasMore: false,
        isEmpty: state.list.isEmpty,
      );
      update();
      return;
    }
    try {
      final List<VodCommentItemModel> items =
          await MediaApi.getVodCommentList(
        vid: vid,
        page: state.pageNumber,
        pageSize: state.pageSize,
      );
      state.list.addAll(items);
      state.total.value = state.list.length;
      final bool hasMore = items.length >= state.pageSize;
      state.pullRefreshController.requestSuccess(
        isFirstPageNum: state.pageNumber == 1,
        hasMore: hasMore,
        isEmpty: state.list.isEmpty,
      );
      update();
    } catch (_) {
      state.pullRefreshController
          .requestFail(isFirstPageNum: state.pageNumber == 1);
    }
  }

  void onRefresh() {
    state.pageNumber = 1;
    state.list.clear();
    getData();
  }

  void onLoad() {
    state.pageNumber++;
    getData();
  }

  /// 评论点赞 / 取消点赞。逻辑与 [CommentLogic.onTapLike] 保持一致，区别仅在
  /// 宿主控件（弹层 vs 内嵌）；高频点击防抖由 UI 层 `clickButton(openLimit: true)`
  /// 统一兜底。
  Future<void> onTapLike(VodCommentItemModel item) async {
    final int? cid = item.commentId;
    if (cid == null) return;
    final bool nextLike = !item.like;
    final BaseRespBean resp =
        await MediaApi.clickCommentLike(id: cid, yes: nextLike);
    if (resp.isSuccess) {
      item.like = nextLike;
      item.likeNum = nextLike
          ? item.likeNum + 1
          : (item.likeNum > 0 ? item.likeNum - 1 : 0);
      update();
    } else {
      showToast(msg: resp.tip ?? '操作失败');
    }
  }
}
