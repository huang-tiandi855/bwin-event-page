import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:comics_app/common/utils/logger.dart';

class NestedPageViewUtils {
  final PageController pageController;
  ScrollDragController? _drag;

  NestedPageViewUtils(this.pageController);

  DragStartDetails? dragStartDetails;

  bool lock = false;

  bool handleNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      return false;
    }
    l.d((notification).toString());

    if (notification is ScrollStartNotification) {
      dragStartDetails = notification.dragDetails;
    }

    if (notification is OverscrollNotification) {
      // if (_drag != null) {
      //   l.d('正在执行');
      //   return false;
      // }
      if (_drag == null) {
        ScrollPositionWithSingleContext a =
            pageController.position as ScrollPositionWithSingleContext;
        _drag = a.drag(dragStartDetails!, () {
          _drag = null;
          l.d('ssss');
        }) as ScrollDragController;
      }
      l.d((_drag.hashCode).toString());
      if (notification.dragDetails != null) {
        _drag?.update(notification.dragDetails!);
      }
    }

    if (notification is ScrollUpdateNotification) {
      return false;
    }

    if (notification is ScrollEndNotification) {
      dragStartDetails = null;
      if (notification.dragDetails != null) {
        l.d('3333');
        _drag?.end(notification.dragDetails!);
      }
    }

    if (notification is UserScrollNotification) {
      switch (notification.direction) {
        case ScrollDirection.forward:
          break;
        case ScrollDirection.idle:
          _drag?.cancel();
          break;
        case ScrollDirection.reverse:
          break;
      }
    }
    return false;
  }
}
