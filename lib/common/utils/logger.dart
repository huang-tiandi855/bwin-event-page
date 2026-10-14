import 'dart:developer';
import 'package:flutter/foundation.dart';

// global log class
final l = _Log();

class _Log {
  void d(String msg, {String? tag}) {
    if (kDebugMode) {
      log(msg, name: tag ?? 'goblin comics');
    }
  }

  void p(String msg) {
    if (kDebugMode) {
      print(msg);
    }
  }
}
