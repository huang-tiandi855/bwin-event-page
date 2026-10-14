import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../common/style/color.dart';
import 'logic.dart';
import 'state.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_date_divider.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/chat_message.dart';

/// 私信聊天页：路由 `AppRoutes.CHAT`，参数 `{otherId, nickName?, avatar?}`
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatLogic>(
      builder: (ChatLogic logic) {
        final ChatState state = logic.state;
        final userName = (state.otherNickName?.isNotEmpty ?? false)
            ? state.otherNickName!
            : '私信';
        final title = state.isOnlineService ? '在线客服：$userName' : userName;
        return Scaffold(
          backgroundColor: AppColor.scaffoldBackground,
          appBar: commonAppBar(title),
          body: SafeArea(
            top: false,
            child: Column(
              children: <Widget>[
                Expanded(child: _ChatList(logic: logic)),
                ChatInputBar(
                  hintText: '请输入您的文字内容',
                  onSendText: logic.sendText,
                  onPickImage: () => _onPickImage(logic),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 点击发图按钮
  void _onPickImage(ChatLogic logic) async {
    final images = await ImagePickers.pickerPaths(
      selectCount: 1,
      showCamera: false,
      cropConfig: CropConfig(enableCrop: false),
    );
    if (images.isNotEmpty) {
      logic.sendImage(images.first.path ?? '');
    }
  }
}

/// 聊天列表区：
/// - `reverse: true` 让 items[0] 渲染在视觉底部（即最新消息）
/// - SmartRefresher 的 footer 在 reverse 模式下渲染在视觉顶部，
///   配合 `enablePullUp: true` 实现「拉到顶 → 加载更多历史」
class _ChatList extends StatelessWidget {
  const _ChatList({required this.logic});

  final ChatLogic logic;

  @override
  Widget build(BuildContext context) {
    final state = logic.state;
    final messages = state.messages;

    if (messages.isEmpty) {
      return Center(
        child: Text(
          '快来发送第一条消息吧～',
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 13.sp,
          ),
        ),
      );
    }

    final List<Widget> items = _buildItems(messages);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: SmartRefresher(
        controller: state.refreshController,
        enablePullDown: false,
        // 始终 true：noData 状态由 footer 内部呈现「已经到顶了」
        enablePullUp: true,
        onLoading: logic.loadMoreHistory,
        footer: _buildFooter(),
        child: ListView.builder(
          controller: state.scrollController,
          reverse: true,
          padding: EdgeInsets.symmetric(vertical: 8.w),
          itemCount: items.length,
          itemBuilder: (_, int index) => items[index],
        ),
      ),
    );
  }

  /// 顶部 footer（reverse 模式下展示在视觉顶端）
  Widget _buildFooter() {
    final textStyle = TextStyle(
      color: const Color(0x80FFFFFF),
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.none,
    );
    return ClassicFooter(
      height: 50.w,
      loadingIcon: SizedBox(
        width: 16.w,
        height: 16.w,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0x80FFFFFF)),
        ),
      ),
      idleText: '上拉加载更多',
      canLoadingText: '松开加载更多',
      loadingText: '加载中…',
      noDataText: '— 已经到顶了 —',
      failedText: '加载失败，点击重试',
      textStyle: textStyle,
      idleIcon: const SizedBox.shrink(),
      canLoadingIcon: const SizedBox.shrink(),
      noMoreIcon: const SizedBox.shrink(),
      failedIcon: const SizedBox.shrink(),
    );
  }

  /// 在消息之间按间隔插入时间分隔；返回的列表已倒序，外层 ListView 用 reverse=true 渲染。
  ///
  /// 在线客服模式（[ChatState.isOnlineService]）下，每条气泡下方会自带时间，
  /// 因此不再插入「居中的日期分隔」标签。
  List<Widget> _buildItems(List<ChatMessage> source) {
    final bool isOnlineService = logic.state.isOnlineService;
    final List<Widget> out = <Widget>[];
    for (int i = 0; i < source.length; i++) {
      final msg = source[i];
      if (!isOnlineService) {
        final bool needDivider = i == 0 ||
            ChatDateDivider.shouldInsert(
                source[i - 1].timestamp, msg.timestamp);
        if (needDivider) {
          out.add(ChatDateDivider(timestamp: msg.timestamp));
        }
      }
      out.add(ChatBubble(message: msg, isOnlineService: isOnlineService));
    }
    return out.reversed.toList();
  }
}
