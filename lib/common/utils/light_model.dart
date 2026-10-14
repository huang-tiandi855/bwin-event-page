import 'dart:convert';

import 'package:comics_app/common/utils/text_util.dart';
import 'package:mmkv/mmkv.dart';

import 'debug_log.dart';



/// 轻量级别存储模型(kv键值对)内部包含文件和内存缓存
final lightKV = _LightModel();

class _LightModel {
  MMKV? mmkv;
  Future config() async{
    await init();
  }
  init() async {
    final rootDir = await MMKV.initialize();
    mmkv ??= MMKV.defaultMMKV();
    debugLog('MMKV for flutter with rootDir = $rootDir');
  }

  void remove(String key) async {
    await init();
    return mmkv?.removeValue(key);
  }

  Future<String?> getString(String key) async {
    await init();
    if (TextUtil.isEmpty(key)) return null;
    var newKey = key;
    return mmkv?.decodeString(newKey);
  }

  Future<bool?> setString(String key, String? value,
      [bool genNewKey = true]) async {
    await init();
    if (TextUtil.isEmpty(key)) return false;
    var newKey = key;
    return mmkv?.encodeString(newKey, value);
  }

  Future<int?> getInt(String? key) async {
    await init();
    if (TextUtil.isEmpty(key!)) return null;
    var newKey = key;
    return mmkv?.decodeInt(newKey);
  }

  Future<bool?> setInt(String key, int value) async {
    await init();
    if (TextUtil.isEmpty(key)) return false;
    var newKey = key;
    return mmkv?.encodeInt(newKey, value);
  }

  Future<bool?> getBool(String? key) async {
    await init();
    if (TextUtil.isEmpty(key!)) return null;
    var newKey = key;
    return mmkv?.decodeBool(newKey);
  }

  Future<bool?> setBool(String key, bool value) async {
    await init();
    if (TextUtil.isEmpty(key)) return false;
    var newKey = key;
    return mmkv?.encodeBool(newKey, value);
  }

  Future<List<String>?> getStringList(String key,
      [bool genNewKey = true]) async {
    await init();
    if (TextUtil.isEmpty(key)) return null;
    var newKey = key;
    var jsonS = mmkv?.decodeString(newKey);
    if (jsonS?.isNotEmpty == true) {
      return json.decode(jsonS!)?.cast<String>();

    } else {
      return <String>[];
    }
  }

  ///
  Future<bool?> setStringList(String key, List<String> list,
      [bool genNewKey = true]) async {
    await init();
    if (TextUtil.isEmpty(key)) return false;
    var newKey = key;
    if (list.isEmpty) {
      return mmkv?.encodeString(newKey, null);
    } else {
      var jsonS = json.encode(list);
      return mmkv?.encodeString(newKey, jsonS);
    }
  }
}
