import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'logic.dart';

/// 修改昵称
class SettingCenterNicknamePage extends StatelessWidget {
  const SettingCenterNicknamePage({Key? key}) : super(key: key);

  static const Color _warn = Color(0xFFFF4D4F);

  @override
  Widget build(BuildContext context) {
    // 路由关闭过程中 GetX 可能已删除 Logic，但本页仍可能被再 build 一次，勿用 GetView.controller。
    if (!Get.isRegistered<SettingCenterNicknameLogic>()) {
      return const SizedBox.shrink();
    }
    final c = Get.find<SettingCenterNicknameLogic>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.scaffoldBackground,
        appBar: commonAppBar("修改昵称", actions: [
          TextButton(
            onPressed: () => c.save(),
            child: Text(
              '保存',
              style: TextStyle(
                color: Colors.white.withOpacity(.5),
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        ]),
        body: GetBuilder<SettingCenterNicknameLogic>(
          builder: (c) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 10.w),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: c.state.controller,
                          focusNode: c.state.focusNode,
                          maxLength: 9,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            isDense: true,
                            counterText: '',
                            border: InputBorder.none,
                            hintText: '输入新的昵称',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(.5),
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: c.state.controller,
                        builder: (context, value, _) {
                          if (value.text.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return GestureDetector(
                            onTap: c.clear,
                            child: Padding(
                              padding: EdgeInsets.all(8.w),
                              child: AssetsGen.images.mine.mineClose.image(
                                width: 18.w,
                                height: 18.w,
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    height: 1,
                    color: c.state.focusNode.hasFocus
                        ? AppColor.primaryButtonColor
                        : Colors.white.withOpacity(0.15),
                  ),
                  SizedBox(height: 10.w),
                  Text(
                    '注意*诱导性昵称会被投诉封号',
                    style: TextStyle(
                      color: _warn,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
