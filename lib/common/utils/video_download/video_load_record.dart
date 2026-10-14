import 'dart:convert';
import 'package:comics_app/common/entities/module_detail_model/content_model.dart';

import '../../utils/light_model.dart';
import '../const.dart';
import '../date_time_util.dart';
import '../debug_log.dart';

class VideoLoadRecord {
  // 工厂方法构造函数
  factory VideoLoadRecord() => _getInstance();

  static VideoLoadRecord get instance => _getInstance();

  // 静态变量_instance，存储唯一对象
  static VideoLoadRecord? _instance;

  VideoLoadRecord._internal();

  // 获取对象
  static VideoLoadRecord _getInstance() {
    _instance ??= VideoLoadRecord._internal();
    return _instance!;
  }

  static const String _playMovieCacheVideoListKey =
      "AppPlayMovieCacheVideoListKey";
  static const String _playShortCacheVideoListKey =
      "AppPlayShortCacheVideoListKey";
  static const String _playCartoonCacheVideoListKey =
      "AppPlayCartoonCacheVideoListKey";

  static const String _loadMovieCacheCountKey = "AppMovieCacheCountKey";

  /// 缓存记录
  Future<List<ContentModel>> getMovieCacheVideoList(CacheMediaType type) async {
    List<ContentModel> videoList = [];
    String localKey = _playMovieCacheVideoListKey;
    if (type == CacheMediaType.short) {
      localKey = _playShortCacheVideoListKey;
    }
    if (type == CacheMediaType.cartoon) {
      localKey = _playCartoonCacheVideoListKey;
    }
    var listString = await lightKV.getStringList(localKey) ?? [];
    for (String element in listString) {
      var jsonMap = json.decode(element);
      videoList.add(ContentModel.fromJson(jsonMap));
    }
    return videoList;
  }

  Future<int> getVideoLoadCount() async {
    String todayKey = DateTimeUtil.utc3YearMonthDay(DateTime.now());
    var localStr = await lightKV.getString(_loadMovieCacheCountKey) ?? "";
    if (localStr.isEmpty) return 5;
    var jsonMap = json.decode(localStr);
    if (jsonMap[todayKey] != null && jsonMap[todayKey] is int) {
      return jsonMap[todayKey];
    }
    return 5;
  }

  saveVideoLoadCount(int count) async {
    try {
      String todayKey = DateTimeUtil.utc3YearMonthDay(DateTime.now());
      if (todayKey.isEmpty) return;
      Map<String, int> countMap = {todayKey: count};
      String mapString = json.encode(countMap);
      await lightKV.setString(_loadMovieCacheCountKey, mapString);
    } catch (e) {
      debugLog(e);
    }
  }

  Future<bool> isExistLoadVideoByUrl(CacheMediaType type, String url) async {
    var videoArr = await getMovieCacheVideoList(type);
    for (var model in videoArr) {
      if (model.videoUrl == url) {
        return true;
      }
    }
    return false;
  }

  saveVideoInfo(CacheMediaType type, ContentModel? video) async {
    if (video == null) return;
    List<String> listString = [];
    List<ContentModel> videoList = [];

    videoList = await getMovieCacheVideoList(type);
    videoList.insert(0, video);
    listString.add(json.encode(video.toJson()));
    if (videoList.length > 1) {
      //去重
      for (int i = 1; i < videoList.length; i++) {
        var element = videoList[i];
        if (element.id == video.id) {
          videoList.remove(element);
        } else {
          listString.add(json.encode(element.toJson()));
        }
      }
    }
    String localKey = _playMovieCacheVideoListKey;
    if (type == CacheMediaType.short) {
      localKey = _playShortCacheVideoListKey;
    }
    if (type == CacheMediaType.cartoon) {
      localKey = _playCartoonCacheVideoListKey;
    }
    await lightKV.setStringList(localKey, listString);
  }

  Future<void> removeVideo(CacheMediaType type, ContentModel? video) async {
    if (video == null) return;
    List<String> listString = [];
    List<ContentModel> videoList = [];
    videoList = await getMovieCacheVideoList(type);
    for (int i = 0; i < videoList.length; i++) {
      var element = videoList[i];
      if (element.id != video.id) {
        listString.add(json.encode(element.toJson()));
      }
    }
    String localKey = _playMovieCacheVideoListKey;
    if (type == CacheMediaType.short) {
      localKey = _playShortCacheVideoListKey;
    }
    if (type == CacheMediaType.cartoon) {
      localKey = _playCartoonCacheVideoListKey;
    }
    await lightKV.setStringList(localKey, listString);
  }

  Future<void> removeVideoList(
      CacheMediaType type, List<ContentModel> videos) async {
    List<String> listString = [];
    List<ContentModel> videoList = [];
    videoList = await getMovieCacheVideoList(type);
    for (int i = 0; i < videoList.length; i++) {
      var element = videoList[i];
      var isDelete = false;
      for (var deleteItem in videos) {
        if (deleteItem.id == element.id) {
          isDelete = true;
          break;
        }
      }
      if (!isDelete) {
        listString.add(json.encode(element.toJson()));
      }
    }
    String localKey = _playMovieCacheVideoListKey;
    if (type == CacheMediaType.short) {
      localKey = _playShortCacheVideoListKey;
    }
    if (type == CacheMediaType.cartoon) {
      localKey = _playCartoonCacheVideoListKey;
    }
    await lightKV.setStringList(localKey, listString);
  }

  Future<void> removeAllVideo(CacheMediaType type) async {
    List<String> listString = [];
    String localKey = _playMovieCacheVideoListKey;
    if (type == CacheMediaType.short) {
      localKey = _playShortCacheVideoListKey;
    }
    if (type == CacheMediaType.cartoon) {
      localKey = _playCartoonCacheVideoListKey;
    }
    await lightKV.setStringList(localKey, listString);
  }
}
