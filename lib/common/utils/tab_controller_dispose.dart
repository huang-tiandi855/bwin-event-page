import 'package:flutter/material.dart';

/// GetX 的 onClose 可能早于路由退出动画最后几帧。
/// TabBar 在这些帧仍会 paint indicator；如果 TabController 已 dispose，
/// Flutter 内部 _IndicatorPainter 会访问到已释放的 AnimationController。
void disposeTabControllerAfterRouteExit(TabController? controller) {
  if (controller == null) return;
  Future<void>.delayed(const Duration(milliseconds: 350), controller.dispose);
}
