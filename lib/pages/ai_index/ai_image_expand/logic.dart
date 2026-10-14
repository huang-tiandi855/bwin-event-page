import 'package:comics_app/common/apis/ai_api.dart';
import 'package:comics_app/common/entities/ai/ai_params.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/pages/ai_index/widgets/ai_gen_media_helper.dart';
import 'package:comics_app/pages/ai_index/widgets/ai_gen_widgets.dart';
import 'package:comics_app/pages/ai_index/widgets/ai_task_submit_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'state.dart';

class AiImageExpandLogic extends GetxController {
  final state = AiImageExpandState();

  int get remainCoins =>
      AIApi.cachedHome?.goldBalance ??
      UserStore.to.getUserInfoModel?.walletApp ??
      0;
  bool get canSubmit => state.hasImage;

  String get costText => AiTaskSubmitHelper.costTextOf(state.rule);

  String get balanceText =>
      AiTaskSubmitHelper.balanceTextOf(state.rule, remainCoins);

  @override
  void onInit() {
    super.onInit();
    state.rule = AiTaskSubmitHelper.ruleFromArgs();
    state.costCoins = AiTaskSubmitHelper.costCoinsFromRule(state.rule);
    UserStore.to.refreshUser().then((_) => update()).catchError((_) {});
  }

  void selectStyle(int index) {
    state.styleIndex = index;
    update(['options']);
  }

  Future<void> pickImage() async {
    final path = await AiGenMediaHelper.pickLocalImage();
    if (path == null) return;
    state.localImagePath = path;
    state.remoteImageUrl = null;
    update(['image', 'submit']);
  }

  void clearImage() {
    state.localImagePath = null;
    state.remoteImageUrl = null;
    update(['image', 'submit']);
  }

  Future<void> pickSize(BuildContext context) async {
    final labels = AiParams.labelsOf(state.sizes);
    final v = await showAiGenOptionSheet(
      context,
      title: '输出尺寸',
      options: labels,
      selected: labels[state.sizeIndex],
    );
    if (v == null) return;
    state.sizeIndex = labels.indexOf(v);
    update(['options']);
  }

  Future<void> startGenerate(BuildContext context) async {
    if (!canSubmit) {
      showToast(msg: '请先上传源图');
      return;
    }
    final url =
        await AiGenMediaHelper.uploadLocalImage(context, state.localImagePath!);
    if (url == null) return;
    state.remoteImageUrl = url;

    final desc = state.descController.text.trim();
    final style = state.styleTemplates[state.styleIndex].value;
    final prompt = AiParams.buildImageExpandPrompt(
      style: style,
      extraDesc: desc,
    );
    if (context.mounted) {
      await AiTaskSubmitHelper.submitAndOpenProgress(
        context: context,
        billingRule: state.rule,
        onBalanceChanged: update,
        create: () => AIApi.expandCreate(
          images: AiParams.serializeAiImages([url]),
          prompt: prompt,
          size: state.sizes[state.sizeIndex].value,
          billingRule: state.rule,
        ),
      );
    }
  }

  @override
  void onClose() {
    state.dispose();
    super.onClose();
  }
}
