import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../data/providers.dart';
import '../../../domain/entities/assignment.dart';
import '../../../domain/entities/bill.dart';
import '../../../domain/entities/item.dart';
import '../../../domain/entities/participant.dart';
import '../../../domain/services/money.dart';
import 'split_notifier.dart' show ParticipantTotal;

part 'bill_detail_notifier.freezed.dart';
part 'bill_detail_notifier.g.dart';

@freezed
abstract class BillDetailState with _$BillDetailState {
  const factory BillDetailState({
    required Bill bill,
    required List<Item> items,
    required List<Participant> participants,
    required List<Assignment> assignments,
  }) = _BillDetailState;

  const BillDetailState._();

  int get paidCount => participants.where((p) => p.isPaid).length;

  /// Per-participant proportional totals. Mirrors `SplitState.calculateTotals`
  /// — duplicated here intentionally to keep the detail screen decoupled from
  /// split-screen state shape; refactor to a shared util if drift appears.
  List<ParticipantTotal> calculateTotals() {
    final currency = bill.currencyCode;
    final totalSubtotal = items.fold<double>(0, (s, i) => s + i.price * i.qty);
    final raw = <_RawTotal>[];
    for (final p in participants) {
      var pSub = 0.0;
      for (final it in items) {
        final assignees = assignments
            .where((a) => a.itemId == it.id)
            .toList(growable: false);
        if (assignees.isEmpty) continue;
        if (assignees.any((a) => a.participantId == p.id)) {
          pSub += (it.price * it.qty) / assignees.length;
        }
      }
      final share = totalSubtotal == 0 ? 0.0 : pSub / totalSubtotal;
      raw.add(
        _RawTotal(
          participantId: p.id,
          subtotal: pSub,
          tax: bill.tax * share,
          service: bill.service * share,
        ),
      );
    }

    final result = raw
        .map(
          (r) => ParticipantTotal(
            participantId: r.participantId,
            subtotal: Money.roundToCurrency(r.subtotal, currency),
            tax: Money.roundToCurrency(r.tax, currency),
            service: Money.roundToCurrency(r.service, currency),
            total: Money.roundToCurrency(
              r.subtotal + r.tax + r.service,
              currency,
            ),
          ),
        )
        .toList();

    // Absorb rounding drift on the last participant when every item is
    // assigned, so displayed totals sum to bill.totalAmount exactly.
    final unassignedSubtotal = _unassignedSubtotal();
    if (result.isNotEmpty && unassignedSubtotal <= 0.0001) {
      final summed = result.fold<double>(0, (s, r) => s + r.total);
      final drift = Money.roundToCurrency(bill.totalAmount, currency) - summed;
      if (drift != 0) {
        for (var i = result.length - 1; i >= 0; i--) {
          if (result[i].total > 0) {
            result[i] = result[i].copyWith(total: result[i].total + drift);
            break;
          }
        }
      }
    }

    return result;
  }

  double _unassignedSubtotal() {
    var sum = 0.0;
    for (final it in items) {
      final hasAny = assignments.any((a) => a.itemId == it.id);
      if (!hasAny) sum += it.price * it.qty;
    }
    return sum;
  }
}

class _RawTotal {
  _RawTotal({
    required this.participantId,
    required this.subtotal,
    required this.tax,
    required this.service,
  });
  final String participantId;
  final double subtotal;
  final double tax;
  final double service;
}

/// Loads the bill graph for the detail screen and exposes the settlement
/// toggle. Strategy: optimistic UI update; on persist failure roll back to the
/// previous state. After a successful participant update, evaluate whether
/// the whole bill should flip `is_settled`.
@riverpod
class BillDetailNotifier extends _$BillDetailNotifier {
  @override
  Future<BillDetailState> build(String billId) async {
    final repo = ref.watch(billRepositoryProvider);

    final bill = _unwrap(await repo.getBill(billId));
    final items = _unwrap(await repo.listItems(billId));
    final participants = _unwrap(await repo.listParticipants(billId));
    final assignments = _unwrap(await repo.listAssignments(billId));

    return BillDetailState(
      bill: bill,
      items: items,
      participants: participants,
      assignments: assignments,
    );
  }

  /// Renames the bill (used after duplication and anywhere a title edit is
  /// needed). Optimistic UI update with rollback on persist failure; empty
  /// titles are rejected by the caller (dialog validation), and a no-op
  /// rename (unchanged title) short-circuits without a network call.
  Future<BillDetailActionError?> renameBill(String title) async {
    final s = state.value;
    if (s == null) {
      return const BillDetailActionError(
        BillDetailActionErrorKind.stateNotReady,
      );
    }
    final next = title.trim();
    if (next.isEmpty || next == s.bill.title) return null;

    final updated = s.bill.copyWith(title: next);
    state = AsyncData(s.copyWith(bill: updated));
    final repo = ref.read(billRepositoryProvider);
    final res = await repo.updateBill(updated);
    if (res is ResultFailure<Bill>) {
      state = AsyncData(s);
      return BillDetailActionError(
        BillDetailActionErrorKind.saveStatusFailed,
        res.failure.toString(),
      );
    }
    return null;
  }

  Future<BillDetailActionError?> toggleParticipantPaymentStatus(
    String participantId,
  ) async {
    final s = state.value;
    if (s == null) {
      return const BillDetailActionError(
        BillDetailActionErrorKind.stateNotReady,
      );
    }

    final idx = s.participants.indexWhere((p) => p.id == participantId);
    if (idx < 0) {
      return const BillDetailActionError(BillDetailActionErrorKind.notFound);
    }
    final old = s.participants[idx];
    final updated = old.copyWith(
      isPaid: !old.isPaid,
      paidAt: !old.isPaid ? DateTime.now() : null,
    );
    final nextList = [...s.participants]..[idx] = updated;

    state = AsyncData(s.copyWith(participants: nextList));

    final repo = ref.read(billRepositoryProvider);
    final res = await repo.upsertParticipant(updated);
    if (res is ResultFailure<Participant>) {
      state = AsyncData(s);
      return BillDetailActionError(
        BillDetailActionErrorKind.saveStatusFailed,
        res.failure.toString(),
      );
    }

    final allPaid = nextList.isNotEmpty && nextList.every((p) => p.isPaid);
    if (allPaid != s.bill.isSettled) {
      final newBill = s.bill.copyWith(isSettled: allPaid);
      final billRes = await repo.updateBill(newBill);
      if (billRes is Success<Bill>) {
        final cur = state.value;
        if (cur != null) {
          state = AsyncData(cur.copyWith(bill: billRes.data));
        }
      }
    }
    return null;
  }

  static T _unwrap<T>(Result<T> r) => switch (r) {
    Success(:final data) => data,
    ResultFailure(:final failure) => throw _FailureException(failure),
  };
}

class BillDetailActionError {
  const BillDetailActionError(this.kind, [this.message]);
  final BillDetailActionErrorKind kind;
  final String? message;
}

enum BillDetailActionErrorKind { notFound, saveStatusFailed, stateNotReady }

class _FailureException implements Exception {
  _FailureException(this.failure);
  final Failure failure;
  @override
  String toString() => failure.toString();
}
