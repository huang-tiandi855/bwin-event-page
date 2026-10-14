import '../../../common/entities/chat/chat_global_store.dart';
import '../../../common/entities/chat/user_chat_record_dto.dart';

/// 消息中心三类消息
enum MessageType { direct, comment, like }

/// 单条消息（统一模型，按 [type] 决定渲染细节）
class MessageItem {
  final MessageType type;
  final String avatarUrl;
  final String userName;

  /// 私信：消息预览
  /// 评论：评论文本
  /// 点赞：通常固定为"赞了你"
  final String content;

  /// 相对时间，如 "一月前" / "2小时前"
  final String time;

  /// 评论 / 点赞 才有的引用内容（视频缩略图 + 标题）
  final String? videoCover;
  final String? videoTitle;

  const MessageItem({
    required this.type,
    required this.avatarUrl,
    required this.userName,
    required this.content,
    required this.time,
    this.videoCover,
    this.videoTitle,
  });
}

class MessageCenterState {
  /// 私信
  List<ChatLoaclRecordItem> directMessages = ChatGlobalStore.to.localMessages;

  /// 评论
  final List<ChatLoaclRecordItem> commentMessages = const [];

  /// 点赞
  final List<ChatLoaclRecordItem> likeMessages = const [];
}
