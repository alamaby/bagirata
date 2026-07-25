import 'package:bagistruk/core/config/app_constants.dart';
import 'package:bagistruk/domain/entities/ocr_result.dart';
import 'package:bagistruk/domain/entities/user_profile.dart';
import 'package:bagistruk/presentation/bills/providers/bill_review_notifier.dart';
import 'package:bagistruk/presentation/settings/providers/profile_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderContainer _container(String currency, {String id = 'u1'}) {
  return ProviderContainer(
    overrides: [
      profileProvider.overrideWith(
        () => _FakeProfileNotifier(
          UserProfile(
            id: id,
            defaultCurrency: currency,
            isAnonymous: true,
          ),
        ),
      ),
    ],
  );
}

Future<BillReviewState> _state(
  ProviderContainer container,
  OcrResult ocr,
) async {
  // Wait for profileProvider to resolve so BillReviewNotifier.build reads the
  // overridden currency snapshot rather than the default `?? 'USD'` fallback.
  await container.read(profileProvider.future);
  final notifier = container.read(billReviewFamily(ocr).notifier);
  return notifier.state;
}

class _FakeProfileNotifier extends ProfileNotifier {
  _FakeProfileNotifier(this._initial);
  final UserProfile _initial;

  @override
  Future<UserProfile> build() async => _initial;
}

void main() {
  group('BillReviewNotifier.build normalization', () {
    test('uses merchant name as title when present', () async {
      final container = _container('IDR');
      addTearDown(container.dispose);
      const ocr = OcrResult(
        items: [OcrLineItem(name: 'Kopi', price: 18000, qty: 1)],
        merchant: 'Warung Pak Tio',
        providerUsed: 'gemini',
      );

      final state = await _state(container, ocr);
      expect(state.title, 'Warung Pak Tio');
      expect(state.items.length, 1);
      expect(state.items.single.name, 'Kopi');
      expect(state.items.single.price, 18000);
      expect(state.items.single.qty, 1);
      expect(state.currency, 'IDR');
    });

    test('falls back to "Untitled bill" when merchant is null', () async {
      final container = _container('IDR');
      addTearDown(container.dispose);
      const ocr = OcrResult(
        items: [OcrLineItem(name: 'Kopi', price: 18000, qty: 1)],
        providerUsed: 'gemini',
      );

      final state = await _state(container, ocr);
      expect(state.title, 'Untitled bill');
    });

    test('falls back to "Untitled bill" when merchant is whitespace',
        () async {
      final container = _container('IDR');
      addTearDown(container.dispose);
      const ocr = OcrResult(
        items: [OcrLineItem(name: 'Kopi', price: 18000, qty: 1)],
        merchant: '   ',
        providerUsed: 'gemini',
      );

      final state = await _state(container, ocr);
      expect(state.title, 'Untitled bill');
    });

    test('currency snapshot defaults to USD when profile has none', () async {
      final container = ProviderContainer(
        overrides: [
          profileProvider.overrideWith(
            () => _FakeProfileNotifier(
              UserProfile(id: 'u1', isAnonymous: true),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      const ocr = OcrResult(
        items: [OcrLineItem(name: 'Kopi', price: 5, qty: 1)],
        providerUsed: 'gemini',
      );

      final state = await _state(container, ocr);
      expect(state.currency, 'USD');
    });

    test('suspectThousandsBug fires for zero-decimal with fractional prices',
        () async {
      final container = _container('IDR');
      addTearDown(container.dispose);
      const ocr = OcrResult(
        items: [OcrLineItem(name: 'Kopi', price: 1.5, qty: 1)],
        providerUsed: 'gemini',
      );

      final state = await _state(container, ocr);
      expect(state.suspectThousandsBug, isTrue);
    });

    test('suspectThousandsBug is false for non-zero-decimal currencies',
        () async {
      final container = _container('USD');
      addTearDown(container.dispose);
      const ocr = OcrResult(
        items: [OcrLineItem(name: 'Coffee', price: 1.5, qty: 1)],
        providerUsed: 'gemini',
      );

      final state = await _state(container, ocr);
      expect(state.suspectThousandsBug, isFalse);
    });

    test('mutations update state via setters', () async {
      final container = _container('IDR');
      addTearDown(container.dispose);
      const ocr = OcrResult(
        items: [
          OcrLineItem(name: 'Kopi', price: 1000, qty: 1),
          OcrLineItem(name: 'Teh', price: 2000, qty: 1),
        ],
        detectedTotal: 3500,
        providerUsed: 'gemini',
      );

      final state0 = await _state(container, ocr);
      final notifier = container.read(billReviewFamily(ocr).notifier);
      notifier.setTitle('Baru');
      notifier.setTax(500);
      notifier.setService(0);
      notifier.setCurrency('USD');
      notifier.updateItem(
        state0.items.first.localId,
        price: 1500,
        qty: 2,
      );

      final state = notifier.state;
      expect(state.title, 'Baru');
      expect(state.tax, 500);
      expect(state.service, 0);
      expect(state.currency, 'USD');
      expect(state.items.first.price, 1500);
      expect(state.items.first.qty, 2);
      expect(state.subtotal, 1500 * 2 + 2000);
    });

    test('addItem appends a new editable item', () async {
      final container = _container('IDR');
      addTearDown(container.dispose);
      const ocr = OcrResult(
        items: [OcrLineItem(name: 'Kopi', price: 1000, qty: 1)],
        providerUsed: 'gemini',
      );

      final state0 = await _state(container, ocr);
      expect(state0.items.length, 1);

      final notifier = container.read(billReviewFamily(ocr).notifier);
      notifier.addItem();
      expect(notifier.state.items.length, 2);
      expect(notifier.state.items.last.price, 0);
      expect(notifier.state.items.last.qty, 1);
    });

    test('removeItem drops the matching item only', () async {
      final container = _container('IDR');
      addTearDown(container.dispose);
      const ocr = OcrResult(
        items: [
          OcrLineItem(name: 'Kopi', price: 1000, qty: 1),
          OcrLineItem(name: 'Teh', price: 2000, qty: 1),
        ],
        providerUsed: 'gemini',
      );

      final state0 = await _state(container, ocr);
      final notifier = container.read(billReviewFamily(ocr).notifier);
      notifier.removeItem(state0.items.first.localId);
      expect(notifier.state.items.length, 1);
      expect(notifier.state.items.single.name, 'Teh');
    });

    test('hasMismatch fires when grand total differs from detected total',
        () async {
      final container = _container('IDR');
      addTearDown(container.dispose);
      const ocr = OcrResult(
        items: [OcrLineItem(name: 'Kopi', price: 100, qty: 1)],
        detectedTotal: 200,
        providerUsed: 'gemini',
      );

      final state = await _state(container, ocr);
      expect(state.hasMismatch, isTrue);
    });

    test('hasMismatch stays false within tolerance', () async {
      final container = _container('IDR');
      addTearDown(container.dispose);
      const ocr = OcrResult(
        items: [OcrLineItem(name: 'Kopi', price: 100, qty: 1)],
        detectedTotal: 100 + AppConstants.billTotalMismatchTolerance,
        providerUsed: 'gemini',
      );

      final state = await _state(container, ocr);
      expect(state.hasMismatch, isFalse);
    });
  });
}
