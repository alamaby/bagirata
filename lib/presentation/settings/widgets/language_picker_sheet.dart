import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/generated/app_l10n.dart';

Future<String?> showLanguagePickerSheet(BuildContext context, String current) {
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
                l10n.languageLabel,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            RadioListTile<String>(
              value: 'id',
              groupValue: current,
              onChanged: (v) => Navigator.of(ctx).pop(v),
              title: Text(l10n.languageIndonesian),
              activeColor: scheme.primary,
            ),
            RadioListTile<String>(
              value: 'en',
              groupValue: current,
              onChanged: (v) => Navigator.of(ctx).pop(v),
              title: Text(l10n.languageEnglish),
              activeColor: scheme.primary,
            ),
          ],
        ),
      );
    },
  );
}