import 'package:comics_app/common/entities/ai/ai_models.dart';
import 'package:flutter/material.dart';

class AiTextToVideoState {
  AiBillingRuleVo? rule;
  int costCoins = 0;
  final TextEditingController promptController = TextEditingController();
  final TextEditingController negativeController = TextEditingController();

  String? localImagePath;
  String? remoteImageUrl;

  final List<String> sizes = ['768x512', '512x512', '1024x576'];
  final List<String> durations = ['5秒'];
  int sizeIndex = 0;
  int durationIndex = 0;

  bool get hasImage =>
      localImagePath != null && localImagePath!.trim().isNotEmpty;

  String get pageTitle => rule?.name ?? '文生视频';

  void dispose() {
    promptController.dispose();
    negativeController.dispose();
  }
}
