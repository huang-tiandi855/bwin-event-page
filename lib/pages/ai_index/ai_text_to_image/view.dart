import 'package:comics_app/pages/ai_index/widgets/ai_gen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'logic.dart';

/// AI「文生图片」。
class AiTextToImagePage extends GetView<AiTextToImageLogic> {
  const AiTextToImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return AiGenScaffold(
      title: state.pageTitle,
      submit: GetBuilder<AiTextToImageLogic>(
        id: 'submit',
        builder: (_) => AiGenSubmitButton(
          enabled: controller.canSubmit,
          onTap: () => controller.startGenerate(context),
        ),
      ),
      children: [
        GetBuilder<AiTextToImageLogic>(
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
          hint: '描述你想生成的画面，例如:穿着丝袜的可爱女孩...',
          showCounter: false,
          minHeight: 112.w,
          onChanged: (_) => controller.update(['submit']),
        ),
        SizedBox(height: 15.w),
        GetBuilder<AiTextToImageLogic>(
          id: 'options',
          builder: (_) => Row(
            children: [
              AiGenDropdownField(
                title: '图片数量',
                value: state.counts[state.countIndex],
                onTap: () => controller.pickCount(context),
              ),
              SizedBox(width: 12.w),
              AiGenDropdownField(
                title: '尺寸',
                value: state.sizes[state.sizeIndex],
                onTap: () => controller.pickSize(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
