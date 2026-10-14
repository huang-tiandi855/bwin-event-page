import 'package:comics_app/common/entities/ai/ai_models.dart';
import 'package:flutter/material.dart';

class AiTextToImageState {
  AiBillingRuleVo? rule;
  int costCoins = 0;
  final TextEditingController promptController = TextEditingController();

  final List<String> counts = ['1张', '2张'];
  final List<String> sizes = ['512x512', '768x768', '1024x1024'];
  int countIndex = 0;
  int sizeIndex = 0;

  String get pageTitle => rule?.name ?? '文生图片';

  void dispose() {
    promptController.dispose();
  }
}
