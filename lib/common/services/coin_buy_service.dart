import 'package:comics_app/common/widgets/common_dialog/coin_dialog.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/store/config.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/store/wallet.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/values/enum.dart';
import 'package:comics_app/common/widgets/memberPaying.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import '../http/base_resp_bean.dart';

class CouponException implements Exception {
  final String message;

  CouponException(this.message);

  @override
  String toString() {
    return message;
  }
}

class CoinNotEnoughException implements Exception {
  final String message;

  CoinNotEnoughException(this.message);

  @override
  String toString() {
    return message;
  }
}

class CoinBuyService {
  static Future<bool?> showVipDialog({
    required String id,
    ProductType productType = ProductType.video,
    bool canUseCoupon = true,
  }) {
    return openMemberPaying(
      isShowCoupon: canUseCoupon,
      id: id,
      productType: productType.value,
    ).then((value) {
      return value == PaySuccess.exchangeSuccessFullly;
    });
  }

  static Future<bool?> showDialog({
    required String id,
    required int coin,
    ProductType productType = ProductType.video,
    String? title,
    bool canUseCoupon = true,
  }) {
    return showCoinDialog<bool>(
      Get.overlayContext!,
      coin: coin,
      canUseCoupon: canUseCoupon,
      onPayCoin: (useCoupon) {
        CoinBuyService.productBuy(
          productId: id,
          productType: productType,
          useCoupon: useCoupon,
        ).then((value) {
          if (value && title != null) {
            CoinBuyService.trackBuyEvent(
              productType: ProductType.video,
              productId: id,
              title: title,
              coin: coin,
            );
          }
          Get.back(result: value);
        }).catchError((err) {
          Get.back(result: false);
          if (err is CoinNotEnoughException) {
            Get.toNamed(AppRoutes.MEMBER_CENTER,
                arguments: {"initialIndex": 1});
          }
        });
      },
    );
  }

  static Future<bool> productBuy({
    required String productId,
    ProductType productType = ProductType.video,
    bool useCoupon = false,
    bool showLoading = true,
  }) async {
    if (useCoupon && UserStore.to.userRightWatchReadCouponList.isEmpty) {
      showToast(msg: "观阅券不足");
      throw CouponException('观阅券不足');
    }
    if (showLoading) {
      SmartDialog.showLoading();
    }
    try {
      final resp = BaseRespBean(0);
      // await CircleApi.productBuy({
      //   'productID': productId,
      //   'productType': productType.value,
      //   "couponId":
      //       useCoupon ? UserStore.to.userRightWatchReadCouponList[0].id : null,
      // });

      if (resp.isSuccess) {
        if (useCoupon) {
          showToast(msg: "观阅券使用成功");
          UserStore.to.refreshRights();
        } else {
          showToast(msg: "购买成功");
          WalletStore.to.refreshWallet();
        }
      } else {
        if (resp.code == 8000) {
          throw CoinNotEnoughException("余额不足");
        } else {
          showToast(msg: resp.tip ?? "购买失败");
        }
      }
      return resp.isSuccess;
    } catch (e) {
      rethrow;
    } finally {
      if (showLoading) {
        SmartDialog.dismiss();
      }
    }
  }

  static void trackBuyEvent({
    required ProductType productType,
    required String productId,
    required String title,
    required int coin,
  }) {
    ConfigStore.to.trackData(productType.name, {
      'id': productId,
      '标题': title,
      '类型': productType.name,
      '价格': coin,
    });
  }
}

enum ProductType {
  video(1);

  const ProductType(this.value);
  final int value;

  String get name {
    switch (this) {
      case video:
        return '短视频';
    }
  }
}
