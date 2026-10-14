import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 恢复默认系统 UI（状态栏 + 底部导航栏可见）。
///
/// 漫画阅读、竖屏视频等页面会切到 [SystemUiMode.immersive]；若进程在后台被挂起
/// 而非完全销毁，回到前台后 AppBar 区域会被系统栏占用或整栏「消失」。
/// 在 [AppLifecycleState.resumed] 与冷启动时调用，保证导航栏稳定可见。
void restoreDefaultSystemUi() {
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
}

/// 与 [AppTheme] / [commonAppBar] 共用的 AppBar 高度，避免在静态 Theme 里使用
/// ScreenUtil（首帧尺寸未就绪时 `44.w` 可能为 0，导致全局 AppBar 高度塌陷）。
const double kAppBarToolbarHeight = kToolbarHeight;
