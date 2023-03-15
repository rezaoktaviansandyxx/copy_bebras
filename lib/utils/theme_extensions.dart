import 'package:flutter/material.dart';

extension ThemeExtensions on BuildContext {
  bool get isLight => Theme.of(this).brightness == Brightness.light;
  bool get isDark => !this.isLight;
}
