import 'package:comics_app/common/entities/sign_in/points_exchange_entity.dart';
import 'package:comics_app/common/entities/sign_in/sign_in_overview_entity.dart';
import 'package:comics_app/common/entities/sign_in/welfare_task_entity.dart';

/// 签到页 state：只装接口模型原文 + 页面级 UI 状态，不再做派生包装。
///
/// 之前这里维护了 `SigninRewardCellUi / SigninMemberDayUi / SigninTaskUi /
/// SigninExchangeUi` 4 个 UI 中间结构。`SigninExchangeUi` 完全没人用；其它三
/// 个本质只是缓存 [SignInRewardItemModel.displayLabel] /
/// [SignInChannelOverviewModel.isDayClaimed] 等几个**已经下沉到 entity** 的
/// getter 结果，view 拿原始接口对象现算即可，省一遍 map / copy。
class SigninState {
  SigninState();

  String userName = '';
  String? userPortrait;
  int viewCount = 0;

  /// 0 福利任务 1 积分兑换
  int welfareSegment = 0;

  static const String avatarPlaceholder =
      'https://i.pinimg.com/originals/0b/75/7c/0b757c02ace9a69e1959f1ce6273b74b.jpg';

  /// 签到总览（`activation/signin/v2/overview`）
  SignInOverviewResultModel? overview;

  /// 福利中心（`activation/welfare/center`）—— 含积分余额 + 邀请数 + 任务列表
  WelfareTaskCenterModel? welfareCenter;

  /// 积分兑换商品（`activation/points/product/list`）
  List<PointsExchangeProductModel> exchangeItems = const [];

  // ---------------------------------------------------------------------------
  // 下面这些 getter 只是给 view 一个更短的读法，所有数据仍走原始接口字段。
  // ---------------------------------------------------------------------------

  /// 连续签到天数（免费通道，`free.lastingDays`）。
  int get consecutiveDays => overview?.free?.lastingDays ?? 0;

  /// 是否会员（`overview.vip`）。
  bool get isMember => overview?.vip == true;

  /// 我的积分（`welfareCenter.myPoints`）。
  int get myPoints => welfareCenter?.myPoints ?? 0;

  /// 累计邀请人数（`welfareCenter.inviteCount`）。
  int get inviteCount => welfareCenter?.inviteCount ?? 0;

  /// 福利任务列表（`welfareCenter.tasks`）。
  List<WelfareTaskItemModel> get welfareTasks =>
      welfareCenter?.tasks ?? const [];
}
