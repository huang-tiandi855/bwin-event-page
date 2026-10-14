///统一存储一些静态变量d
class VariableConfig {
  ///金币充值列表
  // static List<RechargeTypeModel>? rechargeType;

  // ///果币充值列表
  // static List<RechargeTypeModel>? rechargeNakeChatType;

  // ///已经播放过的视频
  // static List<LocalVideoModel>? playedVideoList = [];

  ///视频密
  static dynamic secContent;

  ///token异常弹窗
  static bool onMobileLoginView = false;

  static int? totalWatch;

  static String refreshPreSaleCountDownTime = "refreshPreSaleCountDownTime";

  static String refreshMinePage = "refreshMinePage";

  static String closeFloatingCountDownTime = "closeFloatingCountDownTime";

  static bool isNeedCloseCountDownTimeFloating = false;

  static int? sendMsgPrice;

  static String? packAgeName = "";

  static bool isComporessImage = false;

  static bool scrolPositionViewListen = false;

  ///视频详情页滑动到撸点
  static String scrollPositionToLD = "scrollPositionToLD";

  static String alreadySign = "alreadySign";

  static String shortVideoRecord = "shortVideoRecord";

  static String listenJumpToImagesMorePage = "listenJumpToImagesMorePage";

  static bool isNeedJumoToCommunity = false;
  static String? isNeedJumoToCommunityId;

  static String notifyMyCollectToastShow = "notifyMyCollectToastShow";

  static String lockScreen = "lockScreen";

  static String lockScreenPassword = "lockScreenPassword";

  static bool isClickAppCenter = false;

  // static ModuleDetailModelAllSection? rankingDataModel;
}
