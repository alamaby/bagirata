import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../data/providers.dart';
import '../../../domain/entities/assignment.dart';
import '../../../domain/entities/bill.dart';
import '../../../domain/entities/item.dart';
import '../../../domain/entities/participant.dart';

part 'split_notifier.freezed.dart';
part 'split_notifier.g.dart';

/// Per-participant breakdown produced by [SplitState.calculateTotals].
@freezed
abstract class ParticipantTotal with _$ParticipantTotal {
  const factory ParticipantTotal({
    required String participantId,
    required double subtotal,
    required double tax,
    required double service,
    required double total,
  }) = _ParticipantTotal;
}

@freezed
abstract class SplitState with _$SplitState {
  const factory SplitState({
    required Bill bill,
    required List<Item> items,
    required List<Participant> participants,
    required List<Assignment> assignments,
    String? selectedParticipantId,
  }) = _SplitState;

  const SplitState._();

  double get itemsSubtotal =>
      items.fold<double>(0, (s, i) => s + i.price * i.qty);

  /// Subtotal of items that nobody is assigned to.
  double get unassignedSubtotal {
    var sum = 0.0;
    for (final it in items) {
      final hasAny = assignments.any((a) => a.itemId == it.id);
      if (!hasAny) sum += it.price * it.qty;
    }
    return sum;
  }

  /// Items a given participant is on, with the per-share subtotal already
  /// divided when the item has multiple assignees.
  List<ParticipantItemShare> itemsForParticipant(String participantId) {
    final out = <ParticipantItemShare>[];
    for (final it in items) {
      final assignees =
          assignments.where((a) => a.itemId == it.id).toList(growable: false);
      if (assignees.isEmpty) continue;
      if (!assignees.any((a) => a.participantId == participantId)) continue;
      final share = (it.price * it.qty) / assignees.length;
      out.add(ParticipantItemShare(
        item: it,
        sharedWith: assignees.length,
        share: share,
      ));
    }
    return out;
  }

  /// Proportional share: tax & service split based on each participant's
  /// share of the items' subtotal. Items with multiple assignees split the
  /// item subtotal evenly (50:50 for two, etc.).
  ///
  /// Rounding: each per-participant total is rounded to whole units (rupiah);
  /// any drift caused by rounding is absorbed by the last participant so the
  /// sum of participant totals exactly matches [Bill.totalAmount] when every
  /// item is assigned.
  List<ParticipantTotal> calculateTotals() {
    final totalSubtotal = itemsSubtotal;
    final raw = <_RawTotal>[];
    for (final p in participants) {
      var pSub = 0.0;
      for (final it in items) {
        final assignees =
            assignments.where((a) => a.itemId == it.id).toList(growable: false);
        if (assignees.isEmpty) continue;
        if (assignees.any((a) => a.participantId == p.id)) {
          pSub += (it.price * it.qty) / assignees.length;
        }
      }
      final share = totalSubtotal == 0 ? 0.0 : pSub / totalSubtotal;
      raw.add(_RawTotal(
        participantId: p.id,
        subtotal: pSub,
        tax: bill.tax * share,
        service: bill.service * share,
      ));
    }

    final result = raw
        .map((r) => ParticipantTotal(
              participantId: r.participantId,
              subtotal: _round(r.subtotal),
              tax: _round(r.tax),
              service: _round(r.service),
              total: _round(r.subtotal + r.tax + r.service),
            ))
        .toList();

    // Absorb rounding drift on the last assigned participant so the sum of
    // displayed totals matches the bill total exactly.
    if (result.isNotEmpty && unassignedSubtotal <= 0.0001) {
      final summed = result.fold<double>(0, (s, r) => s + r.total);
      final drift = _round(bill.totalAmount) - summed;
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

  static double _round(double v) => v.roundToDouble();
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

@freezed
abstract class ParticipantItemShare with _$ParticipantItemShare {
  const factory ParticipantItemShare({
    required Item item,
    required int sharedWith,
    required double share,
  }) = _ParticipantItemShare;
}

/// Stateful controller for the split screen. Loads the bill graph from the
/// repository and lets the UI mutate participants/assignments live.
///
/// Persistence strategy: participants are upserted on creation (so they have
/// stable IDs), assignments are persisted via [replaceAssignments] on every
/// toggle — the bill graph is small enough that one round-trip per toggle is
/// fine, and it removes the need for an explicit save button.
@riverpod
class SplitNotifier extends _$SplitNotifier {
  static const _uuid = Uuid();

  @override
  Future<SplitState> build(String billId) async {
    final repo = ref.watch(billRepositoryProvider);

    final billRes = await repo.getBill(billId);
    final bill = _unwrap(billRes);

    final itemsRes = await repo.listItems(billId);
    final items = _unwrap(itemsRes);

    final partsRes = await repo.listParticipants(billId);
    final participants = _unwrap(partsRes);

    final assignsRes = await repo.listAssignments(billId);
    final assignments = _unwrap(assignsRes);

    return SplitState(
      bill: bill,
      items: items,
      participants: participants,
      assignments: assignments,
    );
  }

  void selectParticipant(String? id) {
    final s = state.value;
    if (s == null) return;
    final next = s.selectedParticipantId == id ? null : id;
    state = AsyncData(s.copyWith(selectedParticipantId: next));
  }

  Future<String?> addParticipant(String name) async {
    final s = state.value;
    if (s == null) return 'State belum siap';
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Nama tidak boleh kosong';

    final participant = Participant(
      id: _uuid.v4(),
      billId: s.bill.id,
      name: trimmed,
    );
    final repo = ref.read(billRepositoryProvider);
    final res = await repo.upsertParticipant(participant);
    if (res is ResultFailure<Participant>) {
      return 'Gagal tambah orang: ${res.failure}';
    }
    final saved = (res as Success<Participant>).data;
    state = AsyncData(
      s.copyWith(
        participants: [...s.participants, saved],
        selectedParticipantId: saved.id,
      ),
    );
    return null;
  }

  /// Toggles the selected participant's assignment on [itemId]. Returns an
  /// error message if no participant is selected; null on success.
  Future<String?> toggleAssignment(String itemId) async {
    final s = state.value;
    if (s == null) return null;
    final pid = s.selectedParticipantId;
    if (pid == null) return 'Pilih dulu orang di bawah';

    final existing = s.assignments
        .where((a) => a.itemId == itemId && a.participantId == pid)
        .toList(growable: false);

    final List<Assignment> next;
    if (existing.isNotEmpty) {
      next = s.assignments
          .where((a) => !(a.itemId == itemId && a.participantId == pid))
          .toList();
    } else {
      next = [
        ...s.assignments,
        Assignment(
          id: _uuid.v4(),
          itemId: itemId,
          participantId: pid,
        ),
      ];
    }

    state = AsyncData(s.copyWith(assignments: next));

    final repo = ref.read(billRepositoryProvider);
    final res = await repo.replaceAssignments(s.bill.id, next);
    if (res is ResultFailure<List<Assignment>>) {
      // Roll back local state on persistence failure.
      state = AsyncData(s);
      return 'Gagal simpan assignment: ${res.failure}';
    }
    return null;
  }

  static T _unwrap<T>(Result<T> r) => switch (r) {
        Success(:final data) => data,
        ResultFailure(:final failure) => throw _FailureException(failure),
      };
}

class _FailureException implements Exception {
  _FailureException(this.failure);
  final Failure failure;
  @override
  String toString() => failure.toString();
}
