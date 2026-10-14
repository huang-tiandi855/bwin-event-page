import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'widgets/chat_message.dart';

/// 聊天页状态
class ChatState {
  ChatState() {
    final dynamic args = Get.arguments;
    otherId = _parseId(args);
    otherNickName = (args is Map ? args['nickName']?.toString() : null);
    otherAvatar = (args is Map ? args['avatar']?.toString() : null);
  }

  /// 对方 uid（必传）
  late final int otherId;

  /// 对方昵称（可选，用作 AppBar 标题）
  String? otherNickName;

  /// 对方头像（可选，用于他人侧气泡头像）
  String? otherAvatar;

  /// 消息列表（最早 → 最新；UI 用 `reverse: true` 渲染时按倒序取）
  final List<ChatMessage> messages = <ChatMessage>[];

  /// 列表滚动控制器（reverse 模式下 0 = 底部）
  final ScrollController scrollController = ScrollController();

  /// SmartRefresher 控制器；驱动顶部「上拉加载更多」交互
  ///（reverse=true 模式下，footer 渲染在视觉顶部）
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  // ----- 分页（上拉加载更多历史） -----

  /// 每页条数
  int pageSize = 20;

  /// 已成功加载到的最大页码（0 表示尚未加载过）
  int lastLoadedPage = 0;

  /// 是否还有更多历史；收到 `mt=600009` 或最后一页不足 [pageSize] 时置 false
  bool hasMore = true;

  /// 是否是在线客服
  bool isOnlineService = false;

  /// 客服模式下，「写死的本地欢迎语」是否已经追加过
  /// （只在首次拉取历史成功后追加一次，避免重连 / 重拉时重复）
  bool serviceWelcomeAdded = false;

  /// 从 [Get.arguments] 解析对方 id：兼容 `{ otherId: 1024 }` 与直接传 int 两种形式
  int _parseId(dynamic args) {
    if (args is int) return args;
    if (args is num) return args.toInt();
    if (args is String) return int.tryParse(args) ?? 0;
    if (args is Map) {
      if (args['isOnlineService'] == true) {
        isOnlineService = true;
      }
      final v = args['otherId'] ?? args['id'] ?? args['uid'];
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
    }
    return 0;
  }
}
