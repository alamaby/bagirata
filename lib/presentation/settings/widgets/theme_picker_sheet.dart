import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/generated/app_l10n.dart';

const _themeModes = ['system', 'light', 'dark'];

String themeModeLabel(AppL10n l10n, String mode) => switch (mode) {
  'light' => l10n.themeLight,
  'dark' => l10n.themeDark,
  _ => l10n.themeSystem,
};

IconData themeModeIcon(String mode) => switch (mode) {
  'light' => Icons.light_mode_outlined,
  'dark' => Icons.dark_mode_outlined,
  _ => Icons.brightness_6_outlined,
};

ThemeMode themeModeFromPref(String mode) => switch (mode) {
  'light' => ThemeMode.light,
  'dark' => ThemeMode.dark,
  _ => ThemeMode.system,
};

/// Bottom-sheet theme picker shared by onboarding and Settings. Mirrors the
/// language/currency sheets so all three preference pickers look alike.
Future<String?> showThemePickerSheet(BuildContext context, String current) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      final l10n = AppL10n.of(ctx);
      final scheme = Theme.of(ctx).colorScheme;
      return Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 8.h),
              child: Text(
                l10n.themeLabel,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            for (final mode in _themeModes)
              RadioListTile<String>(
                value: mode,
                groupValue: current,
                onChanged: (v) => Navigator.of(ctx).pop(v),
                title: Text(themeModeLabel(l10n, mode)),
                secondary: Icon(themeModeIcon(mode)),
                activeColor: scheme.primary,
              ),
          ],
        ),
      );
    },
  );
}
