/// 错误编码
///
/// **文档业务码**为字符串（与网关返回 `code` 一致），见各 `DOC_*` 常量。
/// **客户端本地码**（网络异常、响应形态异常等）为 `int`，勿与文档业务码混淆。
// ignore_for_file: constant_identifier_names

class Code {
  // ---------------------------------------------------------------------------
  // 接口文档 —「公共 - 错误码」（语义以后端文案为准）
  // ---------------------------------------------------------------------------

  /// 0000 — 成功
  static const String SUCCESS_DOC = '0000';

  /// 1001 — 系统错误
  static const String DOC_SYSTEM_ERROR = '1001';

  /// 1002 — VIP 播放达到上限
  static const String DOC_VIP_PLAY_LIMIT = '1002';

  /// 1003 — 普通用户播放达到上限
  static const String DOC_NORMAL_USER_PLAY_LIMIT = '1003';

  /// 1005 — 无数据
  static const String DOC_NO_DATA = '1005';

  /// 1006 — 手机号已存在不可重复绑定
  static const String DOC_MOBILE_ALREADY_EXISTS = '1006';

  /// 1007 — 密码或验证码有误
  static const String DOC_PASSWORD_OR_VERIFY_WRONG = '1007';

  /// 1008 — 请购买VIP可畅享无限观影下载视频等多种特权
  static const String DOC_NEED_VIP_FOR_FEATURES = '1008';

  /// 1010 — VIP用户下载限制，请明天再试
  static const String DOC_VIP_DOWNLOAD_LIMIT_NEXT_DAY = '1010';

  /// 1011 — 普通用户下载限制，请明天再试
  static const String DOC_NORMAL_DOWNLOAD_LIMIT_NEXT_DAY = '1011';

  /// 1012 — 游客播放达到上限
  static const String DOC_GUEST_PLAY_LIMIT = '1012';

  /// 1019 — Token过期
  static const int DOC_TOKEN_EXPIRED = 1019;

  /// 1031 — 参数错误
  static const String DOC_PARAM_ERROR = '1031';

  /// 1032 — Token为空
  static const int DOC_TOKEN_EMPTY = 1032;

  /// 1033 — JwtToken为空
  static const int DOC_JWT_TOKEN_EMPTY = 1033;

  /// 1034 — JwtToken过期
  static const int DOC_JWT_TOKEN_EXPIRED = 1034;

  /// 1035 — 金币不足
  static const String DOC_INSUFFICIENT_GOLD = '1035';

  /// 1036 — 请稍后再试
  static const String DOC_TRY_AGAIN_LATER = '1036';

  /// 1037 — 未绑定银行卡
  static const String DOC_BANK_CARD_NOT_BOUND = '1037';

  /// 1038 — 未支付
  static const String DOC_NOT_PAID = '1038';

  /// 1039 — 不允许修改
  static const String DOC_MODIFY_NOT_ALLOWED = '1039';

  /// 1040 — 未授权
  static const String DOC_UNAUTHORIZED = '1040';

  /// 1041 — 用户状态码错误
  static const String DOC_USER_STATE_ERROR = '1041';

  /// 1042 — 评论次数超过限制
  static const String DOC_COMMENT_COUNT_LIMIT = '1042';

  /// 1043 — 评论字数超过限制
  static const String DOC_COMMENT_LENGTH_LIMIT = '1043';

  /// 1044 — 充值VIP后才可以进行评论
  static const String DOC_COMMENT_REQUIRES_VIP = '1044';

  /// 1045 — 上传头像失败
  static const String DOC_AVATAR_UPLOAD_FAILED = '1045';

  /// 1046 — 评论包含敏感词汇
  static const String DOC_COMMENT_SENSITIVE_WORD = '1046';

  /// 1047 — 评论中的字母超过限制
  static const String DOC_COMMENT_LETTER_LIMIT = '1047';

  /// 1048 — 评论中数字超过限制
  static const String DOC_COMMENT_DIGIT_LIMIT = '1048';

  /// 1049 — 类型重复
  static const String DOC_TYPE_DUPLICATE = '1049';

  /// 1050 — 无目标服务器配置
  static const String DOC_NO_TARGET_SERVER_CONFIG = '1050';

  /// 1051 — 不可重复添加机器人
  static const String DOC_BOT_DUPLICATE = '1051';

  /// 1052 — 业务名不可重复
  static const String DOC_BUSINESS_NAME_DUPLICATE = '1052';

  /// 1053 — 至少要关联[全局分类]和[探索分类]中的一个
  static const String DOC_CATEGORY_ASSOCIATION_REQUIRED = '1053';

  /// 1054 — 昵称不可重复
  static const String DOC_NICKNAME_DUPLICATE = '1054';

  /// 1055 — 昵称只能由中文数字和字母组成
  static const String DOC_NICKNAME_FORMAT_INVALID = '1055';

  /// 1056 — 暂时没有客服席位
  static const String DOC_NO_CUSTOMER_SERVICE_SEAT = '1056';

  /// 1057 — 不能重复绑定银行卡
  static const String DOC_BANK_CARD_BIND_DUPLICATE = '1057';

  /// 1058 — 数据无效
  static const String DOC_DATA_INVALID = '1058';

  /// 1059 — 数据过期
  static const String DOC_DATA_EXPIRED = '1059';

  /// 1060 — 已经使用
  static const String DOC_ALREADY_USED = '1060';

  /// 1061 — 标签不可为空
  static const String DOC_TAG_REQUIRED = '1061';

  /// 1062 — 超过限制
  static const String DOC_LIMIT_EXCEEDED = '1062';

  /// 1063 — 游戏流水不足
  static const String DOC_GAME_TURNOVER_INSUFFICIENT = '1063';

  /// 1064 — 已经提交，等待审核生效
  static const String DOC_PENDING_AUDIT = '1064';

  /// 1065 — 请升级新版本
  static const String DOC_UPGRADE_REQUIRED = '1065';

  /// 1066 — 请绑定手机号
  static const String DOC_BIND_MOBILE_REQUIRED = '1066';

  /// 1067 — 不允许操作，请联系客服
  static const String DOC_OPERATION_NOT_ALLOWED_CONTACT_SERVICE = '1067';

  /// FAT10001 — 获取支付二维码失败，请稍后重试。
  static const String DOC_FAT_PAY_QR_FAILED = 'FAT10001';

  /// FAT10002 — 验证码错误
  static const String DOC_FAT_VERIFY_CODE_WRONG = 'FAT10002';

  /// FAT10003 — 修改账户信息失败
  static const String DOC_FAT_ACCOUNT_UPDATE_FAILED = 'FAT10003';

  /// FAT10004 — 账户不存在
  static const String DOC_FAT_ACCOUNT_NOT_FOUND = 'FAT10004';

  /// FAT10005 — 手机号码已经存在
  static const String DOC_FAT_MOBILE_EXISTS = 'FAT10005';

  /// FAT20001 — 未找到详情信息
  static const String DOC_FAT_DETAIL_NOT_FOUND = 'FAT20001';

  /// CMS20001 — 未找到第三方视频信息
  static const String DOC_CMS_THIRD_VIDEO_NOT_FOUND = 'CMS20001';

  /// CMS20002 — 找到第三方视频信息的数量与需要导入的数量不一致
  static const String DOC_CMS_THIRD_VIDEO_COUNT_MISMATCH = 'CMS20002';

  /// SMS10001 — 手机号频繁发送短信
  static const String DOC_SMS_RATE_LIMIT = 'SMS10001';

  /// SMS10002 — 短信通道不可用
  static const String DOC_SMS_CHANNEL_UNAVAILABLE = 'SMS10002';

  // ---------------------------------------------------------------------------
  // 客户端本地码（非文档；不入后端错误码表）
  // ---------------------------------------------------------------------------

  /// 网络异常（客户端）
  static const int NETWORK_ERROR = 2001;

  /// 网络超时
  static const int NETWORK_TIMEOUT = 2002;

  /// 无网络
  static const int LOCAL_NO_NETWORK = 2003;

  /// 取消请求
  static const int LOCAL_CANCEL_REQUEST = 2004;

  /// 响应体非预期形态（非 Map/String JSON）；**勿占用文档 1001（系统错误）**
  static const int LOCAL_RESPONSE_SHAPE_ERROR = 2005;

  /// 历史占位：曾与文档 `1001` 数值重合，已迁移至 [LOCAL_RESPONSE_SHAPE_ERROR]
  @Deprecated('Use Code.LOCAL_RESPONSE_SHAPE_ERROR')
  static const int PARSE_DATE_ERROR = LOCAL_RESPONSE_SHAPE_ERROR;

  /// 账号被封禁（历史服务端约定，文档表未列）
  static const int ACCOUNT_INVISIBLE = 1000;

  /// 禁言（历史服务端约定，文档表未列）
  static const int MUTE = 7005;

  /// Token 异常（历史客户端分类码，文档请用 [DOC_TOKEN_EMPTY] / [DOC_TOKEN_EXPIRED] 等）
  static const int TOKEN_ABNORMAL = 5009;

  /// 验证码 1 分钟内重复（历史约定）
  static const int VERIFY_CODE_REPEAT = 5007;

  /// 重放请求
  static const int REPLAY_ATTACK = 4009;

  /// 兑换失败（历史服务端约定，文档表未列）
  static const int REDEMPTION_FAILED = 22001;

  /// 是否与文档业务成功码 [SUCCESS_DOC] 一致（用于原始 Map / 动态 JSON 的 `code` 字段）
  static bool isDocSuccess(dynamic raw) {
    if (raw == null) return false;
    return raw.toString().trim() == SUCCESS_DOC;
  }

  /// `code` 是否与某条文档业务码相同（忽略首尾空白）
  static bool isDocCode(dynamic raw, String docCode) {
    if (raw == null) return false;
    return raw.toString().trim() == docCode;
  }

  static errorHandleFunction(code, message) {
    return message;
  }
}
