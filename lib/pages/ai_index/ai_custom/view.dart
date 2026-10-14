import 'package:comics_app/pages/ai_index/widgets/ai_gen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'logic.dart';

/// AI「自定义视频」。
class AiCustomPage extends GetView<AiCustomLogic> {
  const AiCustomPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return AiGenScaffold(
      title: state.pageTitle,
      submit: GetBuilder<AiCustomLogic>(
        id: 'submit',
        builder: (_) => AiGenSubmitButton(
          enabled: controller.canSubmit,
          onTap: () => controller.startGenerate(context),
        ),
      ),
      children: [
        GetBuilder<AiCustomLogic>(
          builder: (_) => AiGenCostCard(
            costCoins: state.costCoins,
            remainCoins: controller.remainCoins,
            costText: controller.costText,
            balanceText: controller.balanceText,
          ),
        ),
        SizedBox(height: 15.w),
        const AiGenSectionTitle('上传参考图片'),
        SizedBox(height: 10.w),
        GetBuilder<AiCustomLogic>(
          id: 'image',
          builder: (_) => AiGenUploadBox(
            localPath: state.localImagePath,
            onPick: controller.pickImage,
            onClear: controller.clearImage,
            actionText: '请上传您的图片',
          ),
        ),
        SizedBox(height: 15.w),
        const AiGenSectionTitle('视频描述（可自定义）（选填）'),
        SizedBox(height: 10.w),
        AiGenTextArea(
          controller: state.promptController,
          hint: '描述视频中想要的动作或场景',
        ),
        SizedBox(height: 15.w),
        const AiGenSectionTitle('反向提示词(选填)'),
        SizedBox(height: 10.w),
        AiGenTextArea(
          controller: state.negativeController,
          hint: '不希望出现的内容...',
          showCounter: false,
          minHeight: 112.w,
        ),
        SizedBox(height: 15.w),
        GetBuilder<AiCustomLogic>(
          id: 'options',
          builder: (_) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AiGenChipSection(
                title: '视频尺寸',
                options: state.resolutions,
                selectedIndex: state.resolutionIndex,
                onSelected: controller.selectResolution,
                columns: 2,
              ),
              SizedBox(height: 15.w),
              AiGenChipSection(
                title: '视频时长',
                options: state.durations,
                selectedIndex: state.durationIndex,
                onSelected: controller.selectDuration,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
