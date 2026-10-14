import 'package:comics_app/common/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 通用双按钮确认面板：可直接放进 `Get.dialog` / `Get.bottomSheet` / `showModalBottomSheet`，
/// 或通过 [CustomDialog.open]、[CustomDialog.openBottomSheet] 一键弹出。
class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
    required this.title,
    required this.cancelText,
    required this.confirmText,
    required this.onCancel,
    required this.onConfirm,
    required this.confirmTextColor,
    required this.borderRadius,
  });

  final String title;
  final String cancelText;
  final String confirmText;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final Color confirmTextColor;
  final BorderRadius borderRadius;

  /// 居中 `Get.dialog`（紫色「确认」文案）。
  static Future<bool> open({
    required String title,
    required VoidCallback onTap,
    String cancelText = '再想想',
    String confirmText = '是的',
    VoidCallback? backButton,
    bool barrierDismissible = true,
    Color confirmTextColor = AppColor.bluishPurple,
  }) async {
    final res = await _openAsDialog(
      title: title,
      onTap: onTap,
      cancelText: cancelText,
      confirmText: confirmText,
      backButton: backButton,
      barrierDismissible: barrierDismissible,
      confirmTextColor: confirmTextColor,
    );
    return res ?? false;
  }

  /// 底部 `Get.bottomSheet`（紫色「确认」文案）。
  static Future<bool> openBottomSheet({
    required String title,
    required VoidCallback onTap,
    String cancelText = '再想想',
    String confirmText = '是的',
    VoidCallback? backButton,
    bool barrierDismissible = true,
    Color confirmTextColor = AppColor.bluishPurple,
  }) async {
    final res = await _openAsBottomSheet(
      title: title,
      onTap: onTap,
      cancelText: cancelText,
      confirmText: confirmText,
      backButton: backButton,
      barrierDismissible: barrierDismissible,
      confirmTextColor: confirmTextColor,
    );
    return res ?? false;
  }

  static Future<bool?> _openAsDialog({
    required String title,
    required VoidCallback onTap,
    required String cancelText,
    required String confirmText,
    required VoidCallback? backButton,
    required bool barrierDismissible,
    required Color confirmTextColor,
  }) {
    void onCancel() {
      if (backButton != null) {
        backButton();
      } else {
        Get.back();
      }
    }

    return Get.dialog<bool?>(
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 34.w),
            child: CustomDialog(
              title: title,
              cancelText: cancelText,
              confirmText: confirmText,
              onCancel: onCancel,
              onConfirm: onTap,
              confirmTextColor: confirmTextColor,
              borderRadius: BorderRadius.circular(12.w),
            ),
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  static Future<bool?> _openAsBottomSheet({
    required String title,
    required VoidCallback onTap,
    required String cancelText,
    required String confirmText,
    required VoidCallback? backButton,
    required bool barrierDismissible,
    required Color confirmTextColor,
  }) {
    void onCancel() {
      if (backButton != null) {
        backButton();
      } else {
        Get.back();
      }
    }

    return Get.bottomSheet<bool?>(
      Material(
        color: Colors.transparent,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.w),
            child: CustomDialog(
              title: title,
              cancelText: cancelText,
              confirmText: confirmText,
              onCancel: onCancel,
              onConfirm: onTap,
              confirmTextColor: confirmTextColor,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(12.w)),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.black54,
      isDismissible: barrierDismissible,
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 110.w,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                title,
                style: TextStyle(fontSize: 18.sp),
              ),
            ),
          ),
          Container(
            height: 1,
            color: AppColor.lineColor,
          ),
          SizedBox(
            height: 50.w,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onCancel,
                    child: Text(
                      cancelText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColor.warmGrey,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                ),
                Container(width: 1, color: AppColor.lineColor),
                Expanded(
                  child: InkWell(
                    onTap: onConfirm,
                    child: Text(
                      confirmText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: confirmTextColor,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 与历史 [customDialog] 等价，委托 [CustomDialog.open]。
Future<bool> customDialog(
  String title, {
  required VoidCallback onTap,
  String cancelText = '再想想',
  String confirmText = '是的',
  VoidCallback? backButton,
  bool barrierDismissible = true,
}) {
  return CustomDialog.open(
    title: title,
    onTap: onTap,
    cancelText: cancelText,
    confirmText: confirmText,
    backButton: backButton,
    barrierDismissible: barrierDismissible,
  );
}

/// 与历史 [customDialogBlackConfirm] 等价：黑色「确认」文案。
Future<bool> customDialogBlackConfirm(
  String title, {
  required VoidCallback onTap,
  String cancelText = '再想想',
  String confirmText = '是的',
  VoidCallback? backButton,
  bool barrierDismissible = true,
}) {
  return CustomDialog.open(
    title: title,
    onTap: onTap,
    cancelText: cancelText,
    confirmText: confirmText,
    backButton: backButton,
    barrierDismissible: barrierDismissible,
    confirmTextColor: AppColor.black,
  );
}

/// 底部弹窗 + 紫色「确认」。
Future<bool> customDialogBottomSheet(
  String title, {
  required VoidCallback onTap,
  String cancelText = '再想想',
  String confirmText = '是的',
  VoidCallback? backButton,
  bool barrierDismissible = true,
}) {
  return CustomDialog.openBottomSheet(
    title: title,
    onTap: onTap,
    cancelText: cancelText,
    confirmText: confirmText,
    backButton: backButton,
    barrierDismissible: barrierDismissible,
  );
}

/// 底部弹窗 + 黑色「确认」。
Future<bool> customDialogBlackConfirmBottomSheet(
  String title, {
  required VoidCallback onTap,
  String cancelText = '再想想',
  String confirmText = '是的',
  VoidCallback? backButton,
  bool barrierDismissible = true,
}) {
  return CustomDialog.openBottomSheet(
    title: title,
    onTap: onTap,
    cancelText: cancelText,
    confirmText: confirmText,
    backButton: backButton,
    barrierDismissible: barrierDismissible,
    confirmTextColor: AppColor.black,
  );
}
