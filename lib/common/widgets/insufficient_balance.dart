import 'package:comics_app/common/routers/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Future<void> showInsufficientBalanceDialog() {
  return showDialog(
      barrierDismissible: true,
      context: Get.overlayContext!,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
              onTap: () {},
              child: Container(
                height: 252,
                alignment: Alignment.center,
                width: ScreenUtil().screenWidth,
                decoration: ShapeDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(0.00, -1.00),
                    end: Alignment(0, 1),
                    colors: [Color(0xFFE5FDFF), Colors.white],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(
                      height: 3,
                    ),
                    const Text(
                      '温馨提示',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Opacity(
                      opacity: 0.90,
                      child: Text(
                        '您当前金豆余额不足',
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Opacity(
                      opacity: 0.90,
                      child: Text(
                        '前往购买金豆 返回继续操作',
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: SizedBox(
                            width: 108,
                            height: 38,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  child: Container(
                                    width: 108,
                                    height: 38,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFB3B3B3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(19),
                                      ),
                                    ),
                                  ),
                                ),
                                const Positioned(
                                  left: 26,
                                  top: 9,
                                  child: Text(
                                    '稍后再说',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.toNamed(AppRoutes.MEMBER_CENTER,
                                arguments: {"initialIndex": 1});
                          },
                          child: SizedBox(
                            width: 136,
                            height: 38,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  child: Container(
                                    width: 136,
                                    height: 38,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF94D6DA),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(19),
                                      ),
                                    ),
                                  ),
                                ),
                                const Positioned(
                                  left: 40,
                                  top: 9,
                                  child: Text(
                                    '前往购买',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Opacity(
                      opacity: 0.10,
                      child: Container(
                        width: 296,
                        height: 1,
                        decoration: const BoxDecoration(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )),
        );
      }).then((value) {});
}
