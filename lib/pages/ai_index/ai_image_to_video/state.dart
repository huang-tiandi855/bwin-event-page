import 'package:comics_app/common/entities/ai/ai_models.dart';
import 'package:comics_app/common/entities/ai/ai_params.dart';
import 'package:flutter/material.dart';

class AiImageToVideoState {
  AiBillingRuleVo? rule;
  int costCoins = 0;
  final TextEditingController motionController = TextEditingController();

  String? localImagePath;
  String? remoteImageUrl;

  final List<AiOptionItem> styleTemplates = AiParams.imageToVideoStyles;
  final List<AiOptionItem> durations = AiParams.imageToVideoDurations;
  final List<AiOptionItem> resolutions = AiParams.imageToVideoResolutions;

  int styleIndex = -1;
  int durationIndex = 0;
  int resolutionIndex = 0;

  bool get hasImage =>
      localImagePath != null && localImagePath!.trim().isNotEmpty;

  String get pageTitle => rule?.name ?? '图生视频';

  void dispose() {
    motionController.dispose();
  }
}
