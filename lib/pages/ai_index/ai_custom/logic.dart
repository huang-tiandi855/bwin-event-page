import 'package:comics_app/common/apis/ai_api.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/pages/ai_index/widgets/ai_gen_media_helper.dart';
import 'package:comics_app/pages/ai_index/widgets/ai_task_submit_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'state.dart';

class AiCustomLogic extends GetxController {
  final state = AiCustomState();

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

  void selectResolution(int index) {
    if (index < 0 || index >= state.resolutions.length) return;
    state.resolutionIndex = index;
    update(['options']);
  }

  void selectDuration(int index) {
    if (index < 0 || index >= state.durations.length) return;
    state.durationIndex = index;
    update(['options']);
  }

  Future<void> startGenerate(BuildContext context) async {
    if (!canSubmit) {
      showToast(msg: '请上传参考图片');
      return;
    }
    final url = await AiGenMediaHelper.uploadLocalImage(
      context,
      state.localImagePath!,
    );
    if (url == null) return;
    state.remoteImageUrl = url;
    final images = AIApi.serializePaths([url]);

    final prompt = state.promptController.text.trim();
    final negative = state.negativeController.text.trim();
    if (context.mounted) {
      await AiTaskSubmitHelper.submitAndOpenProgress(
        context: context,
        billingRule: state.rule,
        onBalanceChanged: update,
        create: () => AIApi.customVideoCreate(
          prompt: prompt.isEmpty ? null : prompt,
          images: images,
          negativePrompt: negative.isEmpty ? null : negative,
          size: AiTaskSubmitHelper.parseResolutionSize(
            state.resolutions[state.resolutionIndex],
          ),
          duration: 5,
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
