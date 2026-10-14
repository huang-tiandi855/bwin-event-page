import 'package:comics_app/common/apis/dating_api.dart';
import 'package:comics_app/common/entities/circle/dating_models.dart';

/// 约会筛选项：分类 / 地区树。
///
/// 地区树后台会改排序，文档要求进入约会页时拉取、勿长期缓存内存命中；
/// 仅合并并发请求，不跨次访问复用旧树。
class DatingDictCache {
  DatingDictCache._();

  static final DatingDictCache instance = DatingDictCache._();

  DatingDictBundle? _lastLoaded;
  Future<DatingDictBundle>? _loading;

  DatingDictBundle? get cachedOrNull => _lastLoaded;

  /// 每次调用都会请求接口（并发时共用同一 in-flight）。
  Future<DatingDictBundle> ensureLoaded() {
    return _loading ??= _load().whenComplete(() => _loading = null);
  }

  void invalidate() {
    _lastLoaded = null;
    _loading = null;
  }

  Future<DatingDictBundle> _load() async {
    final results = await Future.wait<Object?>([
      DatingApi.getTypes(),
      DatingApi.getRegionTree(),
    ]);
    final bundle = DatingDictBundle(
      types: results[0] as List<DatingDictItem>? ?? const <DatingDictItem>[],
      regions:
          results[1] as List<DatingRegionNode>? ?? const <DatingRegionNode>[],
    );
    _lastLoaded = bundle;
    return bundle;
  }
}

class DatingDictBundle {
  const DatingDictBundle({
    required this.types,
    required this.regions,
  });

  final List<DatingDictItem> types;
  final List<DatingRegionNode> regions;

  static const DatingDictBundle empty = DatingDictBundle(
    types: <DatingDictItem>[],
    regions: <DatingRegionNode>[],
  );
}
