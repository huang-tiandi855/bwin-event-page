import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../utils/logger.dart';
import 'ws_message_type.dart';

/// 收到一条消息后的处理回调
typedef WSMessageHandler = void Function(Map<String, dynamic> message);

/// WebSocket 连接状态
enum WSStatus { idle, connecting, connected, disconnected }

/// 底层 WebSocket 客户端：负责连接、断线重连、心跳、消息分发
class WSClient {
  WSClient._();
  static final WSClient instance = WSClient._();

  // ----- 连接相关 -----
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  String? _url;
  WSStatus _status = WSStatus.idle;

  // ----- 心跳相关 -----
  Timer? _heartbeatTimer;
  Duration heartbeatInterval = const Duration(seconds: 30);

  /// 心跳消息构造器（可附带最新 token），默认仅发送 `{mt: 500003}`
  Map<String, dynamic> Function()? heartbeatBuilder;

  /// 每次成功建立连接（含断线重连）后触发，用于自动重新认证等业务初始化
  void Function()? onReady;

  // ----- 重连相关 -----
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _manualClose = false;
  Duration reconnectInterval = const Duration(seconds: 3);
  int maxReconnectAttempts = 20;

  // ----- 消息流 -----
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final Map<int, List<WSMessageHandler>> _handlers = {};

  /// 当前连接状态
  WSStatus get status => _status;

  /// 是否已建立连接
  bool get isConnected => _status == WSStatus.connected;

  /// 全量消息流（广播），按需订阅
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  /// 建立 WebSocket 连接（重复调用会先关闭旧连接）
  Future<void> connect(
    String url, {
    Duration? heartbeatInterval,
    Map<String, dynamic> Function()? heartbeatBuilder,
    void Function()? onReady,
  }) async {
    if (heartbeatInterval != null) this.heartbeatInterval = heartbeatInterval;
    if (heartbeatBuilder != null) this.heartbeatBuilder = heartbeatBuilder;
    if (onReady != null) this.onReady = onReady;
    if (_channel != null) {
      await _closeChannel();
    }
    _manualClose = false;
    _url = url;
    _status = WSStatus.connecting;
    try {
      _channel = IOWebSocketChannel.connect(
        Uri.parse(url),
        pingInterval: const Duration(seconds: 25),
        connectTimeout: const Duration(seconds: 15),
      );
      _sub = _channel!.stream.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
      _status = WSStatus.connected;
      _reconnectAttempts = 0;
      _startHeartbeat();
      l.d('connected: $url', tag: 'WS');
      try {
        onReady?.call();
      } catch (e) {
        l.d('onReady error: $e', tag: 'WS');
      }
    } catch (e, s) {
      _status = WSStatus.disconnected;
      l.d('connect fail: $e\n$s', tag: 'WS');
      _scheduleReconnect();
    }
  }

  /// 主动断开连接，并停止重连与心跳
  Future<void> disconnect() async {
    _manualClose = true;
    _stopHeartbeat();
    _cancelReconnect();
    await _closeChannel();
    _status = WSStatus.idle;
  }

  /// 发送任意 JSON 消息（自动补 `t` 时间戳）
  void send(Map<String, dynamic> data) {
    if (_channel == null || _status != WSStatus.connected) {
      l.d('not connected, drop: $data', tag: 'WS');
      return;
    }
    data['t'] ??= DateTime.now().millisecondsSinceEpoch;
    final body = jsonEncode(data);
    try {
      _channel!.sink.add(body);
      l.d('send: $body', tag: 'WS');
    } catch (e) {
      l.d('send fail: $e', tag: 'WS');
    }
  }

  /// 注册某个 mt 的消息回调
  void on(int mt, WSMessageHandler handler) {
    _handlers.putIfAbsent(mt, () => <WSMessageHandler>[]).add(handler);
  }

  /// 注销某个 mt 的消息回调（不传 handler 时清空该 mt 全部回调）
  void off(int mt, [WSMessageHandler? handler]) {
    if (handler == null) {
      _handlers.remove(mt);
    } else {
      _handlers[mt]?.remove(handler);
    }
  }

  /// 清空所有 mt 回调
  void clearHandlers() => _handlers.clear();

  /// 处理收到的原始数据并按 mt 分发
  void _onData(dynamic raw) {
    try {
      final str = raw is String ? raw : raw.toString();
      final decoded = jsonDecode(str);
      if (decoded is! Map) return;
      final data = Map<String, dynamic>.from(decoded);
      l.d('recv: $str', tag: 'WS');
      _messageController.add(data);
      final mt = (data['mt'] as num?)?.toInt();
      if (mt == null) return;
      final list = _handlers[mt];
      if (list == null) return;
      for (final h in List<WSMessageHandler>.of(list)) {
        try {
          h(data);
        } catch (e) {
          l.d('handler error mt=$mt: $e', tag: 'WS');
        }
      }
    } catch (e) {
      l.d('parse fail: $e', tag: 'WS');
    }
  }

  /// 流出错回调
  void _onError(dynamic err) {
    l.d('error: $err', tag: 'WS');
    _status = WSStatus.disconnected;
    _stopHeartbeat();
    _scheduleReconnect();
  }

  /// 流关闭回调
  void _onDone() {
    l.d('done (closed by remote or local)', tag: 'WS');
    _status = WSStatus.disconnected;
    _stopHeartbeat();
    _channel = null;
    if (!_manualClose) _scheduleReconnect();
  }

  /// 关闭并清理底层连接
  Future<void> _closeChannel() async {
    try {
      await _sub?.cancel();
    } catch (_) {}
    _sub = null;
    try {
      await _channel?.sink.close(ws_status.normalClosure);
    } catch (_) {}
    _channel = null;
  }

  /// 启动周期性心跳
  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (_) {
      final msg =
          heartbeatBuilder?.call() ?? <String, dynamic>{'mt': WSMt.heartbeat};
      send(msg);
    });
  }

  /// 停止心跳
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// 安排一次延迟重连
  void _scheduleReconnect() {
    if (_manualClose || _url == null) return;
    if (_reconnectAttempts >= maxReconnectAttempts) {
      l.d('reconnect max reached', tag: 'WS');
      return;
    }
    _reconnectAttempts++;
    _cancelReconnect();
    _reconnectTimer = Timer(reconnectInterval, () {
      l.d('reconnect attempt #$_reconnectAttempts', tag: 'WS');
      connect(
        _url!,
        heartbeatInterval: heartbeatInterval,
        heartbeatBuilder: heartbeatBuilder,
        onReady: onReady,
      );
    });
  }

  /// 取消已安排的重连
  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }
}
