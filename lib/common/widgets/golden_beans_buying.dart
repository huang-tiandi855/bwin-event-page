import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/store/event_tracking_manager.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/widgets/common_dialog/YJLoadingDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../store/wallet.dart';
import '../values/enum.dart';

Future openGoldenBeansBuying(
    {bool isShowCoupon = false,
    String? title,
    required String id,
    required int price,
    required int productType,
    int? episode,
    bool? isComic,
    String? chapId,
    bool? isShortVideo}) async {
  // var res = await Get.bottomSheet(BeansBuying(
  //     isShowCoupon: isShowCoupon,
  //     price: price,
  //     id: id,
  //     episode: episode,
  //     isComic: isComic,
  //     isShortVideo: isShortVideo,
  //     productType: productType,
  //     title: title ?? ''));
  var res = await Get.dialog(Dialog(
      child: BeansBuying(
          isShowCoupon: isShowCoupon,
          price: price,
          id: id,
          episode: episode,
          isComic: isComic,
          isShortVideo: isShortVideo,
          productType: productType,
          chapId: chapId,
          title: title ?? '')));
  return res ?? false;
}

class BeansBuying extends StatefulWidget {
  final bool isShowCoupon; //是否显示观阅券
  final String id; //媒体id
  ///动漫17    //漫画 小说18    //cos19    //真人21  //禁播22  ///写真24   ///图集 短视频 1
  final int productType; //产品类型
  final int price; //金额
  final String title; //标题

  int? episode;

  bool? isComic;
  bool? isShortVideo;
  bool? isAvtarFrame;
  String? chapId;
  BeansBuying(
      {Key? key,
      required this.isShowCoupon,
      required this.id,
      required this.productType,
      required this.price,
      required this.title,
      this.episode,
      this.isComic,
      this.isShortVideo,
      this.isAvtarFrame,
      this.chapId})
      : super(key: key);

  @override
  State<BeansBuying> createState() => _BeansBuyingState();
}

class _BeansBuyingState extends State<BeansBuying> {
  @override
  Widget build(BuildContext context) {
    int watchCount = UserStore.to.userRightWatchReadCouponList.length;

    return Container(
      padding: EdgeInsets.only(left: 0.w, right: 0.w, bottom: 0),
      decoration: ShapeDecoration(
          color: Colors.black.withOpacity(0.4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
      child: Container(
        width: 1.sw,
        height: 1.sw,
        decoration: const ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
            colors: [Colors.white, Colors.white],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              '金豆解锁',
              style: TextStyle(
                color: const Color(0xFF333333),
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            Opacity(
              opacity: 0.10,
              child: Container(
                width: 296,
                height: 1,
                decoration: const BoxDecoration(color: Color(0xFF333333)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '您只需花费 ',
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  widget.price.toString(),
                  style: TextStyle(
                    color: const Color(0xFFFC4162),
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '  金豆',
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Text(
              '即可解锁继续查看',
              style: TextStyle(
                color: const Color(0xFF333333),
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.SHARE_INVITE);
                    },
                    child: Container(
                      width: 124.w,
                      height: 37.w,
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF5F5F5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x7FAEAEC0),
                            blurRadius: 20,
                            offset: Offset(5, 5),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color(0xFFFFFFFF),
                            blurRadius: 20,
                            offset: Offset(-5, -5),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: const Text(
                        "邀请好友",
                        style: TextStyle(
                          color: Color(0xFFB09FD9),
                          fontSize: 14,
                          fontFamily: 'Dream',
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )),
                GestureDetector(
                  onTap: () async {
                    if (widget.id.isEmpty) {
                      showToast(msg: "数据有误，购买失败");
                      return;
                    }
                    try {
                      if (mounted) {
                        YJLoadingDialog.show(context);
                      }
                      BaseRespBean baseRespBean = BaseRespBean(0);
                      // BaseRespBean baseRespBean =
                      //     await CircleApi.productBuy(data);

                      EventTrackingManager().addVideoVipGraphicss(widget.id, widget.title, GraphicsType.coin);

                      if (baseRespBean.isSuccess) {
                        Get.back(result: PaySuccess.successfulPurchase);
                        showToast(msg: "购买成功");
                        WalletStore.to.refreshWallet();

                        ///动漫17    //漫画 小说18    //cos19    //真人21  //禁播22  ///写真24   ///图集 短视频 1
                        switch (widget.productType) {
                          case 17:
                            Map map = {};

                            map["标题"] = widget.title;
                            map["id"] = widget.id;
                            map["类型"] = "动漫";
                            map["价格"] = widget.price;
                            map["集数"] = "第${widget.episode!}集";

                            ConfigStore.to.trackData('购买动漫', map);

                            break;

                          case 18:
                            Map map = {};

                            map["标题"] = widget.title;
                            map["id"] = widget.id;
                            map["类型"] = widget.isComic! ? "漫画" : "小说";
                            map["价格"] = widget.price;

                            ConfigStore.to.trackData(widget.isComic! ? "购买漫画" : "购买小说", map);

                            break;

                          case 19:
                            Map map = {};

                            map["标题"] = widget.title;
                            map["id"] = widget.id;
                            map["类型"] = "COS";
                            map["价格"] = widget.price;
                            map["集数"] = "第${widget.episode!}集";

                            ConfigStore.to.trackData('购买COS视频', map);

                            break;

                          case 21:
                            Map map = {};

                            map["标题"] = widget.title;
                            map["id"] = widget.id;
                            map["类型"] = "真人";
                            map["价格"] = widget.price;
                            map["集数"] = "第${widget.episode!}集";

                            ConfigStore.to.trackData('购买真人视频', map);

                            break;

                          case 22:
                            Map map = {};

                            map["标题"] = widget.title;
                            map["id"] = widget.id;
                            map["类型"] = "禁播";
                            map["价格"] = widget.price;
                            map["集数"] = "第${widget.episode!}集";

                            ConfigStore.to.trackData('购买禁播视频', map);

                            break;

                          case 24:
                            Map map = {};

                            map["标题"] = widget.title;
                            map["id"] = widget.id;
                            map["类型"] = "写真";
                            map["价格"] = widget.price;

                            ConfigStore.to.trackData('购买写真', map);

                            break;

                          case 1:
                            Map map = {};

                            map["标题"] = widget.title;
                            map["id"] = widget.id;
                            map["类型"] = widget.isShortVideo! ? "短视频" : "图集";
                            map["价格"] = widget.price;

                            ConfigStore.to.trackData(widget.isShortVideo! ? "购买短视频" : "购买图集", map);

                            break;
                        }

                        return;
                      } else if (baseRespBean.code == 8000) {
                        Get.back();

                        Get.toNamed(AppRoutes.MEMBER_CENTER, arguments: {"initialIndex": 1});
                      }
                    } finally {
                      if (mounted) {
                        YJLoadingDialog.dismiss(context);
                      }
                    }
                  },
                  child: Container(
                    width: 124.w,
                    height: 37.w,
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF5F5F5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x7FAEAEC0),
                          blurRadius: 20,
                          offset: Offset(5, 5),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Color(0xFFFFFFFF),
                          blurRadius: 20,
                          offset: Offset(-5, -5),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: const Text(
                      "立即支付",
                      style: TextStyle(
                        color: Color(0xFFB09FD9),
                        fontSize: 14,
                        fontFamily: 'Dream',
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: widget.isShowCoupon && watchCount > 0 ? true : false,
              child: GestureDetector(
                onTap: () async {
                  if (watchCount == 0) {
                    showToast(msg: "观阅券不足");
                    return;
                  }
                  if (widget.id.isEmpty) {
                    showToast(msg: "数据有误，使用失败");
                    return;
                  }
                  try {
                    if (mounted) {
                      YJLoadingDialog.show(context);
                    }
                    BaseRespBean baseRespBean = BaseRespBean(0);
                    // BaseRespBean baseRespBean =
                    //     await CircleApi.productBuy(data);
                    if (baseRespBean.isSuccess) {
                      showToast(msg: "观阅券使用成功");
                      UserStore.to.refreshRights();
                      Get.back(result: PaySuccess.exchangeSuccessFullly);
                      return;
                    } else {
                      showToast(msg: "观阅券使用失败，稍后重试");
                    }
                  } finally {
                    if (mounted) {
                      YJLoadingDialog.dismiss(context);
                    }
                  }
                },
                child: Text(
                  '使用观阅券 ($watchCount)',
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
