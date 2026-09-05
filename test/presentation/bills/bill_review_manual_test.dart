import 'package:bagistruk/core/error/failure.dart';
import 'package:bagistruk/core/error/result.dart';
import 'package:bagistruk/data/providers.dart';
import 'package:bagistruk/domain/entities/bill.dart';
import 'package:bagistruk/domain/entities/item.dart';
import 'package:bagistruk/domain/entities/ocr_result.dart';
import 'package:bagistruk/domain/repositories/i_bill_repository.dart';
import 'package:bagistruk/presentation/bills/providers/bill_review_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'bill_review_manual_test.mocks.dart';

@GenerateMocks([IBillRepository])
void main() {
  late MockIBillRepository mockRepo;
  late ProviderContainer container;

  setUpAll(() {
    provideDummy<Result<void>>(const Result.success(null));
    provideDummy<Result<Bill>>(
      Result.success(
        Bill(
          id: '',
          title: '',
          totalAmount: 0,
          currencyCode: 'IDR',
          tax: 0,
          service: 0,
          createdAt: DateTime(2026),
        ),
      ),
    );
    provideDummy<Result<List<Item>>>(const Result.success([]));
  });

  setUp(() {
    mockRepo = MockIBillRepository();
    container = ProviderContainer(
      overrides: [billRepositoryProvider.overrideWithValue(mockRepo)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  BillReviewNotifier notifier() =>
      container.read(billReviewFamily(OcrResult.manual()).notifier);

  void stubSuccess() {
    when(
      mockRepo.ensureSignedIn(),
    ).thenAnswer((_) async => const Result.success(null));
    when(mockRepo.createBill(any)).thenAnswer(
      (_) async => Result.success(
        Bill(
          id: 'bill-manual',
          title: 'Warung Manual',
          totalAmount: 30000,
          currencyCode: 'IDR',
          tax: 0,
          service: 0,
          createdAt: DateTime(2026),
        ),
      ),
    );
    when(mockRepo.upsertItems(any)).thenAnswer(
      (_) async => const Result.success([
        Item(
          id: 'item-1',
          billId: 'bill-manual',
          name: 'Nasi Goreng',
          price: 30000,
          qty: 1,
        ),
      ]),
    );
  }

  group('OcrResult.manual', () {
    test('empty blank form with manual sentinel', () {
      final manual = OcrResult.manual();
      expect(manual.items, isEmpty);
      expect(manual.confidence, 0);
      expect(manual.detectedTotal, isNull);
      expect(manual.receiptDate, isNull);
      expect(manual.isManual, isTrue);
      expect(OcrResult.manualProviderUsed, 'manual');
    });

    test('OCR payloads are not manual', () {
      const ocr = OcrResult(items: [], providerUsed: 'gemini');
      expect(ocr.isManual, isFalse);
    });
  });

  group('BillReviewNotifier.build(manual)', () {
    test('blank state: untitled, no mismatch, no thousands flag', () {
      final state = container.read(billReviewFamily(OcrResult.manual()));
      expect(state.title, 'Untitled bill');
      expect(state.items, isEmpty);
      expect(state.tax, 0);
      expect(state.service, 0);
      expect(state.detectedTotal, isNull);
      expect(state.hasMismatch, isFalse);
      expect(state.suspectThousandsBug, isFalse);
      expect(state.grandTotal, 0);
    });
  });

  group('BillReviewNotifier.save(manual)', () {
    test('empty form → itemsRequired, no repository touch', () async {
      final result = await notifier().save();
      expect(result, isA<SaveError>());
      expect((result as SaveError).kind, SaveErrorKind.itemsRequired);
      verifyNever(mockRepo.ensureSignedIn());
    });

    test('whitespace-only title → titleRequired', () async {
      final n = notifier();
      n.addItem();
      final id = container
          .read(billReviewFamily(OcrResult.manual()))
          .items
          .single
          .localId;
      n.updateItem(id, name: 'Nasi Goreng', price: 30000, qty: 1);
      n.setTitle('   ');

      final result = await n.save();
      expect(result, isA<SaveError>());
      expect((result as SaveError).kind, SaveErrorKind.titleRequired);
      verifyNever(mockRepo.ensureSignedIn());
    });

    test('qty zero → invalidItem (abc-typed qty becomes 0)', () async {
      final n = notifier();
      n.addItem();
      final id = container
          .read(billReviewFamily(OcrResult.manual()))
          .items
          .single
          .localId;
      // UI parses `double.tryParse(v.trim()) ?? 0` — typing "abc" yields 0.
      final parsed = double.tryParse('abc'.trim()) ?? 0;
      n.updateItem(id, name: 'Nasi Goreng', price: 30000, qty: parsed);
      n.setTitle('Warung Manual');

      final result = await n.save();
      expect(result, isA<SaveError>());
      expect((result as SaveError).kind, SaveErrorKind.invalidItem);
      verifyNever(mockRepo.ensureSignedIn());
    });

    test('zero price is allowed → SaveSuccess', () async {
      stubSuccess();
      final n = notifier();
      n.addItem();
      final id = container
          .read(billReviewFamily(OcrResult.manual()))
          .items
          .single
          .localId;
      n.updateItem(id, name: 'Promo gratis', price: 0, qty: 1);
      n.setTitle('Warung Manual');

      final result = await n.save();
      expect(result, isA<SaveSuccess>());
    });

    test('manual happy path uses zero credit path (bill repo only)', () async {
      stubSuccess();
      final n = notifier();
      n.addItem();
      final id = container
          .read(billReviewFamily(OcrResult.manual()))
          .items
          .single
          .localId;
      n.updateItem(id, name: 'Nasi Goreng', price: 30000, qty: 1);
      n.setTitle('Warung Manual');

      final result = await n.save();
      expect(result, isA<SaveSuccess>());

      final captured = verify(
        mockRepo.createBill(captureAny),
      ).captured.cast<Bill>().single;
      expect(captured.title, 'Warung Manual');
      expect(captured.totalAmount, 30000);
      expect(captured.receiptDate, isNull);
    });

    test('upsertItems failure → saveItemsFailed and saving resets', () async {
      when(
        mockRepo.ensureSignedIn(),
      ).thenAnswer((_) async => const Result.success(null));
      when(mockRepo.createBill(any)).thenAnswer(
        (_) async => Result.success(
          Bill(
            id: 'bill-manual',
            title: 'Warung Manual',
            totalAmount: 30000,
            currencyCode: 'IDR',
            tax: 0,
            service: 0,
            createdAt: DateTime(2026),
          ),
        ),
      );
      when(mockRepo.upsertItems(any)).thenAnswer(
        (_) async =>
            const Result.failure(Failure.server(code: 500, message: 'boom')),
      );

      final n = notifier();
      n.addItem();
      final id = container
          .read(billReviewFamily(OcrResult.manual()))
          .items
          .single
          .localId;
      n.updateItem(id, name: 'Nasi Goreng', price: 30000, qty: 1);
      n.setTitle('Warung Manual');

      final first = await n.save();
      expect(first, isA<SaveError>());
      expect((first as SaveError).kind, SaveErrorKind.saveItemsFailed);

      // Saving flag must reset so the user can retry.
      when(mockRepo.upsertItems(any)).thenAnswer(
        (_) async => const Result.success([
          Item(
            id: 'item-1',
            billId: 'bill-manual',
            name: 'Nasi Goreng',
            price: 30000,
            qty: 1,
          ),
        ]),
      );
      final retry = await n.save();
      expect(retry, isA<SaveSuccess>());
    });
  });
}
