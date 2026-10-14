import 'package:comics_app/common/style/location.dart';
import 'package:comics_app/common/utils/screen.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const Color _kHintGrey = Color(0x80FFFFFF);

/// 聊天页底部输入栏：可输入文本、点击发图、发送（图标 / 布局参考 `PostDetailCommentBottomBar`）。
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    this.hintText = '',
    required this.onSendText,
    this.onPickImage,
  });

  /// 输入框占位
  final String hintText;

  /// 点击发送：返回输入文本，由外部清空 controller
  final Future<void> Function(String text) onSendText;

  /// 点击图片按钮（选图后由外层完成上传 + 调用 ws 发送）
  final VoidCallback? onPickImage;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 点击发送图标
  Future<void> _onSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await widget.onSendText(text);
    _controller.clear();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.only(
        left: AppLocation.appHorizontal,
        right: AppLocation.appHorizontal,
        top: 12.w,
        bottom: 12.w + Screen.bottomSafeHeight,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Container(
              height: 40.w,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10.w),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _onSend(),
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: widget.hintText,
                  hintStyle: TextStyle(color: _kHintGrey, fontSize: 14.sp),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          IconButton(
            onPressed: widget.onPickImage,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: AssetsGen.images.circle.postSendImg
                .image(width: 36.w, height: 36.w),
          ),
          SizedBox(width: 8.w),
          IconButton(
            onPressed: _controller.text.trim().isEmpty ? null : _onSend,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: AssetsGen.images.circle.postSendMsg
                .image(width: 36.w, height: 36.w),
          ),
        ],
      ),
    );
  }
}
