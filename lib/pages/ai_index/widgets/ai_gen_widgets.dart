import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../gen/assets.gen.dart';
import 'ai_gen_style.dart';

/// AI 生成页通用脚手架（暗色稿）。
class AiGenScaffold extends StatelessWidget {
  const AiGenScaffold({
    super.key,
    required this.title,
    required this.children,
    this.submit,
  });

  final String title;
  final List<Widget> children;

  /// 底部固定「开始生成」区域；为空时不展示底栏。
  final Widget? submit;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AiGenStyle.background,
        appBar: _AiGenAppBar(title: title),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(15.w, 15.w, 15.w, 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
            ),
            if (submit != null) ...[
              Container(height: 1, color: AiGenStyle.divider),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(15.w, 14.w, 15.w, 10.w),
                  child: submit!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AiGenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AiGenAppBar({required this.title});

  final String title;

  @override
  Size get preferredSize => Size.fromHeight(44.w);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 44.w,
      backgroundColor: AiGenStyle.background,
      surfaceTintColor: AiGenStyle.background,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leadingWidth: 54.w,
      leading: GestureDetector(
        onTap: () => Get.back(),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: SvgPicture.asset(
            AssetsGen.images.ai.aiBack,
            width: 24.w,
            height: 24.w,
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          height: 1,
          fontSize: 18.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}

class AiGenCostCard extends StatelessWidget {
  const AiGenCostCard({
    super.key,
    required this.costCoins,
    required this.remainCoins,
    this.costText,
    this.balanceText,
  });

  final int costCoins;
  final int remainCoins;
  final String? costText;
  final String? balanceText;

  @override
  Widget build(BuildContext context) {
    final cost = costText ?? '$costCoins金币';
    final balance = balanceText ?? '$remainCoins金币';
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: Radius.circular(49.5.r),
      padding: EdgeInsets.zero,
      dashPattern: const [3, 2],
      strokeWidth: .5,
      color: AiGenStyle.accent,
      child: Container(
        width: double.infinity,
        height: 42.w,
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: AiGenStyle.surface,
          borderRadius: BorderRadius.circular(49.5.r),
        ),
        child: RichText(
          maxLines: 1,
          text: TextSpan(
            style: TextStyle(
              height: 1,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            children: [
              const TextSpan(text: '本次将消耗 '),
              TextSpan(
                text: cost,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AiGenStyle.gold,
                ),
              ),
              const TextSpan(
                text: '   (账户余额 ',
                style: TextStyle(color: AiGenStyle.muted),
              ),
              TextSpan(
                text: balance,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AiGenStyle.gold,
                ),
              ),
              const TextSpan(
                text: ')',
                style: TextStyle(color: AiGenStyle.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AiGenSectionTitle extends StatelessWidget {
  const AiGenSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        height: 1,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    );
  }
}

class AiGenUploadBox extends StatelessWidget {
  const AiGenUploadBox({
    super.key,
    required this.localPath,
    required this.onPick,
    required this.onClear,
    this.actionText = '请上传您的图片',
    this.height,
  });

  final String? localPath;
  final VoidCallback onPick;
  final VoidCallback onClear;
  final String actionText;
  final double? height;

  bool get hasImage => localPath != null && localPath!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final boxHeight = height ?? 270.w;
    return GestureDetector(
      onTap: hasImage ? null : onPick,
      child: DottedBorder(
        padding: EdgeInsets.zero,
        dashPattern: const [3, 2],
        strokeWidth: .5,
        color: AiGenStyle.accent,
        child: SizedBox(
          width: double.infinity,
          height: boxHeight,
          child: hasImage ? _buildSelected() : _buildEmpty(),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return ColoredBox(
      color: AiGenStyle.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AssetsGen.images.ai.aiUploadWand,
            width: 40.w,
            height: 40.w,
          ),
          SizedBox(height: 18.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 8.w),
            decoration: BoxDecoration(
              color: AiGenStyle.accent,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              actionText,
              style: TextStyle(
                height: 1,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: AiGenStyle.buttonEnabledText,
              ),
            ),
          ),
          SizedBox(height: 12.w),
          Text(
            '支持 JPG / PNG / WebP，最大 10MB',
            style: TextStyle(
              height: 1,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: AiGenStyle.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelected() {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AiGenStyle.surface),
        Padding(
          padding: EdgeInsets.all(5.w),
          child: Image.file(File(localPath!), fit: BoxFit.cover),
        ),
        Positioned(
          top: 5.w,
          right: 10.w,
          child: GestureDetector(
            onTap: onClear,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 28.w,
              height: 28.w,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x99000000),
              ),
              child: SvgPicture.asset(
                AssetsGen.images.ai.aiUploadClose,
                width: 16.w,
                height: 16.w,
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: onPick,
            child: Container(
              height: 36.w,
              alignment: Alignment.center,
              color: Colors.black.withOpacity(.45),
              child: Text(
                '重新选择',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AiGenChipSection extends StatelessWidget {
  const AiGenChipSection({
    super.key,
    required this.title,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
    this.allowDeselect = false,
    this.columns,
    this.itemWidth,
  });

  final String title;
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool allowDeselect;
  final int? columns;
  final double? itemWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AiGenSectionTitle(title),
        SizedBox(height: 15.w),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.w,
          children: List.generate(options.length, (i) {
            final selected = i == selectedIndex;
            final chip = GestureDetector(
              onTap: () {
                if (allowDeselect && selected) {
                  onSelected(-1);
                } else {
                  onSelected(i);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AiGenStyle.chipSelectedBg
                          : AiGenStyle.surface,
                      borderRadius: BorderRadius.circular(49.5.r),
                      border: selected
                          ? Border.all(color: AiGenStyle.accent, width: .5)
                          : null,
                    ),
                    child: Text(
                      options[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        height: 1,
                        fontSize: 12.sp,
                        fontWeight:
                            selected ? FontWeight.w500 : FontWeight.w400,
                        color: selected ? AiGenStyle.accent : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
            return chip;
          }),
        ),
      ],
    );
  }
}

class AiGenTextArea extends StatelessWidget {
  const AiGenTextArea({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLength = AiGenStyle.maxPromptLength,
    this.minHeight,
    this.showCounter = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLength;
  final double? minHeight;
  final bool showCounter;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: minHeight ?? 112.w),
          padding:
              EdgeInsets.fromLTRB(12.w, 12.w, 12.w, showCounter ? 28.w : 12.w),
          decoration: BoxDecoration(
            color: AiGenStyle.surface,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            maxLength: maxLength,
            maxLines: null,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1.4,
            ),
            cursorColor: AiGenStyle.accent,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              counterText: '',
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AiGenStyle.muted,
              ),
            ),
          ),
        ),
        if (showCounter)
          Positioned(
            right: 12.w,
            bottom: 10.w,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, value, __) {
                return Text(
                  '${value.text.characters.length}/$maxLength',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AiGenStyle.muted,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class AiGenDropdownField extends StatelessWidget {
  const AiGenDropdownField({
    super.key,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AiGenSectionTitle(title),
          SizedBox(height: 10.w),
          _DropdownBox(value: value, onTap: onTap),
        ],
      ),
    );
  }
}

class AiGenFullDropdownField extends StatelessWidget {
  const AiGenFullDropdownField({
    super.key,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AiGenSectionTitle(title),
        SizedBox(height: 10.w),
        _DropdownBox(value: value, onTap: onTap),
      ],
    );
  }
}

class _DropdownBox extends StatelessWidget {
  const _DropdownBox({required this.value, required this.onTap});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 35.w,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            AssetsGen.images.ai.aiArrowDown.image(
              width: 10.w,
              height: 9.w,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

class AiGenSubmitButton extends StatelessWidget {
  const AiGenSubmitButton({
    super.key,
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        height: 50.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AiGenStyle.accent : AiGenStyle.surface,
          borderRadius: BorderRadius.circular(49.5.r),
        ),
        child: Text(
          '开始生成',
          style: TextStyle(
            height: 1,
            fontSize: 19.sp,
            fontWeight: FontWeight.w400,
            color: enabled
                ? AiGenStyle.buttonEnabledText
                : AiGenStyle.buttonDisabledText,
          ),
        ),
      ),
    );
  }
}

Future<String?> showAiGenOptionSheet(
  BuildContext context, {
  required String title,
  required List<String> options,
  required String selected,
}) async {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AiGenStyle.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 14.w),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            ...options.map((e) {
              final selectedNow = e == selected;
              return ListTile(
                title: Text(
                  e,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: selectedNow ? AiGenStyle.accent : Colors.white,
                    fontWeight: selectedNow ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                trailing: selectedNow
                    ? const Icon(Icons.check, color: AiGenStyle.accent)
                    : null,
                onTap: () => Navigator.of(ctx).pop(e),
              );
            }),
            SizedBox(height: 8.w),
          ],
        ),
      );
    },
  );
}
