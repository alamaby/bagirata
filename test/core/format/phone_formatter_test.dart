import 'package:bagistruk/core/format/phone_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneFormatter.normalize', () {
    test('null input returns null', () {
      expect(PhoneFormatter.normalize(null), isNull);
    });

    test('empty string returns null', () {
      expect(PhoneFormatter.normalize(''), isNull);
    });

    test('whitespace only returns null', () {
      expect(PhoneFormatter.normalize('   '), isNull);
    });

    test('leading 0 replaces with 62', () {
      expect(PhoneFormatter.normalize('081234567890'), '6281234567890');
    });

    test('plus-62 prefix stripped and replaced with 62', () {
      expect(PhoneFormatter.normalize('+62 812-3456-7890'), '6281234567890');
    });

    test('already international format stays unchanged', () {
      expect(PhoneFormatter.normalize('6281234567890'), '6281234567890');
    });

    test('non-numeric characters stripped', () {
      expect(PhoneFormatter.normalize('abc12def3'), '123');
    });

    test('single digit after leading 0 returns 62 prefix', () {
      expect(PhoneFormatter.normalize('0'), '62');
    });

    test('Unicode Arabic-Indic digits stripped (ASCII regex)', () {
      // Dart RegExp [^0-9] only matches ASCII digits 0-9.
      // Unicode digits like ٠١٢٣٤٥ are stripped.
      expect(PhoneFormatter.normalize('٠١٢٣٤٥'), isNull);
    });

    test('Devanagari digits stripped', () {
      expect(PhoneFormatter.normalize('०१२३४५'), isNull);
    });

    test('full-width digits stripped', () {
      expect(PhoneFormatter.normalize('１２３４５'), isNull);
    });

    test('bare domestic mobile gains 62 prefix', () {
      expect(PhoneFormatter.normalize('81234567890'), '6281234567890');
    });

    test('bare domestic mobile with separators gains 62 prefix', () {
      expect(PhoneFormatter.normalize('812-3456-7890'), '6281234567890');
    });

    test('short bare number keeps digits (bucket policy is caller-side)', () {
      expect(PhoneFormatter.normalize('812345'), '812345');
    });

    test('non-mobile short number untouched', () {
      expect(PhoneFormatter.normalize('123456'), '123456');
    });
  });

  group('PhoneFormatter.pretty', () {
    test('62-prefixed renders as familiar 08', () {
      expect(PhoneFormatter.pretty('6281234567890'), '081234567890');
    });

    test('already-local number unchanged', () {
      expect(PhoneFormatter.pretty('081234567890'), '081234567890');
    });

    test('short and foreign numbers pass through digit-stripped', () {
      expect(PhoneFormatter.pretty('123456'), '123456');
      expect(PhoneFormatter.pretty('+1-415-555-1234'), '14155551234');
    });

    test('null and empty become empty string', () {
      expect(PhoneFormatter.pretty(null), '');
      expect(PhoneFormatter.pretty('   '), '');
    });
  });

  group('PhoneFormatter.waMeLink', () {
    test('valid phone returns wa.me URL', () {
      expect(
        PhoneFormatter.waMeLink('081234567890'),
        'https://wa.me/6281234567890',
      );
    });

    test('fewer than 6 digits returns null', () {
      expect(PhoneFormatter.waMeLink('12345'), isNull);
    });

    test('null input returns null', () {
      expect(PhoneFormatter.waMeLink(null), isNull);
    });

    test('whitespace only returns null', () {
      expect(PhoneFormatter.waMeLink('   '), isNull);
    });

    test('exactly 6 digits returns valid URL (cutoff boundary)', () {
      expect(PhoneFormatter.waMeLink('123456'), 'https://wa.me/123456');
    });
  });
}
