import 'package:comics_app/common/apis/game_api.dart';
import 'package:comics_app/common/entities/circle/gaming_models.dart';

/// 黄游字典全局缓存：分类 / 平台 / 语言一次拉取，筛选切换不重复请求。
class GamesDictCache {
  GamesDictCache._();

  static final GamesDictCache instance = GamesDictCache._();

  GamesDictBundle? _cached;
  Future<GamesDictBundle>? _loading;

  GamesDictBundle? get cachedOrNull => _cached;

  /// 已有缓存直接返回；否则并行拉三类字典并缓存。
  Future<GamesDictBundle> ensureLoaded() {
    final GamesDictBundle? hit = _cached;
    if (hit != null) return Future<GamesDictBundle>.value(hit);
    return _loading ??= _load().whenComplete(() {
      _loading = null;
    });
  }

  void invalidate() {
    _cached = null;
    _loading = null;
  }

  Future<GamesDictBundle> _load() async {
    final List<List<GamingDictItem>?> results = await Future.wait(<
        Future<List<GamingDictItem>?>>[
      GameApi.getCategories(),
      GameApi.getPlatforms(),
      GameApi.getLanguages(),
    ]);
    final GamesDictBundle bundle = GamesDictBundle(
      categories: results[0] ?? const <GamingDictItem>[],
      platforms: results[1] ?? const <GamingDictItem>[],
      languages: results[2] ?? const <GamingDictItem>[],
    );
    _cached = bundle;
    return bundle;
  }
}

class GamesDictBundle {
  const GamesDictBundle({
    required this.categories,
    required this.platforms,
    required this.languages,
  });

  final List<GamingDictItem> categories;
  final List<GamingDictItem> platforms;
  final List<GamingDictItem> languages;

  static const GamesDictBundle empty = GamesDictBundle(
    categories: <GamingDictItem>[],
    platforms: <GamingDictItem>[],
    languages: <GamingDictItem>[],
  );
}
