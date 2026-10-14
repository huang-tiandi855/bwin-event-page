import 'package:flutter/material.dart';

/// AI 生成子页统一视觉 token（对齐 Figma 暗色稿 / 高级脱衣页）。
class AiGenStyle {
  AiGenStyle._();

  static const Color background = Color(0xFF101010);
  static const Color surface = Color(0xFF1C1C1C);
  static const Color accent = Color(0xFFF5850B);
  static const Color gold = Color(0xFFFFCF86);
  static const Color muted = Color(0xFF8D8D8D);
  static const Color chipSelectedBg = Color(0x26F5850B);
  static const Color divider = Color(0xFF3F3F46);
  static const Color buttonDisabledText = Color(0xFF8D8D8D);
  static const Color buttonEnabledText = Color(0xFF0B0C13);

  static const int maxImageBytes = 10 * 1024 * 1024;
  static const int maxPromptLength = 500;
}
