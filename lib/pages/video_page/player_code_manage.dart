/// 长视频详情接口返回的播放鉴权 code。
///
/// 路由总览：
/// - [nonMember] (1008) → 「开通会员」弹窗 / 浮层
///   ([VipPlayerOverlay] / [ShortVideoAuthOverlay])
/// - [noPay]     (1038) → 「金币付费」浮层
///   ([GoldPlayerOverlay] / [ShortVideoGoldOverlay])；
///   左按钮调用 [MediaApi.videoGoldPay] 进行扣费
///
/// **注意 1035（[notEnoughGold]，金币不足）只会从 [MediaApi.videoGoldPay]
/// 这一支付接口返回，详情接口 [MediaApi.getMediaInfo] 永远不会返回它。**
/// 因此「金币不足」是支付过程中的临时态，由长 / 短视频 logic 在收到 1035
/// 时把浮层切换为「金币不足」形态展示（标题改成「金币不足」、左按钮改为
/// 「去充值」跳钱包），状态本身不挂在 [MediaInfo.code] 上。
class PlayerCodeManage {
  const PlayerCodeManage._();

  /// 未授权。
  static const int unauth = 1040;

  /// 非会员普通用户播放限制。
  static const int userLimitPlay = 1003;

  /// 非会员。
  static const int nonMember = 1008;

  /// 金币不足。仅 [MediaApi.videoGoldPay] 会返回，详情接口不会。
  static const int notEnoughGold = 1035;

  /// 未支付。
  static const int noPay = 1038;

  /// 详情接口可能返回的鉴权码集合（不含 [notEnoughGold]，理由见 class 注释）。
  static const Set<int> authCodes = <int>{
    unauth,
    userLimitPlay,
    nonMember,
    noPay,
  };

  static bool isAuthCode(int? code) => code != null && authCodes.contains(code);

  /// 可正常播放（非鉴权拦截码）。
  static bool canPlay(int? code) => !isAuthCode(code);

  /// 是否走「开通会员」弹窗 / 浮层。仅 1008（[nonMember]）。
  static bool requiresMemberPay(int? code) => code == nonMember;

  /// 是否走「金币付费」弹窗 / 浮层。仅 1038（[noPay]）。
  ///
  /// 1035 的「金币不足」形态由支付动作触发，不通过详情 code 派生，
  /// 详见 class 注释。
  static bool requiresGoldPay(int? code) => code == noPay;

  static String message(int? code) {
    switch (code) {
      case unauth:
        return '未授权';
      case userLimitPlay:
        return '非会员普通用户播放限制';
      case nonMember:
        return '非会员';
      case notEnoughGold:
        return '金币不足';
      case noPay:
        return '未支付';
      default:
        return '';
    }
  }
}
