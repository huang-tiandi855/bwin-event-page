// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

enum ScrollMetricsGroup {
  home('0'),
  circle('1'),
  dark('2'),
  video('3');

  const ScrollMetricsGroup(this.value);

  final String value;

  static ScrollMetricsGroup fromValue(String value) {
    switch (value) {
      case '0':
        return home;
      case '1':
        return circle;
      case '2':
        return dark;
      case '3':
        return video;
      default:
        return home;
    }
  }
}

class ScrollMetricsManager {
  factory ScrollMetricsManager() {
    _instance ??= ScrollMetricsManager._();
    return _instance!;
  }

  static ScrollMetricsManager get sharedInstance => ScrollMetricsManager();

  static ScrollMetricsManager? _instance;

  ScrollMetricsManager._();

  final Map<ScrollMetricsGroup, _ScrollMetrics> _manager = {};

  /// 圈子「社区」内层 `_categories` TabBarView 当前页的 [ScrollController]。
  ScrollController? _circleCommunityInnerScrollController;
  VoidCallback? _circleCommunityInnerScrollListener;

  /// 圈子社区页：有内层绑定时以 [ScrollController.offset] 为准，避免 [setCurrentKey] /
  /// 外层 [addNotification] 用错 key 或过时 metrics 把底栏图标刷成「未滚动」。
  void _applyCircleScrollNotifier() {
    final m = _getManager(ScrollMetricsGroup.circle);
    final c = _circleCommunityInnerScrollController;
    if (c != null && c.hasClients) {
      m.scrollNotifier.value = c.offset;
    } else {
      m.scrollNotifier.value = m.currentScrollOffset;
    }
  }

  void bindCircleCommunityInnerScroll(ScrollController? controller) {
    if (_circleCommunityInnerScrollController == controller) {
      return;
    }
    final prev = _circleCommunityInnerScrollController;
    final prevListener = _circleCommunityInnerScrollListener;
    if (prev != null && prevListener != null) {
      prev.removeListener(prevListener);
    }
    _circleCommunityInnerScrollController = controller;
    _circleCommunityInnerScrollListener = null;

    if (controller == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _applyCircleScrollNotifier());
      return;
    }

    void listener() {
      _applyCircleScrollNotifier();
    }

    _circleCommunityInnerScrollListener = listener;
    controller.addListener(listener);
    WidgetsBinding.instance.addPostFrameCallback((_) => listener());
  }

  _ScrollMetrics _getManager(ScrollMetricsGroup group) {
    if (!_manager.containsKey(group)) {
      _manager[group] = _ScrollMetrics();
    }
    return _manager[group]!;
  }

  void scrollToTop(ScrollMetricsGroup group) {
    if (group == ScrollMetricsGroup.circle &&
        _circleCommunityInnerScrollController != null &&
        _circleCommunityInnerScrollController!.hasClients) {
      _circleCommunityInnerScrollController!.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      return;
    }
    _getManager(group).scrollToTop();
  }

  void setCurrentKey(ScrollKey key, ScrollMetricsGroup group) {
    _getManager(group).assignCurrentKey(key);
    if (group == ScrollMetricsGroup.circle) {
      _applyCircleScrollNotifier();
    } else {
      final m = _getManager(group);
      m.scrollNotifier.value = m.currentScrollOffset;
    }
  }

  void addNotification(ScrollKey key, ScrollNotification notification,
      ScrollMetricsGroup group) {
    _getManager(group).storeNotification(key, notification);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (group == ScrollMetricsGroup.circle) {
        _applyCircleScrollNotifier();
      } else {
        final m = _getManager(group);
        m.scrollNotifier.value = m.currentScrollOffset;
      }
    });
  }

  double getScrollOffset(ScrollMetricsGroup group) {
    if (group == ScrollMetricsGroup.circle &&
        _circleCommunityInnerScrollController != null &&
        _circleCommunityInnerScrollController!.hasClients) {
      return _circleCommunityInnerScrollController!.offset;
    }
    return getScrollNotifier(group).value;
  }

  ValueNotifier<double> getScrollNotifier(ScrollMetricsGroup group) {
    return _getManager(group).scrollNotifier;
  }
}

class _ScrollMetrics {
  ValueNotifier<double> scrollNotifier = ValueNotifier(0);

  ScrollKey? _currentKey;
  ScrollKey? get currentKey => _currentKey;

  void assignCurrentKey(ScrollKey key) {
    _currentKey = key;
  }

  final Map<ScrollKey, ScrollNotification> _notification = {};

  ScrollNotification? get currentNotification {
    return _notification[currentKey];
  }

  double get currentScrollOffset {
    return currentNotification?.metrics.pixels ?? 0;
  }

  void storeNotification(ScrollKey key, ScrollNotification notification) {
    _notification[key] = notification;
  }

  ScrollNotification? getNotification(Key key) {
    return _notification[key];
  }

  void scrollToTop() {
    final notification = currentNotification;
    final ctx = notification?.context;
    if (ctx == null || !ctx.mounted) {
      return;
    }
    final scrollableState = Scrollable.maybeOf(ctx);
    if (scrollableState == null) {
      return;
    }
    final position = scrollableState.position;
    if (!position.hasPixels) {
      return;
    }
    try {
      position.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } catch (_) {}
  }
}

class ScrollKey<T> extends ValueKey<T> {
  const ScrollKey({
    required this.key,
    this.isNestedScroll = false,
  }) : super(key);
  final T key;
  final bool isNestedScroll;
}

// class CustomScrollNotification extends ScrollNotification {
//   CustomScrollNotification({
//     required this.key,
//     required ScrollMetrics metrics,
//     required BuildContext? context,
//   }) : super(metrics: metrics, context: context);
//   final ScrollKey key;

//   @override
//   String toString() {
//     return 'Key: $key, metrics: $metrics';
//   }
// }
