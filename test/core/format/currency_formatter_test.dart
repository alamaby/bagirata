import 'package:bagistruk/core/format/currency_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyFormatter.supported', () {
    test('contains expected count', () {
      expect(CurrencyFormatter.supported.length, 21);
    });

    test('contains IDR', () {
      expect(CurrencyFormatter.supported, contains('IDR'));
    });

    test('contains USD', () {
      expect(CurrencyFormatter.supported, contains('USD'));
    });

    test('contains EUR', () {
      expect(CurrencyFormatter.supported, contains('EUR'));
    });

    test('supportedSet is a Set', () {
      expect(CurrencyFormatter.supportedSet, isA<Set<String>>());
    });
  });

  group('CurrencyFormatter.definitionOf', () {
    test('IDR has 0 decimal digits and Rp symbol', () {
      final d = CurrencyFormatter.definitionOf('IDR');
      expect(d.code, 'IDR');
      expect(d.decimalDigits, 0);
      expect(d.symbol, 'Rp ');
    });

    test('USD has 2 decimal digits and dollar symbol', () {
      final d = CurrencyFormatter.definitionOf('USD');
      expect(d.code, 'USD');
      expect(d.decimalDigits, 2);
      expect(d.symbol, r'$');
    });

    test('lowercase input normalized to uppercase', () {
      expect(CurrencyFormatter.definitionOf('eur').code, 'EUR');
    });

    test('whitespace trimmed', () {
      expect(CurrencyFormatter.definitionOf('  USD  ').code, 'USD');
    });

    test('unknown code falls back to USD', () {
      final d = CurrencyFormatter.definitionOf('XYZ');
      expect(d.code, 'USD');
      expect(d.symbol, r'$');
    });

    test('empty string falls back to USD', () {
      expect(CurrencyFormatter.definitionOf('').code, 'USD');
    });

    test('whitespace-only string falls back to USD', () {
      expect(CurrencyFormatter.definitionOf('   ').code, 'USD');
    });
  });

  group('CurrencyFormatter.matchesQuery', () {
    final eurDef = CurrencyFormatter.definitionOf('EUR');
    final usdDef = CurrencyFormatter.definitionOf('USD');

    test('EUR matches alias Spain', () {
      expect(CurrencyFormatter.matchesQuery(eurDef, 'Spain'), isTrue);
    });

    test('EUR does not match eropa (no match)', () {
      expect(CurrencyFormatter.matchesQuery(eurDef, 'eropa'), isFalse);
    });

    test('empty query matches all', () {
      expect(CurrencyFormatter.matchesQuery(usdDef, ''), isTrue);
    });

    test('whitespace-only query matches all', () {
      expect(CurrencyFormatter.matchesQuery(usdDef, '   '), isTrue);
    });

    test('code prefix matches', () {
      expect(CurrencyFormatter.matchesQuery(usdDef, 'us'), isTrue);
    });

    test('display name matches', () {
      expect(CurrencyFormatter.matchesQuery(usdDef, 'Dollar'), isTrue);
    });

    test('null byte in query does not crash', () {
      expect(
        () => CurrencyFormatter.matchesQuery(usdDef, '\x00\n'),
        returnsNormally,
      );
    });
  });

  group('CurrencyFormatter.of', () {
    test('IDR returns NumberFormat with 0 decimal digits', () {
      final fmt = CurrencyFormatter.of('IDR');
      expect(fmt.decimalDigits, 0);
      final formatted = fmt.format(12345);
      // id_ID uses '.' as thousand separator, so 'Rp 12.345' is correct.
      expect(formatted, contains('12'));
      expect(formatted, contains('345'));
    });
  });
}
