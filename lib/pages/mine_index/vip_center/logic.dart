import 'package:comics_app/common/apis/mine_apis.dart';
import 'package:comics_app/common/entities/mine/vip_card_model.dart';
import 'package:get/get.dart';

import 'state.dart';

class VipCenterLogic extends GetxController {
  final VipCenterState state = VipCenterState();

  static const String kCarousel = 'vip_products_carousel';
  static const String kPermissions = 'vip_member_permissions';
  static const String kPay = 'vip_pay_bar';

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final list = await MineApis.getVipCardList();
    if (list.isEmpty) {
      state.products = [];
      state.listRevision++;
      state.productIndex = 0;
      _syncMemberPermissions();
      update([kCarousel, kPermissions, kPay]);
      return;
    }
    // list.sort((a, b) => (a.position ?? 0).compareTo(b.position ?? 0));
    state.products = list;
    state.listRevision++;
    if (state.initId != null) {
      final index = list.indexWhere((item) => item.id == state.initId);
      state.productIndex = index == -1 ? 0 : index;
    } else {
      state.productIndex = 0;
    }
    _syncMemberPermissions();
    update([kCarousel, kPermissions, kPay]);
  }

  /// 当前选中的商品；越界或空列表时返回 null
  VipCardModel? get selectedCard {
    final i = state.productIndex;
    if (i < 0 || i >= state.products.length) return null;
    return state.products[i];
  }

  void _syncMemberPermissions() {
    final i = state.productIndex;
    if (i < 0 || i >= state.products.length) {
      state.memberPermissions = [];
      return;
    }
    final product = state.products[i];
    state.memberPermissions =
        List<VipMemberPermissionModel>.from(product.memberPermissions);
  }

  void selectProduct(int index) {
    if (index == state.productIndex) return;
    if (index < 0 || index >= state.products.length) return;
    state.productIndex = index;
    _syncMemberPermissions();
    update([kPermissions, kPay]);
  }
}
