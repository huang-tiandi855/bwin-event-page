import 'dart:io';

import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common/store/config.dart';
import 'chat_message.dart';

/// 自己气泡背景（私信默认）
const Color _kMineBg = Color(0xFF4C9EEA);

/// 他人气泡背景（半透明白叠加在黑底上呈深灰）
final Color _kOtherBg = Colors.white.withOpacity(0.15);

/// 头像尺寸
const double _kAvatarSize = 34;

/// 单条气泡下方时间戳样式：#FFFFFF80 / 12px / 400
final TextStyle _kBubbleTimeStyle = TextStyle(
  color: const Color(0x80FFFFFF),
  fontSize: 12.sp,
  fontWeight: FontWeight.w400,
);

/// 把毫秒时间戳格式化为 `MM-dd HH:mm`（在线客服气泡下方使用）
String _formatBubbleTime(int ts) {
  final dt = DateTime.fromMillisecondsSinceEpoch(ts).toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
}

/// 单条聊天气泡：根据 [ChatMessage.type] 切换不同子组件（文本/图片/视频…）。
///
/// [isOnlineService] 在线客服会话样式：
/// - 自己气泡背景换成 [AppColor.primaryButtonColor]
/// - 每条消息气泡下方追加一行 `MM-dd HH:mm` 时间
/// - 客服「欢迎语」消息走富文本分支（[ChatMessage.isServiceWelcome]）
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    this.isOnlineService = false,
    this.onTapMessage,
    this.onAvatarTap,
  });

  final ChatMessage message;
  final bool isOnlineService;

  /// 点击消息体（图片/视频点击预览或播放）
  final void Function(ChatMessage msg)? onTapMessage;

  /// 点击头像
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final bool isMine = message.isMine;
    final avatar = _Avatar(url: message.avatar, onTap: onAvatarTap);
    final bubble = _buildContent();

    // 客服模式：气泡下方追加一行时间
    final Widget body = isOnlineService
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              bubble,
              SizedBox(height: 6.w),
              Text(_formatBubbleTime(message.timestamp),
                  style: _kBubbleTimeStyle),
            ],
          )
        : bubble;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          if (!isMine) avatar,
          if (!isMine) SizedBox(width: 10.w),
          Flexible(child: body),
          if (isMine) SizedBox(width: 10.w),
          if (isMine) avatar,
        ],
      ),
    );
  }

  /// 按类型分发到具体内容组件
  Widget _buildContent() {
    if (message.isServiceWelcome) {
      return const _ServiceWelcomeContent();
    }
    switch (message.type) {
      case ChatMessageType.text:
        return _TextContent(message: message, isOnlineService: isOnlineService);
      case ChatMessageType.image:
        return _ImageContent(message: message, onTap: onTapMessage);
      case ChatMessageType.video:
        return _VideoContent(message: message, onTap: onTapMessage);
      case ChatMessageType.voice:
      case ChatMessageType.unknown:
        return _TextContent(
          message: ChatMessage(
            id: message.id,
            type: ChatMessageType.text,
            content: '[暂不支持的消息类型]',
            isMine: message.isMine,
            timestamp: message.timestamp,
            avatar: message.avatar,
          ),
          isOnlineService: isOnlineService,
        );
    }
  }
}

/// 头像
class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, this.onTap});

  final String? url;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_kAvatarSize.w / 2),
        child: CustomImage(
          url: url,
          width: _kAvatarSize.w,
          height: _kAvatarSize.w,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/// 文本气泡
class _TextContent extends StatelessWidget {
  const _TextContent({required this.message, this.isOnlineService = false});

  final ChatMessage message;
  final bool isOnlineService;

  @override
  Widget build(BuildContext context) {
    final bool isMine = message.isMine;
    final Color bg = isMine
        ? (isOnlineService ? AppColor.primaryButtonColor : _kMineBg)
        : _kOtherBg;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 0.66.sw),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.w),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

/// 客服「写死的本地欢迎语」气泡（仅 isOnlineService 模式出现）。
/// - 文案 #FFFFFF / 14px / 400
/// - 中间的 `www.xxx.com` 用红色高亮
class _ServiceWelcomeContent extends StatelessWidget {
  const _ServiceWelcomeContent();

  @override
  Widget build(BuildContext context) {
    final TextStyle base = TextStyle(
      color: Colors.white,
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      height: 1.5,
    );
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 0.66.sw),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.w),
        decoration: BoxDecoration(
          color: _kOtherBg,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text.rich(
          TextSpan(
            style: base,
            children: <InlineSpan>[
              const TextSpan(text: '亲亲，请问您需要什么协助呢？\n'),
              const TextSpan(text: '若您有商务合作需求，欢迎透过一下链接了解详情并联系我们：\n'),
              TextSpan(
                text: '${ConfigStore.to.configBean.shareUrl ?? ""}\n',
                style: base.copyWith(
                    color: AppColor.primaryButtonColor, height: 2),
              ),
              const TextSpan(text: '提醒您：由于近期微信支付通道不稳定，推荐使用支付宝支付，成功率高且快速哟'),
            ],
          ),
        ),
      ),
    );
  }
}

/// 图片气泡
class _ImageContent extends StatelessWidget {
  const _ImageContent({required this.message, this.onTap});

  final ChatMessage message;
  final void Function(ChatMessage msg)? onTap;

  /// 缩略图框边长（固定方形，让本地图 / 网络图 / 竖图 / 横图 渲染框完全一致）
  double get _thumbSize => 0.5.sw;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!(message);
          return;
        }
        Get.toNamed(
          AppRoutes.PICTURE_PREVIEW,
          arguments: {
            'seriesCover': [message.content],
            'index': 0,
            'isLocalImg': message.isLocalImg,
          },
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          width: _thumbSize,
          height: _thumbSize,
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (message.isLocalImg) {
      return Image.file(
        File(message.content),
        width: _thumbSize,
        height: _thumbSize,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(color: Colors.black26),
      );
    }
    return CustomImage(
      url: message.content,
      width: _thumbSize,
      height: _thumbSize,
      fit: BoxFit.contain,
    );
  }
}

/// 视频气泡：封面 + 中间播放按钮
class _VideoContent extends StatelessWidget {
  const _VideoContent({required this.message, this.onTap});

  final ChatMessage message;
  final void Function(ChatMessage msg)? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!(message);
          return;
        }
        Get.toNamed(
          AppRoutes.SIMPLE_PLAYER,
          arguments: {
            'videoUrl': message.content,
            'coverUrl': message.cover ?? '',
            'aspectRatio': 16 / 9,
          },
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 0.55.sw,
            maxHeight: 0.55.sw,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black,
                  child: message.cover != null && message.cover!.isNotEmpty
                      ? CustomImage(url: message.cover, fit: BoxFit.cover)
                      : const SizedBox.expand(),
                ),
              ),
              AssetsGen.images.circle.postPaly.image(width: 44.w, height: 44.w),
              if (message.duration > 0)
                Positioned(
                  right: 8.w,
                  bottom: 8.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      _formatDuration(message.duration),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
