import 'package:comics_app/common/entities/mine/vip_card_model.dart';
import 'package:get/get.dart';

class VipCenterState {
  /// 对应接口 `product/list` 返回列表
  List<VipCardModel> products = [];

  /// 当前选中的 `products` 下标
  int productIndex = 0;

  /// 列表刷新自增，用于轮播 [ValueKey] 重建
  int listRevision = 0;

  int? initId;

  /// 当前选中商品的 [VipCardModel.memberPermissions] 快照
  List<VipMemberPermissionModel> memberPermissions = [];

  VipCenterState() {
    final dynamic rawId = Get.arguments?['id'];
    if (rawId is int) {
      initId = rawId;
    } else if (rawId != null) {
      initId = int.tryParse(rawId.toString());
    }
  }
}
