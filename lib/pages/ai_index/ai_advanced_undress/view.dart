import 'dart:io';

import 'package:comics_app/common/entities/ai/ai_params.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../gen/assets.gen.dart';
import 'logic.dart';
import 'state.dart';

/// AI「高级脱衣」生成页。
class AiAdvancedUndressPage extends GetView<AiAdvancedUndressLogic> {
  const AiAdvancedUndressPage({super.key});

  static const Color _background = Color(0xFF101010);
  static const Color _surface = Color(0xFF1C1C1C);
  static const Color _accent = Color(0xFFF5850B);
  static const Color _gold = Color(0xFFFFCF86);
  static const Color _muted = Color(0xFF71717B);

  AiAdvancedUndressState get state => controller.state;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(15.w, 15.w, 15.w, 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GetBuilder<AiAdvancedUndressLogic>(
                      builder: (_) => _buildCostCard(),
                    ),
                    SizedBox(height: 15.w),
                    _buildSectionTitle('上传人物图片'),
                    SizedBox(height: 10.w),
                    _buildUploadArea(),
                    SizedBox(height: 15.w),
                    GetBuilder<AiAdvancedUndressLogic>(
                      id: 'options',
                      builder: (_) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildChipSection(
                            title: '选择模式',
                            options: AiParams.labelsOf(state.modes),
                            selectedIndex: state.modeIndex,
                            onSelected: controller.selectMode,
                          ),
                          SizedBox(height: 15.w),
                          _buildChipSection(
                            title: '奶子大小',
                            options: AiParams.labelsOf(state.breastSizes),
                            selectedIndex: state.breastIndex,
                            onSelected: controller.selectBreast,
                          ),
                          SizedBox(height: 15.w),
                          _buildChipSection(
                            title: '设定下体',
                            options: AiParams.labelsOf(state.hairStyles),
                            selectedIndex: state.hairIndex,
                            onSelected: controller.selectHair,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(height: 1, color: const Color(0xFF3F3F46)),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 44.w,
      backgroundColor: _background,
      surfaceTintColor: _background,
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
        state.pageTitle,
        style: TextStyle(
          height: 1,
          fontSize: 18.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCostCard() {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: Radius.circular(49.5.r),
      padding: EdgeInsets.zero,
      dashPattern: const [3, 2],
      strokeWidth: .5,
      color: _accent,
      child: Container(
        width: double.infinity,
        height: 42.w,
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: _surface,
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
                text: controller.costText,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: _gold,
                ),
              ),
              const TextSpan(
                text: '   (账户余额 ',
                style: TextStyle(color: _muted),
              ),
              TextSpan(
                text: controller.balanceText,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: _gold,
                ),
              ),
              const TextSpan(
                text: ')',
                style: TextStyle(color: _muted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
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

  Widget _buildUploadArea() {
    return GetBuilder<AiAdvancedUndressLogic>(
      id: 'image',
      builder: (_) {
        Widget content = _buildImagePicker();
        if (state.isUploading) {
          content = _buildUploadingImage();
        } else if (state.isUploadSuccess) {
          content = _buildSelectedImage();
        }
        return GestureDetector(
          onTap: state.uploadStatus == AiImageUploadStatus.idle
              ? controller.pickImage
              : null,
          child: DottedBorder(
            padding: EdgeInsets.zero,
            dashPattern: const [3, 2],
            strokeWidth: .5,
            color: _accent,
            child: SizedBox(
              width: double.infinity,
              height: 270.w,
              child: content,
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePicker() {
    return ColoredBox(
      color: _surface,
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
              color: _accent,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              '请选择您要脱衣的素材',
              style: TextStyle(
                height: 1,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF0B0C13),
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
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadingImage() {
    return ColoredBox(
      color: _surface,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RotatedBox(
            quarterTurns: 3,
            child: SvgPicture.asset(
              AssetsGen.images.ai.aiUploadingFrame,
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            top: 72.w,
            left: 0,
            right: 0,
            height: 36.w,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00F5850B),
                    Color(0x4DF5850B),
                    Color(0x00F5850B),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              '上传中',
              style: TextStyle(
                height: 1,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: _accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: EdgeInsets.all(5.w),
          child: Image.file(
            File(state.localImagePath!),
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 5.w,
          right: 10.w,
          child: GestureDetector(
            onTap: controller.clearImage,
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
      ],
    );
  }

  Widget _buildChipSection({
    required String title,
    required List<String> options,
    required int selectedIndex,
    required ValueChanged<int> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        SizedBox(height: 15.w),
        Wrap(
          spacing: 8.w,
          runSpacing: 10.w,
          children: List.generate(options.length, (index) {
            final selected = index == selectedIndex;
            return GestureDetector(
              onTap: () => onSelected(index),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0x26F5850B)
                      : const Color(0xFF1C1C1C),
                  borderRadius: BorderRadius.circular(49.5.r),
                  border:
                      selected ? Border.all(color: _accent, width: .5) : null,
                ),
                child: Text(
                  options[index],
                  style: TextStyle(
                    height: 1,
                    fontSize: 12.sp,
                    fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                    color: selected ? _accent : Colors.white,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(15.w, 14.w, 15.w, 10.w),
        child: GetBuilder<AiAdvancedUndressLogic>(
          id: 'submit',
          builder: (_) {
            final enabled = state.isUploadSuccess;
            return GestureDetector(
              onTap: enabled ? () => controller.startGenerate(context) : null,
              child: Container(
                width: double.infinity,
                height: 50.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: enabled ? _accent : _surface,
                  borderRadius: BorderRadius.circular(49.5.r),
                ),
                child: Text(
                  '开始生成',
                  style: TextStyle(
                    height: 1,
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w400,
                    color: enabled ? const Color(0xFF0B0C13) : _muted,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
