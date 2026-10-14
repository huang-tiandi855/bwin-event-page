import 'package:comics_app/common/utils/system_ui_util.dart';
import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:flutter/material.dart';
import 'color.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    scaffoldBackgroundColor: AppColor.scaffoldBackground,
    primaryColor: AppColor.accentColor,
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
          fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400),
    ),
    tabBarTheme: const TabBarTheme(
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory),
    appBarTheme: const AppBarTheme(
      toolbarHeight: kAppBarToolbarHeight,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      backgroundColor: AppColor.scaffoldBackground,
      iconTheme: IconThemeData(
        color: AppColor.primaryText,
      ),
      titleTextStyle: TextStyle(
        color: AppColor.primaryText,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      toolbarTextStyle: TextStyle(
        color: AppColor.primaryText,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoWillPopScopePageTransionsBuilder(),
      },
    ),
  );
}
