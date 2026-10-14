part of short_video_player;

/// App 内短视频正片解码器全局池：任意时刻最多 [maxCapacity] 个存活的
/// [VideoPlayerController]，避免热门 KeepAlive + 二级页 + 长视频叠出
/// MediaCodec `NO_MEMORY`。
///
/// 「回收」= dispose 旧实例后腾出名额再 create（Flutter `video_player` 无法
/// 安全地对同一 controller 换 URL）。
class ShortVideoPlayerPool {
  ShortVideoPlayerPool._();

  static final ShortVideoPlayerPool instance = ShortVideoPlayerPool._();

  /// 正片解码器硬上限。
  static const int maxCapacity = 3;

  /// 当前前台列表允许绑定的窗口大小（有视频前贴片时可临时降为 2）。
  int _windowCapacity = maxCapacity;

  Object? _activeOwner;

  final List<_PoolSlot> _slots = <_PoolSlot>[];

  final Map<Object, void Function(int index)> _evictionCallbacks =
      <Object, void Function(int index)>{};

  Future<void> _chain = Future<void>.value();

  int get windowCapacity => _windowCapacity;

  Object? get activeOwner => _activeOwner;

  int get liveCount => _slots.length;

  void setWindowCapacity(int value) {
    final int next = value.clamp(1, maxCapacity);
    if (_windowCapacity == next) return;
    _windowCapacity = next;
    log(
      'POOL windowCapacity=$_windowCapacity',
      name: 'ShortVideoPlayerPool',
    );
  }

  void setActiveOwner(Object? owner) {
    if (identical(_activeOwner, owner)) return;
    _activeOwner = owner;
    log(
      'POOL activeOwner=${owner?.runtimeType}',
      name: 'ShortVideoPlayerPool',
    );
  }

  /// 列表创建时注册；被其它 owner 抢占槽位时回调，让 UI 清掉 hasController。
  void attachOwner(
    Object owner, {
    required void Function(int index) onEvicted,
  }) {
    _evictionCallbacks[owner] = onEvicted;
  }

  void detachOwner(Object owner) {
    _evictionCallbacks.remove(owner);
    if (identical(_activeOwner, owner)) {
      _activeOwner = null;
    }
  }

  Future<T> _enqueue<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _chain = _chain.then((_) async {
      try {
        completer.complete(await action());
      } catch (e, st) {
        completer.completeError(e, st);
      }
    }).catchError((_) {});
    return completer.future;
  }

  /// 为 [owner]+[index] 取得一个解码器；满员时先踢非 activeOwner，再踢其它。
  Future<VideoPlayerController> acquire({
    required Object owner,
    required int index,
    required VideoPlayerController Function() create,
  }) {
    return _enqueue(() async {
      for (final slot in _slots) {
        if (identical(slot.owner, owner) &&
            slot.index == index &&
            slot.controller != null) {
          return slot.controller!;
        }
      }

      while (_slots.length >= maxCapacity) {
        final bool evicted = await _evictOne(acquiringOwner: owner);
        if (!evicted) {
          throw StateError(
            'ShortVideoPlayerPool: unable to free a slot for $owner#$index',
          );
        }
      }

      final VideoPlayerController controller = create();
      _slots.add(
        _PoolSlot(owner: owner, index: index, controller: controller),
      );
      log(
        'POOL ACQUIRE ${owner.runtimeType}#$index '
        'live=${_slots.length}/$maxCapacity',
        name: 'ShortVideoPlayerPool',
      );
      return controller;
    });
  }

  Future<void> releaseSlot(Object owner, int index) {
    return _enqueue(() async {
      final victims = _slots
          .where((s) => identical(s.owner, owner) && s.index == index)
          .toList(growable: false);
      for (final slot in victims) {
        await _disposeSlot(slot, notifyOwner: false);
      }
    });
  }

  Future<void> releaseOwner(Object owner) {
    return _enqueue(() async {
      final victims = _slots
          .where((s) => identical(s.owner, owner))
          .toList(growable: false);
      for (final slot in victims) {
        await _disposeSlot(slot, notifyOwner: false);
      }
      if (identical(_activeOwner, owner)) {
        _activeOwner = null;
      }
      log(
        'POOL RELEASE_OWNER ${owner.runtimeType} live=${_slots.length}',
        name: 'ShortVideoPlayerPool',
      );
    });
  }

  Future<void> releaseAll() {
    return _enqueue(() async {
      final victims = List<_PoolSlot>.from(_slots);
      for (final slot in victims) {
        await _disposeSlot(slot, notifyOwner: true);
      }
      _activeOwner = null;
      log('POOL RELEASE_ALL', name: 'ShortVideoPlayerPool');
    });
  }

  /// @return false 表示没有可踢的槽（不应发生）。
  Future<bool> _evictOne({required Object acquiringOwner}) async {
    _PoolSlot? victim;

    // 1) 非当前前台 owner
    if (_activeOwner != null) {
      for (final slot in _slots) {
        if (!identical(slot.owner, _activeOwner)) {
          victim = slot;
          break;
        }
      }
    }

    // 2) 非正在 acquire 的 owner
    if (victim == null) {
      for (final slot in _slots) {
        if (!identical(slot.owner, acquiringOwner)) {
          victim = slot;
          break;
        }
      }
    }

    // 3) 同 owner 最旧槽（FIFO）
    victim ??= _slots.isEmpty ? null : _slots.first;

    if (victim == null) return false;
    await _disposeSlot(victim, notifyOwner: true);
    return true;
  }

  Future<void> _disposeSlot(
    _PoolSlot slot, {
    required bool notifyOwner,
  }) async {
    _slots.remove(slot);
    final VideoPlayerController? controller = slot.controller;
    slot.controller = null;
    try {
      await controller?.dispose();
    } catch (_) {}
    log(
      'POOL EVICT ${slot.owner.runtimeType}#${slot.index} '
      'live=${_slots.length}/$maxCapacity',
      name: 'ShortVideoPlayerPool',
    );
    if (notifyOwner) {
      _evictionCallbacks[slot.owner]?.call(slot.index);
    }
  }
}

class _PoolSlot {
  _PoolSlot({
    required this.owner,
    required this.index,
    required this.controller,
  });

  final Object owner;
  final int index;
  VideoPlayerController? controller;
}
