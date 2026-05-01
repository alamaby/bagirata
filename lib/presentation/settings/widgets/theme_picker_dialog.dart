import 'package:flutter/material.dart';

import '../../../l10n/generated/app_l10n.dart';

Future<String?> showThemePickerDialog(
  BuildContext context,
  String current,
) {
  return showDialog<String>(
    context: context,
    builder: (ctx) {
      final l10n = AppL10n.of(ctx);
      return SimpleDialog(
        title: Text(l10n.themeLabel),
        children: [
          RadioListTile<String>(
            value: 'system',
            groupValue: current,
            onChanged: (v) => Navigator.of(ctx).pop(v),
            title: Text(l10n.themeSystem),
          ),
          RadioListTile<String>(
            value: 'light',
            groupValue: current,
            onChanged: (v) => Navigator.of(ctx).pop(v),
            title: Text(l10n.themeLight),
          ),
          RadioListTile<String>(
            value: 'dark',
            groupValue: current,
            onChanged: (v) => Navigator.of(ctx).pop(v),
            title: Text(l10n.themeDark),
          ),
        ],
      );
    },
  );
}
