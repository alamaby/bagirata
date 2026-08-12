import 'package:bagistruk/l10n/generated/app_l10n_en.dart';
import 'package:bagistruk/presentation/auth/widgets/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppL10nEn();

  group('validateEmail', () {
    test('null returns empty error', () {
      expect(validateEmail(null, l10n), l10n.authEmailRequired);
    });

    test('empty string returns empty error', () {
      expect(validateEmail('', l10n), l10n.authEmailRequired);
    });

    test('whitespace only returns empty error', () {
      expect(validateEmail('   ', l10n), l10n.authEmailRequired);
    });

    test('no @ sign returns format error', () {
      expect(validateEmail('foo', l10n), l10n.authInvalidEmailFormat);
    });

    test('no dot in domain returns format error', () {
      expect(validateEmail('foo@bar', l10n), l10n.authInvalidEmailFormat);
    });

    test('valid email returns null', () {
      expect(validateEmail('foo@bar.com', l10n), isNull);
    });

    test('trimmed valid email returns null', () {
      expect(validateEmail('  user@example.com  ', l10n), isNull);
    });

    test('special chars in local part accepted by regex', () {
      expect(validateEmail('a.b+c@x.y', l10n), isNull);
    });

    test('no local part returns format error (boundary)', () {
      expect(validateEmail('@x.com', l10n), l10n.authInvalidEmailFormat);
    });

    test('trailing dot in domain returns format error (boundary)', () {
      expect(validateEmail('a@b.', l10n), l10n.authInvalidEmailFormat);
    });

    test('very long email does not crash (security)', () {
      final longLocal = 'a' * 10000;
      final result = validateEmail('$longLocal@x.com', l10n);
      expect(result, isNull);
    });
  });

  group('validatePassword', () {
    test('null returns empty error', () {
      expect(validatePassword(null, l10n), l10n.authPasswordRequired);
    });

    test('empty string returns empty error', () {
      expect(validatePassword('', l10n), l10n.authPasswordRequired);
    });

    test('5 chars returns length error', () {
      expect(validatePassword('12345', l10n), l10n.authPasswordMinLength);
    });

    test('6 chars returns null', () {
      expect(validatePassword('123456', l10n), isNull);
    });

    test('longer password returns null', () {
      expect(validatePassword('longerpassword', l10n), isNull);
    });

    test('very long password does not crash (security)', () {
      final longPass = 'a' * 10000;
      expect(validatePassword(longPass, l10n), isNull);
    });
  });
}
