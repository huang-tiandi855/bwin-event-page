import 'dart:convert';

import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'debug_log.dart';
import 'light_model.dart';

class MediaPlayRecordModel<T> {
  final T model;
  final int episode;
  final Duration position;

  final DateTime lastPlayTime;

  MediaPlayRecordModel({
    required this.model,
    this.episode = 1,
    this.position = Duration.zero,
    required this.lastPlayTime,
  });

  Map<String, dynamic> toJson({
    required Map<String, dynamic> Function(T) modelFactory,
  }) {
    return {
      'lastPlayTime': lastPlayTime.millisecondsSinceEpoch,
      'model': modelFactory(model),
      'episode': episode,
      'position': position.inSeconds,
    };
  }

  factory MediaPlayRecordModel.fromJson({
    required Map<String, dynamic> json,
    required T Function(Map<String, dynamic>) modelFactory,
  }) {
    return MediaPlayRecordModel(
      lastPlayTime: DateTime.fromMillisecondsSinceEpoch(json['lastPlayTime']),
      model: modelFactory(json['model']),
      episode: json['episode'] ?? 1,
      position: Duration(seconds: json['position'] ?? 0),
    );
  }
}

class MediaPlayRecord {
  factory MediaPlayRecord() {
    _instance ??= MediaPlayRecord._();
    return _instance!;
  }

  static MediaPlayRecord get sharedInstance => MediaPlayRecord();

  static MediaPlayRecord? _instance;

  MediaPlayRecord._();

  final String historySkitsKey = 'historySkitsKey'; //短剧

  Map<String, MediaPlayRecordModel<AllMediaInfoModel>>? skitsRecords;

  //添加短剧播放记录
  Future<void> insertSkits({
    required AllMediaInfoModel model,
    int episode = 0,
    Duration position = Duration.zero,
  }) async {
    skitsRecords ??= await getSkitsRecords();
    Map<String, MediaPlayRecordModel<AllMediaInfoModel>> temp = Map.from(skitsRecords ?? {});
    temp[model.id!] = MediaPlayRecordModel(
      model: model,
      episode: episode,
      position: position,
      lastPlayTime: DateTime.now(),
    );
    // 根据lastPlayTime排序，最后加入的在最前面
    final sortedEntries = temp.entries.toList()..sort((a, b) => b.value.lastPlayTime.compareTo(a.value.lastPlayTime));

    // 如果记录超过50个，只保留前50个
    if (sortedEntries.length > 50) {
      sortedEntries.removeRange(50, sortedEntries.length);
    }

    temp = Map.fromEntries(sortedEntries);

    try {
      final value = temp.map((key, value) {
        return MapEntry(key, value.toJson(modelFactory: (model) => model.toJson()));
      });

      await lightKV.setString(historySkitsKey, json.encode(value));
      skitsRecords = temp;
    } catch (e) {
      debugLog(e);
    }
  }

  //获取短剧播放记录
  Future<Map<String, MediaPlayRecordModel<AllMediaInfoModel>>> getSkitsRecords() async {
    if (skitsRecords != null) {
      return Future.value(skitsRecords);
    }

    try {
      final result = await lightKV.getString(historySkitsKey);
      if (result == null) {
        return {};
      } else {
        final map = json.decode(result);
        if (map is Map) {
          return map.map((key, value) {
            return MapEntry(
              key,
              MediaPlayRecordModel.fromJson(
                json: value,
                modelFactory: AllMediaInfoModel.fromJson,
              ),
            );
          });
        }
        return {};
      }
    } catch (e) {
      return {};
    }
  }
}
