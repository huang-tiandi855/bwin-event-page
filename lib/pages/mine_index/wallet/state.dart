import 'package:comics_app/common/entities/mine/vip_card_model.dart';

class WalletState {
  /// 当前账户金币余额
  int coinBalance = 0;

  int selectedIndex = 0;

  bool loading = true;

  List<VipCardModel> products = <VipCardModel>[];
}
