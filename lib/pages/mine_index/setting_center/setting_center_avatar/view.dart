import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../image/network/custom_image_network.dart';
import 'logic.dart';

/// 选择头像
class SettingCenterAvatarPage extends StatelessWidget {
  const SettingCenterAvatarPage({Key? key}) : super(key: key);

  static const _hint = Color(0x80FFFFFF);

  @override
  Widget build(BuildContext context) {
    // 路由关闭过程中 GetX 可能已删除 Logic，但本页仍可能被再 build 一次，勿用 GetView.controller。
    if (!Get.isRegistered<SettingCenterAvatarLogic>()) {
      return const SizedBox.shrink();
    }
    final c = Get.find<SettingCenterAvatarLogic>();

    return Scaffold(
      backgroundColor: AppColor.scaffoldBackground,
      appBar: commonAppBar("选择头像", actions: [
        TextButton(
          onPressed: () => c.save(),
          child: Text(
            '保存',
            style: TextStyle(
              color: _hint,
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        )
      ]),
      body: GetBuilder<SettingCenterAvatarLogic>(
        builder: (c) {
          final preview = c.previewUrl;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                SizedBox(height: 30.w),
                Center(
                  child: CustomImage(
                    url: preview,
                    width: 100.w,
                    height: 100.w,
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                ),
                SizedBox(height: 26.w),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 60.w,
                      mainAxisSpacing: 16.w,
                      crossAxisSpacing: 34.w,
                      childAspectRatio: 1,
                    ),
                    itemCount: c.state.avatarList.length,
                    itemBuilder: (context, index) {
                      final url = c.state.avatarList[index]?.url ?? '';
                      final selected = c.state.selectedIndex == index;
                      return GestureDetector(
                        onTap: () => c.selectIndex(index),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CustomImage(
                              url: url,
                              width: 60,
                              height: 60,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            if (selected)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: AssetsGen.images.mine.vipCenterSel.image(
                                  width: 20.w,
                                  height: 20.w,
                                  fit: BoxFit.contain,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
