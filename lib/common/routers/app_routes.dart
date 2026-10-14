// ignore_for_file: constant_identifier_names

/*
对外已配置路由
/// 用于配置内部跳转
// 首页跳转，需跳到特定分类 proxinner://home_modules?moduleId=
// 首页跳转，跳到首页导航 proxinner://home_navigation_drawer
// 搜索页 proxinner://search_page
// 长视频播放页 proxinner://video_page?id=
// 排行榜页 proxinner://rank_detail
// 福利中心首页 proxinner://signin_welfare
// 福利中心首页，跳到福利任务位置 proxinner://signin_welfare_task
// 福利中心首页，跳到奖品兑换位置 proxinner://signin_welfare_reward
// 分享页 proxinner://mine_share_invite
// 用户信息设置页 proxinner://setting_center
// 会员中心页 proxinner://member_center?id=  //id：对应卡皮id
// 钱包页 proxinner://wallet
// 积分使用明细页 proxinner://signin_exchange_records
// 观看记录页 proxinner://history_record
// 我的收藏页 proxinner://mine_my_collection
// 社区首页  proxinner://post_modules?moduleId=&showPostAlert= //跳到社区showPostAlert:0 不弹发贴翻窗 1弹出发帖弹窗
// 客服聊天页面 proxinner://customer_service
// 客服（常见问题）页面 proxinner://mine_common_problem
// AI首页 proxinner://ai_modules
*/

class AppRoutes {
  static const SPLASH = '/splash'; //启动页
  static const APPLICATION_PAGE = '/applicationPage';

  static const USER_CENTER = '/userCenter'; //用户主页
  static const COMMENT_DETAILS = '/commentDetails'; //评论详情

  ///首页
  static const HOME_PAGE = '/homePage';

  /// 首页模块 — home_index（GetX 独立骨架，见 `pages/home/home_index`）
  static const HOME_INDEX_PAGE = '/homeIndexPage';

  /// 首页专题详情（`topic_more_detail`）
  static const TOPIC_MORE_DETAIL = '/topicMoreDetail';

  /// 首页排行榜二级页（`rank_detail`）
  static const RANK_DETAIL = '/rank_detail';

  /// 首页签到 / 福利（`signin_welfare`）
  static const SIGNIN_WELFARE = '/signin_welfare';

  /// 首页签到 / 查看全部签到记录
  static const SIGNIN_RECORDS = '/signinRecords';

  /// 首页签到 / 积分兑换记录
  static const SIGNIN_EXCHANGE_RECORDS = '/signin_exchange_records';

  /// 首页签到 / 代理推广数据
  static const AGENT_PROMOTION_DATA = '/agentPromotionData';

  /// 首页签到 / 代理收益明细
  static const AGENT_INCOME_DETAIL = '/agentIncomeDetail';
  static const FEATURED_PAGE = '/homePage/featured';
  static const TOPIC_PAGE = '/topicPage';
  static const ORIGINAL_TOPIC_PAGE = '/originaltopicPage';
  static const CHANNEL_PAGE = '/channelPage';
  static const SEARCH_PAGE = '/search_page';
  static const SEARCH_RESULT_PAGE = '/search_result_page';
  static const HOT_RANKING_PAGE = '/hotRankingPage';
  static const CATEGORIES_PAGE = '/categoriesPage';
  static const VIDEOTOPIC_PAGE = '/videoTopicPage';

  ///圈子
  static const HOT_TOPIC = '/hotTopic'; //热门推荐
  static const POST_DETAILS = '/postDetails'; //帖子详情
  static const GAME_DETAILS = '/gameDetails'; //游戏详情
  static const DATING_DETAILS = '/datingDetails'; //约会详情

  static const PUBLISH = '/publish';
  // static const MY_MESSAGE = '/myMessage'; //我的消息
  static const PICTURE_PREVIEW = '/picturePreview'; //图片预览
  static const PICTURE_GROUP_PREVIEW = '/PICTURE_GROUP_PREVIEW'; //图组预览

  ///福利
  static const WELFARE_DETAILS = '/welfare_details'; //福利详情

  ///书架
  static const NOVEL_DETAILS_PAGE = '/novel_details_page'; //书架详情
  static const READER = '/reader'; //小说阅读器
  static const COMIC_READER = '/comic_reader'; //漫画阅读器

  static const VIDEO_PAGE = '/video_page'; //视频详情

  static const H5_PAGE = '/h5_page'; //网页

  static const PORTRAY = '/portray_page';
  static const BILL_DETAILS = '/bill_details'; //账单详情
  static const ACCOUNT_CREDENTIALS = '/account_credentials'; //账号凭证
  static const EXCHANGE_CODE = '/exchange_code'; //兑换码
  static const PROMOTION_RECORDS = '/promotion_records'; //推广记录

  static const TAGS_DETAIL = '/tags_detail_page';
  static const TAGS_SPECIAL_DETAIL = '/tags_detail_special_page';

  static const CREATE_CENTER = '/create_center';

  /// 提现
  static const WITH_DRAWAL = '/with_drawal';

  static const UPLOAD_RULE = '/upload_rule';

  /// 视频模块-片库
  /// 短视频、短剧首页
  static const SHORT_VIDEO_MAIN = '/short_video_main';

  //意见反馈
  static const FEEDBACK = '/feedback';

  /// 加群开车（官方社群 / 商务合作）
  static const GROUPS = '/groups';

  /// 金币充值
  static const WALLET = '/wallet';

  //会员中心
  static const MEMBER_CENTER = '/member_center';

  /// 账号安全 / 账号找回（mine_index）
  static const ACCOUNT_SAFE = '/account_safe';

  /// 手机号找回
  static const ACCOUNT_SAFE_PHONE_RECOVERY = '/account_safe_phone_recovery';

  /// 扫描凭证（账号安全 / 凭证找回）
  static const ACCOUNT_SAFE_SCAN_VOUCHER = '/account_safe_scan_voucher';

  /// 设置中心（mine_index）
  static const SETTING_CENTER = '/setting_center';

  /// 设置中心 — 子页
  static const SETTING_CENTER_SELECT_AVATAR = '/setting_center_select_avatar';
  static const SETTING_CENTER_EDIT_NICKNAME = '/setting_center_edit_nickname';
  static const SETTING_CENTER_EDIT_GENDER = '/setting_center_edit_gender';
  static const SETTING_CENTER_BIND_PHONE = '/setting_center_bind_phone';
  static const SETTING_CENTER_BIND_INVITE = '/setting_center_bind_invite';

  /// 邀请分享
  static const SHARE_INVITE = '/mine_share_invite';

  /// 邀请分享 — 邀请记录
  static const MINE_INVITE_RECORD = '/mine_invite_record';

  /// 我的页 — 多 Tab 媒体列表（与全局 [HISTORY_RECORD] 等旧页路由区分）
  static const MINE_MY_COLLECTION = '/mine_my_collection';
  static const MINE_MY_PURCHASE = '/mine_my_purchase';
  static const MINE_MY_LIKES = '/mine_my_likes';
  static const MINE_INDEX_HISTORY = '/history_record';

  /// 我的页 — 我的关注（双 Tab：关注 / 粉丝）
  static const MINE_MY_FOLLOW = '/mine_my_follow';

  /// 我的页 — 常见问题（官方客服）
  static const MINE_COMMON_PROBLEM = '/mine_common_problem';

  /// 我的页 — 消息中心（我的消息）
  static const MESSAGE_CENTER = '/mine_message_center';

  /// 锁屏图案（九宫格）：默认解锁；`Get.toNamed(..., arguments: 1|2)` 设置 / 关锁前验证
  static const LOCK_SCREEN_PATTERN = '/lockScreenPattern';

  /// 简单播放器
  static const SIMPLE_PLAYER = '/simple_player';

  /// 私信聊天页（参数：`{otherId, nickName?, avatar?}`，详见 `lib/pages/common/chat`）
  static const CHAT = '/chat';

  /// AI — 高级脱衣
  static const AI_ADVANCED_UNDRESS = '/ai_advanced_undress';

  /// AI — 文生图片
  static const AI_TEXT_TO_IMAGE = '/ai_text_to_image';

  /// AI — 文生视频
  static const AI_TEXT_TO_VIDEO = '/ai_text_to_video';

  /// AI — 突破拓展（图片拓展）
  static const AI_IMAGE_EXPAND = '/ai_image_expand';

  /// AI — 图生视频
  static const AI_IMAGE_TO_VIDEO = '/ai_image_to_video';

  /// AI — 自定义
  static const AI_CUSTOM = '/ai_custom';

  /// AI — 我的作品
  static const AI_RECORD = '/ai_record';

  /// AI — 任务预估进度
  static const AI_TASK_PROGRESS = '/ai_task_progress';
}
