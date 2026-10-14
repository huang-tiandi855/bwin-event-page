import 'package:comics_app/common/entities/ai/ai_params.dart';
import 'package:comics_app/pages/ai_index/widgets/ai_gen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'logic.dart';

/// AI「图生视频」。
class AiImageToVideoPage extends GetView<AiImageToVideoLogic> {
  const AiImageToVideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return AiGenScaffold(
      title: state.pageTitle,
      submit: GetBuilder<AiImageToVideoLogic>(
        id: 'submit',
        builder: (_) => AiGenSubmitButton(
          enabled: controller.canSubmit,
          onTap: () => controller.startGenerate(context),
        ),
      ),
      children: [
        GetBuilder<AiImageToVideoLogic>(
          builder: (_) => AiGenCostCard(
            costCoins: state.costCoins,
            remainCoins: controller.remainCoins,
            costText: controller.costText,
            balanceText: controller.balanceText,
          ),
        ),
        SizedBox(height: 15.w),
        const AiGenSectionTitle('上传图片'),
        SizedBox(height: 10.w),
        GetBuilder<AiImageToVideoLogic>(
          id: 'image',
          builder: (_) => AiGenUploadBox(
            localPath: state.localImagePath,
            onPick: controller.pickImage,
            onClear: controller.clearImage,
            actionText: '请上传您的图片',
          ),
        ),
        SizedBox(height: 15.w),
        GetBuilder<AiImageToVideoLogic>(
          id: 'options',
          builder: (_) => AiGenChipSection(
            title: '风格模版',
            options: AiParams.labelsOf(state.styleTemplates),
            selectedIndex: state.styleIndex,
            onSelected: controller.selectStyle,
            allowDeselect: true,
          ),
        ),
        SizedBox(height: 15.w),
        const AiGenSectionTitle('运动描述(选填)'),
        SizedBox(height: 10.w),
        AiGenTextArea(
          controller: state.motionController,
          hint: '例如:镜头缓慢推近，风吹动树叶',
        ),
        SizedBox(height: 15.w),
        GetBuilder<AiImageToVideoLogic>(
          id: 'options',
          builder: (_) => Row(
            children: [
              AiGenDropdownField(
                title: '视频时长',
                value: state.durations[state.durationIndex].label,
                onTap: () => controller.pickDuration(context),
              ),
              SizedBox(width: 12.w),
              AiGenDropdownField(
                title: '分辨率',
                value: state.resolutions[state.resolutionIndex].label,
                onTap: () => controller.pickResolution(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
