import 'package:flutter/material.dart';

class SettingCenterInviteState {
  final TextEditingController controller = TextEditingController();
  bool canSubmit = false;

  void dispose() {
    controller.dispose();
  }
}
