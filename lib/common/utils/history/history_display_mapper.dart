import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/entities/media_info.dart';
import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/entities/video_model/video_model.dart';

import 'history_record_model.dart';

/// 浏览记录 → 我的页列表展示模型。
///
/// 帖子浏览记录现在直接以 [PostCardData] 落库（由 [HistoryOperation.addPost] /
/// [HistoryOperation.getPostCardHistory] 收尾），不再走这里的 mapper。
///
/// 长/短视频浏览记录现在直接以 [MediaInfo] 落库（由 [HistoryOperation.add] /
/// [HistoryOperation.addShortVideoModel] / [HistoryOperation.getMediaInfoHistory]
/// 收尾），展示走 [fromMediaInfo]。
class HistoryDisplayMapper {
  static MediaVideoModel fromVideoModel(VideoModel model) {
    return MediaVideoModel(
      id: model.id,
      title: model.title,
      vodPic: model.autoCover,
      readNumber: model.playCount ?? model.pageViewCount,
      gold: model.originCoins ?? model.coins,
      isVip: model.freeArea == true,
    );
  }

  static MediaVideoModel fromMediaInfo(MediaInfo info) {
    final vod = info.result?.vod;
    final data = info.data;
    final tagList = _resolveTags(vod, data);
    final gold = vod?.gold ?? data?.price ?? 0;
    return MediaVideoModel(
      id: vod?.id?.toString() ?? data?.id,
      title: vod?.title ?? data?.title,
      vodPic: vod?.vodHorizontalPic ??
          vod?.vodPic ??
          vod?.vodVerticalPic ??
          data?.horizontalCover ??
          data?.verticalCover ??
          data?.autoCover,
      readNumber: vod?.readNumber ?? data?.countBrowse,
      gold: gold,
      collects: vod?.collects ?? data?.countCollect,
      tags: tagList,
      videoType: vod?.videoType,
      isVip: vod?.isVip ?? false,
      vodDuration: vod?.vodDuration,
    );
  }

  static List<String>? _resolveTags(
    MediaInfoVod? vod,
    AllMediaInfoModel? data,
  ) {
    final vodTags = vod?.tags;
    if (vodTags != null && vodTags.isNotEmpty) {
      return vodTags.where((e) => e.trim().isNotEmpty).toList();
    }
    final detailTags = data?.getTagsList() ?? const <String>[];
    if (detailTags.isNotEmpty) {
      return detailTags.where((e) => e.trim().isNotEmpty).toList();
    }
    final tagNames = data?.tagNames;
    if (tagNames != null && tagNames.isNotEmpty) {
      return tagNames.where((e) => e.trim().isNotEmpty).toList();
    }
    final tags = data?.tags;
    if (tags != null && tags.isNotEmpty) {
      return tags.where((e) => e.trim().isNotEmpty).toList();
    }
    return null;
  }

  /// 兼容旧版 [HistoryRecordModel] 落库数据。
  static MediaVideoModel fromHistoryRecord(HistoryRecordModel record) {
    return MediaVideoModel(
      id: record.id ?? record.mediaID,
      title: record.title,
      vodPic: record.horizontalCover ?? record.verticalCover,
      readNumber: record.countBrowse,
      gold: record.price,
      collects: record.collects,
      tags: record.tagNames,
    );
  }
}
