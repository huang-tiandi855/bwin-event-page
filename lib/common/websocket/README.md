# WebSocket 模块使用说明

基于后端《WebSocket 消息收发对接文档》的客户端封装。底层使用 `web_socket_channel: ^2.4.0`，已在 `pubspec.yaml` 中声明，无需额外配置。

---

## 1. 目录结构

```
lib/common/websocket/
├── websocket.dart          桶导出（统一入口）
├── ws_message_type.dart    所有 mt 常量（WSMt，与文档段位对齐）
├── ws_client.dart          底层连接：心跳 / 断线重连 / 消息分发
└── ws_service.dart         业务 API：认证、文本/图片/视频/语音、记录、互动、黑名单
```

引入方式：

```dart
import 'package:comics_app/common/websocket/websocket.dart';
```

---

## 2. 设计要点

- **单例 + 广播流**：`WSClient.instance` / `WSService.instance`，`messageStream` 是 broadcast，任意页面都可订阅；同时支持 `on(mt, handler)` 按消息号注册回调。
- **心跳保活**：`Timer.periodic(30s)` 自动发送 `mt=500003`，自动带上 `UserStore.to.getAccessToken()` 的 `tkn`，并设置底层 `pingInterval: 25s` 让 OS 层也保活。
- **断线重连**：默认 3 秒一次、最多 20 次；主动调用 `disconnect()` / `forceDisconnect()` 时不会触发重连。
- **自动重认证**：每次连接（含重连）建立后自动触发 `onReady` 回调，`WSService` 在里面读 `UserStore` token 自动发 `authToken`，业务侧无需关心。
- **通用字段自动注入**：所有发送都会自动补 `t`（毫秒时间戳）；用户态消息自动注入 `tkn`，调用方可显式覆盖。
- **按需连接 + 引用计数 + 延迟断开**：见下方第 3 节。

---

## 3. 连接生命周期管理（重点）

本 App 只有「私信」和「在线客服」两个场景用到 WebSocket，**不在登录后全局常驻**。
连接采用引用计数 + 延迟断开策略，由 `WSService` 提供 3 个 API：

| 方法 | 用途 | 何时调用 |
| --- | --- | --- |
| `acquire([url])` | 引用计数 +1；首次会触发 connect + 自动认证 | 进入聊天 / 客服场景前（按钮点击或 `onInit`） |
| `release({delay})` | 引用计数 -1；归零后 60s 延迟真正断开 | 离开聊天 / 客服场景（`onClose`） |
| `forceDisconnect()` | 立即清零计数并断开 | 登出 / 异地登录 / 授权失败 / 切换账号 |

- 默认 `acquire()` 不传 url 时使用 `ConfigStore.to.configBean.chatDomain`。
- 多个聊天页 / 客服页同时存在时，引用计数确保不会被任一页面的 `release` 误断。
- 用户快速返回再进入新会话时，60s 延迟断开机制会让连接被复用，无需重连。

`ChatLogic` 已经在 `onInit` 调 `acquire()`、`onClose` 调 `release()`，对话页本身无需关心连接状态。
入口侧（如「私信」按钮 onTap）可以在 `Get.toNamed` **之前**再调一次 `acquire()` 做预连接，导航动画期间并发完成握手 + 认证，进页面瞬时可用。

---

## 4. 关键 API 一览（`WSService`）

| 方法 | mt | 说明 |
| --- | --- | --- |
| `acquire([url])` / `release()` / `forceDisconnect()` | - | 引用计数式连接管理（首选） |
| `connect(url)` / `disconnect()` | - | 直接管理连接（特殊场景） |
| `authToken(token)` | 500002 | 用户 token 认证（连上后自动调，一般无需手动） |
| `authVisitor(id)` | 500005 | 游客临时认证 |
| `sendHeartbeat()` | 500003 | 主动心跳 |
| `sendText` | 200001 | 用户发送文本 |
| `sendImage` | 200002 | 用户发送图片 |
| `sendVideo` | 200003 | 用户发送视频（需 `duration`） |
| `sendVoice` | 200004 | 用户发送语音（需 `duration`） |
| `visitorSendText` / `Image` / `Video` / `Voice` | 400001~400004 | 游客发送各类消息 |
| `fetchUserRecords` | 800001 | 拉取我的聊天记录 |
| `deleteRecords` | 800002 | 删除聊天记录 |
| `fetchOfficialRecords` | 800003 | 拉取官方推送记录 |
| `batchDeleteContacts` | 800004 | 批量删除联系人会话 |
| `fetchVisitorRecords` | 900001 | 拉取游客聊天记录 |
| `fetchInteractiveList` | 500006 | 互动消息列表 |
| `readInteractive` | 500007 | 标记互动消息已读 |
| `fetchInteractiveUnread` | 500008 | 互动消息未读数 |
| `deleteInteractive` | 500009 | 删除互动消息 |
| `fetchBlackList` | 700001 | 黑名单列表 |
| `removeBlack` | 700002 | 移除黑名单 |
| `addBlack` | 700003 | 加入黑名单 |
| `sendRaw(data)` | * | 兜底，自定义未覆盖的 mt 时使用 |

---

## 5. 服务端回执码（`WSMt`，mt=600xxx）

订阅时直接用常量，避免硬编码：

| 常量 | mt | 含义 |
| --- | --- | --- |
| `WSMt.authSuccess` | 600001 | 授权成功 |
| `WSMt.authFail` | 600002 | 授权失败 |
| `WSMt.offline` | 600003 | 用户已离线 |
| `WSMt.success` | 600005 | 操作成功（删除等） |
| `WSMt.unAuth` | 600006 | 未授权 |
| `WSMt.loginAnother` | 600007 | 异地登录 |
| `WSMt.sendFail` | 600008 | 发送失败 |
| `WSMt.noMore` | 600009 | 没有更多了 |
| `WSMt.timeShort` | 600010 | 时间不足 |
| `WSMt.sensitive` | 600011 | 命中敏感词 |
| `WSMt.notVip` | 600012 | 非会员 |
| `WSMt.paramErr` | 600013 | 参数错误 |
| `WSMt.targetErr` | 600014 | 对象有误 |
| `WSMt.newToken` | 600015 | 服务端续签的新 token |
| `WSMt.hitBlack` | 600016 | 命中黑名单 |
| `WSMt.forbidden` | 600017 | 被禁言 |
| `WSMt.interactiveMsg` | 600018 | 互动消息推送 |
| `WSMt.interactiveUnreadNumMsg` | 600019 | 互动消息未读数推送 |

---

## 6. 使用示例

### 6.1 进入聊天 / 客服场景（推荐写法）

```dart
import 'package:comics_app/common/websocket/websocket.dart';

final ws = WSService.instance;

// 入口按钮 onTap：预连接（fire-and-forget）+ 立刻跳路由
void onPrivateMessageTap() {
  ws.acquire(); // 不传 url 自动用 ConfigStore.to.configBean.chatDomain
  Get.toNamed(AppRoutes.CHAT, arguments: {'otherId': 1024});
}

// 登出 / 异地登录 / 切账号
void onLogout() {
  ws.forceDisconnect();
}
```

> `ChatLogic.onInit` 已经内置 `acquire`、`onClose` 已经内置 `release`，
> 业务侧只需关注「进入场景」「登出」两个时机。

### 6.2 监听服务端回执（按需）

```dart
ws.on(WSMt.authSuccess, (msg) => print('授权成功: $msg'));
ws.on(WSMt.authFail, (_) => print('授权失败，需要重新登录'));
ws.on(WSMt.loginAnother, (_) => ws.forceDisconnect()); // 异地登录
ws.on(WSMt.newToken, (m) {
  final newTkn = m['msg']?.toString();
  if (newTkn != null && newTkn.isNotEmpty) {
    // 持久化新 token，下次心跳会自动带上
  }
});
```

### 6.3 发送各类聊天消息

```dart
// 文本
ws.sendText(to: 1024, msg: 'hello world');

// 图片（msg 传图片 URL/Key）
ws.sendImage(to: 1024, url: '/img.png');

// 视频（duration 必填，单位秒）
ws.sendVideo(to: 1024, url: '/v.mp4', duration: 12);

// 语音（duration 必填，单位秒）
ws.sendVoice(to: 1024, url: 'https://cdn.x/a.mp3', duration: 8);
```

### 6.4 监听对端发来的聊天消息

服务端推送的 `mt` 与发送时一致（`200001~200004`），可统一订阅：

```dart
ws.on(WSMt.sendTxt, (m) {
  final record = (m['chatRecord'] as List?)?.firstOrNull;
  print('收到文本: ${record?['msg']}');
});

ws.on(WSMt.sendImg, (m) => print('收到图片: $m'));
ws.on(WSMt.sendVideo, (m) => print('收到视频: $m'));
ws.on(WSMt.sendVoice, (m) => print('收到语音: $m'));
```

### 6.5 拉取/删除聊天记录

```dart
// 拉取我和某联系人的记录（不传 contactId 则拉所有联系人维度）
ws.fetchUserRecords(contactId: '1024', pageNum: 1, pageSize: 20);

// 删除整个会话
ws.deleteRecords(contactId: '1024', bothDel: false);

// 删除指定的若干条记录
ws.deleteRecords(records: [
  {'id': 17409870988800001, 'from': '1001', 'to': '1024'},
]);

// 拉取官方推送
ws.fetchOfficialRecords(officialId: '10000');

// 批量删除联系人会话
ws.batchDeleteContacts(contactIds: ['1024', '1025']);
```

### 6.6 互动消息

```dart
// 拉取互动列表（服务端通过 mt=600018 推送）
ws.fetchInteractiveList(page: 1, pageSize: 20);
ws.on(WSMt.interactiveMsg, (m) {
  print('互动列表: ${m['interactive']}, 新增: ${m['newNum']}');
});

// 拉取互动未读数（服务端通过 mt=600019 推送）
ws.fetchInteractiveUnread();
ws.on(WSMt.interactiveUnreadNumMsg, (m) {
  print('互动未读数: ${m['newNum']}');
});

// 标记某条互动消息已读
ws.readInteractive(createTime: 1740000000000);

// 删除某条互动消息
ws.deleteInteractive(createTime: 1740000000000);
```

### 6.7 黑名单

```dart
ws.fetchBlackList(pageNum: 1, pageSize: 20);
ws.addBlack(contactId: 1024);
ws.removeBlack(contactId: 1024);
```

### 6.8 游客模式

```dart
// 游客认证
ws.authVisitor('1000001');

// 游客发文本/图片/视频/语音
ws.visitorSendText(from: 91001, to: 1024, msg: 'hi');
ws.visitorSendImage(from: 91001, to: 1024, url: 'https://.../x.png');
ws.visitorSendVideo(from: 91001, to: 1024, url: '...mp4', duration: 12);
ws.visitorSendVoice(from: 91001, to: 1024, url: '...mp3', duration: 8);

// 游客拉取聊天记录
ws.fetchVisitorRecords(visitorId: 91001);
```

### 6.9 全量消息流（订阅所有消息）

```dart
final sub = ws.messageStream.listen((data) {
  print('收到原始消息: $data');
});

// 离开页面时记得取消订阅
sub.cancel();
```

### 6.10 兜底：发送未封装的 mt

```dart
ws.sendRaw({
  'mt': 123456,
  'custom': 'value',
});
```

---

## 7. 连接生命周期（按需 + 延迟断开）

```
1) 入口按钮 onTap → ws.acquire()  ← 引用计数 +1，首次触发 connect
2) [自动] 建立连接 + 启动心跳 + 监听消息
3) [onReady] 自动 ws.authToken(UserStore token)
4) [收到 mt=600001] 业务可正常收发
5) Get.toNamed(AppRoutes.CHAT) → ChatLogic.onInit 再 acquire()（幂等）
6) 离开 ChatPage → ChatLogic.onClose → ws.release()
7) 60s 内未再 acquire → 真正 disconnect（释放 socket、心跳）
8) 60s 内又有页面 acquire → 取消 release 定时器，复用现有连接
9) 网络抖动 → 自动重连（3s/次，最多 20 次），重连成功后 onReady 自动重认证
10) ws.forceDisconnect() → 立即清零计数 + 断开（登出 / 异地登录使用）
```

> **登出 / 切换账号**：调 `ws.forceDisconnect()`；下次进聊天页 `acquire()` 会自动用新 token 重连重认证。

---

## 8. 调试建议

1. 客户端发送 / 接收都会通过 `l.d(..., tag: 'WS')` 打印（仅 Debug 模式），过滤 `WS` 日志即可定位。
2. 任何业务消息发出后未收到回执，请检查：
   - `mt` 是否在 `WSMt` 中（不在则用 `sendRaw`）；
   - 是否已先完成认证（业务消息均依赖服务端 `OnlineUserManager` 里的 uid）；
   - 必填字段（`to` / `msg` / `tkn`）是否带上，否则服务端 `MsgJsonValidity` 会返回错误并下发 `600013` 等回执。
3. 联调先用 `wscat` / `websocat` / Postman 跑通：
   ```bash
   wscat -c ws://localhost:6500/chat
   > {"mt":500002,"tkn":"YOUR_TOKEN"}
   < {"mt":600001,"msg":"授权成功","t":...}
   ```
