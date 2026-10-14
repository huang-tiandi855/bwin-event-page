import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'phone_recovery_logic.dart';
import 'phone_recovery_state.dart';

/// 手机号找回
class PhoneRecoveryPage extends StatelessWidget {
  const PhoneRecoveryPage({Key? key}) : super(key: key);

  static const Color _hint = Color(0x80FFFFFF);

  @override
  Widget build(BuildContext context) {
    // 与路由 Binding 双保险：避免个别导航路径未触发 Binding 时 Get.find 抛错
    if (!Get.isRegistered<PhoneRecoveryLogic>()) {
      Get.put(PhoneRecoveryLogic(), permanent: false);
    }
    final logic = Get.find<PhoneRecoveryLogic>();
    final state = logic.state;

    final labelStyle = TextStyle(
      color: Colors.white,
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
    );
    final inputStyle = TextStyle(
      color: Colors.white,
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
    );
    final hintStyle = TextStyle(
      color: _hint,
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.scaffoldBackground,
        appBar: commonAppBar('账号登录'),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16.w),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _PhoneFieldBlock(
                      state: state,
                      labelStyle: labelStyle,
                      inputStyle: inputStyle,
                      hintStyle: hintStyle,
                      logic: logic,
                      onClear: logic.clearPhone,
                      isPassword: false,
                      showBottomDivider: true,
                    ),
                    _PhoneFieldBlock(
                      state: state,
                      labelStyle: labelStyle,
                      inputStyle: inputStyle,
                      hintStyle: hintStyle,
                      logic: logic,
                      onClear: logic.clearPassword,
                      isPassword: true,
                      showBottomDivider: false,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 36.w),
              GetBuilder<PhoneRecoveryLogic>(
                id: PhoneRecoveryLogic.canSubmitId,
                builder: (lg) {
                  final ok = lg.state.canSubmit;
                  return SizedBox(
                    height: 48.w,
                    child: FilledButton(
                      onPressed: ok ? lg.submitRecover : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColor.primaryButtonColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        disabledBackgroundColor:
                            AppColor.primaryButtonColor.withOpacity(.45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.w),
                        ),
                      ),
                      child: Text(
                        '找回',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneFieldBlock extends StatelessWidget {
  const _PhoneFieldBlock({
    required this.state,
    required this.labelStyle,
    required this.inputStyle,
    required this.hintStyle,
    required this.logic,
    required this.onClear,
    required this.isPassword,
    required this.showBottomDivider,
  });

  final PhoneRecoveryState state;
  final TextStyle labelStyle;
  final TextStyle inputStyle;
  final TextStyle hintStyle;
  final PhoneRecoveryLogic logic;
  final VoidCallback onClear;
  final bool isPassword;
  final bool showBottomDivider;

  static const Color _line = Color(0x26FFFFFF);

  @override
  Widget build(BuildContext context) {
    final controller =
        isPassword ? state.passwordController : state.phoneController;
    final label = isPassword ? '密码' : '手机号';
    final hint = isPassword ? '请输入密码' : '请输入11位手机号';

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: showBottomDivider ? _line : Colors.transparent,
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 17.w, horizontal: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 72.w,
            child: Text(label, style: labelStyle),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: isPassword
                  ? TextInputType.visiblePassword
                  : TextInputType.phone,
              obscureText: isPassword,
              inputFormatters: isPassword
                  ? null
                  : [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
              style: inputStyle,
              cursorColor: Colors.white,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: hintStyle,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged:
                  isPassword ? logic.onPasswordChanged : logic.onPhoneChanged,
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: onClear,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.only(left: 4.w, right: 4.w),
                  child: AssetsGen.images.mine.mineClose.image(
                    width: 20.w,
                    height: 20.w,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
