import 'package:comics_app/common/entities/sign_in/sign_in_overview_entity.dart';

/// 签到记录页 state：只装 `activation/signin/v2/overview` 返回的原始模型，
/// 不再维护 `SignRecordRewardUi` 这种把 `day / label / checked / locked` 拍平
/// 的 UI 中间结构——这几个字段都能从 [SignInRewardItemModel] 配合 entity 上的
/// [SignInChannelOverviewModel.isDayClaimed] 现算，view 直接读即可。
class SignRecordState {
  static const List<String> tabs = ['免费', '会员'];

  SignInOverviewResultModel? overview;

  bool get isVip => overview?.vip == true;

  int get freeLastingDays => overview?.free?.lastingDays ?? 0;
  int get memberLastingDays => overview?.member?.lastingDays ?? 0;

  List<SignInRewardItemModel> get freeRewards =>
      overview?.freeRewards ?? const [];
  List<SignInRewardItemModel> get memberRewards =>
      overview?.memberRewards ?? const [];

  SignInChannelOverviewModel? get freeChannel => overview?.free;
  SignInChannelOverviewModel? get memberChannel => overview?.member;
}
