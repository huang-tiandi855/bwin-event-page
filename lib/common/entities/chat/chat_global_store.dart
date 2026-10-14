import '../../services/storage.dart';
import 'user_chat_record_dto.dart';

class ChatGlobalStore {
  static ChatGlobalStore? _instance;
  static ChatGlobalStore get instance => _instance ??= ChatGlobalStore._();

  static const String _localMessagesKey = 'chat_local_record_key';

  ChatGlobalStore._() {
    final raw = StorageService.to.read(_localMessagesKey);
    if (raw is! List) {
      localMessages = [];
    } else {
      localMessages = raw.map((e) => ChatLoaclRecordItem.fromJson(e)).toList();
    }
  }

  static ChatGlobalStore get to => instance;

  bool isInChat = false; //是否在聊天页面

  List<ChatLoaclRecordItem> localMessages = [];

  void addLocalMessage(UserChatRecordDto item) {
    if (item.chatRecord.isEmpty) return;
    final record = item.chatRecord.first;
    final index = localMessages.indexWhere((e) => e.from == record.from);
    if (index != -1) {
      localMessages[index] =
          ChatLoaclRecordItem(from: record.from, message: item);
    } else {
      localMessages.add(ChatLoaclRecordItem(from: record.from, message: item));
    }
    _saveMessage();
  }

  void _saveMessage() {
    StorageService.to.white(
        _localMessagesKey, localMessages.map((e) => e.toJson()).toList());
  }

  void removeMessage(String from) {
    localMessages.removeWhere((e) => e.from == from);
    _saveMessage();
  }
}
