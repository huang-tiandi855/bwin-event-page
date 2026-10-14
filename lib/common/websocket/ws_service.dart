import 'dart:async';

import '../store/config.dart';
import '../store/user.dart';
import '../utils/logger.dart';
import 'ws_client.dart';
import 'ws_message_type.dart';

/// 业务层 WebSocket 封装：在 [WSClient] 之上提供按 mt 分类的便捷调用方法。
///
/// 连接策略：登录后由 `ApplicationLogic.connectChat()` 触发一次 [connect]，
/// 之后由 [WSClient] 自动维持心跳 / 断线重连；消息中心需要随时收到推送，
/// 所以不再使用按页面引用计数 / 延迟断开的策略。
class WSService {
  WSService._();
  static final WSService instance = WSService._();

  WSClient get _client => WSClient.instance;

  /// 全量消息流
  Stream<Map<String, dynamic>> get messageStream => _client.messageStream;

  /// 当前连接状态
  WSStatus get status => _client.status;

  /// 是否已连接
  bool get isConnected => _client.isConnected;

  /// 默认的 WebSocket 地址：从全局配置 `ConfigStore.to.configBean.chatDomain` 读取
  String? get defaultUrl {
    try {
      return ConfigStore.to.configBean.chatDomain;
    } catch (_) {
      return null;
    }
  }

  /// 建立连接并启动心跳：不传 [url] 时使用 [defaultUrl]。
  ///
  /// 已连或连接中的状态会复用现有连接（幂等）；底层 [WSClient.connect] 会自动重连，
  /// 业务侧通常只需要在登录成功 / app resume 时调用一次。
  Future<void> connect([
    String? url,
    Duration heartbeatInterval = const Duration(seconds: 30),
  ]) async {
    if (_client.isConnected || _client.status == WSStatus.connecting) {
      return;
    }
    final target = (url ?? defaultUrl ?? '').trim();
    if (target.isEmpty) {
      l.d('connect abort: empty url', tag: 'WS');
      return;
    }
    return _client.connect(
      target,
      heartbeatInterval: heartbeatInterval,
      heartbeatBuilder: _buildHeartbeat,
      onReady: _onReady,
    );
  }

  /// 主动断开 WebSocket（登出 / 异地登录 / 授权失败 / 切换账号时使用）
  Future<void> disconnect() => _client.disconnect();

  /// 心跳消息构造器：自动附带最新 token
  Map<String, dynamic> _buildHeartbeat() {
    final tkn = UserStore.to.getAccessToken();
    final m = <String, dynamic>{'mt': WSMt.heartbeat};
    if (tkn != null && tkn.isNotEmpty) m['tkn'] = tkn;
    return m;
  }

  /// 每次连接 / 重连成功后自动发认证；无 token 时跳过（如游客客服场景）
  void _onReady() {
    final tkn = UserStore.to.getAccessToken();
    if (tkn != null && tkn.isNotEmpty) {
      authToken(tkn);
    }
  }

  /// 注册 mt 消息回调
  void on(int mt, WSMessageHandler handler) => _client.on(mt, handler);

  /// 注销 mt 消息回调
  void off(int mt, [WSMessageHandler? handler]) => _client.off(mt, handler);

  /// 发送任意 JSON（自定义 mt 时使用）
  void sendRaw(Map<String, dynamic> data) => _client.send(data);

  // ================== 1. 认证 / 心跳 (500xxx) ==================

  /// 用户 token 认证（mt=500002）
  void authToken(String token) {
    _client.send({'mt': WSMt.authToken, 'tkn': token});
  }

  /// 游客临时认证（mt=500005）
  void authVisitor(String visitorId) {
    _client.send({'mt': WSMt.authVisitor, 'id': visitorId});
  }

  /// 主动发送一次心跳（mt=500003）
  void sendHeartbeat({String? token}) {
    final tkn = (token ?? UserStore.to.getAccessToken() ?? '').trim();
    final m = <String, dynamic>{'mt': WSMt.heartbeat};
    if (tkn.isNotEmpty) m['tkn'] = tkn;
    _client.send(m);
  }

  // ================== 2. 用户聊天消息 (200xxx) ==================

  /// 发送文本消息（mt=200001）
  void sendText({
    required int to,
    required String msg,
    String? token,
    String? nickName,
    String? avatar,
    bool isOfficialPush = false,
  }) {
    _client.send(_buildUserChat(
      WSMt.sendTxt,
      to: to,
      msg: msg,
      token: token,
      nickName: nickName,
      avatar: avatar,
      isOfficialPush: isOfficialPush,
    ));
  }

  /// 发送图片消息（mt=200002），msg 传图片 URL
  void sendImage({
    required int to,
    required String url,
    String? token,
    String? nickName,
    String? avatar,
    bool isOfficialPush = false,
  }) {
    _client.send(_buildUserChat(
      WSMt.sendImg,
      to: to,
      msg: url,
      token: token,
      nickName: nickName,
      avatar: avatar,
      isOfficialPush: isOfficialPush,
    ));
  }

  /// 发送视频消息（mt=200003），duration 单位秒
  void sendVideo({
    required int to,
    required String url,
    required int duration,
    String? token,
    String? nickName,
    String? avatar,
    bool isOfficialPush = false,
  }) {
    _client.send(_buildUserChat(
      WSMt.sendVideo,
      to: to,
      msg: url,
      duration: duration,
      token: token,
      nickName: nickName,
      avatar: avatar,
      isOfficialPush: isOfficialPush,
    ));
  }

  /// 发送语音消息（mt=200004），duration 单位秒
  void sendVoice({
    required int to,
    required String url,
    required int duration,
    String? token,
    String? nickName,
    String? avatar,
    bool isOfficialPush = false,
  }) {
    _client.send(_buildUserChat(
      WSMt.sendVoice,
      to: to,
      msg: url,
      duration: duration,
      token: token,
      nickName: nickName,
      avatar: avatar,
      isOfficialPush: isOfficialPush,
    ));
  }

  /// 组装用户聊天消息通用字段
  Map<String, dynamic> _buildUserChat(
    int mt, {
    required int to,
    required String msg,
    String? token,
    int duration = 0,
    String? nickName,
    String? avatar,
    bool isOfficialPush = false,
  }) {
    final tkn = (token ?? UserStore.to.getAccessToken() ?? '').trim();
    final data = <String, dynamic>{
      'mt': mt,
      'to': to,
      'msg': msg,
      'duration': duration,
      'isOfficialPush': isOfficialPush,
    };
    if (tkn.isNotEmpty) data['tkn'] = tkn;
    if (nickName != null) data['nickName'] = nickName;
    if (avatar != null) data['avatar'] = avatar;
    return data;
  }

  // ================== 3. 游客聊天消息 (400xxx) ==================

  /// 游客发送文本消息（mt=400001）
  void visitorSendText({
    required int from,
    required int to,
    required String msg,
    bool isOfficialPush = false,
  }) {
    _client.send(_buildVisitorChat(
      WSMt.visitorTxt,
      from: from,
      to: to,
      msg: msg,
      isOfficialPush: isOfficialPush,
    ));
  }

  /// 游客发送图片消息（mt=400002）
  void visitorSendImage({
    required int from,
    required int to,
    required String url,
    bool isOfficialPush = false,
  }) {
    _client.send(_buildVisitorChat(
      WSMt.visitorImg,
      from: from,
      to: to,
      msg: url,
      isOfficialPush: isOfficialPush,
    ));
  }

  /// 游客发送视频消息（mt=400003），duration 单位秒
  void visitorSendVideo({
    required int from,
    required int to,
    required String url,
    required int duration,
    bool isOfficialPush = false,
  }) {
    _client.send(_buildVisitorChat(
      WSMt.visitorVideo,
      from: from,
      to: to,
      msg: url,
      duration: duration,
      isOfficialPush: isOfficialPush,
    ));
  }

  /// 游客发送语音消息（mt=400004），duration 单位秒
  void visitorSendVoice({
    required int from,
    required int to,
    required String url,
    required int duration,
    bool isOfficialPush = false,
  }) {
    _client.send(_buildVisitorChat(
      WSMt.visitorVoice,
      from: from,
      to: to,
      msg: url,
      duration: duration,
      isOfficialPush: isOfficialPush,
    ));
  }

  /// 组装游客聊天消息通用字段
  Map<String, dynamic> _buildVisitorChat(
    int mt, {
    required int from,
    required int to,
    required String msg,
    int duration = 0,
    bool isOfficialPush = false,
  }) {
    return <String, dynamic>{
      'mt': mt,
      'from': from,
      'to': to,
      'msg': msg,
      'duration': duration,
      'isVisitor': true,
      'isOfficialPush': isOfficialPush,
    };
  }

  // ================== 4. 用户聊天记录 (800xxx) ==================

  /// 拉取我的聊天记录（mt=800001）
  void fetchUserRecords({
    String? contactId,
    int msgType = 1,
    int pageNum = 1,
    int pageSize = 20,
    String? token,
  }) {
    final tkn = (token ?? UserStore.to.getAccessToken() ?? '').trim();
    final data = <String, dynamic>{
      'mt': WSMt.recordUser,
      'msgType': msgType,
      'pageNum': pageNum,
      'pageSize': pageSize,
    };
    if (tkn.isNotEmpty) data['tkn'] = tkn;
    if (contactId != null) data['contactId'] = contactId;
    _client.send(data);
  }

  /// 删除聊天记录（mt=800002）：contactId 非空则删整个会话，否则按 records 删
  void deleteRecords({
    String? contactId,
    List<Map<String, dynamic>>? records,
    bool bothDel = false,
    String? token,
  }) {
    final tkn = (token ?? UserStore.to.getAccessToken() ?? '').trim();
    final data = <String, dynamic>{
      'mt': WSMt.recordDel,
      'bothDel': bothDel,
    };
    if (tkn.isNotEmpty) data['tkn'] = tkn;
    if (contactId != null) data['contactId'] = contactId;
    if (records != null) data['records'] = records;
    _client.send(data);
  }

  /// 拉取官方推送记录（mt=800003）
  void fetchOfficialRecords({required String officialId, String? token}) {
    final tkn = (token ?? UserStore.to.getAccessToken() ?? '').trim();
    final data = <String, dynamic>{
      'mt': WSMt.recordOfficial,
      'contactId': officialId,
    };
    if (tkn.isNotEmpty) data['tkn'] = tkn;
    _client.send(data);
  }

  /// 批量删除联系人会话（mt=800004）
  void batchDeleteContacts({
    required List<String> contactIds,
    bool bothDel = false,
    String? token,
  }) {
    final tkn = (token ?? UserStore.to.getAccessToken() ?? '').trim();
    final data = <String, dynamic>{
      'mt': WSMt.recordBatchDel,
      'contactId': contactIds,
      'bothDel': bothDel,
    };
    if (tkn.isNotEmpty) data['tkn'] = tkn;
    _client.send(data);
  }

  // ================== 5. 游客聊天记录 (900xxx) ==================

  /// 拉取游客聊天记录（mt=900001）
  void fetchVisitorRecords({
    required int visitorId,
    int msgType = 1,
    int pageNum = 1,
    int pageSize = 20,
  }) {
    _client.send({
      'mt': WSMt.recordVisitor,
      'id': visitorId,
      'msgType': msgType,
      'pageNum': pageNum,
      'pageSize': pageSize,
    });
  }

  // ================== 6. 互动消息 (500006~500009) ==================

  /// 拉取互动消息列表（mt=500006）
  void fetchInteractiveList({int page = 1, int pageSize = 20}) {
    _client.send({
      'mt': WSMt.interactiveList,
      'page': page,
      'pageSize': pageSize,
    });
  }

  /// 标记一条互动消息已读（mt=500007）
  void readInteractive({required int createTime}) {
    _client.send({'mt': WSMt.interactiveRead, 'createTime': createTime});
  }

  /// 查询互动消息未读数（mt=500008）
  void fetchInteractiveUnread() {
    _client.send({'mt': WSMt.interactiveUnreadCount});
  }

  /// 删除一条互动消息（mt=500009）
  void deleteInteractive({required int createTime}) {
    _client.send({'mt': WSMt.interactiveDel, 'createTime': createTime});
  }

  // ================== 7. 黑名单 (700xxx) ==================

  /// 获取黑名单列表（mt=700001）
  void fetchBlackList({int pageNum = 1, int pageSize = 20, String? token}) {
    final tkn = (token ?? UserStore.to.getAccessToken() ?? '').trim();
    final data = <String, dynamic>{
      'mt': WSMt.blackList,
      'pageNum': pageNum,
      'pageSize': pageSize,
    };
    if (tkn.isNotEmpty) data['tkn'] = tkn;
    _client.send(data);
  }

  /// 移除黑名单（mt=700002）
  void removeBlack({required int contactId, String? token}) {
    final tkn = (token ?? UserStore.to.getAccessToken() ?? '').trim();
    final data = <String, dynamic>{
      'mt': WSMt.blackRemove,
      'contactId': contactId,
    };
    if (tkn.isNotEmpty) data['tkn'] = tkn;
    _client.send(data);
  }

  /// 加入黑名单（mt=700003）
  void addBlack({required int contactId, String? token}) {
    final tkn = (token ?? UserStore.to.getAccessToken() ?? '').trim();
    final data = <String, dynamic>{
      'mt': WSMt.blackAdd,
      'contactId': contactId,
    };
    if (tkn.isNotEmpty) data['tkn'] = tkn;
    _client.send(data);
  }
}
