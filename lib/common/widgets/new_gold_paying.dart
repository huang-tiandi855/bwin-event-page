import 'package:comics_app/common/apis/acg_api.dart';
import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/entities/module_detail_model/content_model.dart';
import 'package:comics_app/common/utils/const.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import '../../generated/assets.dart';
import '../http/base_resp_bean.dart';
import '../routers/app_routes.dart';
import '../store/event_tracking_manager.dart';
import '../store/wallet.dart';
import '../utils/toast_util.dart';
import '../values/enum.dart';

Future openNewGoldBeanPaying(
    {required AllMediaInfoModel info,
    required int currentIndex,
    bool isShowCoupon = true,
    int? productType,
    bool isSingleBuy = false,
    bool isFullBuy = false,
    bool isnovelOrComic = false}) async {
  var res = await Get.bottomSheet(NewGoldBeanPaying(
    isShowCoupon: isShowCoupon,
    productType: productType,
    isnovelOrComic: isnovelOrComic,
    info: info,
    currentIndex: currentIndex,
    isSingleBuy: info.sellType == 0 || isSingleBuy,
    isFullBuy:  isFullBuy || info.kind == KindConst.NOVELKIND,
  ));
  return res ?? false;
}

class NewGoldBeanPaying extends StatelessWidget {
  final bool isShowCoupon;
  final AllMediaInfoModel info;

  final bool? isnovelOrComic;
  final int currentIndex;
  final int? productType; //产品类型
  final bool isSingleBuy;
  final bool isFullBuy;
  NewGoldBeanPaying(
      {Key? key,
      required this.isShowCoupon,
      this.productType,
      this.isnovelOrComic,
      required this.info,
      required this.currentIndex,
      this.isSingleBuy = false,
      this.isFullBuy = false})
      : super(key: key);
  var total = (WalletStore.to.getWalletModel!.amount! + WalletStore.to.getWalletModel!.income!);
  @override
  Widget build(BuildContext context) {
    var title = info.title ?? "";
    ContentModel? currentInfo = info.contents[currentIndex];
    return Container(
      padding: EdgeInsets.only(left: 0.w, right: 0.w, bottom: 0),
      decoration: ShapeDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(8)))),
      child: Container(
        width: 1.sw,
        height: 1.sw,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: const ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
            colors: [Colors.white, Colors.white],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
                onTap: () => Get.back(),
                child: Image.asset(
                  Assets.acgCloseIcon,
                  width: 18,
                  height: 18,
                )),
            12.verticalSpace,
            Row(
              children: [
                CustomImage(
                  url: info.verticalCover ?? info.horizontalCover,
                  width: 77,
                  height: 112,
                  borderRadius: BorderRadius.circular(10),
                  widthAndHeightAdaptive: false,
                ),
                8.horizontalSpace,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    10.verticalSpace,
                    Text(
                      '第${currentInfo.episodeNumber ?? 1}集',
                      style: const TextStyle(color: Color(0xff777777), fontSize: 10, fontWeight: FontWeight.w400),
                    ),
                  ],
                )
              ],
            ),
            10.verticalSpace,
            if (isFullBuy != true) ...[
              10.verticalSpace,
              itemWidget(isSingleBuy ? "本集价格":"单集价格", "${currentInfo.price ?? 0}"),
            ],
            if (isSingleBuy != true) ...[10.verticalSpace, itemWidget("全集价格", "${info.price ?? 0}")],
            10.verticalSpace,
            itemWidget("我的金豆", "$total"),
            10.verticalSpace,
            if (isFullBuy == true || isSingleBuy == true)
              GestureDetector(
                onTap: () {
                  if (isFullBuy) {
                    openBuy(productId: info.id ?? "");
                  } else {
                    openBuy(productId: info.id ?? "", chatId: currentInfo.id ?? "");
                  }
                },
                child: Container(
                  height: 120.w,
                  width: 1.sw,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      image: DecorationImage(image: AssetImage(Assets.acgNovalDetialBg), fit: BoxFit.fitWidth)),
                  child: Text(isFullBuy ? "全集购买" : "单集购买",
                      style: TextStyle(fontSize: 18.sp, color: const Color(0xffB09FD9), fontWeight: FontWeight.w900)),
                ),
              )
            else
              Container(
                width: 1.sw,
                height: 78.w,
                decoration: const BoxDecoration(
                    image: DecorationImage(image: AssetImage(Assets.acgGoldBuyBg), fit: BoxFit.fill)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (total < currentInfo.price!) {
                          Get.toNamed(AppRoutes.MEMBER_CENTER, arguments: {"initialIndex": 1})?.then((value) {});
                          return;
                        }
                        await openBuy(productId: info.id!);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: const Text(
                        '全集购买',
                        style: TextStyle(color: Color(0xffB09FD9), fontSize: 14, fontWeight: FontWeight.w900),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        if (total < currentInfo.price!) {
                          Get.toNamed(AppRoutes.MEMBER_CENTER, arguments: {"initialIndex": 1})?.then((value) {});
                          return;
                        }
                        await openBuy(chatId: info.contents[currentIndex].id, productId: info.id!);
                      },
                      child: const Text(
                        '单集购买',
                        style: TextStyle(color: Color(0xffB09FD9), fontSize: 14, fontWeight: FontWeight.w900),
                      ),
                    )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget itemWidget(String title, String coin) {
    return SizedBox(
        width: 1.sw,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                Image.asset(
                  Assets.pngGoldCoin,
                  width: 14,
                ),
                10.horizontalSpace,
                Text(
                  coin,
                  style: const TextStyle(color: Color(0xffF2990E), fontSize: 14, fontWeight: FontWeight.w500),
                )
              ],
            )
          ],
        ));
  }

  Future<void> openBuy({String? chatId, required String productId}) async {
    SmartDialog.showLoading();
    BaseRespBean baseRespBean =
        await ACGApi.productNewBuy(productID: productId, chapterID: chatId, productType: productType);
    EventTrackingManager().addVideoVipGraphicss(chatId ?? "", currentIndex.toString(), GraphicsType.coin);
    SmartDialog.dismiss();
    if (baseRespBean.isSuccess) {
      showToast(msg: "购买成功");
      if(chatId != null) {
        Get.back(result: PaySuccess.successfulPurchase);
      }else{
        Get.back(result: PaySuccess.successfulAllEsp);
      }
      WalletStore.to.refreshWallet();
    } else if (baseRespBean.code == 8000) {
      Get.back();
      Get.toNamed(AppRoutes.MEMBER_CENTER, arguments: {"initialIndex": 1});
    } else {
      showToast(msg: '${baseRespBean.tip}');
    }
  }
}
