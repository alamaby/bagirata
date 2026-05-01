import 'package:flutter/material.dart';

import '../../../core/format/currency_formatter.dart';
import '../../../l10n/generated/app_l10n.dart';

Future<String?> showCurrencyPickerDialog(
  BuildContext context,
  String current,
) {
  return showDialog<String>(
    context: context,
    builder: (ctx) {
      final l10n = AppL10n.of(ctx);
      return SimpleDialog(
        title: Text(l10n.currencyLabel),
        children: [
          for (final code in CurrencyFormatter.supported)
            RadioListTile<String>(
              value: code,
              groupValue: current,
              onChanged: (v) => Navigator.of(ctx).pop(v),
              title: Text(CurrencyFormatter.displayName(code)),
            ),
        ],
      );
    },
  );
}
