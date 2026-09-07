import 'package:bagistruk/data/services/deep_link_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeepLinkHandler.parseShareToken', () {
    test('extracts token from bagistruk://share/<token>', () {
      expect(
        DeepLinkHandler.parseShareToken(
          Uri.parse('bagistruk://share/abc123XYZ'),
        ),
        'abc123XYZ',
      );
    });

    test('rejects auth callbacks and other schemes/hosts', () {
      expect(
        DeepLinkHandler.parseShareToken(
          Uri.parse('bagistruk://auth/callback?code=xyz'),
        ),
        isNull,
      );
      expect(
        DeepLinkHandler.parseShareToken(Uri.parse('https://x.test/share/abc')),
        isNull,
      );
      expect(
        DeepLinkHandler.parseShareToken(Uri.parse('bagistruk://share/')),
        isNull,
      );
      expect(
        DeepLinkHandler.parseShareToken(Uri.parse('bagistruk://share')),
        isNull,
      );
    });

    test('consumeShareToken is one-shot', () {
      // Nothing pending initially (or leftover from another test is drained).
      DeepLinkHandler.consumeShareToken();
      expect(DeepLinkHandler.consumeShareToken(), isNull);
    });
  });
}
