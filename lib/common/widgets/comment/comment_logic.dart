import 'package:comics_app/common/apis/circle_api.dart';
import 'package:comics_app/common/apis/media_api.dart';
import 'package:comics_app/common/entities/comment/vod_comment_item_model.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/widgets/comment/comment_view.dart';
import 'package:get/get.dart';

import '../../apis/game_api.dart';
import 'comment_state.dart';

/// 评论列表（内嵌版）业务逻辑。
///
/// 数据源按 [commentType] 分流，但返回模型统一是 [VodCommentItemModel]：
/// - [CommentType.media] / [CommentType.video]：走 `MediaApi.getVodCommentList`。
/// - [CommentType.post]：帖子评论 [CircleApi.getPostCommentList]。
/// - [CommentType.game]：游戏评论 [GameApi.getCommentList]（`/gaming/comment/list`）。

class CommentLogic extends GetxController {
  final CommentState state = CommentState();
  String id;
  String? sId;
  CommentType commentType;

  CommentLogic(this.id, this.commentType, {this.sId});

  @override
  void onInit() {
    super.onInit();
    state.objID = id;
    getData();
  }

  /// 拉取评论列表。
  ///
  /// `id` 在业务层是字符串（兼容老调用），新接口要求 `vid` / `pid` 为 int；
  /// 解析失败直接以"空 + 无更多"成功收尾，避免误调用与 UI 卡 loading。
  /// 按 [commentType] 分流列表接口，见 [_fetchPage]。

  /// [MediaApi.getVodCommentList]。
  Future<void> getData() async {
    final int? targetId = int.tryParse(id);
    if (targetId == null) {
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
          await _fetchPage(targetId, state.pageNumber);
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

  /// 按 [commentType] 选接口；两条接口返回都是 [VodCommentItemModel] 列表，
  /// 失败均以空数组表达，不抛异常给上层。
  ///
  /// 注意：`CircleApi.getPostCommentList` 不接受 `pageSize`，由后端默认决定每页
  /// 数量。`getData` 里的 `hasMore = items.length >= state.pageSize` 假设两边
  /// 默认页大小一致，若日后帖子接口默认页大小变化，需在这里对齐 `pageSize` 或
  /// 由 [CommentState] 区分两套页大小。
  Future<List<VodCommentItemModel>> _fetchPage(int targetId, int page) {
    switch (commentType) {
      case CommentType.post:
        return CircleApi.getPostCommentList(targetId, page);
      case CommentType.game:
        return GameApi.getCommentList(targetId, page);
      case CommentType.media:
      case CommentType.video:
        return MediaApi.getVodCommentList(
          vid: targetId,
          page: page,
          pageSize: state.pageSize,
        );
    }
  }

  void onRefresh() {
    state.pageNumber = 1;
    state.list.clear();
    getData();
  }

  /// 业务侧切换 id（例如长视频换集 / 切播）时直接复用本 controller。
  void refreshId(String id, String sId, CommentType commentType) {
    this.id = id;
    this.sId = sId;
    this.commentType = commentType;
    onRefresh();
  }

  void onLoad() {
    state.pageNumber++;
    getData();
  }

  /// 评论点赞 / 取消点赞。调 `MediaApi.clickCommentLike(id, yes)`：
  /// - 成功：本地翻转 `item.like` 并对 `item.likeNum` 做 ±1（不小于 0），
  ///   触发列表重绘；
  /// - 失败：保持原状并 toast 提示。
  ///
  /// 高频点击防抖由 UI 层 `clickButton(openLimit: true)` 统一兜底，这里只关心
  /// 业务流程。
  Future<void> onTapLike(VodCommentItemModel item) async {
    final int? cid = item.commentId;
    if (cid == null) return;
    final bool nextLike = !item.like;
    late final BaseRespBean resp;
    switch (commentType) {
      case CommentType.post:
        resp = await CircleApi.postCommentLike(cid);
        break;
      case CommentType.game:
        resp = await GameApi.commentPerfect(cid);
        break;
      case CommentType.media:
      case CommentType.video:
        resp = await MediaApi.clickCommentLike(id: cid, yes: nextLike);
        break;
    }
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
