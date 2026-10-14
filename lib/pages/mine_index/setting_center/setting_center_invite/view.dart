import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'logic.dart';

/// 绑定邀请码
class SettingCenterInvitePage extends StatelessWidget {
  const SettingCenterInvitePage({Key? key}) : super(key: key);

  static const Color _hint = Color(0x80FFFFFF);
  static const Color _line = Color(0x26FFFFFF);

  @override
  Widget build(BuildContext context) {
    // 路由关闭过程中 GetX 可能已删除 Logic，但本页仍可能被再 build 一次，勿用 GetView.controller。
    if (!Get.isRegistered<SettingCenterInviteLogic>()) {
      return const SizedBox.shrink();
    }
    final c = Get.find<SettingCenterInviteLogic>();

    return Scaffold(
      backgroundColor: AppColor.scaffoldBackground,
      appBar: commonAppBar("绑定邀请码"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16.w),
            Text(
              '输入邀请码',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.w),
            Text(
              '邀请码只能绑定一次 且不能修改',
              style: TextStyle(
                color: _hint,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.w),
            Container(
              height: 50.w,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: _line, width: 1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '邀请码',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(width: 38.w),
                  Expanded(
                    child: TextField(
                      controller: c.state.controller,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      cursorColor: Colors.white,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: '请输入邀请码（字母大写）',
                        hintStyle: TextStyle(
                          color: _hint,
                          fontSize: 13.sp,
                        ),
                      ),
                      onChanged: c.onTextChanged,
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: c.state.controller,
                    builder: (context, value, _) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return GestureDetector(
                        onTap: () {
                          c.state.controller.clear();
                          c.onTextChanged('');
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: 4.w),
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
            ),
            SizedBox(height: 12.w),
            Text(
              '邀请1人 获得一天会员',
              style: TextStyle(
                color: Colors.white.withOpacity(.3),
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 40.w),
            GetBuilder<SettingCenterInviteLogic>(
              id: 'canSubmit',
              builder: (c) {
                final ok = c.state.canSubmit;
                return SizedBox(
                  height: 48.w,
                  child: FilledButton(
                    onPressed: ok ? c.submit : null,
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
        ),
      ),
    );
  }
}
