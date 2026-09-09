import 'package:bagistruk/core/error/failure.dart';
import 'package:bagistruk/core/error/result.dart';
import 'package:bagistruk/data/providers.dart';
import 'package:bagistruk/domain/entities/assignment.dart';
import 'package:bagistruk/domain/entities/bill.dart';
import 'package:bagistruk/domain/entities/item.dart';
import 'package:bagistruk/domain/entities/participant.dart';
import 'package:bagistruk/presentation/bills/providers/bill_detail_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../bill_review_notifier_save_test.mocks.dart';

void main() {
  late MockIBillRepository mockRepo;
  late ProviderContainer container;
  const billId = 'bill-1';
  final bill = Bill(
    id: billId,
    title: 'Lama',
    totalAmount: 100000,
    createdAt: DateTime.utc(2026, 9, 1),
  );

  setUpAll(() {
    provideDummy<Result<Bill>>(Result.success(bill));
    provideDummy<Result<List<Item>>>(const Result.success([]));
    provideDummy<Result<List<Participant>>>(const Result.success([]));
    provideDummy<Result<List<Assignment>>>(const Result.success([]));
  });

  setUp(() {
    mockRepo = MockIBillRepository();
    when(
      mockRepo.getBill(any),
    ).thenAnswer((_) async => Result.success(bill));
    when(
      mockRepo.listItems(any),
    ).thenAnswer((_) async => const Result.success([]));
    when(
      mockRepo.listParticipants(any),
    ).thenAnswer((_) async => const Result.success([]));
    when(
      mockRepo.listAssignments(any),
    ).thenAnswer((_) async => const Result.success([]));
    container = ProviderContainer(
      overrides: [billRepositoryProvider.overrideWithValue(mockRepo)],
    );
    final sub = container.listen(billDetailFamily(billId), (_, _) {});
    addTearDown(sub.close);
  });

  tearDown(() {
    container.dispose();
  });

  Future<BillDetailNotifier> notifier() async {
    await container.read(billDetailFamily(billId).future);
    return container.read(billDetailFamily(billId).notifier);
  }

  group('BillDetailNotifier.renameBill', () {
    test('trims, updates optimistically, and persists', () async {
      when(mockRepo.updateBill(any)).thenAnswer(
        (inv) async =>
            Result.success(inv.positionalArguments.single as Bill),
      );

      final err = await (await notifier()).renameBill('  Baru  ');

      expect(err, isNull);
      expect(
        container.read(billDetailFamily(billId)).value?.bill.title,
        'Baru',
      );
      verify(
        mockRepo.updateBill(
          argThat(predicate<Bill>((b) => b.id == billId && b.title == 'Baru')),
        ),
      ).called(1);
    });

    test('unchanged title skips the network call', () async {
      final err = await (await notifier()).renameBill('Lama');

      expect(err, isNull);
      verifyNever(mockRepo.updateBill(any));
    });

    test('persist failure rolls back to the old title', () async {
      when(mockRepo.updateBill(any)).thenAnswer(
        (_) async => const Result.failure(
          Failure.server(code: 500, message: 'boom'),
        ),
      );

      final err = await (await notifier()).renameBill('Baru');

      expect(err, isNotNull);
      expect(
        container.read(billDetailFamily(billId)).value?.bill.title,
        'Lama',
      );
    });
  });
}
