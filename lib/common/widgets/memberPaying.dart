import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/store/event_tracking_manager.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/values/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../routers/app_routes.dart';

Future openMemberPaying(
    {String? id,
    String? chatId,
    bool isShowCoupon = true,
    String? title,
    int? productType,
    double? width,
    double? height,
    bool? isnovelOrComic = false,
    bool? isBottomSheet = false}) async {
  dynamic res;
  if (isBottomSheet ?? false) {
    res = await Get.bottomSheet(MemberPaying(
      id: id,
      isShowCoupon: isShowCoupon,
      title: title ?? '需要开通会员才可观看',
      productType: productType,
      isnovelOrComic: isnovelOrComic,
      width: width,
      height: height,
      chatId: chatId,
    ));
  } else {
    res = await Get.dialog(Dialog(
        child: MemberPaying(
      width: width,
      height: height,
      isShowCoupon: isShowCoupon,
      id: id,
      productType: productType,
      title: title ?? '需要开通会员才可观看',
      chatId: chatId,
    )));
  }
  return res ?? false;
}

class MemberPaying extends StatelessWidget {
  final bool isShowCoupon;
  final String? id;
  final String title;
  final double? width;
  final double? height;
  final bool? isnovelOrComic;
  final String? chatId;
  final int? productType; //产品类型
  const MemberPaying(
      {Key? key,
      required this.isShowCoupon,
      this.id,
      required this.title,
      this.width,
      this.height,
      this.productType,
      this.isnovelOrComic,
      this.chatId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    printInfo(info: "$id====>$productType");
    int watchCount = UserStore.to.userRightWatchReadCouponList.length;
    return Container(
      width: width ?? double.infinity,
      height: height ?? 274.w,
      padding: EdgeInsets.only(left: 0.w, right: 0.w, bottom: 0),
      decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            '温馨提示',
            style: TextStyle(
              color: const Color(0xFF333333),
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Opacity(
            opacity: 0.10,
            child: Container(
              width: double.infinity,
              height: 1,
              decoration: const BoxDecoration(color: Color(0xFF333333)),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '您还不是会员 无法继续',
                style: TextStyle(
                  color: const Color(0xFF333333),
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Text(
            '开通会员 即可解锁继续查看',
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
                    color: Colors.white,
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
                  child: const Text('邀请好友',
                      style: TextStyle(
                        color: Color(0xFFB09FD9),
                        fontSize: 14,
                        fontFamily: 'Dream',
                        fontWeight: FontWeight.w900,
                      )),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  Get.toNamed(AppRoutes.MEMBER_CENTER)?.then((value) {});

                  if (!isnovelOrComic!) {
                    EventTrackingManager().addVideoVipGraphicss(id, title, GraphicsType.vip);
                  }
                },
                child: Container(
                  width: 124.w,
                  height: 37.w,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    color: Colors.white,
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
                  child: const Text('开通会员',
                      style: TextStyle(
                        color: Color(0xFFB09FD9),
                        fontSize: 14,
                        fontFamily: 'Dream',
                        fontWeight: FontWeight.w900,
                      )),
                ),
              ),
            ],
          ),
          Visibility(
            visible: isShowCoupon && watchCount > 0 ? true : false,
            child: GestureDetector(
              onTap: () async {
                printInfo(info: "$id====>$productType");
                if (id == null || productType == null) {
                  showToast(msg: "不支持观阅券购买");
                  return;
                }
                if (watchCount == 0) {
                  showToast(msg: "观阅券不足");
                  return;
                }

                BaseRespBean baseRespBean = BaseRespBean(0);
                // BaseRespBean baseRespBean = await CircleApi.productBuy(data);
                if (baseRespBean.isSuccess) {
                  Get.back(result: PaySuccess.exchangeSuccessFullly);
                  showToast(msg: "观阅券使用成功");
                  UserStore.to.refreshRights();
                  return;
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
    );
  }
}
