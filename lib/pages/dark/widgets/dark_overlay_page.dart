import 'package:comics_app/common/routers/app_navigator.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DarkOverlayPage extends StatelessWidget {
  const DarkOverlayPage({super.key});

  Future<void> _openMemberCentre() async {
    // await showVipPurchaseBottomSheet(
    //   onPay: (card) async {
    //     // 接支付逻辑
    //   },
    // );
    // await UserStore.to.refreshUser();
    AppNavigator.to.go(AppRoutes.MEMBER_CENTER);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (UserStore.to.isDarkVip() == true) {
        return const SizedBox.shrink();
      }

      return SizedBox.expand(
        child: Material(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AssetsGen.images.home.darkMaskBg.image(
                fit: BoxFit.cover,
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Color(0xDD100000),
                    ],
                    stops: [0, .72, 1],
                  ),
                ),
              ),
              SafeArea(
                bottom: true,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 42.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _UnlockBounceButton(
                          onTap: _openMemberCentre,
                        ),
                        24.h.verticalSpace,
                        Stack(
                          children: [
                            Text(
                              '一次解锁，了解真实暗黑的世界',
                              style: TextStyle(
                                fontSize: 20.sp,
                                height: 1,
                                fontWeight: FontWeight.w500,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 1
                                  ..color = const Color(0xFFD30201),
                              ),
                            ),
                            Text(
                              '一次解锁，了解真实暗黑的世界',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
                                height: 1,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// 暗网解锁按钮：循环放大缩小的「呼吸 / 弹跳」动画。
///
/// 抽成独立 [StatefulWidget] 是为了：
/// 1. 让外层 [DarkOverlayPage] 继续保持 [StatelessWidget] + [Obx] 不被打散；
/// 2. 不论 [Obx] 因为 VIP 状态变化重建外层多少次，本控件只要还挂在树上就
///    复用同一个 [AnimationController]，避免动画从头跳一次。
class _UnlockBounceButton extends StatefulWidget {
  const _UnlockBounceButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_UnlockBounceButton> createState() => _UnlockBounceButtonState();
}

class _UnlockBounceButtonState extends State<_UnlockBounceButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _scale = Tween<double>(
    begin: 0.8,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: AssetsGen.images.home.icDarkUnlockButton.image(
          width: 177.w,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
