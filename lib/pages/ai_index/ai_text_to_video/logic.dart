import 'package:comics_app/common/apis/ai_api.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/pages/ai_index/widgets/ai_gen_media_helper.dart';
import 'package:comics_app/pages/ai_index/widgets/ai_gen_widgets.dart';
import 'package:comics_app/pages/ai_index/widgets/ai_task_submit_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'state.dart';

class AiTextToVideoLogic extends GetxController {
  final state = AiTextToVideoState();

  int get remainCoins =>
      AIApi.cachedHome?.goldBalance ??
      UserStore.to.getUserInfoModel?.walletApp ??
      0;
  bool get canSubmit =>
      state.promptController.text.trim().isNotEmpty && state.hasImage;

  String get costText => AiTaskSubmitHelper.costTextOf(state.rule);

  String get balanceText =>
      AiTaskSubmitHelper.balanceTextOf(state.rule, remainCoins);

  @override
  void onInit() {
    super.onInit();
    state.rule = AiTaskSubmitHelper.ruleFromArgs();
    state.costCoins = AiTaskSubmitHelper.costCoinsFromRule(state.rule);
    state.promptController.addListener(() => update(['submit']));
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

  Future<void> pickSize(BuildContext context) async {
    final v = await showAiGenOptionSheet(
      context,
      title: '尺寸',
      options: state.sizes,
      selected: state.sizes[state.sizeIndex],
    );
    if (v == null) return;
    state.sizeIndex = state.sizes.indexOf(v);
    update(['options']);
  }

  Future<void> pickDuration(BuildContext context) async {
    final v = await showAiGenOptionSheet(
      context,
      title: '时长',
      options: state.durations,
      selected: state.durations[state.durationIndex],
    );
    if (v == null) return;
    state.durationIndex = state.durations.indexOf(v);
    update(['options']);
  }

  Future<void> startGenerate(BuildContext context) async {
    if (state.promptController.text.trim().isEmpty) {
      showToast(msg: '请填写视频描述');
      return;
    }
    if (!state.hasImage) {
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
    final negative = state.negativeController.text.trim();
    if (context.mounted) {
      await AiTaskSubmitHelper.submitAndOpenProgress(
        context: context,
        billingRule: state.rule,
        onBalanceChanged: update,
        create: () => AIApi.textVideoCreate(
          prompt: state.promptController.text.trim(),
          negativePrompt: negative.isEmpty ? null : negative,
          images: images,
          size: state.sizes[state.sizeIndex],
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
