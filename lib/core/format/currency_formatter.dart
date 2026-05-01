import 'package:intl/intl.dart';

/// Currency formatting per ISO-4217 code. The list is intentionally short —
/// only currencies surfaced in the settings picker are supported, so an
/// unknown code falls back to IDR rather than silently producing the wrong
/// symbol.
class CurrencyFormatter {
  const CurrencyFormatter._();

  static const List<String> supported = <String>[
    'IDR',
    'USD',
    'MYR',
    'AUD',
    'SGD',
    'SAR',
  ];

  static NumberFormat of(String code) {
    switch (code) {
      case 'USD':
        return NumberFormat.currency(
          locale: 'en_US',
          symbol: r'$',
          decimalDigits: 2,
        );
      case 'MYR':
        return NumberFormat.currency(
          locale: 'ms_MY',
          symbol: 'RM ',
          decimalDigits: 2,
        );
      case 'AUD':
        return NumberFormat.currency(
          locale: 'en_AU',
          symbol: r'A$',
          decimalDigits: 2,
        );
      case 'SGD':
        return NumberFormat.currency(
          locale: 'en_SG',
          symbol: r'S$',
          decimalDigits: 2,
        );
      case 'SAR':
        return NumberFormat.currency(
          locale: 'ar_SA',
          symbol: 'ر.س ',
          decimalDigits: 2,
        );
      case 'IDR':
      default:
        return NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        );
    }
  }

  /// Long display name shown in the picker dialog. Kept here so the screen
  /// does not need to maintain a parallel mapping.
  static String displayName(String code) {
    switch (code) {
      case 'IDR':
        return 'Indonesian Rupiah (IDR)';
      case 'USD':
        return 'US Dollar (USD)';
      case 'MYR':
        return 'Malaysian Ringgit (MYR)';
      case 'AUD':
        return 'Australian Dollar (AUD)';
      case 'SGD':
        return 'Singapore Dollar (SGD)';
      case 'SAR':
        return 'Saudi Riyal (SAR)';
      default:
        return code;
    }
  }
}
