import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// player_float 目录说明：
/// 这里统一放置“叠在播放器画面上的浮层 UI”，组件不直接处理播放权限或路由业务。
///
/// 长视频播放器内的 VIP 购买浮层。
///
/// 使用视频封面作为播放器占位背景，只负责展示 UI 和回调点击事件；
/// 具体的会员状态判断、路由跳转和播放恢复逻辑由调用方处理。
class VipPlayerOverlay extends StatelessWidget {
  const VipPlayerOverlay({
    super.key,
    this.videoType = 0,
    required this.cover,
    required this.onBackTap,
    required this.onInviteTap,
    required this.onOpenMemberTap,
  });

  /// 播放器区域占位封面图。
  final String cover;

  final int videoType;

  /// 返回按钮点击。
  final VoidCallback onBackTap;

  /// 邀请好友得 VIP 按钮点击。
  final VoidCallback onInviteTap;

  /// 开通预购免费看按钮点击。
  final VoidCallback onOpenMemberTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 212.w,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomImage(
            url: cover,
            height: 212.w,
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.5)),
          Positioned(
            top: 16.w,
            left: 16.w,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onBackTap,
              child: Image.asset(
                'assets/images/png/app_back.png',
                width: 24.w,
                height: 24.w,
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '开通会员',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  16.w.verticalSpace,
                  videoType == 2
                      ? Text(
                          '当前内容仅限高级会员观看',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : Text(
                          '全站视频免费观看',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                  18.h.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      getConfirmButton(
                        '邀请好友得VIP',
                        width: 138.w,
                        height: 30.h,
                        radius: 100.r,
                        onClick: onInviteTap,
                        colors: const [
                          Color(0XFFBA14FF),
                          Color(0XFF601EFF),
                        ],
                      ),
                      20.w.horizontalSpace,
                      getConfirmButton(
                        videoType == 2 ? '升级会员免费看' : '开通预购免费看',
                        width: 138.w,
                        height: 30.h,
                        radius: 100.r,
                        onClick: onOpenMemberTap,
                        colors: const [
                          Color(0XFFE16A20),
                          Color(0XFFE13520),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
