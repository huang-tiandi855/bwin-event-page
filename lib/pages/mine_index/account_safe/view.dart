import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 账号找回
class AccountSafePage extends StatelessWidget {
  const AccountSafePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBackground,
      appBar: commonAppBar('账号找回'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 24.w),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.05),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            children: [
              _MenuTile(
                title: '账号找回',
                onTap: () => Get.toNamed(AppRoutes.ACCOUNT_SAFE_PHONE_RECOVERY),
              ),
              _line(),
              _MenuTile(
                title: '凭证找回',
                onTap: () => Get.toNamed(AppRoutes.ACCOUNT_SAFE_SCAN_VOUCHER),
              ),
              _line(),
              _MenuTile(
                title: '联系客服',
                onTap: () => Get.toNamed(AppRoutes.MINE_COMMON_PROBLEM),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line() => Container(
        margin: EdgeInsets.only(left: 16.w),
        height: 1,
        color: Colors.white.withOpacity(.15),
      );
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 17.w),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            AssetsGen.images.mine.mineLineBack.image(
              width: 16.w,
              height: 16.w,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
