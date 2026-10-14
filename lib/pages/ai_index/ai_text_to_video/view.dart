import 'package:comics_app/pages/ai_index/widgets/ai_gen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'logic.dart';

/// AI「文生视频」。
class AiTextToVideoPage extends GetView<AiTextToVideoLogic> {
  const AiTextToVideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return AiGenScaffold(
      title: state.pageTitle,
      submit: GetBuilder<AiTextToVideoLogic>(
        id: 'submit',
        builder: (_) => AiGenSubmitButton(
          enabled: controller.canSubmit,
          onTap: () => controller.startGenerate(context),
        ),
      ),
      children: [
        GetBuilder<AiTextToVideoLogic>(
          builder: (_) => AiGenCostCard(
            costCoins: state.costCoins,
            remainCoins: controller.remainCoins,
            costText: controller.costText,
            balanceText: controller.balanceText,
          ),
        ),
        SizedBox(height: 15.w),
        const AiGenSectionTitle('创作描述(提示词)'),
        SizedBox(height: 10.w),
        AiGenTextArea(
          controller: state.promptController,
          hint: '描述你想生成的视频内容...',
          onChanged: (_) => controller.update(['submit']),
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
        const AiGenSectionTitle('上传人物图片(选填)'),
        SizedBox(height: 10.w),
        GetBuilder<AiTextToVideoLogic>(
          id: 'image',
          builder: (_) => AiGenUploadBox(
            localPath: state.localImagePath,
            onPick: controller.pickImage,
            onClear: controller.clearImage,
            actionText: '请选择您要上传的素材',
            height: 195.w,
          ),
        ),
        SizedBox(height: 15.w),
        GetBuilder<AiTextToVideoLogic>(
          id: 'options',
          builder: (_) => Row(
            children: [
              AiGenDropdownField(
                title: '尺寸',
                value: state.sizes[state.sizeIndex],
                onTap: () => controller.pickSize(context),
              ),
              SizedBox(width: 12.w),
              AiGenDropdownField(
                title: '时长',
                value: state.durations[state.durationIndex],
                onTap: () => controller.pickDuration(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
