import 'package:comics_app/common/entities/chat/chat_global_store.dart';
import 'package:comics_app/common/store/user.dart';

import '../entities/chat/user_chat_record_dto.dart';
import '../utils/logger.dart';
import 'ws_message_type.dart';
import 'ws_service.dart';

/// 监听 WS 推送，把发给当前用户的聊天消息落到 [ChatGlobalStore]，
/// 供「消息中心」展示最近一条会话。
///
/// 当前用户在聊天页（[ChatGlobalStore.isInChat] == true）时这里早退，
/// 改由 `ChatLogic._handleRealtimePush` 兜底（聊天页只会显示当前会话的消息，
/// 收到非当前会话对方的消息时，再调 [saveIncoming] 落到全局 store）。
class WSListen {
  WSListen._();
  static WSListen? _instance;
  static WSListen get instance => _instance ??= WSListen._();
  static WSListen get to => instance;

  static const List<int> _chatMts = <int>[
    WSMt.sendTxt,
    WSMt.sendImg,
    WSMt.sendVideo,
    WSMt.sendVoice,
  ];

  bool _listening = false;

  void listen() {
    if (_listening) return;
    _listening = true;
    for (final mt in _chatMts) {
      WSService.instance.on(mt, (data) => _handleMessage(mt, data));
    }
  }

  /// 仅当不在聊天页时处理：把发给「我」的消息存到全局会话列表。
  void _handleMessage(int mt, Map<String, dynamic> data) {
    if (ChatGlobalStore.to.isInChat) return;
    saveIncoming(mt, data);
  }

  /// 把一条入站聊天消息保存到 [ChatGlobalStore]（只保存发给当前用户的）。
  ///
  /// 既支持「实时推送（根字段）」也支持服务端少数会附 `chatRecord` 列表的形式。
  /// 聊天页内部收到「非当前会话对方」的消息时也调用本方法，避免漏存。
  void saveIncoming(int mt, Map<String, dynamic> data) {
    l.d('saveIncoming mt=$mt: $data', tag: 'WSListen');
    final UserChatRecordDto item =
        UserChatRecordDto.fromRealtimePush(data, defaultType: mt);
    if (item.chatRecord.isEmpty) return;

    final record = item.chatRecord.first;
    if (record.from.isEmpty && record.to.isEmpty) return;

    final myId = UserStore.to.getUserInfoModel?.uid?.toString() ?? '';
    if (myId.isEmpty || record.to != myId) return;

    ChatGlobalStore.to.addLocalMessage(item);
  }
}
