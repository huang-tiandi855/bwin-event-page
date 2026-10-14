import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 长视频播放器内观影券付费浮层。
///
/// 触发链路：
/// 详情接口返回 1008（[PlayerCodeManage.nonMember]）/
/// 1038（[PlayerCodeManage.noPay]）时，[VideoPageLogic] 先看
/// `UserStore.getUserInfoModel.movieTickets`，> 0 即把
/// [VipPlayerOverlay] / [GoldPlayerOverlay] 替换为本浮层。
///
/// 仅一个真正可点的按钮 ——「使用观影券」：调用
/// [MediaApi.videoTicketPay] 扣 1 张观影券，成功后由 [VideoPageLogic]
/// 刷用户信息 + 重拉详情起播。
///
/// 「跳过预览」按钮是 UI 设计稿里的视觉元素，不绑定任何回调（点击无响应），
/// 仅做装饰展示。所以一旦命中 ticket 浮层，用户唯一的退出路径就是用券。
///
/// 组件本身只负责 UI；扣券、路由、播放器重启交给上层。
class MovieTicketPlayerOverlay extends StatelessWidget {
  const MovieTicketPlayerOverlay({
    super.key,
    required this.cover,
    required this.remainTickets,
    required this.onBackTap,
    required this.onUseTicketTap,
  });

  /// 播放器区域占位封面图。
  final String cover;

  /// 剩余观影券次数（来自 `UserStore.getUserInfoModel.movieTickets`）。
  /// 仅用于副标题展示，不参与业务判断。
  final int remainTickets;

  /// 返回按钮点击。
  final VoidCallback onBackTap;

  /// 「使用观影券」按钮点击。
  final VoidCallback onUseTicketTap;

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
                    '当前视频可使用观影券免费解锁',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  10.w.verticalSpace,
                  Text(
                    '剩余观影券：$remainTickets 张',
                    style: TextStyle(
                      color: Colors.white.withOpacity(.7),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  16.w.verticalSpace,
                  getConfirmButton(
                    '使用观影券',
                    width: 192.w,
                    height: 30.h,
                    radius: 100.r,
                    onClick: onUseTicketTap,
                    colors: const [
                      Color(0XFFE16A20),
                      Color(0XFFE13520),
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
