import 'package:flutter/material.dart';

class AppTypography {
  const AppTypography._();

  static TextTheme textTheme(Color onSurface) {
    final base = Typography.material2021().black;
    return base.apply(
      bodyColor: onSurface,
      displayColor: onSurface,
    );
  }
}
