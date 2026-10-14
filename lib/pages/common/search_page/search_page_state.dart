import 'package:comics_app/common/entities/hot_search_words.dart';
import 'package:comics_app/common/services/servers.dart';
import 'package:flutter/widgets.dart';

import '../../../common/entities/MediaListInfo.dart';
import '../../../common/store/config.dart';
import '../../../common/values/storage.dart';

class SearchPageState {
  /// 历史记录最多保留条数；超过时新关键字顶替最旧的。
  static const int maxHistoryCount = 10;

  TextEditingController textEditingController = TextEditingController(text: "");

  List<String> tags = [];

  List<String> hotSearchKeywords = [];

  //SearchHotTags? searchHotTags;
  HotSearchWords? hotSearchWords;

  MediaListInfo? mediaListInfo;

  List<MediaList> mediaList = [];

  List<MediaList> searchResultList = [];

  /// 搜索历史记录关键字（最新置顶，最多 [maxHistoryCount] 条）。
  ///
  /// 持久化在 [Storage.searchList]，存储格式统一为 `List<String>`，方便
  /// [StorageService]（基于 GetStorage）直接 JSON 序列化。
  List<String> searchList = <String>[];

  bool isNeedExpand = false;

  bool? isHideClear = true;

  bool hasSearched = false;

  bool isSearching = false;

  String searchKeyword = '';

  int searchKindIndex = 0;

  int searchSortIndex = 1;

  SearchPageState() {
    searchList = _readPersistedHistory();
  }

  /// 重新从本地缓存加载搜索历史。
  void reloadSearchHistory() {
    searchList = _readPersistedHistory();
  }

  /// 写入一条历史记录：去重 + 置顶 + 超出上限时丢弃最早的一条。
  void saveKeywords(String text) {
    final keyword = text.trim();
    if (keyword.isEmpty) return;

    final Map map = {'关键字': keyword};
    ConfigStore.to.trackData('搜索', map);

    searchList.removeWhere((e) => e == keyword);
    searchList.insert(0, keyword);
    if (searchList.length > maxHistoryCount) {
      searchList = searchList.sublist(0, maxHistoryCount);
    }
    StorageService.to.white(Storage.searchList, searchList);
  }

  /// 读取并兼容旧版本的本地数据：旧版本曾以 `SearchListBean` 实例直接写入，
  /// 由于 `GetStorage` 走 JSON 序列化，落地后可能是 `List<Map>` 或非法对象，
  /// 这里统一回退成 `List<String>`，避免老用户升级后历史丢失或类型异常。
  static List<String> _readPersistedHistory() {
    final dynamic raw = StorageService.to.read(Storage.searchList);
    if (raw is! List) return <String>[];
    final List<String> result = <String>[];
    for (final dynamic item in raw) {
      String? keyword;
      if (item is String) {
        keyword = item;
      } else if (item is Map) {
        final dynamic legacy = item['keyWord'] ?? item['keyword'];
        if (legacy is String) keyword = legacy;
      }
      if (keyword == null) continue;
      final trimmed = keyword.trim();
      if (trimmed.isEmpty || result.contains(trimmed)) continue;
      result.add(trimmed);
      if (result.length >= maxHistoryCount) break;
    }
    return result;
  }
}
