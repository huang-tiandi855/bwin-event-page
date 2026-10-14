import 'package:comics_app/common/apis/mine_apis.dart';
import 'package:comics_app/common/entities/mine/vip_card_model.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/widgets/common_dialog/select_pay_method_bottom_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'state.dart';

class WalletLogic extends GetxController {
  final WalletState state = WalletState();

  VipCardModel? get selectedProduct {
    final list = state.products;
    if (list.isEmpty) return null;
    final i = state.selectedIndex.clamp(0, list.length - 1);
    return list[i];
  }

  static String? giftLabel(VipCardModel model) {
    final gift = model.gifGold;
    if (gift == null || gift <= 0) return null;
    return '赠送$gift金币';
  }

  @override
  void onInit() {
    super.onInit();
    _syncCoinBalance();
    loadProducts();
  }

  void _syncCoinBalance() {
    final user = UserStore.to.getUserInfoModel;
    state.coinBalance = user?.walletApp ?? 0;
  }

  /// 金币充值档位：`type=1` `showType=1`
  Future<void> loadProducts() async {
    state.loading = true;
    update();

    try {
      final list = await MineApis.getVipCardList(type: 1);
      list.sort((a, b) => (a.position ?? 0).compareTo(b.position ?? 0));
      state.products = list;
      if (state.selectedIndex >= state.products.length) {
        state.selectedIndex = 0;
      }
    } catch (e, st) {
      debugPrint('wallet loadProducts error: $e\n$st');
      state.products = <VipCardModel>[];
    } finally {
      state.loading = false;
      update();
    }
  }

  void selectOption(int index) {
    if (index == state.selectedIndex ||
        index < 0 ||
        index >= state.products.length) {
      return;
    }
    state.selectedIndex = index;
    update();
  }

  void onTapUnlock() {
    final card = selectedProduct;
    if (card == null) return;
    selectPayMethodBottomSheet(card: card);
  }
}
