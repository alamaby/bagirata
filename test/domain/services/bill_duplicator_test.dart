import 'package:bagistruk/core/error/failure.dart';
import 'package:bagistruk/core/error/result.dart';
import 'package:bagistruk/domain/entities/assignment.dart';
import 'package:bagistruk/domain/entities/bill.dart';
import 'package:bagistruk/domain/entities/item.dart';
import 'package:bagistruk/domain/entities/participant.dart';
import 'package:bagistruk/domain/repositories/i_bill_repository.dart';
import 'package:bagistruk/domain/services/bill_duplicator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'bill_duplicator_test.mocks.dart';

final _stubBill = Bill(
  id: 'stub',
  title: 'stub',
  totalAmount: 0,
  currencyCode: 'IDR',
  tax: 0,
  service: 0,
  createdAt: DateTime.utc(2026),
);

/// M4/F12: client-side duplication preserves the bill graph (items,
/// participants incl. phone, assignment weights) with fresh IDs, reset
/// settlement, and cleared receipt date.
@GenerateMocks([IBillRepository])
void main() {
  // Mockito needs a dummy for every non-nullable custom return type used
  // in `when(...)` stubbing (same pattern as repository_contract_test).
  setUpAll(() {
    provideDummy<Result<Bill>>(Result.success(_stubBill));
    provideDummy<Result<List<Item>>>(const Result.success([]));
    provideDummy<Result<List<Participant>>>(const Result.success([]));
    provideDummy<Result<List<Assignment>>>(const Result.success([]));
    provideDummy<Result<Participant>>(
      const Result.success(
        Participant(id: 'stub', billId: 'stub', name: 'stub'),
      ),
    );
    provideDummy<Result<String>>(const Result.success(''));
    // `any` matchers on non-nullable params need argument dummies too.
    provideDummy<Bill>(_stubBill);
    provideDummy<List<Item>>(const []);
    provideDummy<List<Assignment>>(const []);
    provideDummy<Participant>(
      const Participant(id: 'stub', billId: 'stub', name: 'stub'),
    );
    provideDummy<String>('');
  });

  group('BillDuplicator', () {
    late MockIBillRepository repo;
    late BillDuplicator duplicator;

    final sourceBill = Bill(
      id: 'bill-src',
      title: 'Team lunch',
      totalAmount: 150000,
      currencyCode: 'IDR',
      tax: 10000,
      service: 5000,
      isSettled: true,
      receiptDate: DateTime.utc(2026, 8, 1),
      createdAt: DateTime.utc(2026, 8, 2),
      category: 'makan',
      tags: const ['team'],
    );
    const items = [
      Item(id: 'i1', billId: 'bill-src', name: 'Nasi', price: 50000, qty: 2),
      Item(id: 'i2', billId: 'bill-src', name: 'Teh', price: 10000, qty: 1),
    ];
    const participants = [
      Participant(
        id: 'p1',
        billId: 'bill-src',
        name: 'Ana',
        isPaid: true,
        phone: '+62812',
      ),
      Participant(id: 'p2', billId: 'bill-src', name: 'Budi', isPaid: false),
    ];
    const assignments = [
      Assignment(
        id: 'a1',
        itemId: 'i1',
        participantId: 'p1',
        shareWeight: 2,
      ),
      Assignment(
        id: 'a2',
        itemId: 'i1',
        participantId: 'p2',
        shareWeight: 1,
      ),
      Assignment(
        id: 'a3',
        itemId: 'i2',
        participantId: 'p2',
        shareWeight: 1,
      ),
    ];

    setUp(() {
      repo = MockIBillRepository();
      duplicator = BillDuplicator(repo);
      when(repo.getBill('bill-src')).thenAnswer(
        (_) async => Result.success(sourceBill),
      );
      when(repo.listItems('bill-src')).thenAnswer(
        (_) async => Result.success(items),
      );
      when(repo.listParticipants('bill-src')).thenAnswer(
        (_) async => Result.success(participants),
      );
      when(repo.listAssignments('bill-src')).thenAnswer(
        (_) async => Result.success(assignments),
      );
      when(
        repo.createBill(any),
      ).thenAnswer((inv) async => Result.success(inv.positionalArguments[0] as Bill));
      when(repo.upsertItems(any)).thenAnswer(
        (inv) async =>
            Result.success(List<Item>.from(inv.positionalArguments[0] as List)),
      );
      when(repo.upsertParticipant(any)).thenAnswer(
        (inv) async =>
            Result.success(inv.positionalArguments[0] as Participant),
      );
      when(
        repo.replaceAssignments(any, any),
      ).thenAnswer(
        (inv) async => Result.success(
          List<Assignment>.from(inv.positionalArguments[1] as List),
        ),
      );
    });

    test('duplicates graph with fresh ids and reset settlement', () async {
      final res = await duplicator.duplicate('bill-src');
      expect(res, isA<Success<String>>());
      final newId = (res as Success<String>).data;
      expect(newId, isNot('bill-src'));

      final created =
          verify(repo.createBill(captureAny)).captured.single as Bill;
      expect(created.id, newId);
      expect(created.title, 'Team lunch');
      expect(created.isSettled, isFalse);
      expect(created.receiptDate, isNull);
      expect(created.category, 'makan');
      expect(created.tags, ['team']);

      final writtenItems =
          verify(repo.upsertItems(captureAny)).captured.single as List<Item>;
      expect(writtenItems, hasLength(2));
      expect(writtenItems.map((i) => i.billId).toSet(), {newId});
      expect(writtenItems.map((i) => i.id), isNot(contains('i1')));

      final writtenParticipants =
          verify(repo.upsertParticipant(captureAny)).captured
              .cast<Participant>();
      expect(writtenParticipants, hasLength(2));
      final ana = writtenParticipants.firstWhere((p) => p.name == 'Ana');
      expect(ana.isPaid, isFalse);
      expect(ana.paidAt, isNull);
      expect(ana.phone, '+62812');

      final writtenAssignments =
          verify(repo.replaceAssignments(newId, captureAny)).captured.single
              as List<Assignment>;
      expect(writtenAssignments, hasLength(3));
      // Weights preserved; ids remapped onto the new graph.
      final weights = writtenAssignments.map((a) => a.shareWeight).toList()
        ..sort();
      expect(weights, [1, 1, 2]);
      final newItemIds = writtenItems.map((i) => i.id).toSet();
      final newParticipantIds = writtenParticipants.map((p) => p.id).toSet();
      for (final a in writtenAssignments) {
        expect(newItemIds, contains(a.itemId));
        expect(newParticipantIds, contains(a.participantId));
      }
    });

    test('empty bill fails without writing', () async {
      when(repo.listItems('bill-src')).thenAnswer(
        (_) async => const Result.success(<Item>[]),
      );
      final res = await duplicator.duplicate('bill-src');
      expect(res.isFailure, isTrue);
      verifyNever(repo.createBill(any));
    });

    test('source fetch failure short-circuits', () async {
      when(repo.getBill('bill-src')).thenAnswer(
        (_) async => const Result.failure(Failure.auth('stub')),
      );
      final res = await duplicator.duplicate('bill-src');
      expect(res.isFailure, isTrue);
      verifyNever(repo.createBill(any));
    });
  });
}
