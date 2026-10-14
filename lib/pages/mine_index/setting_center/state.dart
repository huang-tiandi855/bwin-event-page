import 'package:comics_app/pages/image/network/image_cache_manager.dart';

class SettingCenterState {
  /// [CustomImageNetwork] 使用的磁盘缓存（与 [ImgCacheMgr] 工厂单例一致）
  final ImgCacheMgr customNetworkImageCache = ImgCacheMgr();

  /// [ImgCacheMgr] 临时目录占用，由 [SettingCenterLogic] 异步刷新
  String cacheSizeLabel = '--';
}
