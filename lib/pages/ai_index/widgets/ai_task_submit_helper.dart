import 'package:comics_app/common/apis/ai_api.dart';
import 'package:comics_app/common/entities/ai/ai_models.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/widgets/common_dialog/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// AI 各功能页提交后的公共收尾：刷新余额/home，进入进度页。
class AiTaskSubmitHelper {
  AiTaskSubmitHelper._();

  /// 从路由参数取出首页传入的 [AiBillingRuleVo]。
  static AiBillingRuleVo? ruleFromArgs() {
    final args = Get.arguments;
    if (args is AiBillingRuleVo) return args;
    if (args is Map) {
      final rule = args['rule'];
      if (rule is AiBillingRuleVo) return rule;
    }
    return null;
  }

  /// 从「N张」类文案解析出图数。
  static int parseImageNum(String label, {int fallback = 1}) {
    final m = RegExp(r'(\d+)').firstMatch(label);
    if (m == null) return fallback;
    return int.tryParse(m.group(1)!) ?? fallback;
  }

  /// 自定义分辨率 label → 尺寸 value（取最后一段 `WxH`）。
  static String parseResolutionSize(String label) {
    final m =
        RegExp(r'(\d+)\s*[xX×]\s*(\d+)').firstMatch(label);
    if (m != null) return '${m.group(1)}x${m.group(2)}';
    return label.trim();
  }

  /// 应用规则价格到页面 `costCoins`；优先次数扣费且有剩余时费用视为 0。
  static int costCoinsFromRule(AiBillingRuleVo? rule) {
    if (rule == null) return 0;
    if (rule.deductMode == 2 && remainTimesOf(rule) > 0) return 0;
    return rule.goldPrice ?? 0;
  }

  static int remainTimesOf(AiBillingRuleVo? rule) {
    if (rule == null) return 0;
    final aiType = AIApi.aiTypeOfRuleCode(rule.ruleCode) ?? rule.aiType;
    final user = UserStore.to.getUserInfoModel;
    switch (aiType) {
      case AIApi.aiTypeImage:
        return user?.aiUndressTimes ?? rule.remainTimes ?? 0;
      case AIApi.aiTypeVideo:
        return user?.aiFaceSwapTimes ?? rule.remainTimes ?? 0;
      default:
        return rule.remainTimes ?? 0;
    }
  }

  /// 费用 Banner 主文案（与 H5 `formatRuleCost.costText` 对齐）。
  static String costTextOf(AiBillingRuleVo? rule) {
    if (rule == null) return '--';
    final remain = remainTimesOf(rule);
    if (rule.deductMode == 2 && remain > 0) return '1次';
    return '${rule.goldPrice ?? 0}金币';
  }

  /// 费用 Banner 副文案。
  static String balanceTextOf(AiBillingRuleVo? rule, int goldBalance) {
    final remain = remainTimesOf(rule);
    if (rule != null && rule.deductMode == 2 && remain > 0) {
      return '$remain 次';
    }
    return '$goldBalance 金币';
  }

  static void _applyLocalCost(AiTaskVo task, AiBillingRuleVo? rule) {
    final gold = task.userCostGold ?? 0;
    final times = task.userCostTimes ?? 0;
    final ruleCode = task.ruleCode ?? rule?.ruleCode;
    final aiType =
        AIApi.aiTypeOfRuleCode(ruleCode) ?? rule?.aiType ?? task.type;

    UserStore.to.applyLocalAiTaskCost(
      gold: gold,
      imageTimes: aiType == AIApi.aiTypeImage ? times : 0,
      videoTimes: aiType == AIApi.aiTypeVideo ? times : 0,
    );

    final home = AIApi.cachedHome;
    if (home == null) return;

    final nextGold = gold <= 0
        ? home.goldBalance
        : (home.goldBalance - gold < 0 ? 0 : home.goldBalance - gold);
    final nextRules = home.rules.map((item) {
      final itemType = AIApi.aiTypeOfRuleCode(item.ruleCode) ?? item.aiType;
      if (times <= 0 || itemType != aiType) return item;
      final current = item.remainTimes ?? 0;
      final next = current - times;
      return item.copyWith(remainTimes: next < 0 ? 0 : next);
    }).toList();

    AIApi.cachedHome = home.copyWith(
      goldBalance: nextGold,
      rules: nextRules,
    );
  }

  /// 执行 create，成功后刷新并跳转进度页。
  static Future<AiTaskVo?> submitAndOpenProgress({
    required BuildContext context,
    required Future<AiTaskVo?> Function() create,
    AiBillingRuleVo? billingRule,
    VoidCallback? onBalanceChanged,
    String? loadingMessage,
  }) async {
    final shown = await loadingDialog.show(
      context,
      message: loadingMessage ?? '提交中...',
      showTip: false,
      isDismissible: false,
    );
    if (!shown) return null;

    AiTaskVo? task;
    try {
      task = await create();
    } catch (_) {
      showToast(msg: '提交失败');
      return null;
    } finally {
      await loadingDialog.dismiss();
    }

    if (task == null || task.id == null) {
      return null;
    }

    _applyLocalCost(task, billingRule);
    onBalanceChanged?.call();

    try {
      await Future.wait([
        AIApi.getHome(),
        UserStore.to.refreshUser(),
      ]);
      onBalanceChanged?.call();
    } catch (_) {
      // The task already exists; a balance refresh failure is non-fatal.
    }

    if (!context.mounted) return task;
    showToast(msg: '任务已提交');
    Get.toNamed(
      AppRoutes.AI_TASK_PROGRESS,
      arguments: {
        'id': task.id,
        'task': task,
      },
    );
    return task;
  }
}
