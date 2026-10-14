import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/entities/video_model/tags_model.dart';
import 'package:comics_app/common/entities/video_model/video_model.dart';

/// 将 `cms/vod/list` 接口的 [MediaVideoModel] 转换为短视频沉浸式
/// 播放页 [ShortVideoPlayPage] 所需的 [VideoModel]。
///
/// 业务上多个入口（短视频 tab、垂直 tab、搜索资源库等）都会复用这套
/// 转换逻辑，统一收敛到此扩展，避免散落到各个 Logic 中重复实现。
extension MediaVideoModelShortPlayConvert on MediaVideoModel {
  VideoModel toShortPlayVideoModel() {
    final picInfo = vodPicInfo;
    final verticalCover = _pickNonEmpty([
      vodPic,
      picInfo?.verticalLarge,
      picInfo?.verticalSmall,
    ]);
    final cover = _pickNonEmpty([
      picInfo?.horizontalLarge,
      picInfo?.horizontalSmall,
      verticalCover,
    ]);
    final goldCoin = _toInt(gold) ?? 0;
    return VideoModel(
      id: id,
      newsType: 'SP',
      title: title,
      sourceUrl: vodSerialNumber?.toString(),
      playTime: vodDuration,
      cover: cover,
      verticalCover: verticalCover,
      playCount: readNumber,
      coins: goldCoin,
      originCoins: goldCoin,
      freeArea: !isVip && goldCoin <= 0,
      isRecommend: (recommend ?? 0) > 0,
      tags: _parseTags(tags),
    );
  }
}

String? _pickNonEmpty(List<String?> values) {
  for (final value in values) {
    final text = value?.trim();
    if (text != null && text.isNotEmpty) return text;
  }
  return null;
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

List<TagsModel> _parseTags(dynamic raw) {
  if (raw == null) return const [];
  if (raw is String) {
    final name = raw.trim();
    if (name.isEmpty) return const [];
    return [
      TagsModel.fromJson({'name': name})
    ];
  }
  if (raw is! List) return const [];

  return raw.map((item) {
    if (item is Map) {
      return TagsModel.fromJson(Map<String, dynamic>.from(item));
    }
    return TagsModel.fromJson({'name': item.toString()});
  }).toList();
}
