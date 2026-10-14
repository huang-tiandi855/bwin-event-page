import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'logic.dart';

/// 性别选择
class SettingCenterGenderPage extends StatelessWidget {
  const SettingCenterGenderPage({Key? key}) : super(key: key);

  static Color get _card => Colors.white.withOpacity(.05);

  static Color get _divider => Colors.white.withOpacity(.15);

  @override
  Widget build(BuildContext context) {
    // 路由关闭过程中 GetX 可能已删除 Logic，但本页仍可能被再 build 一次，勿用 GetView.controller。
    if (!Get.isRegistered<SettingCenterGenderLogic>()) {
      return const SizedBox.shrink();
    }
    final c = Get.find<SettingCenterGenderLogic>();

    return Scaffold(
      backgroundColor: AppColor.scaffoldBackground,
      appBar: commonAppBar("修改性别", actions: [
        TextButton(
          onPressed: () => c.save(),
          child: Text(
            '保存',
            style: TextStyle(
              color: Colors.white.withOpacity(.55),
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ]),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: GetBuilder<SettingCenterGenderLogic>(
          builder: (c) {
            return Container(
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (_, __) => _line(),
                itemBuilder: (context, index) {
                  const labels = ['男', '女', '保密'];
                  return _row(c, index, labels[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _line() => Container(
        margin: EdgeInsets.only(left: 16.w),
        height: 1,
        color: _divider,
      );

  Widget _row(SettingCenterGenderLogic c, int index, String label) {
    final sel = c.state.selected == index;
    return InkWell(
      onTap: () => c.select(index),
      child: SizedBox(
        height: 50.w,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              if (sel)
                AssetsGen.images.mine.vipCenterSel.image(
                  width: 20.w,
                  height: 20.w,
                  fit: BoxFit.contain,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
