import 'package:comics_app/common/style/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../common/res/r.dart';
import 'logic.dart';
import 'pattern_lock.dart';

/// 锁屏图案页：默认解锁；`Get.toNamed(AppRoutes.LOCK_SCREEN_PATTERN, arguments: 1|2)` 设置 / 关锁前验证。
///
/// 可选：构造传入 [legacyWhetherVerify] 时优先于 [Get.arguments]。
class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key, this.legacyWhetherVerify});

  final int? legacyWhetherVerify;

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  late final PasswordLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = Get.put(
      PasswordLogic(
        initialMode: widget.legacyWhetherVerify,
      ),
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<PasswordLogic>()) {
      Get.delete<PasswordLogic>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PasswordLogic>(
      init: _logic,
      builder: (PasswordLogic logic) {
        final s = logic.state;
        final hintColor =
            s.errorVisual ? const Color(0xFFFF3B30) : const Color(0xFF999999);
        return PopScope(
          canPop: logic.canPop,
          child: Scaffold(
            backgroundColor: AppColor.scaffoldBackground,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor:
                  logic.canPop ? Colors.black : AppColor.scaffoldBackground,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: logic.canPop,
              leading: logic.canPop
                  ? IconButton(
                      icon: SvgPicture.asset(
                        R.back,
                        width: 24.w,
                        color: AppColor.white,
                      ),
                      color: Colors.white,
                      onPressed: () => Get.back(),
                    )
                  : null,
              title: Text(
                logic.appBarTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              systemOverlayStyle: SystemUiOverlayStyle.light,
            ),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    s.hint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: hintColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: 46.w),
                  Center(
                    child: PatternLock(
                      key: ValueKey(s.patternRevision),
                      size: 1.sw * 0.82,
                      errorVisual: s.errorVisual,
                      onStart: logic.onPatternStart,
                      onTooShort: logic.onPatternTooShort,
                      onComplete: logic.onPatternSubmit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
