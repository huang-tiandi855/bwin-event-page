import 'package:comics_app/common/res/r.dart';
import 'package:comics_app/common/store/event_tracking_manager.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../routers/app_routes.dart';

Future openVipDialog({String id = '', bool isShowCoupon = true}) async {
  var res = await Get.dialog(VipDialog(id: id, isShowCoupon: isShowCoupon));
  return res ?? false;
}

class VipDialog extends StatelessWidget {
  final bool isShowCoupon;
  final String id;

  const VipDialog({Key? key, required this.isShowCoupon, required this.id})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int watchCount = UserStore.to.userRightWatchReadCouponList.length;
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          child: Center(
            child: Container(
              alignment: Alignment.center,
              height: 175.w,
              decoration: BoxDecoration(
                  color: AppColor.c1b164c,
                  borderRadius: BorderRadius.circular(12.w)),
              margin: EdgeInsets.symmetric(horizontal: 34.w),
              child: Stack(
                children: [
                  Positioned(
                      right: 12.w,
                      top: 12.w,
                      child: InkWell(
                        onTap: () => Get.back(),
                        child: SvgPicture.asset(R.close, width: 16.w),
                      )),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        height: 67.w,
                        padding: EdgeInsets.symmetric(vertical: 18.w),
                        child: Text(
                          '需要开通会员才可观看',
                          style: TextStyle(fontSize: 18.sp),
                        ),
                      ),
                      Container(
                        height: 1.w,
                        color: AppColor.c272356,
                      ),
                      SizedBox(height: 10.w),
                      Expanded(
                          child: Container(
                        alignment: isShowCoupon
                            ? Alignment.bottomCenter
                            : Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            EventTrackingManager()
                                .addUserVipGraphicss(GraphicsType.vip);
                            Get.toNamed(AppRoutes.MEMBER_CENTER);
                          },
                          child: Container(
                            width: 218.w,
                            height: 39.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.w),
                              color: AppColor.cffc833,
                            ),
                            child: Text("立即开通",
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    color: AppColor.c191641,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      )),
                      isShowCoupon
                          ? Expanded(
                              child: Center(
                              child: InkWell(
                                onTap: () async {
                                  if (id.isEmpty) {
                                    showToast(msg: "不支持观阅券观看");
                                    return;
                                  }
                                  if (watchCount == 0) {
                                    showToast(msg: "观阅券不足");
                                    return;
                                  }
                                  // BaseRespBean baseRespBean =
                                  //     await CircleApi.ticketPurchasePaying(id);
                                  // if (baseRespBean.isSuccess) {
                                  //   Get.back(
                                  //       result:
                                  //           PaySuccess.exchangeSuccessFullly);
                                  //   showToast(msg: "观阅券使用成功");
                                  //   UserStore.to.refreshUser();
                                  //   return;
                                  // }
                                },
                                child: Text(
                                  '使用观阅券 ($watchCount)',
                                  style:
                                      const TextStyle(color: AppColor.c898989),
                                ),
                              ),
                            ))
                          : Expanded(
                              child: Center(
                              child: GestureDetector(
                                onTap: () => Get.back(),
                                child: const Text('稍后再说',
                                    style: TextStyle(color: AppColor.c898989)),
                              ),
                            ))
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
