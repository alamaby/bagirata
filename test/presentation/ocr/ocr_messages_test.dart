import 'package:bagistruk/core/error/failure.dart';
import 'package:bagistruk/l10n/generated/app_l10n.dart';
import 'package:bagistruk/presentation/ocr/utils/ocr_messages.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// M4/F14.5: 413 (server size guard) maps to the too-large message with
/// `canRetry=false` — retrying the identical oversized draft is pointless.
/// Uses `lookupAppL10n` directly (no widget pump needed for pure mapping).
void main() {
  AppL10n id() => lookupAppL10n(const Locale('id'));
  AppL10n en() => lookupAppL10n(const Locale('en'));

  group('friendlyOcrMessage 413', () {
    test('413 code maps to too-large, no retry', () {
      final msg = friendlyOcrMessage(
        const Failure.server(code: 413, message: 'too_many_images'),
        id(),
      );
      expect(msg.title, id().ocrErrorTooLargeTitle);
      expect(msg.body, id().ocrErrorTooLargeBody);
      expect(msg.canRetry, isFalse);
    });

    test('payload-too-large body maps without status code', () {
      final msg = friendlyOcrMessage(
        const Failure.server(message: 'payload too large'),
        en(),
      );
      expect(msg.title, en().ocrErrorTooLargeTitle);
      expect(msg.canRetry, isFalse);
    });

    test('retryable failures keep canRetry=true', () {
      final msg = friendlyOcrMessage(
        const Failure.server(code: 503, message: 'unavailable'),
        id(),
      );
      expect(msg.canRetry, isTrue);
    });
  });
}
