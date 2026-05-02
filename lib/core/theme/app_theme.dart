import 'package:flutter/material.dart';

import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  /// Receipt-paper green seed — distinctive without competing with merchant
  /// branding shown in scanned previews.
  static const Color _seed = Color(0xFF2E7D5B);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: AppTypography.textTheme(scheme.onSurface),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        scrolledUnderElevation: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // Use Size(0, 48) — NOT Size.fromHeight(48), which expands to
          // Size(double.infinity, 48) and forces every FilledButton's minimum
          // width to infinity. That blows up `BoxConstraints forces an
          // infinite width` whenever a FilledButton sits in a parent that
          // passes loose constraints (e.g. Row(mainAxisSize: min) inside a
          // bottom sheet's action row). Full-width buttons still get full
          // width via Column(crossAxisAlignment: stretch) or an explicit
          // SizedBox(width: double.infinity) wrapper at the call site.
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
