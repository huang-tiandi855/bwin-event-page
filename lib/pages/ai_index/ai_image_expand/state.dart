import 'package:comics_app/common/entities/ai/ai_models.dart';
import 'package:comics_app/common/entities/ai/ai_params.dart';
import 'package:flutter/material.dart';

class AiImageExpandState {
  AiBillingRuleVo? rule;
  int costCoins = 0;
  final TextEditingController descController = TextEditingController();

  String? localImagePath;
  String? remoteImageUrl;

  final List<AiOptionItem> styleTemplates = AiParams.imageExpandStyles;
  final List<AiOptionItem> sizes = AiParams.imageExpandSizes;

  int styleIndex = 0;
  int sizeIndex = 0;

  bool get hasImage =>
      localImagePath != null && localImagePath!.trim().isNotEmpty;

  String get pageTitle => rule?.name ?? '图片拓展';

  void dispose() {
    descController.dispose();
  }
}
