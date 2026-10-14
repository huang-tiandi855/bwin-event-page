import 'package:comics_app/common/routers/app_routes.dart';
import 'package:get/get.dart';

import '../../../../../common/apis/mine_apis.dart';
import 'promotion_data_state.dart';

class PromotionDataLogic extends GetxController {
  final PromotionDataState state = PromotionDataState();
  @override
  void onInit() {
    super.onInit();
    _syncIncomeListInvite();
  }

  void _syncIncomeListInvite() {
    MineApis.getIncomeListInvite().then((value) {
      state.inviteIncomeSummaryModel = value;
      update();
    });
  }

  void onTapWithdraw() {
    Get.toNamed(AppRoutes.WITH_DRAWAL,
        arguments: {'num': state.walletBalanceModel?.invitation});
  }

  void openIncomeDetail() {
    Get.toNamed(AppRoutes.AGENT_INCOME_DETAIL);
  }
}
