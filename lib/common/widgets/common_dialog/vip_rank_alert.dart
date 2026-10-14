// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routers/app_routes.dart';

///分享二维码对话框
class VipRankAlert extends StatefulWidget {
  static Future show(BuildContext context,
      {String? title, String? desc, String? descTwo}) {
    return showDialog(
      context: context,
      builder: (context) {
        return VipRankAlert(
          title: title,
          desc: desc,
          descTwo: descTwo,
        );
      },
    );
  }

  final String? title;
  final String? desc;
  final String? descTwo;

  const VipRankAlert({super.key, this.title, this.desc, this.descTwo});

  @override
  State<VipRankAlert> createState() => _ShareVideoDialog();
}

class _ShareVideoDialog extends State<VipRankAlert>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              Text(
                widget.title ?? "温馨提示",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff333333),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: const Color(0xff333333).withOpacity(0.1),
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  widget.desc ?? "您还不是会员 无法继续",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xff333333),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  widget.descTwo ?? "开通会员 即可解锁继续查看",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff333333),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildButtonMenu(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonMenu() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 108,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context, 0);
                Get.toNamed(AppRoutes.SHARE_INVITE);
              },
              child: Container(
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
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 136,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context, 0);
                Get.toNamed(AppRoutes.MEMBER_CENTER)?.then((value) {});
              },
              child: Container(
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
                  "开通会员",
                  style: TextStyle(
                    color: Color(0xFFB09FD9),
                    fontSize: 14,
                    fontFamily: 'Dream',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
