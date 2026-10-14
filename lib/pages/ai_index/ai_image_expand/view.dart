import 'package:comics_app/common/entities/ai/ai_params.dart';
import 'package:comics_app/pages/ai_index/widgets/ai_gen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'logic.dart';

/// AI「图片拓展」。
class AiImageExpandPage extends GetView<AiImageExpandLogic> {
  const AiImageExpandPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return AiGenScaffold(
      title: state.pageTitle,
      submit: GetBuilder<AiImageExpandLogic>(
        id: 'submit',
        builder: (_) => AiGenSubmitButton(
          enabled: controller.canSubmit,
          onTap: () => controller.startGenerate(context),
        ),
      ),
      children: [
        GetBuilder<AiImageExpandLogic>(
          builder: (_) => AiGenCostCard(
            costCoins: state.costCoins,
            remainCoins: controller.remainCoins,
            costText: controller.costText,
            balanceText: controller.balanceText,
          ),
        ),
        SizedBox(height: 15.w),
        GetBuilder<AiImageExpandLogic>(
          id: 'options',
          builder: (_) => AiGenChipSection(
            title: '风格模版',
            options: AiParams.labelsOf(state.styleTemplates),
            selectedIndex: state.styleIndex,
            onSelected: controller.selectStyle,
          ),
        ),
        SizedBox(height: 15.w),
        const AiGenSectionTitle('上传图片'),
        SizedBox(height: 10.w),
        GetBuilder<AiImageExpandLogic>(
          id: 'image',
          builder: (_) => AiGenUploadBox(
            localPath: state.localImagePath,
            onPick: controller.pickImage,
            onClear: controller.clearImage,
            actionText: '请上传您要拓展的图片',
          ),
        ),
        SizedBox(height: 15.w),
        const AiGenSectionTitle('拓展描述(选填)'),
        SizedBox(height: 10.w),
        AiGenTextArea(
          controller: state.descController,
          hint: '描述拓展方向，例如:向外延伸山脉，保持风格一致',
        ),
        SizedBox(height: 15.w),
        GetBuilder<AiImageExpandLogic>(
          id: 'options',
          builder: (_) => AiGenFullDropdownField(
            title: '输出尺寸',
            value: state.sizes[state.sizeIndex].label,
            onTap: () => controller.pickSize(context),
          ),
        ),
      ],
    );
  }
}
