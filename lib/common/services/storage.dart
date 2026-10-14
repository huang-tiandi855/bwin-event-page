import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// ---------------------------------------------------- 注意储存的数据不能超过2.5M ------------------------------------------------------------*/
class StorageService extends GetxService {
  static StorageService get to => Get.find();
  late final GetStorage _prefs;

  Future<StorageService> init() async {
    await GetStorage.init();
    _prefs = GetStorage();
    return this;
  }

  ///写入
  white(String key, dynamic value) {
    _prefs.write(key, value);
  }

  ///读取
  dynamic read(String key) {
    return _prefs.read(key);
  }

  ///删除指定key值
  dynamic remove(String key)  {
    return _prefs.remove(key);
  }

  ///监听key
  listenKey(String key, void Function(dynamic) callback) {
    _prefs.listenKey(key, callback);
  }

  ///移除监听key
  removeListen(String key) {
    _prefs.remove(key);
  }

  ///清空所有数据
  erase() {
    _prefs.erase();
  }
}
