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
  });
}
