import 'package:comics_app/common/apis/ai_api.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/pages/ai_index/widgets/ai_gen_widgets.dart';
import 'package:comics_app/pages/ai_index/widgets/ai_task_submit_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'state.dart';

class AiTextToImageLogic extends GetxController {
  final state = AiTextToImageState();

  int get remainCoins =>
      AIApi.cachedHome?.goldBalance ??
      UserStore.to.getUserInfoModel?.walletApp ??
      0;
  bool get canSubmit => state.promptController.text.trim().isNotEmpty;

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

  Future<void> pickCount(BuildContext context) async {
    final v = await showAiGenOptionSheet(
      context,
      title: '图片数量',
      options: state.counts,
      selected: state.counts[state.countIndex],
    );
    if (v == null) return;
    state.countIndex = state.counts.indexOf(v);
    update(['options']);
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

  Future<void> startGenerate(BuildContext context) async {
    if (!canSubmit) {
      showToast(msg: '请填写创造描述');
      return;
    }
    final prompt = state.promptController.text.trim();
    final imageNum = AiTaskSubmitHelper.parseImageNum(
      state.counts[state.countIndex],
    );
    final size = state.sizes[state.sizeIndex];
    await AiTaskSubmitHelper.submitAndOpenProgress(
      context: context,
      billingRule: state.rule,
      onBalanceChanged: update,
      create: () => AIApi.imageCreate(
        prompt: prompt,
        imageNum: imageNum,
        size: size,
        billingRule: state.rule,
      ),
    );
  }

  @override
  void onClose() {
    state.dispose();
    super.onClose();
  }
}
