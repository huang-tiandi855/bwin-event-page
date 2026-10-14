import 'package:comics_app/common/entities/ai/ai_models.dart';
import 'package:comics_app/common/entities/ai/ai_params.dart';

enum AiImageUploadStatus { idle, uploading, success }

class AiAdvancedUndressState {
  /// 首页传入的计费规则。
  AiBillingRuleVo? rule;

  /// 本次消耗金币（由 [rule] 计算）。
  int costCoins = 0;

  /// 本地待上传图片路径。
  String? localImagePath;

  /// 上传成功后的远程地址。
  String? remoteImageUrl;

  AiImageUploadStatus uploadStatus = AiImageUploadStatus.idle;
  double uploadProgress = 0;

  int modeIndex = 0;
  int breastIndex = 0;
  int hairIndex = 0;

  final List<AiOptionItem> modes = AiParams.advancedUndressModes;
  final List<AiOptionItem> breastSizes = AiParams.advancedUndressBreasts;
  final List<AiOptionItem> hairStyles = AiParams.advancedUndressPubics;

  static const int maxImageBytes = 10 * 1024 * 1024;

  bool get hasImage =>
      localImagePath != null && localImagePath!.trim().isNotEmpty;

  bool get isUploading => uploadStatus == AiImageUploadStatus.uploading;

  bool get isUploadSuccess =>
      uploadStatus == AiImageUploadStatus.success &&
      remoteImageUrl != null &&
      remoteImageUrl!.trim().isNotEmpty;

  String get pageTitle => '高级脱衣';
}
