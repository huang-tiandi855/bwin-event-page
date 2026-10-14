import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../common/store/config.dart';
import 'logic.dart';

/// 邀请分享（mine_index）
class ShareInvitePage extends GetView<ShareInviteLogic> {
  const ShareInvitePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final officialUrl = ConfigStore.to.configBean.shareUrl ?? "";
    final shareUrl =
        "$officialUrl?code=${UserStore.to.getUserInfoModel?.invitationCode ?? ''}";
    final invitationCode = UserStore.to.getUserInfoModel?.invitationCode ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: commonAppBar(
        '邀请分享',
        isShowLine: false,
        actions: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Get.toNamed(AppRoutes.MINE_INVITE_RECORD),
            child: Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Center(
                child: Text(
                  '记录',
                  style: TextStyle(
                    color: const Color(0x80FFFFFF),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AssetsGen.images.mine.shareInviteBg.image(fit: BoxFit.cover),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RepaintBoundary(
                  key: controller.state.boundaryKey,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: QrImageView(
                          padding: EdgeInsets.all(15.w),
                          data: shareUrl,
                          backgroundColor: Colors.white,
                          size: 180.w,
                        ),
                      ),
                      SizedBox(height: 8.w),
                      Text(
                        '邀请码',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          color: const Color(0xFFFFFFFF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        invitationCode.isEmpty ? '—' : invitationCode,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 40.sp,
                          color: const Color(0xFFFFFFFF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8.w),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.w,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x4D000000),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          "官网地址：$officialUrl",
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFFFFFFFF),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 14.w),
                      Text(
                        '提示*苹果手机请用相机扫码/安卓手机推荐UC浏览器扫码',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColor.primaryButtonColor,
                          fontWeight: FontWeight.w400,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15.w),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40.w,
                      width: 112.w,
                      child: FilledButton(
                        onPressed: () => controller.copyLink(shareUrl),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFFFFFF),
                          foregroundColor: const Color(0xFF000000),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.w),
                          ),
                        ),
                        child: Text(
                          '复制链接',
                          style: TextStyle(
                            color: const Color(0xFF000000),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20.w),
                    SizedBox(
                      height: 40.w,
                      width: 112.w,
                      child: FilledButton(
                        onPressed: () => controller.savePoster(shareUrl),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColor.primaryButtonColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.w),
                          ),
                        ),
                        child: Text(
                          '保存图片',
                          style: TextStyle(
                            color: const Color(0xFFFFFFFF),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 28.w),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
