import 'package:bagistruk/core/error/failure.dart';
import 'package:bagistruk/core/error/result.dart';
import 'package:bagistruk/data/providers.dart';
import 'package:bagistruk/domain/entities/assignment.dart';
import 'package:bagistruk/domain/entities/bill.dart';
import 'package:bagistruk/domain/entities/item.dart';
import 'package:bagistruk/domain/entities/participant.dart';
import 'package:bagistruk/domain/repositories/i_bill_repository.dart';
import 'package:bagistruk/presentation/bills/providers/split_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'split_assign_all_test.mocks.dart';

@GenerateMocks([IBillRepository])
void main() {
  late MockIBillRepository mockRepo;
  late ProviderContainer container;

  Bill testBill() => Bill(
    id: 'bill-1',
    title: 'Bukber',
    totalAmount: 100000,
    currencyCode: 'IDR',
    tax: 10000,
    service: 5000,
    createdAt: DateTime(2026),
  );

  Item item(String id, double price) => Item(
    id: id,
    billId: 'bill-1',
    name: 'Item $id',
    price: price,
    qty: 1,
  );

  Participant participant(String id, String name) =>
      Participant(id: id, billId: 'bill-1', name: name);

  setUpAll(() {
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
    provideDummy<Result<List<Participant>>>(const Result.success([]));
    provideDummy<Result<List<Assignment>>>(const Result.success([]));
    provideDummy<Result<Participant>>(
      Result.success(Participant(id: '', billId: '', name: '')),
    );
    provideDummy<Result<void>>(const Result.success(null));
  });

  void seedGraph({
    List<Item>? items,
    List<Participant>? participants,
    List<Assignment>? assignments,
  }) {
    mockRepo = MockIBillRepository();
    when(mockRepo.getBill(any)).thenAnswer((_) async => Result.success(testBill()));
    when(
      mockRepo.listItems(any),
    ).thenAnswer((_) async => Result.success(items ?? []));
    when(
      mockRepo.listParticipants(any),
    ).thenAnswer((_) async => Result.success(participants ?? []));
    when(
      mockRepo.listAssignments(any),
    ).thenAnswer((_) async => Result.success(assignments ?? []));
    when(mockRepo.upsertParticipant(any)).thenAnswer(
      (inv) async => Result.success(
        (inv.positionalArguments.single as Participant),
      ),
    );
    when(mockRepo.replaceAssignments(any, any)).thenAnswer(
      (inv) async => Result.success(
        (inv.positionalArguments[1] as List<Assignment>),
      ),
    );
    container = ProviderContainer(
      overrides: [billRepositoryProvider.overrideWithValue(mockRepo)],
    );
  }

  tearDown(() {
    container.dispose();
  });

  Future<SplitState> loadState() async {
    final s = await container.read(splitFamily('bill-1').future);
    return s;
  }

  group('SplitNotifier.addParticipant dedup + normalize', () {
    test('duplicate name (case/whitespace) rejected', () async {
      seedGraph(participants: [participant('p1', 'Budi')]);
      await loadState();
      final notifier = container.read(splitFamily('bill-1').notifier);

      for (final name in ['budi', 'BUDI', '  Budi  ']) {
        final err = await notifier.addParticipant(name);
        expect(err, isNotNull);
        expect(err!.kind, SplitActionErrorKind.duplicateName);
      }
      verifyNever(mockRepo.upsertParticipant(any));
    });

    test('distinct name accepted with normalized phone', () async {
      seedGraph(participants: [participant('p1', 'Budi')]);
      await loadState();
      final notifier = container.read(splitFamily('bill-1').notifier);

      final err = await notifier.addParticipant('Ani', phone: '0812 3456 789');
      expect(err, isNull);
      final captured = verify(
        mockRepo.upsertParticipant(captureAny),
      ).captured.cast<Participant>().single;
      expect(captured.phone, '628123456789');
    });

    test('unique-violation race maps to duplicateName', () async {
      seedGraph(participants: [participant('p1', 'Budi')]);
      await loadState();
      final notifier = container.read(splitFamily('bill-1').notifier);

      // Simulate the double-tap race: in-memory check passed (different
      // client state), server rejects via participants_bill_name_unique.
      when(mockRepo.upsertParticipant(any)).thenAnswer(
        (_) async => const Result.failure(
          Failure.server(
            code: 23505,
            message:
                'duplicate key value violates unique constraint "participants_bill_name_unique"',
          ),
        ),
      );
      final err = await notifier.addParticipant('Ani');
      expect(err, isNotNull);
      expect(err!.kind, SplitActionErrorKind.duplicateName);
    });

    test('short phone collapses to null', () async {
      seedGraph(participants: [participant('p1', 'Budi')]);
      await loadState();
      final notifier = container.read(splitFamily('bill-1').notifier);

      final err = await notifier.addParticipant('Ani', phone: '123');
      expect(err, isNull);
      final captured = verify(
        mockRepo.upsertParticipant(captureAny),
      ).captured.cast<Participant>().single;
      expect(captured.phone, isNull);
    });
  });

  group('SplitNotifier.assignAll', () {
    test('assigns everyone to everything in one round-trip', () async {
      seedGraph(
        items: [item('i1', 60000), item('i2', 25000)],
        participants: [participant('p1', 'Budi'), participant('p2', 'Ani')],
      );
      await loadState();
      final notifier = container.read(splitFamily('bill-1').notifier);

      final err = await notifier.assignAll();
      expect(err, isNull);
      final saved = verify(
        mockRepo.replaceAssignments(any, captureAny),
      ).captured.cast<List<Assignment>>().single;
      expect(saved.length, 4);
      for (final it in ['i1', 'i2']) {
        for (final p in ['p1', 'p2']) {
          expect(
            saved.any((a) => a.itemId == it && a.participantId == p),
            isTrue,
          );
        }
      }
    });

    test('idempotent — second call is a no-op without repo touch', () async {
      seedGraph(
        items: [item('i1', 60000)],
        participants: [participant('p1', 'Budi'), participant('p2', 'Ani')],
      );
      await loadState();
      final notifier = container.read(splitFamily('bill-1').notifier);

      expect(await notifier.assignAll(), isNull);
      expect(await notifier.assignAll(), isNull);
      verify(mockRepo.replaceAssignments(any, any)).called(1);
    });

    test('keeps existing pairs and adds only missing ones', () async {
      seedGraph(
        items: [item('i1', 60000), item('i2', 25000)],
        participants: [participant('p1', 'Budi'), participant('p2', 'Ani')],
        assignments: const [
          Assignment(id: 'a1', itemId: 'i1', participantId: 'p1'),
        ],
      );
      await loadState();
      final notifier = container.read(splitFamily('bill-1').notifier);

      expect(await notifier.assignAll(), isNull);
      final saved = verify(
        mockRepo.replaceAssignments(any, captureAny),
      ).captured.cast<List<Assignment>>().single;
      expect(saved.length, 4);
      expect(saved.any((a) => a.id == 'a1'), isTrue);
    });

    test('persistence failure rolls back to previous assignments', () async {
      seedGraph(
        items: [item('i1', 60000)],
        participants: [participant('p1', 'Budi')],
      );
      when(mockRepo.replaceAssignments(any, any)).thenAnswer(
        (_) async =>
            const Result.failure(Failure.server(code: 500, message: 'boom')),
      );
      await loadState();
      final notifier = container.read(splitFamily('bill-1').notifier);

      final err = await notifier.assignAll();
      expect(err, isNotNull);
      expect(err!.kind, SplitActionErrorKind.saveAssignmentFailed);
      final state = container.read(splitFamily('bill-1')).value!;
      expect(state.assignments, isEmpty);
    });

    test('empty graph is a no-op', () async {
      seedGraph();
      await loadState();
      final notifier = container.read(splitFamily('bill-1').notifier);
      expect(await notifier.assignAll(), isNull);
      verifyNever(mockRepo.replaceAssignments(any, any));
    });
  });

  group('SplitState equal totals', () {
    test('equal split of 100000 across 3 is whole rupiah', () {
      final bill = testBill();
      final items = [item('i1', 85000)];
      final parts = [
        participant('p1', 'A'),
        participant('p2', 'B'),
        participant('p3', 'C'),
      ];
      final assigns = [
        for (final p in parts)
          Assignment(id: 'a-${p.id}', itemId: 'i1', participantId: p.id),
      ];
      final state = SplitState(
        bill: bill,
        items: items,
        participants: parts,
        assignments: assigns,
      );
      final totals = state.calculateTotals();
      expect(totals.length, 3);
      // Whole rupiah each — no fractional drift for IDR.
      for (final t in totals) {
        expect(t.total, equals(t.total.roundToDouble()));
      }
      final summed = totals.fold<double>(0, (s, t) => s + t.total);
      expect(summed, bill.totalAmount);
    });
  });
}
