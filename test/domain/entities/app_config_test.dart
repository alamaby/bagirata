import 'package:bagistruk/domain/entities/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

List<Map<String, dynamic>> _rows({dynamic promoValue}) => [
  {'key': 'legal.terms_version', 'value': 1},
  {'key': 'legal.privacy_version', 'value': 1},
  if (promoValue != null)
    {'key': 'promo.onboarding_plus_trial', 'value': promoValue},
];

void main() {
  group('AppConfig.fromRows — promo onboarding', () {
    test('parses promo fields when enabled', () {
      final config = AppConfig.fromRows(_rows(promoValue: {
        'enabled': true,
        'title_id': 'Dapatkan Plus Gratis!',
        'title_en': 'Get Free Plus!',
        'body_id': 'Nikmati akses gratis.',
        'body_en': 'Enjoy free access.',
      }));

      expect(config.promoOnboardingEnabled, isTrue);
      expect(config.promoOnboardingTitleId, 'Dapatkan Plus Gratis!');
      expect(config.promoOnboardingTitleEn, 'Get Free Plus!');
      expect(config.promoOnboardingBodyId, 'Nikmati akses gratis.');
      expect(config.promoOnboardingBodyEn, 'Enjoy free access.');
      expect(config.hasCompletePromoOnboardingCopy, isTrue);
    });

    test('promoOnboardingEnabled is false when enabled is false', () {
      final config = AppConfig.fromRows(_rows(promoValue: {
        'enabled': false,
        'title_id': 'X',
        'title_en': 'Y',
        'body_id': 'A',
        'body_en': 'B',
      }));

      expect(config.promoOnboardingEnabled, isFalse);
    });

    test('promoOnboardingEnabled is false when key is missing', () {
      final config = AppConfig.fromRows(_rows(promoValue: null));

      expect(config.promoOnboardingEnabled, isFalse);
    });

    test('promoOnboardingEnabled is false with empty object', () {
      final config = AppConfig.fromRows(_rows(promoValue: <String, dynamic>{}));

      expect(config.promoOnboardingEnabled, isFalse);
    });

    test('title/body default to empty string when fields missing', () {
      final config = AppConfig.fromRows(_rows(promoValue: {
        'enabled': true,
      }));

      expect(config.promoOnboardingTitleId, isEmpty);
      expect(config.promoOnboardingTitleEn, isEmpty);
      expect(config.promoOnboardingBodyId, isEmpty);
      expect(config.promoOnboardingBodyEn, isEmpty);
      expect(config.hasCompletePromoOnboardingCopy, isFalse);
    });

    test('handles null promo value gracefully', () {
      final config = AppConfig.fromRows(_rows(promoValue: null));

      expect(config.promoOnboardingEnabled, isFalse);
      expect(config.promoOnboardingTitleId, isEmpty);
      expect(config.promoOnboardingBodyEn, isEmpty);
    });

    test('malformed enabled string does not throw and returns false', () {
      final config = AppConfig.fromRows(_rows(promoValue: {
        'enabled': 'true',
        'title_id': 'A',
        'title_en': 'B',
        'body_id': 'C',
        'body_en': 'D',
      }));

      expect(config.promoOnboardingEnabled, isFalse);
      expect(config.promoOnboardingTitleId, 'A');
    });

    test('malformed title_id integer does not throw and returns empty', () {
      final config = AppConfig.fromRows(_rows(promoValue: {
        'enabled': true,
        'title_id': 123,
        'title_en': 'B',
        'body_id': 'C',
        'body_en': 'D',
      }));

      expect(config.promoOnboardingEnabled, isTrue);
      expect(config.promoOnboardingTitleId, isEmpty);
      expect(config.promoOnboardingTitleEn, 'B');
      expect(config.hasCompletePromoOnboardingCopy, isFalse);
    });

    test('malformed body_id null does not throw and returns empty', () {
      final config = AppConfig.fromRows(_rows(promoValue: {
        'enabled': true,
        'title_id': 'A',
        'title_en': 'B',
        'body_id': null,
        'body_en': 'D',
      }));

      expect(config.promoOnboardingEnabled, isTrue);
      expect(config.promoOnboardingBodyId, isEmpty);
      expect(config.hasCompletePromoOnboardingCopy, isFalse);
    });

    test('hasCompletePromoOnboardingCopy true only when all fields non-empty',
        () {
      final base = {
        'enabled': true,
        'title_id': 'A',
        'title_en': 'B',
        'body_id': 'C',
        'body_en': 'D',
      };

      expect(
        AppConfig.fromRows(_rows(promoValue: base))
            .hasCompletePromoOnboardingCopy,
        isTrue,
      );

      for (final field in ['title_id', 'title_en', 'body_id', 'body_en']) {
        final variant = Map<String, dynamic>.from(base)..[field] = '';
        expect(
          AppConfig.fromRows(_rows(promoValue: variant))
              .hasCompletePromoOnboardingCopy,
          isFalse,
          reason: 'should be false when $field is empty',
        );
      }
    });
  });

  group('AppConfig.fallback', () {
    test('promoOnboardingEnabled is false', () {
      expect(AppConfig.fallback.promoOnboardingEnabled, isFalse);
    });

    test('promo title/body are empty', () {
      expect(AppConfig.fallback.promoOnboardingTitleId, isEmpty);
      expect(AppConfig.fallback.promoOnboardingTitleEn, isEmpty);
      expect(AppConfig.fallback.promoOnboardingBodyId, isEmpty);
      expect(AppConfig.fallback.promoOnboardingBodyEn, isEmpty);
    });

    test('hasCompletePromoOnboardingCopy is false', () {
      expect(AppConfig.fallback.hasCompletePromoOnboardingCopy, isFalse);
    });
  });

  group('AppConfig.copyWith — promo', () {
    test('preserves promo fields when not overridden', () {
      final config = AppConfig(
        termsVersion: 1,
        privacyVersion: 1,
        promoOnboardingEnabled: true,
        promoOnboardingTitleId: 'ID',
        promoOnboardingTitleEn: 'EN',
        promoOnboardingBodyId: 'B ID',
        promoOnboardingBodyEn: 'B EN',
      );

      final copy = config.copyWith(termsVersion: 2);

      expect(copy.promoOnboardingEnabled, isTrue);
      expect(copy.promoOnboardingTitleId, 'ID');
      expect(copy.promoOnboardingTitleEn, 'EN');
      expect(copy.promoOnboardingBodyId, 'B ID');
      expect(copy.promoOnboardingBodyEn, 'B EN');
    });

    test('overrides promo fields when specified', () {
      final config = AppConfig.fallback;
      final copy = config.copyWith(promoOnboardingEnabled: true);

      expect(copy.promoOnboardingEnabled, isTrue);
      expect(copy.termsVersion, 1);
      expect(copy.privacyVersion, 1);
    });
  });
}
