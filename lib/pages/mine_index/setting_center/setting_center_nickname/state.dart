import 'package:flutter/material.dart';

class SettingCenterNicknameState {
  late final TextEditingController controller;
  final FocusNode focusNode = FocusNode();

  SettingCenterNicknameState(String initial) {
    controller = TextEditingController(text: initial);
  }

  void dispose() {
    focusNode.dispose();
    controller.dispose();
  }
}
