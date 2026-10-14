import 'package:comics_app/common/entities/post_entity.dart';
import 'package:comics_app/common/style/location.dart';
import 'package:comics_app/common/utils/screen.dart';
import 'package:comics_app/common/widgets/comment/comment_view.dart';
import 'package:comics_app/common/widgets/comment/msg_send/msg_send_logic.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

const Color _kHintGrey = Color(0x80FFFFFF);

/// 帖子详情、游戏详情等页底部：输入框占位 + 发图 / 收藏 / 评论（与 [MsgSendLogic] 联动）。
class PostDetailCommentBottomBar extends StatefulWidget {
  const PostDetailCommentBottomBar({
    super.key,
    required this.postId,
    this.postItem,
    this.hintText = '请输入您的文字内容',
    this.commentType = CommentType.video,
    this.isPop = false,
    this.onSend,
    this.onCollect,
    this.isCollect = false,
  });

  final String postId;

  /// 旧详情页（如 [PostList] 数据流）传入用于评论数本地乐观更新；
  /// 新接入的 [PostCardData] 详情页不再依赖该字段，留 `null` 即可。
  final PostList? postItem;

  /// 输入框占位文案。
  final String hintText;
  final CommentType commentType;
  final bool isPop;
  final bool isCollect;
  final Function(String result)? onSend;
  final Function()? onCollect;

  @override
  State<PostDetailCommentBottomBar> createState() =>
      _PostDetailCommentBottomBarState();
}

class _PostDetailCommentBottomBarState
    extends State<PostDetailCommentBottomBar> {
  String text = '';

  late MsgSendLogic logic;

  @override
  void initState() {
    super.initState();
    logic = Get.put(
      MsgSendLogic(
        widget.postId,
        widget.postItem,
        widget.commentType,
        widget.isPop,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.only(
        left: AppLocation.appHorizontal,
        right: AppLocation.appHorizontal,
        top: 16.w,
        bottom: 16.w + Screen.bottomSafeHeight,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _showSendMsg,
              child: Container(
                height: 40.w,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10.w),
                ),
                child: Text(
                  text.isEmpty ? widget.hintText : text,
                  style: TextStyle(color: _kHintGrey, fontSize: 14.sp),
                ),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          // IconButton(
          //   onPressed: () async {
          //     await widget.onSend?.call(text);
          //     text = '';
          //     logic.state.textEditingController.clear();
          //     setState(() {});
          //   },
          //   icon: AssetsGen.images.circle.postSendImg
          //       .image(width: 36.w, height: 36.w),
          // ),
          IconButton(
            onPressed: widget.onCollect,
            icon: widget.isCollect
                ? AssetsGen.images.circle.postCollecteSel
                    .image(width: 36.w, height: 36.w)
                : AssetsGen.images.circle.postCollecte
                    .image(width: 36.w, height: 36.w),
          ),
          IconButton(
            onPressed: () async {
              await widget.onSend?.call(text);
              text = '';
              logic.state.textEditingController.clear();
              setState(() {});
            },
            icon: AssetsGen.images.circle.postSendMsg
                .image(width: 36.w, height: 36.w),
          ),
        ],
      ),
    );
  }

  void _showSendMsg() async {
    final result = await logic.updateShowSendStatus(false, result: (string) {});
    text = logic.state.textEditingController.text;
    setState(() {});
    if (result != null) {
      await widget.onSend?.call(text);
      text = '';
      logic.state.textEditingController.clear();
      setState(() {});
    }
  }
}
