import 'package:comics_app/common/services/scroll_metrics_manager.dart';
import 'package:comics_app/common/widgets/keep_alive_widget.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class TabBarViewItem extends StatelessWidget {
  const TabBarViewItem({
    Key? key,
    required this.child,
    required this.uniqueKey,
    this.ignore = false,
  }) : super(key: key);

  // tabbarview 嵌套 tabbarview 时，不对外层进行监听
  final bool ignore;

  final ScrollKey uniqueKey;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class ScrollMetricsListenableBuilder extends StatelessWidget {
  const ScrollMetricsListenableBuilder({
    super.key,
    required this.group,
    required this.builder,
    this.child,
  });

  final ScrollMetricsGroup group;

  final Widget? child;

  final Widget Function(BuildContext, double, Widget? child) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable:
          ScrollMetricsManager.sharedInstance.getScrollNotifier(group),
      builder: (context, value, child) {
        return builder(context, value, child);
      },
      child: child,
    );
  }
}

class TabBarViewListenWrapper extends StatelessWidget {
  const TabBarViewListenWrapper({
    super.key,
    required this.group,
    required this.controller,
    this.physics,
    this.children = const [],
    this.keepAlive = true,
    this.wrapExtendedVisibilityDetector = false,
    this.scrollCallback,
  });

  final ScrollMetricsGroup group;
  final TabController controller;
  final List<TabBarViewItem> children;
  final ScrollPhysics? physics;
  final bool keepAlive;

  final bool wrapExtendedVisibilityDetector;
  final Function(bool isStartScroll)? scrollCallback;
  static ScrollMetricsGroup getGroup(BuildContext context) {
    return context
        .findAncestorWidgetOfExactType<TabBarViewListenWrapper>()!
        .group;
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller,
      physics: physics,
      children: children.map((e) {
        Widget child = e;
        if (wrapExtendedVisibilityDetector) {
          child = ExtendedVisibilityDetector(
            uniqueKey:
                ValueKey(e.uniqueKey.key + '_' + 'ExtendedVisibilityDetector'),
            child: child,
          );
        }
        if (e.ignore) {
          return keepAlive ? KeepAliveWidget(child) : child;
        } else {
          child = VisibilityDetector(
            key: e.uniqueKey,
            child: child,
            onVisibilityChanged: (VisibilityInfo visibilityInfo) {
              if (visibilityInfo.visibleFraction != 0) {
                ScrollMetricsManager.sharedInstance
                    .setCurrentKey(e.uniqueKey, group);
              }
            },
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification) {
              if (notification.metrics.axisDirection == AxisDirection.down ||
                  notification.metrics.axisDirection == AxisDirection.up) {
                ScrollMetricsManager.sharedInstance.addNotification(
                  e.uniqueKey,
                  notification,
                  group,
                );
                scrollCallback?.call(false);
              }
            } else if (notification is ScrollStartNotification) {
              if (notification.metrics.axisDirection == AxisDirection.down ||
                  notification.metrics.axisDirection == AxisDirection.up) {
                scrollCallback?.call(true);
              }
            }

            return true;
          },
          child: keepAlive ? KeepAliveWidget(child) : child,
        );
      }).toList(),
    );
  }
}
