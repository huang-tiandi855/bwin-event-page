/// WebSocket 消息号（mt）常量集合。
///
/// 与文档 `EChatSendMessageTypeEnum` / `EChatReceiveMessageTypeEnum` /
/// `EUserSendMessageTypeEnum` / `EUserReceiveMessageTypeEnum` /
/// `VisitorMessageTypeEnum` / `EUserBlackTypeEnum` /
/// `EUserMessageRecordTypeEnum` / `EVisMessageRecordTypeEnum` 一一对应。
class WSMt {
  WSMt._();

  // -------- 200xxx: 客户端 → 服务端 用户聊天 --------
  static const int sendTxt = 200001;
  static const int sendImg = 200002;
  static const int sendVideo = 200003;
  static const int sendVoice = 200004;

  // -------- 400xxx: 客户端 → 服务端 游客聊天 --------
  static const int visitorTxt = 400001;
  static const int visitorImg = 400002;
  static const int visitorVideo = 400003;
  static const int visitorVoice = 400004;

  // -------- 500xxx: 客户端 → 服务端 用户系统（认证 / 心跳 / 互动） --------
  static const int authToken = 500002;
  static const int heartbeat = 500003;
  static const int authVisitor = 500005;
  static const int interactiveList = 500006;
  static const int interactiveRead = 500007;
  static const int interactiveUnreadCount = 500008;
  static const int interactiveDel = 500009;

  // -------- 600xxx: 服务端 → 客户端 用户系统（认证回执 / 通知） --------
  static const int authSuccess = 600001;
  static const int authFail = 600002;
  static const int offline = 600003;
  static const int success = 600005;
  static const int unAuth = 600006;
  static const int loginAnother = 600007;
  static const int sendFail = 600008;
  static const int noMore = 600009;
  static const int timeShort = 600010;
  static const int sensitive = 600011;
  static const int notVip = 600012;
  static const int paramErr = 600013;
  static const int targetErr = 600014;
  static const int newToken = 600015;
  static const int hitBlack = 600016;
  static const int forbidden = 600017;
  static const int interactiveMsg = 600018;
  static const int interactiveUnreadNumMsg = 600019;

  // -------- 700xxx: 黑名单 --------
  static const int blackList = 700001;
  static const int blackRemove = 700002;
  static const int blackAdd = 700003;

  // -------- 800xxx: 用户聊天记录 --------
  static const int recordUser = 800001;
  static const int recordDel = 800002;
  static const int recordOfficial = 800003;
  static const int recordBatchDel = 800004;

  // -------- 900xxx: 游客聊天记录 --------
  static const int recordVisitor = 900001;
}
