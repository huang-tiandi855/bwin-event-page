import 'package:comics_app/common/entities/post_entity.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../noScrollBehaviorWidget.dart';
import '../pullRefreshView/pull_refresh_view.dart';
import 'comment_logic.dart';
import 'comment_state.dart';
import 'video_comment_item.dart';

/// 评论作用域 / 业务类型。
///
/// 历史上区分 `media`（ACG / 原创 / 短剧 / 小说）与 `video`（视频 / 短视频 /
/// 社区）以拼装老 `/comment/list` 的 `objType` 参数；当前评论列表统一走
/// `MediaApi.getVodCommentList` 不再使用 `objType`，但部分调用点仍传入该枚举，
/// 因此保留类型本身不动，按需扩展。
/// 帖子评论接口不一致，传post类型请求post评论列表
enum CommentType { media, video, post, game }

extension CommentTypeExtension on CommentType {
  String get type {
    switch (this) {
      case CommentType.media:
        return 'media';
      case CommentType.video:
        return 'video';
      case CommentType.post:
        return 'post';
      case CommentType.game:
        return 'game';
    }
  }
}

/// 评论列表（内嵌版）组件，使用 [VideoCommentItem] 渲染极简卡片。
class CommentComponent extends StatefulWidget {
  final String id;
  final String? sId;
  final CommentType type;
  final PostList? postItem;
  final bool isNeedInnerScroll;
  final bool isShowAllCommentsTitle;
  const CommentComponent({
    Key? key,
    required this.id,
    required this.type,
    this.sId,
    this.isShowAllCommentsTitle = true,
    this.postItem,
    this.isNeedInnerScroll = true,
  }) : super(key: key);

  @override
  State<CommentComponent> createState() => _CommentComponentState();
}

class _CommentComponentState extends State<CommentComponent> {
  bool get isShowAllCommentsTitle => widget.isShowAllCommentsTitle;
  bool get isNeedInnerScroll => widget.isNeedInnerScroll;
  String get id => widget.id;
  String? get sId => widget.sId;
  CommentType get type => widget.type;

  // tag 直接用 id（业务侧 vid / postId 等）保持稳定，便于 [MsgSendLogic]
  // 等外部模块通过 `Get.find<CommentLogic>(tag: id)` 反查同一实例做乐观插入。
  late final tag = id;
  late final controller = Get.put(CommentLogic(id, type, sId: sId), tag: tag);

  @override
  void didUpdateWidget(covariant CommentComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      controller.refreshId(widget.id, widget.sId ?? '', widget.type);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return GetBuilder(
      init: controller,
      tag: tag,
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
                  '评论',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: AppColor.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Expanded(
              child: GetBuilder<CommentLogic>(
                tag: tag,
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
      CommentLogic logic, CommentState state) {
    return PullRefreshView(
      key: ValueKey('PullRefreshView$isNeedInnerScroll$id'),
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
