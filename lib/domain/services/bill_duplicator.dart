import 'package:uuid/uuid.dart';

import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../entities/assignment.dart';
import '../entities/bill.dart';
import '../entities/item.dart';
import '../entities/participant.dart';
import '../repositories/i_bill_repository.dart';

/// M4/F12 client-side bill duplication. Composes existing repository calls:
/// fetch source graph → write new graph with fresh IDs, `createdAt` now,
/// settlement reset (isPaid false, paidAt null), receiptDate cleared.
/// `shareWeight` is preserved per assignment (M1 decision).
///
/// Not a repository method: duplication is client orchestration over the
/// public repo surface, so it stays unit-testable against a fake
/// [IBillRepository] without touching PostgREST semantics.
class BillDuplicator {
  BillDuplicator(this._repo, [Uuid? uuid]) : _uuid = uuid ?? const Uuid();
  final IBillRepository _repo;
  final Uuid _uuid;

  /// Duplicates [billId] and returns the new bill's id.
  Future<Result<String>> duplicate(String billId) async {
    final billRes = await _repo.getBill(billId);
    if (billRes is ResultFailure<Bill>) {
      return Result.failure(billRes.failure);
    }
    final source = (billRes as Success<Bill>).data;

    final itemsRes = await _repo.listItems(billId);
    if (itemsRes is ResultFailure<List<Item>>) {
      return Result.failure(itemsRes.failure);
    }
    final items = (itemsRes as Success<List<Item>>).data;
    if (items.isEmpty) {
      // No `Failure.validation` variant exists in the closed union — unknown
      // with an `empty_bill` tag is log-only; the UI surfaces a generic
      // localized message for all duplicate failures.
      return const Result.failure(Failure.unknown('empty_bill', null));
    }

    final participantsRes = await _repo.listParticipants(billId);
    if (participantsRes is ResultFailure<List<Participant>>) {
      return Result.failure(participantsRes.failure);
    }
    final participants =
        (participantsRes as Success<List<Participant>>).data;

    final assignmentsRes = await _repo.listAssignments(billId);
    if (assignmentsRes is ResultFailure<List<Assignment>>) {
      return Result.failure(assignmentsRes.failure);
    }
    final assignments =
        (assignmentsRes as Success<List<Assignment>>).data;

    final newBillId = _uuid.v4();
    final now = DateTime.now().toUtc();
    final createRes = await _repo.createBill(
      Bill(
        id: newBillId,
        title: source.title,
        totalAmount: source.totalAmount,
        currencyCode: source.currencyCode,
        tax: source.tax,
        service: source.service,
        receiptDate: null,
        createdAt: now,
        category: source.category,
        tags: source.tags,
      ),
    );
    if (createRes is ResultFailure<Bill>) {
      return Result.failure(createRes.failure);
    }

    // Remap old item/participant IDs to fresh ones, preserving the graph.
    final itemIdMap = <String, String>{
      for (final i in items) i.id: _uuid.v4(),
    };
    final participantIdMap = <String, String>{
      for (final p in participants) p.id: _uuid.v4(),
    };

    final itemsWrite = await _repo.upsertItems([
      for (final i in items)
        Item(
          id: itemIdMap[i.id]!,
          billId: newBillId,
          name: i.name,
          price: i.price,
          qty: i.qty,
        ),
    ]);
    if (itemsWrite is ResultFailure<List<Item>>) {
      return Result.failure(itemsWrite.failure);
    }

    for (final p in participants) {
      final write = await _repo.upsertParticipant(
        Participant(
          id: participantIdMap[p.id]!,
          billId: newBillId,
          name: p.name,
          phone: p.phone,
        ),
      );
      if (write is ResultFailure<Participant>) {
        return Result.failure(write.failure);
      }
    }

    final mappedAssignments = [
      for (final a in assignments)
        if (itemIdMap.containsKey(a.itemId) &&
            participantIdMap.containsKey(a.participantId))
          Assignment(
            id: _uuid.v4(),
            itemId: itemIdMap[a.itemId]!,
            participantId: participantIdMap[a.participantId]!,
            shareWeight: a.shareWeight,
          ),
    ];
    final assignRes = await _repo.replaceAssignments(
      newBillId,
      mappedAssignments,
    );
    if (assignRes is ResultFailure<List<Assignment>>) {
      return Result.failure(assignRes.failure);
    }
    return Result.success(newBillId);
  }
}
