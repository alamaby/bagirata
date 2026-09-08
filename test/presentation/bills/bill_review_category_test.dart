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

import 'bill_review_category_test.mocks.dart';

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
    when(
      mockRepo.ensureSignedIn(),
    ).thenAnswer((_) async => const Result.success(null));
    when(mockRepo.createBill(any)).thenAnswer(
      (inv) async => Result.success(
        (inv.positionalArguments.single as Bill),
      ),
    );
    when(mockRepo.upsertItems(any)).thenAnswer(
      (_) async => const Result.success(<Item>[]),
    );
  });

  tearDown(() {
    container.dispose();
  });

  BillReviewNotifier notifier() {
    const ocr = OcrResult(
      items: [OcrLineItem(name: 'Nasi Goreng', price: 25000, qty: 1)],
      merchant: 'Warung Test',
      providerUsed: 'gemini',
    );
    return container.read(billReviewFamily(ocr).notifier);
  }

  group('BillReviewNotifier category/tags', () {
    test('defaults to lain with no tags', () {
      expect(notifier().state.category, 'lain');
      expect(notifier().state.tags, isEmpty);
    });

    test('setCategory coerces unknown codes', () {
      final n = notifier();
      n.setCategory('makan');
      expect(n.state.category, 'makan');
      n.setCategory('FOOD');
      expect(n.state.category, 'lain');
    });

    test('setTags normalizes and caps', () {
      final n = notifier();
      n.setTags([' Kopi ', '', 'KOPI', 'a', 'b', 'c', 'd', 'e']);
      expect(n.state.tags, ['Kopi', 'a', 'b', 'c', 'd']);
    });

    test('save persists coerced category and normalized tags', () async {
      final n = notifier();
      n.setCategory('transport');
      n.setTags(['Kantor', 'kantor', '  ']);

      final result = await n.save();
      expect(result, isA<SaveSuccess>());

      final captured =
          verify(mockRepo.createBill(captureAny)).captured.single as Bill;
      expect(captured.category, 'transport');
      expect(captured.tags, ['Kantor']);
    });

    test('save coerces invalid category instead of failing', () async {
      final n = notifier();
      // Bypass the setter to simulate hostile state.
      n.setCategory('lain');
      n.state = n.state.copyWith(category: 'FOOD');
      n.setTags([]);

      final result = await n.save();
      expect(result, isA<SaveSuccess>());

      final captured =
          verify(mockRepo.createBill(captureAny)).captured.single as Bill;
      expect(captured.category, 'lain');
    });

    test('non-Plus field input strips tags on save', () async {
      final n = notifier();
      // Simulate a Free user typing into a locked field: tags must not leak.
      n.setTagsField('kopi, kantor', isPlus: false);

      final result = await n.save();
      expect(result, isA<SaveSuccess>());

      final captured =
          verify(mockRepo.createBill(captureAny)).captured.single as Bill;
      expect(captured.tags, isEmpty);
    });
  });
}
