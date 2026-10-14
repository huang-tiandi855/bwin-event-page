import 'package:flutter/material.dart';

class SettingCenterPhoneState {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool canSubmit = false;

  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
  }
}
