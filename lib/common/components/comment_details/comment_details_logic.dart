import 'package:get/get.dart';

import '../../entities/comment_entity.dart';
import '../../http/base_resp_bean.dart';
import '../../utils/toast_util.dart';
import 'comment_details_state.dart';

class CommentDetailsLogic extends GetxController {
  final CommentDetailsState state = CommentDetailsState();

  @override
  void onInit() {
    super.onInit();
    onRefresh();
  }


  void onRefresh() {
    state.pageNumber = 1;
    state.list.clear();
    getData();
  }

  void onLoading() {
    state.pageNumber++;
    getData();
  }

  void getData() async {
    try {
      BaseRespBean baseRespBean = BaseRespBean(0);
      // BaseRespBean baseRespBean = await CircleApi.getCommentInfo(data);
      if (baseRespBean.isSuccess) {
        if (state.pageNumber == 1 &&
            ((state.commentList.info?.length ?? 0) > 0)) {
          var map = state.commentList.info![0].toJson();
          CommentList commentList = CommentList.fromJson(map);
          state.list.add(commentList);
        }
        CommentEntity commentEntity = CommentEntity.fromJson(baseRespBean.data);
        state.list.addAll(commentEntity.list ?? []);
        bool isEmpty = state.list.isEmpty ? true : false;
        state.pullRefreshController.requestSuccess(
            isFirstPageNum: state.pageNumber == 1,
            hasMore: commentEntity.hasNext ?? false,
            isEmpty: isEmpty);
        update();
        return;
      }
      state.pullRefreshController
          .requestFail(isFirstPageNum: state.pageNumber == 1);
    } catch (e) {
      state.pullRefreshController
          .requestFail(isFirstPageNum: state.pageNumber == 1);
    }
  }

  void likeAndUnlike(int index) async {
    bool isLike;
    if (index == -1) {
      isLike = state.commentList.isLike ?? false;
    } else {
      isLike = state.list[index].isLike ?? false;
    }
    BaseRespBean baseRespBean = BaseRespBean(0);
    if (isLike) {
      // baseRespBean = await CircleApi.thumbsDownApp(data);
    } else {
      // baseRespBean = await CircleApi.thumbsUpApp(data);
    }
    if (baseRespBean.isSuccess) {
      if (index == -1) {
        state.commentList.isLike = !isLike;
        if (!isLike) {
          state.commentList.likeCount = (state.commentList.likeCount ?? 0) + 1;
          showToast(msg: "点赞成功");
        } else {
          state.commentList.likeCount = (state.commentList.likeCount ?? 0) - 1;
          showToast(msg: "取消点赞");
        }
        update(['likeAndUnlikeSingle']);
      } else {
        state.list[index].isLike = !isLike;
        if (!isLike) {
          state.list[index].likeCount = (state.list[index].likeCount ?? 0) + 1;
          showToast(msg: "点赞成功");
        } else {
          state.list[index].likeCount = (state.list[index].likeCount ?? 0) - 1;
          showToast(msg: "取消点赞");
        }
        update(['likeAndUnlike']);
      }
    }
  }




}
