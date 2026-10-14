import 'package:get/get.dart';

import '../../../../../common/entities/mine/invite_income_summary_model.dart';
import '../../../../../common/entities/wallet_balance_model.dart';

class PromotionDataState {
  WalletBalanceModel? walletBalanceModel;
  InviteIncomeSummaryModel? inviteIncomeSummaryModel;

  PromotionDataState() {
    walletBalanceModel = Get.arguments?['model'];
  }
}
