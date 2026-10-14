import 'package:comics_app/common/style/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

const Color _kRuleColor = Color(0x80FFFFFF);
const Color _kFooterColor = Color(0x4DFFFFFF);
const Color _kButtonTextColor = Color(0xFFFFFFFF);

/// 「发布规则」提示弹窗。
///
/// 视觉对齐 [showNeedVipDialog]：圆角 10、暗色卡片、顶部标题 + 分割线、
/// 中部规则正文、底部 [AppColor.primaryButtonColor] 按钮。
///
/// 用法：
/// ```dart
/// showPublishRuleDialog();
/// ```
Future<void> showPublishRuleDialog({
  String title = '发布规则',
  List<String> rules = _kDefaultRules,
  String footer = '请遵守社区规则，否则会被官方机器人拉黑',
  String buttonText = '我知道了',
  bool barrierDismissible = true,
}) {
  return Get.dialog<void>(
    barrierDismissible: barrierDismissible,
    barrierColor: const Color(0xB2181818),
    Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 47),
      child: PublishRuleDialog(
        title: title,
        rules: rules,
        footer: footer,
        buttonText: buttonText,
      ),
    ),
  );
}

const List<String> _kDefaultRules = [
  '禁止发布广告图文（含LINE、WECHAT、QQ、网址、二维码等外链）',
  '禁止发布诱导图文（求网址、求软体等）',
  '禁止发布儿童色情、兽*内容',
];

class PublishRuleDialog extends StatelessWidget {
  const PublishRuleDialog({
    super.key,
    required this.title,
    required this.rules,
    required this.footer,
    required this.buttonText,
  });

  final String title;
  final List<String> rules;
  final String footer;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: ColoredBox(
        color: const Color(0xFF222627),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 15.w),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 15.w),
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.white.withOpacity(0.05),
            ),
            SizedBox(height: 14.w),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  for (int i = 0; i < rules.length; i++) ...[
                    Text(
                      '·${rules[i]}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _kRuleColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                    if (i != rules.length - 1) SizedBox(height: 4.w),
                  ],
                ],
              ),
            ),
            SizedBox(height: 12.w),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                footer,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _kFooterColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 18.w),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColor.primaryButtonColor,
                    foregroundColor: _kButtonTextColor,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => Get.back(),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      color: _kButtonTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
