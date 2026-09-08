import 'package:bagistruk/core/billing/share_link_token.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShareLinkToken', () {
    test('generate produces unique opaque tokens', () {
      final a = ShareLinkToken.generate();
      final b = ShareLinkToken.generate();
      expect(a, isNotEmpty);
      expect(a, isNot(equals(b)));
      // No dashes: safe as a single deep-link path segment.
      expect(a.contains('-'), isFalse);
    });

    test('hash is a deterministic 64-char lowercase hex (SHA-256)', () {
      final h1 = ShareLinkToken.hash('abc123');
      final h2 = ShareLinkToken.hash('abc123');
      expect(h1, equals(h2));
      expect(h1, matches(RegExp(r'^[0-9a-f]{64}$')));
      // Distinct tokens hash distinctly.
      expect(ShareLinkToken.hash('abc124'), isNot(equals(h1)));
    });

    test('shareText puts link first, fallback second', () {
      const link = 'bagistruk://share/abc123';
      const fallback = 'Get the app: https://x.test/';
      final text = ShareLinkToken.shareText(
        link: link,
        fallbackLine: fallback,
      );
      expect(text, '$link\n$fallback');
      // Raw link stays intact on line 1 (tappable where installed).
      expect(text.split('\n').first, link);
    });
  });

  group('ShareLinkCountdown', () {
    final expires = DateTime.utc(2026, 9, 8, 12);

    test('remaining clamps at zero, never negative', () {
      expect(
        ShareLinkCountdown.remaining(
          expiresAt: expires,
          now: DateTime.utc(2026, 9, 8, 13),
        ),
        Duration.zero,
      );
      expect(
        ShareLinkCountdown.remaining(
          expiresAt: expires,
          now: DateTime.utc(2026, 9, 1, 12),
        ),
        const Duration(days: 7),
      );
    });

    test('isExpired only at/below zero (server stays source of truth)', () {
      expect(
        ShareLinkCountdown.isExpired(
          expiresAt: expires,
          now: DateTime.utc(2026, 9, 8, 12),
        ),
        isTrue,
      );
      expect(
        ShareLinkCountdown.isExpired(
          expiresAt: expires,
          now: DateTime.utc(2026, 9, 8, 11, 59, 59),
        ),
        isFalse,
      );
    });

    test('bucket boundaries: 24h→days, 1h→hours, sub-minute→1 min', () {
      expect(ShareLinkCountdown.wholeDays(const Duration(hours: 24)), 1);
      expect(ShareLinkCountdown.wholeDays(const Duration(hours: 23, minutes: 59)), 0);
      expect(ShareLinkCountdown.wholeHours(const Duration(hours: 23)), 23);
      expect(ShareLinkCountdown.wholeMinutes(const Duration(seconds: 30)), 1);
      expect(ShareLinkCountdown.wholeMinutes(const Duration(hours: 2)), 120);
    });
  });
}
