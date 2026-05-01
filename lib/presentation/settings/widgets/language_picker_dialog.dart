import 'package:flutter/material.dart';

import '../../../l10n/generated/app_l10n.dart';

Future<String?> showLanguagePickerDialog(
  BuildContext context,
  String current,
) {
  return showDialog<String>(
    context: context,
    builder: (ctx) {
      final l10n = AppL10n.of(ctx);
      return SimpleDialog(
        title: Text(l10n.languageLabel),
        children: [
          RadioListTile<String>(
            value: 'id',
            groupValue: current,
            onChanged: (v) => Navigator.of(ctx).pop(v),
            title: Text(l10n.languageIndonesian),
          ),
          RadioListTile<String>(
            value: 'en',
            groupValue: current,
            onChanged: (v) => Navigator.of(ctx).pop(v),
            title: Text(l10n.languageEnglish),
          ),
        ],
      );
    },
  );
}
