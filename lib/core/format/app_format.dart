import 'package:intl/intl.dart';

/// App-wide formatters defaulted to Indonesian locale (`id_ID`).
///
/// Rupiah convention: `Rp ` prefix + thousands separator `.`, no decimals
/// (whole rupiah is the practical unit; cents don't exist in real receipts).
class AppFormat {
  const AppFormat._();

  static const String locale = 'id_ID';

  /// Rupiah currency. Example: `Rp 104.002`.
  static NumberFormat currency() => NumberFormat.currency(
        locale: locale,
        symbol: 'Rp ',
        decimalDigits: 0,
      );

  /// Long-form date in Indonesian. Example: `29 April 2026`.
  static DateFormat longDate() => DateFormat.yMMMMd(locale);

  /// Short numeric date. Example: `29/04/2026`.
  static DateFormat shortDate() => DateFormat('dd/MM/yyyy', locale);
}
