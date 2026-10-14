import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/widgets/custom_picture_management.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../style/color.dart';

/// 弹出「选择发布类型」底部弹窗；选中后关闭弹窗并跳转 [AppRoutes.PUBLISH]。
///
/// - **图片**、**图文**：当前发布页均为图文流，均使用 [UploadType.UPLOAD_IMG]。
/// - **视频**：[UploadType.UPLOAD_VIDEO]。
Future<void> showSelectPublishTypeBottomSheet() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: AppColor.scaffoldBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await Get.bottomSheet<void>(
    const SelectPublishTypeBottomSheet(),
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: Colors.black54,
  );

  // 关闭后恢复
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
}

/// 选择发布类型（图片 / 视频 / 图文）底部弹窗 UI。
class SelectPublishTypeBottomSheet extends StatelessWidget {
  const SelectPublishTypeBottomSheet({super.key});

  void _onSelect(UploadType type) {
    Get.back<void>();
    Get.toNamed(AppRoutes.PUBLISH, arguments: {'type': type});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.scaffoldBackground,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColor.scaffoldBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 10.w, 20.w, 20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 17.w),
                Container(
                  width: 34.w,
                  height: 5.w,
                  decoration: BoxDecoration(
                    color: const Color(0x26FFFFFF),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
                SizedBox(height: 37.w),
                Text(
                  '选择发布类型',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16.w),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _PublishTypeOption(
                      image: AssetsGen.images.circle.publishTypeImg,
                      label: '图片',
                      onTap: () => _onSelect(UploadType.UPLOAD_IMG),
                    ),
                    _PublishTypeOption(
                      image: AssetsGen.images.circle.publishTypeVideo,
                      label: '视频',
                      onTap: () => _onSelect(UploadType.UPLOAD_VIDEO),
                    ),
                    _PublishTypeOption(
                      image: AssetsGen.images.circle.publishTypeText,
                      label: '图文',
                      onTap: () => _onSelect(UploadType.UPLOAD_IMG_AND_TEXT),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PublishTypeOption extends StatelessWidget {
  const _PublishTypeOption({
    required this.image,
    required this.label,
    required this.onTap,
  });

  final AssetGenImage image;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconSize = 50.w;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          image.image(
            width: iconSize,
            height: iconSize,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 10.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
