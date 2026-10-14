import 'package:comics_app/common/entities/ai/ai_models.dart';
import 'package:flutter/material.dart';

class AiCustomState {
  AiBillingRuleVo? rule;
  int costCoins = 0;
  final TextEditingController promptController = TextEditingController();
  final TextEditingController negativeController = TextEditingController();

  String? localImagePath;
  String? remoteImageUrl;

  final List<String> resolutions = [
    '竖屏 480x832',
    '竖屏 704x1280',
    '横屏 832x480',
    '横屏 1280x704',
  ];
  final List<String> durations = ['5秒'];

  int resolutionIndex = 0;
  int durationIndex = 0;

  bool get hasImage =>
      localImagePath != null && localImagePath!.trim().isNotEmpty;

  String get pageTitle => rule?.name ?? '自定义视频';

  void dispose() {
    promptController.dispose();
    negativeController.dispose();
  }
}
