import 'package:comics_app/common/entities/post_entity.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../comment/comment_view.dart';
import '../comment/video_comment_item.dart';
import '../noScrollBehaviorWidget.dart';
import '../pullRefreshView/pull_refresh_view.dart';
import 'comment_pop_logic.dart';
import 'comment_pop_state.dart';

/// 评论列表（底部弹层版）组件，使用 [VideoCommentItem] 渲染极简卡片。
class CommentPopComponent extends StatelessWidget {
  final bool isShowAllCommentsTitle;
  final String id;
  final PostList? postItem;
  final bool isNeedInnerScroll;
  final CommentType type;

  /// 标题区显示「X 条评论」时使用的真实评论总数（来自宿主页面的
  /// `commentCount`，如短视频 [ShortVideoModel.commentCount]、帖子
  /// [PostList.commentCount] 等）。
  ///
  /// 与 `state.list.length`（仅是「已加载条数」）区分开：弹窗首屏只
  /// 拿到 pageSize 条评论，若用 list.length 会与宿主页面的评论计数
  /// 显示不一致。传 null 时回落到 `state.list.length`，兼容旧调用点。
  final int? totalCount;

  const CommentPopComponent({
    Key? key,
    required this.id,
    required this.type,
    this.isShowAllCommentsTitle = true,
    this.postItem,
    this.isNeedInnerScroll = true,
    this.totalCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(CommentPopLogic(id, type));
    final state = Get.find<CommentPopLogic>().state;
    return GetBuilder(
      init: CommentPopLogic(id, type),
      tag: 'CommentPopLogic_$id$isNeedInnerScroll${type.type}',
      assignId: true,
      builder: (logic) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isShowAllCommentsTitle)
              Padding(
                padding: EdgeInsets.only(bottom: 10.w),
                child: Text(
                  '${totalCount ?? state.list.length}条评论',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColor.primaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            Expanded(
              child: GetBuilder<CommentPopLogic>(
                builder: (logic) {
                  return ScrollConfiguration(
                    behavior: NoScrollBehaviorWidget(),
                    child: _buildPullRefreshView(logic, state),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  PullRefreshView _buildPullRefreshView(
      CommentPopLogic logic, CommentPopState state) {
    return PullRefreshView(
      enablePullDown: false,
      retryOnTap: () async => logic.onRefresh(),
      controller: state.pullRefreshController,
      onLoading: () async => logic.onLoad(),
      child: ListView.builder(
        physics:
            isNeedInnerScroll ? null : const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: state.list.length,
        itemBuilder: (BuildContext context, int index) {
          final item = state.list[index];
          return VideoCommentItem(
            item: item,
            onTapLike: () => logic.onTapLike(item),
          );
        },
      ),
    );
  }
}
