import 'dart:convert';
import 'dart:math';

import 'package:comics_app/common/entities/circle/post_card_data.dart';
import 'package:comics_app/common/entities/media_info.dart';
import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/entities/module_detail_model/content_model.dart';
import 'package:comics_app/common/entities/video_model/video_model.dart';
import 'package:comics_app/common/services/storage.dart';
import 'package:comics_app/common/utils/light_model.dart';
import 'package:comics_app/common/utils/logger.dart';
import 'package:comics_app/common/values/enum.dart';
import 'package:get/get.dart';

import '../../entities/circle/game_data_model.dart';
import 'history_record_model.dart';

export 'history_record_model.dart';

Map<String, dynamic>? getLastRead(kind) {
  final info = StorageService.to.read("$kind")?.first;
  if (info != null) {
    final AllMediaInfoModel? model =
        HistoryOperation.getInstance()?.historyToInfoModel(info);
    return {"data": model, "index": info["episode"]};
  }
  return null;
}

class HistoryOperation {
  static HistoryOperation? _instance;
  int maxCount = 100;

  // 私有的命名构造函数
  HistoryOperation._internal();

  static HistoryOperation? getInstance() {
    _instance ??= HistoryOperation._internal();

    return _instance;
  }

  /// 写入长视频 / 写真等浏览记录：直接落 [MediaInfo] JSON（与帖子存
  /// [PostCardData] 同思路），并附带 [episode] / [duration] 供续播。
  add({
    required MediaInfo? info,
    required int episode,
    int? duration,
    HistoryRecordType recordType = HistoryRecordType.video,
  }) {
    try {
      if (info == null || _mediaInfoId(info) == null) return;
      _insertMediaInfoHistory(
        _historyRecordKey(recordType),
        info,
        episode: episode,
        duration: duration,
      );
    } catch (e) {
      l.d('$e', tag: 'error');
    }
  }

  String _historyRecordKey(HistoryRecordType type) => type.toString();

  String _storageKey(dynamic type) {
    if (type is HistoryRecordType) {
      return _historyRecordKey(type);
    }
    if (type is MediaKind) {
      return type.index.toString();
    }
    return type.toString();
  }

  HistoryRecordModel _historyRecordFromStorage(dynamic value) {
    if (value is HistoryRecordModel) return value;
    if (value is Map) {
      return HistoryRecordModel.fromJson(Map<String, dynamic>.from(value));
    }
    return HistoryRecordModel.fromJson(<String, dynamic>{});
  }

  List<HistoryRecordModel> _readStorageHistory(String key) {
    final list = StorageService.to.read(key) ?? [];
    if (list is! List) return [];
    return list.map(_historyRecordFromStorage).toList();
  }

  void _writeStorageHistory(
    String key,
    List<HistoryRecordModel> list,
  ) {
    StorageService.to.white(key, list.map((e) => e.toJson()).toList());
  }

  void _insertStorageHistory(String key, HistoryRecordModel data) {
    final list = _readStorageHistory(key);
    final mediaId = data.mediaID ?? data.id;
    list.removeWhere((element) => (element.mediaID ?? element.id) == mediaId);
    if (list.length > maxCount) {
      list.removeLast();
    }
    list.insert(0, data);
    _writeStorageHistory(key, list);
  }

  AllMediaInfoModel historyToInfoModel(Map<String, dynamic> data) {
    return AllMediaInfoModel(
        id: data['mediaID'],
        title: data['title'],
        permission: data['permission'],
        horizontalCover: data['horizontalCover'],
        verticalCover: data['verticalCover'],
        direction: data['direction'],
        tagNames: data['tagNames'],
        tags: data['tags'],
        kind: data['kind'],
        price: data['price'],
        totalEpisode: data['totalEpisode'],
        contents: data['contents'].map((e) => ContentModel.fromJson(e)));
  }

  //添加历史记录
  addAllMedia({
    required AllMediaInfoModel? info, //媒体信息
    required int episode, //当前播放的集数
  }) {
    try {
      if (info?.kind == null) return;
      final data = HistoryRecordModel.fromAllMedia(info!, episode: episode);
      _insertStorageHistory(info.kind.toString(), data);
    } catch (e) {
      l.d('$e', tag: 'error');
    }
  }

  // 添加短视频/视频历史记录（旧 VideoModel 路径，保留兼容）
  addVideoModel({
    required VideoModel? info,
    HistoryRecordType recordType = HistoryRecordType.short,
  }) {
    try {
      if (info?.id == null) return;
      final data = HistoryRecordModel.fromVideoModel(
        info!,
        recordType: recordType,
      );
      _insertStorageHistory(_historyRecordKey(recordType), data);
    } catch (e) {
      l.d('$e', tag: 'error');
    }
  }

  /// 写入短视频浏览记录：直接落 [MediaInfo] JSON。
  addShortVideoModel({
    required MediaInfo? info,
    HistoryRecordType recordType = HistoryRecordType.short,
  }) {
    try {
      if (info == null || _mediaInfoId(info) == null) return;
      _insertMediaInfoHistory(_historyRecordKey(recordType), info);
    } catch (e) {
      l.d('$e', tag: 'error');
    }
  }

  /// 取出长/短视频浏览历史（按插入顺序倒序）。
  ///
  /// 与 [getPostCardHistory] 平行：存储已改为 [MediaInfo] JSON，
  /// 「我的 - 历史记录」影片 / 抖音 Tab 应使用本方法。
  List<MediaInfo> getMediaInfoHistory(HistoryRecordType type) {
    return _readMediaInfoHistory(_historyRecordKey(type));
  }

  /// 按媒体 id 查续播信息（[episode] / [duration]）。
  Map<String, dynamic>? queryMediaHistoryById(
    HistoryRecordType type,
    String id,
  ) {
    try {
      if (id.isEmpty) return null;
      final list = _readMediaInfoRaw(_historyRecordKey(type));
      for (final map in list) {
        if (_rawMediaId(map) == id) return map;
      }
      return null;
    } catch (e) {
      l.d('$e', tag: 'error');
      return null;
    }
  }

  String? _mediaInfoId(MediaInfo info) {
    final vodId = info.result?.vod?.id;
    if (vodId != null) return vodId.toString();
    final dataId = info.data?.id;
    if (dataId != null && dataId.isNotEmpty) return dataId;
    return null;
  }

  String? _rawMediaId(Map<String, dynamic> json) {
    final result = json['result'];
    if (result is Map) {
      final vod = result['vod'];
      if (vod is Map && vod['id'] != null) {
        return vod['id'].toString();
      }
    }
    final data = json['data'];
    if (data is Map && data['id'] != null) {
      return data['id'].toString();
    }
    return (json['id'] ?? json['mediaID'])?.toString();
  }

  List<Map<String, dynamic>> _readMediaInfoRaw(String key) {
    final raw = StorageService.to.read(key);
    if (raw is! List) return <Map<String, dynamic>>[];
    final out = <Map<String, dynamic>>[];
    for (final dynamic e in raw) {
      if (e is Map) {
        out.add(Map<String, dynamic>.from(e));
      }
    }
    return out;
  }

  List<MediaInfo> _readMediaInfoHistory(String key) {
    final out = <MediaInfo>[];
    for (final map in _readMediaInfoRaw(key)) {
      // 旧版 HistoryRecordModel 无 result/data 包装，跳过避免脏数据污染列表。
      if (map['result'] is! Map && map['data'] is! Map && map['code'] == null) {
        continue;
      }
      out.add(_mediaInfoFromHistoryJson(map));
    }
    return out;
  }

  /// 历史落库是 [MediaInfo.toJson]（同时带 `result` + `data`）。
  ///
  /// [MediaInfo.fromJson] 会优先吃 `data`，导致 `result.vod`（含 tags / isVip /
  /// gold）在回读时丢失；这里有 `result` 时只用它还原，保证角标与标签可用。
  MediaInfo _mediaInfoFromHistoryJson(Map<String, dynamic> map) {
    if (map['result'] is Map) {
      return MediaInfo.fromJson(<String, dynamic>{
        'code': map['code'],
        'message': map['message'],
        'msg': map['msg'],
        'total': map['total'],
        'hash': map['hash'],
        'time': map['time'],
        'tip': map['tip'],
        'result': map['result'],
      });
    }
    return MediaInfo.fromJson(map);
  }

  void _insertMediaInfoHistory(
    String key,
    MediaInfo info, {
    int? episode,
    int? duration,
  }) {
    final id = _mediaInfoId(info);
    if (id == null) return;
    final list = _readMediaInfoRaw(key);
    list.removeWhere((element) => _rawMediaId(element) == id);
    if (list.length >= maxCount) {
      list.removeLast();
    }
    final json = info.toJson();
    if (episode != null) json['episode'] = episode;
    if (duration != null) json['duration'] = duration;
    list.insert(0, json);
    StorageService.to.white(key, list);
  }

  /// 写入帖子浏览记录。
  ///
  /// 直接以 [PostCardData] 的 JSON 入库，不再经过 [HistoryRecordModel] 的二次
  /// 转换，方便消费方（如「我的 - 浏览记录」帖子 Tab、详情页回跳）拿到完整
  /// 的列表卡片数据来还原 UI；读取走 [getPostCardHistory]。
  addPost({required PostCardData? info}) {
    try {
      if (info == null || info.id == 0) return;
      final key = _historyRecordKey(HistoryRecordType.post);
      final list = _readPostCardHistory(key);
      list.removeWhere((PostCardData e) => e.id == info.id);
      if (list.length >= maxCount) {
        list.removeLast();
      }
      list.insert(0, info);
      StorageService.to.white(
        key,
        list.map((PostCardData e) => e.toJson()).toList(),
      );
    } catch (e) {
      l.d('$e', tag: 'error');
    }
  }

  /// 取出帖子浏览历史（按插入顺序倒序）。
  ///
  /// 与 [getHistoryRecords] 平行存在：因为帖子的存储格式现在是 [PostCardData]
  /// 的 JSON，无法再通过 [_historyRecordFromStorage] 反序列化成
  /// [HistoryRecordModel]。`mine_history_record/logic.dart` 帖子 Tab 等
  /// 消费方应使用本方法。
  List<PostCardData> getPostCardHistory() {
    return _readPostCardHistory(_historyRecordKey(HistoryRecordType.post));
  }

  List<PostCardData> _readPostCardHistory(String key) {
    final raw = StorageService.to.read(key);
    if (raw is! List) return <PostCardData>[];
    final out = <PostCardData>[];
    for (final dynamic e in raw) {
      if (e is PostCardData) {
        out.add(e);
      } else if (e is Map) {
        out.add(PostCardData.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    return out;
  }

  /// 删除 [insertHistoryModel] / [fetchHistorys] 写入的某条记录（lightKV）
  Future<bool> deleteHistoryModelAt(HistoryRecordType type, int index) async {
    try {
      final list = await fetchHistorys<VideoModel>(type);
      if (index < 0 || index >= list.length) return false;
      list.removeAt(index);
      final temp = list
          .map((e) => jsonEncode(historyModelToJsonString<VideoModel>(e)))
          .toList();
      final res = await lightKV.setStringList(_historyRecordKey(type), temp);
      return res ?? false;
    } catch (e) {
      l.d('$e', tag: 'error');
      return false;
    }
  }

  List<HistoryRecordModel> getHistoryRecords(HistoryRecordType type) {
    return _readStorageHistory(_historyRecordKey(type));
  }

  //删除历史记录
  bool delete(dynamic type, int index) {
    try {
      final key = _storageKey(type);
      // 走原始 List 操作，避免在帖子 key 下被强解成 HistoryRecordModel
      // 而把 PostCardData JSON 中未识别的字段抹平。
      final raw = StorageService.to.read(key);
      if (raw is! List) return false;
      final list = List<dynamic>.from(raw);
      if (index < 0 || index >= list.length) return false;
      list.removeAt(index);
      StorageService.to.white(key, list);
      return true;
    } catch (e) {
      l.d('$e', tag: 'error');
      return false;
    }
  }

  //清空历史记录
  Future<bool> clear(dynamic type) async {
    try {
      await StorageService.to.remove(_storageKey(type));
      return true;
    } catch (e) {
      l.d('$e', tag: 'error');
      return false;
    }
  }

  //通过id查询数据
  queryDataById(dynamic type, String id) {
    try {
      List list = _readStorageHistory(_storageKey(type));
      if (list.isNotEmpty) {
        var map = list.where((e) => e['mediaID'] == id).toList();
        if (map.isNotEmpty) {
          return map[0]['episode'];
        }
        return null;
      }
      return null;
    } catch (e) {
      l.d('$e', tag: 'error');
      return null;
    }
  }

  //通过id查询数据
  queryMapById(dynamic kind, String id) {
    try {
      List list = _readStorageHistory(_storageKey(kind));
      if (list.isNotEmpty) {
        var map = list.where((e) => e['mediaID'] == id).toList();
        return map[0];
      }
      return null;
    } catch (e) {
      l.d('$e', tag: 'error');
      return null;
    }
  }

  //通过id查询数据
  queryDataByKindId(dynamic kind, String id) {
    try {
      List list = _readStorageHistory(_storageKey(kind));
      if (list.isNotEmpty) {
        var map = list.where((e) => e['mediaID'] == id).toList();
        if (map.isNotEmpty) {
          return map[0]['episode'];
        }
        return null;
      }
      return null;
    } catch (e) {
      l.d('$e', tag: 'error');
      return null;
    }
  }

  //查询历史
  List? get(dynamic type) {
    return _readStorageHistory(_storageKey(type));
  }

  insertHistoryModel<T>(T model, HistoryRecordType type) async {
    if (model == null) return;
    try {
      final id = getModelId(model);
      final historys = await fetchHistorys<T>(type);
      final cm =
          historys.firstWhereOrNull((element) => getModelId<T>(element) == id);
      if (cm != null) {
        historys.remove(cm);
        historys.insert(0, cm);
      } else {
        historys.insert(0, model);
      }
      final temp = historys.map((e) {
        final json = historyModelToJsonString<T>(e);
        return jsonEncode(json);
      }).toList();
      await lightKV.setStringList(
          _historyRecordKey(type), temp.sublist(0, min(20, temp.length)));
    } catch (e) {
      l.d('insertHistoryModel $e');
    }
  }

  Map<String, dynamic> historyModelToJsonString<T>(T model) {
    switch (T) {
      case VideoModel:
        return (model as VideoModel).toJson();
      // case CartoonMediaInfo:
      //   return (model as CartoonMediaInfo).toJson();
      // case CollectionModel:
      //   return (model as CollectionModel).toJson();
      default:
        return (model as VideoModel).toJson();
    }
  }

  T? historyJsonStrToModel<T>(String jsons) {
    final json = Map<String, dynamic>.from(jsonDecode(jsons));
    switch (T) {
      case VideoModel:
        return VideoModel.fromJson(json) as T;
      // case CartoonMediaInfo:
      //   return CartoonMediaInfo.fromJson(json) as T;
      // case CollectionModel:
      //   return CollectionModel.fromJson(json) as T;
      default:
        return VideoModel.fromJson(json) as T;
    }
  }

  String? getModelId<T>(T model) {
    switch (T) {
      case VideoModel:
        return (model as VideoModel).id;
      // case CartoonMediaInfo:
      //   return (model as CartoonMediaInfo).id;
      // case CollectionModel:
      //   return (model as CollectionModel).id;
      default:
        return null;
    }
  }

  Future<List<T>> fetchHistorys<T>(HistoryRecordType type) async {
    try {
      final historys = await lightKV.getStringList(_historyRecordKey(type));
      if (historys?.isEmpty ?? true) return <T>[];
      return List<T>.from(historys!.map((e) {
        return historyJsonStrToModel<T>(e);
      }).toList());
    } catch (e) {
      l.d('fetchHistorys $e');
      return <T>[];
    }
  }

  Future<bool> clearRecordHistoryByType(HistoryRecordType type) async {
    try {
      await StorageService.to.remove(_historyRecordKey(type));
      final res = await lightKV.setStringList(_historyRecordKey(type), []);

      return res ?? false;
    } catch (e) {
      l.d('fetchHistorys $e');
      return false;
    }
  }



  /// 写入游戏浏览记录，直接以 [GameDataModel] JSON 入库；读取走 [getGameHistory]。
  addGame({required GameDataModel? info}) {
    try {
      if (info == null || info.id == 0) return;
      final key = _historyRecordKey(HistoryRecordType.game);
      final list = _readGameHistory(key);
      list.removeWhere((GameDataModel e) => e.id == info.id);
      if (list.length >= maxCount) {
        list.removeLast();
      }
      list.insert(0, info);
      StorageService.to.white(
        key,
        list.map((GameDataModel e) => e.toJson()).toList(),
      );
    } catch (e) {
      l.d('$e', tag: 'error');
    }
  }

  /// 取出游戏浏览历史（按插入顺序倒序）。
  List<GameDataModel> getGameHistory() {
    return _readGameHistory(_historyRecordKey(HistoryRecordType.game));
  }

  List<GameDataModel> _readGameHistory(String key) {
    final raw = StorageService.to.read(key);
    if (raw is! List) return <GameDataModel>[];
    final out = <GameDataModel>[];
    for (final dynamic e in raw) {
      if (e is GameDataModel) {
        out.add(e);
      } else if (e is Map) {
        out.add(GameDataModel.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    return out;
  }
}
