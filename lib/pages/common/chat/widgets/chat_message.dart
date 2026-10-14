import 'package:comics_app/common/entities/chat/user_chat_record_dto.dart';
import 'package:comics_app/common/websocket/websocket.dart';

/// 聊天消息类型：与服务端 mt 段位（200001~200004 / 400001~400004）一一对应。
enum ChatMessageType { text, image, video, voice, unknown }

extension ChatMessageTypeX on ChatMessageType {
  /// 业务发送时对应的 mt（用户聊天 200xxx）
  int get sendMt {
    switch (this) {
      case ChatMessageType.text:
        return WSMt.sendTxt;
      case ChatMessageType.image:
        return WSMt.sendImg;
      case ChatMessageType.video:
        return WSMt.sendVideo;
      case ChatMessageType.voice:
        return WSMt.sendVoice;
      case ChatMessageType.unknown:
        return 0;
    }
  }

  /// 由 mt 反推消息类型
  static ChatMessageType fromMt(int? mt) {
    switch (mt) {
      case WSMt.sendTxt:
      case WSMt.visitorTxt:
        return ChatMessageType.text;
      case WSMt.sendImg:
      case WSMt.visitorImg:
        return ChatMessageType.image;
      case WSMt.sendVideo:
      case WSMt.visitorVideo:
        return ChatMessageType.video;
      case WSMt.sendVoice:
      case WSMt.visitorVoice:
        return ChatMessageType.voice;
      default:
        return ChatMessageType.unknown;
    }
  }
}

/// 发送状态
enum ChatSendStatus { sending, success, failed }

/// 单条聊天消息（UI 层模型，与 [WSMt] 段位解耦）
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.type,
    required this.content,
    required this.isMine,
    required this.timestamp,
    this.duration = 0,
    this.cover,
    this.avatar,
    this.nickName,
    this.status = ChatSendStatus.success,
    this.isLocalImg = false,
    this.isServiceWelcome = false,
  });

  /// 本地或服务端 id（本地构造时可用 timestamp 拼）
  final String id;
  final ChatMessageType type;

  /// 文本：文字本体；图片/视频/语音：媒体 URL
  String content;
  bool isLocalImg = false;

  /// 是否本人发送
  final bool isMine;

  /// 毫秒时间戳
  final int timestamp;

  /// 视频/语音时长（秒）
  final int duration;

  /// 视频封面（可选）
  final String? cover;

  /// 发送方头像
  final String? avatar;

  /// 发送方昵称
  final String? nickName;

  /// 发送状态（仅本人发送的消息才会变化）
  ChatSendStatus status;

  /// 是否为「客服写死的本地欢迎语」消息（仅 isOnlineService 模式下出现）
  /// 客服气泡里需要把 `www.xxx.com` 高亮成红色，单独走富文本渲染分支。
  final bool isServiceWelcome;

  /// 把 [ChatRecordItem] 转成 UI 层 [ChatMessage]
  factory ChatMessage.fromRecord(
    ChatRecordItem item, {
    required bool isMine,
    String? avatar,
    String? nickName,
  }) {
    final ts =
        item.crtDate > 0 ? item.crtDate : DateTime.now().millisecondsSinceEpoch;
    return ChatMessage(
      id: item.id.isNotEmpty ? item.id : ts.toString(),
      type: ChatMessageTypeX.fromMt(item.type),
      content: item.msg,
      duration: item.duration,
      isMine: isMine,
      timestamp: ts,
      avatar: avatar,
      nickName: nickName,
    );
  }
}
