import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:comics_app/common/entities/user_info_model_entity.dart';
import 'package:comics_app/common/store/user.dart';

import 'logic.dart';
import 'state.dart';

/// 绑定手机号
class SettingCenterPhonePage extends StatelessWidget {
  const SettingCenterPhonePage({Key? key}) : super(key: key);

  static const Color _hint = Color(0x80FFFFFF);

  @override
  Widget build(BuildContext context) {
    // 路由关闭过程中 GetX 可能已删除 Logic，但本页仍可能被再 build 一次，勿用 GetView.controller。
    if (!Get.isRegistered<SettingCenterPhoneLogic>()) {
      return const SizedBox.shrink();
    }
    final c = Get.find<SettingCenterPhoneLogic>();

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
    final recoverStyle = TextStyle(
      color: AppColor.primaryButtonColor,
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
    );

    final user = UserStore.to.getUserInfoModel;
    final alreadyBound = user?.bindStatus == 1;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.scaffoldBackground,
        appBar: commonAppBar('绑定手机号'),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16.w),
              if (alreadyBound)
                _AlreadyBoundPhoneCard(phoneText: _boundPhoneDisplay(user))
              else ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _PhoneFieldBlock(
                        state: c.state,
                        labelStyle: labelStyle,
                        inputStyle: inputStyle,
                        hintStyle: hintStyle,
                        logic: c,
                        onClear: c.clearPhone,
                        isPassword: false,
                        showBottomDivider: true,
                      ),
                      _PhoneFieldBlock(
                        state: c.state,
                        labelStyle: labelStyle,
                        inputStyle: inputStyle,
                        hintStyle: hintStyle,
                        logic: c,
                        onClear: c.clearPassword,
                        isPassword: true,
                        showBottomDivider: false,
                        recoverStyle: recoverStyle,
                        onFindPassword: c.findPassword,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 36.w),
                GetBuilder<SettingCenterPhoneLogic>(
                  id: 'canSubmit',
                  builder: (lg) {
                    final ok = lg.state.canSubmit;
                    return SizedBox(
                      height: 48.w,
                      child: FilledButton(
                        onPressed: ok ? lg.submit : null,
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
                          '立即绑定',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _boundPhoneDisplay(UserInfoModelEntity? u) {
  if (u == null) return '--';
  final m = u.mobile?.trim();
  if (m != null && m.isNotEmpty) return m;
  return '--';
}

/// `bindStatus == 2`：已绑定手机号时的展示
class _AlreadyBoundPhoneCard extends StatelessWidget {
  const _AlreadyBoundPhoneCard({required this.phoneText});

  final String phoneText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10.r),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 28.w, 20.w, 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '您已绑定手机号',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 16.w),
          Text(
            phoneText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 28.w),
          SizedBox(
            height: 48.w,
            child: FilledButton(
              onPressed: () => Get.back(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColor.primaryButtonColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.w),
                ),
              ),
              child: Text(
                '返回',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
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
    this.recoverStyle,
    this.onFindPassword,
  });

  final SettingCenterPhoneState state;
  final TextStyle labelStyle;
  final TextStyle inputStyle;
  final TextStyle hintStyle;
  final SettingCenterPhoneLogic logic;
  final VoidCallback onClear;
  final bool isPassword;
  final bool showBottomDivider;
  final TextStyle? recoverStyle;
  final VoidCallback? onFindPassword;

  static const Color _line = Color(0x26FFFFFF);

  @override
  Widget build(BuildContext context) {
    final controller =
        isPassword ? state.passwordController : state.phoneController;
    final label = isPassword ? '设置密码' : '手机号';
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
          if (isPassword && recoverStyle != null && onFindPassword != null)
            GestureDetector(
              onTap: onFindPassword,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.only(left: 4.w),
                child: Text('密码找回', style: recoverStyle),
              ),
            ),
        ],
      ),
    );
  }
}
