import 'package:comics_app/common/entities/ai/ai_models.dart';
import 'package:comics_app/common/routers/app_routes.dart';

import '../../gen/assets.gen.dart';

class AiIndexState {
  AiClientHomeVo? homeModel;
  bool loading = false;

  /// 启用且按 [AiBillingRuleVo.sort] 降序后的规则（供宫格渲染）。
  List<AiBillingRuleVo> displayRules = const [];

  static List<AiBillingRuleVo> sortedEnabledRules(
      List<AiBillingRuleVo>? rules) {
    if (rules == null || rules.isEmpty) return const [];
    final list = rules.where((r) => r.status == null || r.status == 1).toList();
    list.sort((a, b) => (b.sort ?? 0).compareTo(a.sort ?? 0));
    return list;
  }

  String get tipText => '作品仅保留3个月，请及时下载';

  int get goldBalance => homeModel?.goldBalance ?? 0;

  /// [ruleCode] → 路由；未知返回 null。
  static String? routeOf(String? ruleCode) {
    switch (ruleCode) {
      case 'ai_undress':
        return AppRoutes.AI_ADVANCED_UNDRESS;
      case 'ai_text_to_image':
        return AppRoutes.AI_TEXT_TO_IMAGE;
      case 'ai_text_to_video':
        return AppRoutes.AI_TEXT_TO_VIDEO;
      case 'ai_image_expand':
        return AppRoutes.AI_IMAGE_EXPAND;
      case 'ai_image_to_video':
        return AppRoutes.AI_IMAGE_TO_VIDEO;
      case 'ai_custom':
        return AppRoutes.AI_CUSTOM;
      default:
        return null;
    }
  }

  /// [ruleCode] → 本地卡片背景图。
  static String coverOf(String? ruleCode) {
    switch (ruleCode) {
      case 'ai_undress':
        return AssetsGen.images.ai.aiUndressCover.path;
      case 'ai_text_to_image':
        return AssetsGen.images.ai.aiTextToImageCover.path;
      case 'ai_text_to_video':
        return AssetsGen.images.ai.aiTextToVideoCover.path;
      case 'ai_image_expand':
        return AssetsGen.images.ai.aiImageExpandCover.path;
      case 'ai_image_to_video':
        return AssetsGen.images.ai.aiImageToVideoCover.path;
      case 'ai_custom':
        return AssetsGen.images.ai.aiCustomCover.path;
      default:
        return AssetsGen.images.ai.aiCustomCover.path;
    }
  }

  /// [ruleCode] → 本地角标图。
  static String iconOf(String? ruleCode) {
    switch (ruleCode) {
      case 'ai_undress':
        return AssetsGen.images.ai.aiUndress;
      case 'ai_text_to_image':
        return AssetsGen.images.ai.aiTextToImage;
      case 'ai_text_to_video':
        return AssetsGen.images.ai.aiTextToVideo;
      case 'ai_image_expand':
        return AssetsGen.images.ai.aiImageExpand;
      case 'ai_image_to_video':
        return AssetsGen.images.ai.aiImageToVideo;
      case 'ai_custom':
        return AssetsGen.images.ai.aiCustom;
      default:
        return AssetsGen.images.ai.aiCustom;
    }
  }

  /// 本地约定的 HOT 入口（仅 UI 角标）。
  static bool isHot(String? ruleCode) {
    return ruleCode == 'ai_undress' ||
        ruleCode == 'ai_image_expand' ||
        ruleCode == 'ai_image_to_video' ||
        ruleCode == 'ai_custom';
  }

  /// 后端名称为空时使用与 H5 相同的本地标题。
  static String fallbackTitleOf(String? ruleCode) {
    switch (ruleCode) {
      case 'ai_undress':
        return '高级脱衣';
      case 'ai_text_to_image':
        return '文生图片';
      case 'ai_text_to_video':
        return '文生视频';
      case 'ai_image_expand':
        return '图片拓展';
      case 'ai_image_to_video':
        return '图生视频';
      case 'ai_custom':
        return '自定义视频';
      default:
        return 'AI创作';
    }
  }

  /// 后端介绍为空时使用与 H5 相同的本地介绍。
  static String fallbackDescriptionOf(String? ruleCode) {
    switch (ruleCode) {
      case 'ai_undress':
        return '更高级 更好玩 的脱衣';
      case 'ai_text_to_image':
        return '输入提示词 生成无限图片';
      case 'ai_text_to_video':
        return '实现您想象的 任何涩涩场景';
      case 'ai_image_expand':
        return '上传照片 解锁任何姿势';
      case 'ai_image_to_video':
        return '上传照片 解锁她的另一面';
      case 'ai_custom':
        return '上传她的照片 满足你内心的渴望';
      default:
        return '体验更多 AI 创作能力';
    }
  }
}
