import 'dart:async';

import 'package:comics_app/common/entities/chat/user_chat_record_dto.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/utils/files_upload/multi_image_upload_task.dart';
import 'package:comics_app/common/utils/task_manager.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/websocket/websocket.dart';
import 'package:comics_app/common/websocket/ws_listen.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../common/entities/chat/chat_global_store.dart';
import 'state.dart';
import 'widgets/chat_message.dart';

/// 聊天页业务逻辑：订阅 WS 收消息、发文本/图片/视频、上拉加载更多历史
class ChatLogic extends GetxController {
  final ChatState state = ChatState();

  /// 全量消息流订阅（接收聊天记录 / 实时推送）
  StreamSubscription<Map<String, dynamic>>? _msgSub;

  /// 当前正在请求的页码（0 表示空闲）；用于与 [_onMessage] 关联到正确的 fetch
  int _requestingPage = 0;

  /// 聊天页内的断线重连巡检定时器：底层 [WSClient] 已经有 3s/最多 20 次的自动重连，
  /// 这里在 app 已放弃重连、或进页面时本来就未连的场景做兜底。
  Timer? _reconnectTimer;

  /// 巡检间隔；与 [WSClient.reconnectInterval] 错开，避免抢占底层重连节奏
  static const Duration _reconnectCheckInterval = Duration(seconds: 10);

  @override
  void onInit() {
    super.onInit();
    ChatGlobalStore.to.isInChat = true;
    _msgSub = WSService.instance.messageStream.listen(_onMessage);
    // 订阅认证成功事件：每次连接 / 重连建立后拉一次最新页
    WSService.instance.on(WSMt.authSuccess, _onAuthSuccess);

    // 连接由 ApplicationLogic 在 app 启动时常驻建立；
    // 若进页面时连接已就绪，立刻拉第一页，否则等 authSuccess 回执后再拉。
    if (WSService.instance.isConnected) {
      _fetchHistory(pageNum: 1);
    } else {
      _ensureConnected();
    }
    _reconnectTimer =
        Timer.periodic(_reconnectCheckInterval, (_) => _ensureConnected());
  }

  @override
  void onClose() {
    state.scrollController.dispose();
    state.refreshController.dispose();
    WSService.instance.off(WSMt.authSuccess, _onAuthSuccess);
    _msgSub?.cancel();
    _msgSub = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    ChatGlobalStore.to.isInChat = false;
    super.onClose();
  }

  /// 如果当前未连接且不在「连接中」，发起一次 connect；本身是幂等的。
  /// 重连成功后 `_onReady → authToken → authSuccess` 会触发 [_onAuthSuccess] 自动重拉第一页。
  void _ensureConnected() {
    final ws = WSService.instance;
    if (ws.isConnected || ws.status == WSStatus.connecting) return;
    ws.connect();
  }

  // ============================== 接收 ==============================

  /// 通用消息分发：根据 mt 路由到 历史边界 / 发送回执 / 实时推送 / 记录列表 等不同分支。
  void _onMessage(Map<String, dynamic> data) {
    final int mt = (data['mt'] as num?)?.toInt() ?? 0;

    // ---- A. 历史拉取的边界回执 ----
    if (mt == WSMt.noMore || mt == WSMt.paramErr) {
      _onFetchBoundary(mt);
      return;
    }

    // ---- B. 发送回执（成功 / 失败 / 频繁 / 敏感 / 黑名单 / 禁言 / 目标异常 / 非 VIP）----
    if (mt == WSMt.success) {
      _markLatestSendStatus(ChatSendStatus.success);
      return;
    }
    if (mt == WSMt.sendFail ||
        mt == WSMt.sensitive ||
        mt == WSMt.timeShort ||
        mt == WSMt.hitBlack ||
        mt == WSMt.forbidden ||
        mt == WSMt.notVip ||
        mt == WSMt.targetErr) {
      _markLatestSendStatus(ChatSendStatus.failed);
      _toastForSendFail(mt);
      return;
    }

    // ---- C. 实时聊天推送（200001~200004，字段在根上，没有 chatRecord 包装）----
    final bool isUserChatPush = mt == WSMt.sendTxt ||
        mt == WSMt.sendImg ||
        mt == WSMt.sendVideo ||
        mt == WSMt.sendVoice;
    if (isUserChatPush && data['chatRecord'] is! List) {
      _handleRealtimePush(mt, data);
      return;
    }

    // ---- D. 聊天记录列表（含 chatRecord 字段）----
    if (data['chatRecord'] is! List) return;
    final dto = UserChatRecordDto.fromJson(data);

    // mt=0 且有未完成请求 → 视为我们 fetch 的响应；否则视为后端批量推送
    final bool isHistoryResp = mt == 0 && _requestingPage > 0;
    final bool isLoadMore = isHistoryResp && _requestingPage > 1;

    _consumeRecord(dto, autoScrollBottom: !isLoadMore);

    if (isHistoryResp) {
      if (dto.chatRecord.isNotEmpty) {
        state.lastLoadedPage = _requestingPage;
      }
      if (dto.chatRecord.length < state.pageSize) {
        state.hasMore = false;
      }
      final bool wasFirstPage = _requestingPage == 1;
      _requestingPage = 0;

      if (isLoadMore) {
        if (state.hasMore) {
          state.refreshController.loadComplete();
        } else {
          state.refreshController.loadNoData();
        }
      }

      // 客服会话：首次拉取历史完成后，把「写死的本地欢迎语」追加到末尾
      if (wasFirstPage) _maybeAppendServiceWelcome();

      update();
    }
  }

  /// 历史拉取边界回执处理（mt=600009 已到顶 / mt=600013 参数错）
  void _onFetchBoundary(int mt) {
    if (_requestingPage == 0) return;
    final bool wasLoadMore = _requestingPage > 1;
    final bool wasFirstPage = _requestingPage == 1;
    if (mt == WSMt.noMore) state.hasMore = false;
    _requestingPage = 0;
    if (wasLoadMore) {
      if (mt == WSMt.noMore) {
        state.refreshController.loadNoData();
      } else {
        state.refreshController.loadFailed();
      }
    }
    // 客服会话：首页若直接返回「无更多 / 参数错」，同样补一条欢迎语兜底
    if (wasFirstPage) _maybeAppendServiceWelcome();
    update();
  }

  /// 处理实时聊天推送：根字段构造 [ChatRecordItem] → 入消息列表
  ///
  /// - 我自己发的回执（from = 当前用户）→ 升级本地占位消息（id / 时间戳 / 成功态）
  /// - 对端发来的消息 → 追加并滚到底部
  void _handleRealtimePush(int mt, Map<String, dynamic> data) {
    // ChatRecordItem.fromJson 读 'type' 字段；推送里通常只有 'mt'，做兜底
    final fields = Map<String, dynamic>.from(data);
    fields['type'] ??= mt;
    final item = ChatRecordItem.fromJson(fields);

    if (item.from.isEmpty && item.to.isEmpty) return;

    // 仅处理当前会话双方的消息；其他人发给我的消息转存到全局会话列表（消息中心）
    final otherIdStr = state.otherId.toString();
    final bool involves = item.from == otherIdStr || item.to == otherIdStr;
    if (!involves) {
      WSListen.instance.saveIncoming(mt, data);
      return;
    }

    final String myUid = UserStore.to.getUserInfoModel?.uid?.toString() ?? '';
    final bool isMine = myUid.isNotEmpty && item.from == myUid;

    // 我自己消息的回执：升级本地占位（去重 + 同步服务端 id / 时间戳）
    if (isMine) {
      final int idx = state.messages.indexWhere((m) =>
          m.isMine &&
          m.status == ChatSendStatus.sending &&
          m.id.startsWith('local_') &&
          m.content == item.msg &&
          m.type.sendMt == item.type);
      if (idx >= 0) {
        final upgraded = ChatMessage.fromRecord(
          item,
          isMine: true,
          avatar: UserStore.to.getUserInfoModel?.bestAvatar,
        )..status = ChatSendStatus.success;
        state.messages[idx] = upgraded;
        _sortMessages();
        update();
        return;
      }
    }

    // 按服务端 id 去重，避免「回执 + chatRecord 推送」双发场景重复
    if (item.id.isNotEmpty && state.messages.any((m) => m.id == item.id)) {
      return;
    }

    final msg = ChatMessage.fromRecord(
      item,
      isMine: isMine,
      avatar: isMine
          ? UserStore.to.getUserInfoModel?.bestAvatar
          : state.otherAvatar,
      nickName: isMine ? null : state.otherNickName,
    );
    state.messages.add(msg);
    _sortMessages();
    update();
    _scrollToBottom();
  }

  /// 标记「最近一条正在发送的消息」为指定状态
  void _markLatestSendStatus(ChatSendStatus status) {
    final int idx = state.messages.lastIndexWhere(
      (m) => m.isMine && m.status == ChatSendStatus.sending,
    );
    if (idx < 0) return;
    state.messages[idx].status = status;
    update();
  }

  /// 发送失败类回执的 toast 文案
  void _toastForSendFail(int mt) {
    String text;
    switch (mt) {
      case WSMt.sensitive:
        text = '消息包含敏感内容';
        break;
      case WSMt.timeShort:
        text = '发送过于频繁，请稍候再试';
        break;
      case WSMt.hitBlack:
        text = '对方已将你拉黑';
        break;
      case WSMt.forbidden:
        text = '账号已被禁言';
        break;
      case WSMt.notVip:
        text = '该操作需要 VIP';
        break;
      case WSMt.targetErr:
        text = '聊天对象异常';
        break;
      case WSMt.sendFail:
      default:
        text = '发送失败';
    }
    showToast(msg: text);
  }

  /// 认证成功回执：拉一次第一页（重连场景也会自动重拉，保证消息齐全）
  void _onAuthSuccess(Map<String, dynamic> _) {
    _fetchHistory(pageNum: 1);
  }

  /// SmartRefresher.onLoading 回调：上拉触发加载更多历史
  void loadMoreHistory() {
    // 还没拉过第一页 / 没有更多 / 已经在请求中 → 直接释放 footer 状态
    if (state.lastLoadedPage <= 0) {
      state.refreshController.loadComplete();
      return;
    }
    if (!state.hasMore) {
      state.refreshController.loadNoData();
      return;
    }
    if (_requestingPage > 0) {
      // 已经在拉，等响应回来会自动 loadComplete；这里先释放本次拉手势
      state.refreshController.loadComplete();
      return;
    }
    _fetchHistory(pageNum: state.lastLoadedPage + 1, isLoadMore: true);
  }

  /// 拉取聊天记录（mt=800001）
  void _fetchHistory({required int pageNum, bool isLoadMore = false}) {
    if (state.otherId <= 0) return;
    if (_requestingPage > 0) return;
    _requestingPage = pageNum;
    WSService.instance.fetchUserRecords(
      contactId: state.otherId.toString(),
      pageNum: pageNum,
      pageSize: state.pageSize,
    );
  }

  /// 消费一份 [UserChatRecordDto]：补全对方信息 + 合并消息列表
  void _consumeRecord(
    UserChatRecordDto dto, {
    bool autoScrollBottom = true,
  }) {
    bool changed = false;

    // 用服务端 contactInfo / contactAvatar 补全（本地未传时）
    final String? srvNick = dto.contactInfo?.nickName;
    if ((state.otherNickName == null || state.otherNickName!.isEmpty) &&
        srvNick != null &&
        srvNick.isNotEmpty) {
      state.otherNickName = srvNick;
      changed = true;
    }
    final String? srvAvatar = dto.contactAvatar?.url;
    if ((state.otherAvatar == null || state.otherAvatar!.isEmpty) &&
        srvAvatar != null &&
        srvAvatar.isNotEmpty) {
      state.otherAvatar = srvAvatar;
      changed = true;
    }

    if (dto.chatRecord.isNotEmpty) {
      final String myUid = UserStore.to.getUserInfoModel?.uid?.toString() ?? '';
      final String otherIdStr = state.otherId.toString();
      for (final item in dto.chatRecord) {
        // 过滤掉与当前会话无关的记录
        final bool involves = item.from == otherIdStr || item.to == otherIdStr;
        if (!involves) continue;

        final bool isMine = item.from == myUid;
        final msg = ChatMessage.fromRecord(
          item,
          isMine: isMine,
          avatar: isMine
              ? UserStore.to.getUserInfoModel?.bestAvatar
              : state.otherAvatar,
          nickName: isMine ? null : state.otherNickName,
        );

        // 去重：服务端 id 已经唯一；本地占位消息（local_*）不会与服务端 id 冲突
        final existed =
            state.messages.any((m) => m.id == msg.id && msg.id.isNotEmpty);
        if (existed) continue;

        state.messages.add(msg);
        changed = true;
      }
    }

    if (changed) {
      _sortMessages();
      update();
      if (autoScrollBottom) _scrollToBottom();
    }
  }

  // ============================== 发送 ==============================

  /// 发送文本消息
  Future<void> sendText(String text) async {
    if (text.trim().isEmpty) return;
    if (state.otherId <= 0) {
      showToast(msg: '聊天对象异常');
      return;
    }
    final msg = _buildLocal(
      type: ChatMessageType.text,
      content: text.trim(),
    );
    _appendLocal(msg);
    WSService.instance.sendText(to: state.otherId, msg: text.trim());
  }

  /// 发送图片消息：先用本地路径插占位（UI 立刻显示本地图），后台上传完成后
  /// 把 content 替换为远端 URL 再发 WS；上传失败置失败态。
  Future<void> sendImage(String localPath) async {
    if (localPath.isEmpty || state.otherId <= 0) return;

    // 1. 立刻插入占位（content = 本地路径，sending 状态）
    final msg = _buildLocal(
      type: ChatMessageType.image,
      content: localPath,
    );
    _appendLocal(msg);

    // 2. 异步上传
    dynamic model;
    try {
      model =
          await taskManager.addTaskToQueue(MultiImageUploadTask([localPath],isUploadChatImages: true));
    } catch (_) {
      msg.status = ChatSendStatus.failed;
      update();
      showToast(msg: '图片上传失败');
      return;
    }
    final List uploaded = (model?.filePath as List?) ?? const [];
    if (uploaded.isEmpty) {
      msg.status = ChatSendStatus.failed;
      update();
      showToast(msg: '图片上传失败');
      return;
    }

    // 3.
    final remoteUrl = uploaded.first.toString();

    // 4. 通过 WS 发送
    WSService.instance.sendImage(to: state.otherId, url: remoteUrl);
  }

  /// 发送视频消息（外层完成上传后传入视频 URL + 时长）
  Future<void> sendVideo({
    required String url,
    required int duration,
    String? cover,
  }) async {
    if (url.isEmpty || state.otherId <= 0) return;
    final msg = _buildLocal(
      type: ChatMessageType.video,
      content: url,
      duration: duration,
      cover: cover,
    );
    _appendLocal(msg);
    WSService.instance.sendVideo(
      to: state.otherId,
      url: url,
      duration: duration,
    );
  }

  // ============================== 辅助 ==============================

  /// 构造本地消息（self 发出）
  ChatMessage _buildLocal({
    required ChatMessageType type,
    required String content,
    int duration = 0,
    String? cover,
  }) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return ChatMessage(
      id: 'local_$ts',
      type: type,
      content: content,
      duration: duration,
      cover: cover,
      isMine: true,
      timestamp: ts,
      avatar: UserStore.to.getUserInfoModel?.bestAvatar,
      status: ChatSendStatus.sending,
      isLocalImg: type == ChatMessageType.image,
    );
  }

  /// 追加本地消息并刷新
  void _appendLocal(ChatMessage msg) {
    state.messages.add(msg);
    update();
    _scrollToBottom();
  }

  /// 客服模式专用：在首页历史拉取完成后，追加一条「写死的本地欢迎语」消息。
  /// 仅追加一次（[ChatState.serviceWelcomeAdded] 兜底防重）。
  void _maybeAppendServiceWelcome() {
    if (!state.isOnlineService) return;
    if (state.serviceWelcomeAdded) return;
    state.serviceWelcomeAdded = true;

    final int ts = DateTime.now().millisecondsSinceEpoch;
    final ChatMessage welcome = ChatMessage(
      id: 'service_welcome_$ts',
      type: ChatMessageType.text,
      content: '',
      isMine: false,
      timestamp: ts,
      avatar: state.otherAvatar,
      nickName: state.otherNickName,
      isServiceWelcome: true,
    );
    state.messages.add(welcome);
    _sortMessages();
    _scrollToBottom();
  }

  /// 按时间戳升序排序
  void _sortMessages() {
    state.messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// 滚到最底部（reverse 模式下 offset=0 即底部）
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!state.scrollController.hasClients) return;
      state.scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }
}
