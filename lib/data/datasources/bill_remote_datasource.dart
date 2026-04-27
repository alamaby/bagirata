import 'package:supabase_flutter/supabase_flutter.dart';

import '../dtos/assignment_dto.dart';
import '../dtos/bill_dto.dart';
import '../dtos/item_dto.dart';
import '../dtos/participant_dto.dart';

/// Thin wrapper around PostgREST. No error handling here — exceptions bubble
/// up to be translated centrally by [guardAsync] in the repository layer.
class BillRemoteDataSource {
  BillRemoteDataSource(this._client);
  final SupabaseClient _client;

  static const _bills = 'bills';
  static const _items = 'items';
  static const _participants = 'participants';
  static const _assignments = 'assignments';

  Future<List<BillDto>> listBills() async {
    final rows = await _client
        .from(_bills)
        .select()
        .order('created_at', ascending: false);
    return rows.map((r) => BillDto.fromJson(r)).toList(growable: false);
  }

  Future<BillDto> getBill(String id) async {
    final row = await _client.from(_bills).select().eq('id', id).single();
    return BillDto.fromJson(row);
  }

  Future<BillDto> upsertBill(BillDto dto) async {
    final row = await _client
        .from(_bills)
        .upsert(dto.toJson())
        .select()
        .single();
    return BillDto.fromJson(row);
  }

  Future<void> deleteBill(String id) =>
      _client.from(_bills).delete().eq('id', id);

  Future<List<ItemDto>> listItems(String billId) async {
    final rows = await _client.from(_items).select().eq('bill_id', billId);
    return rows.map((r) => ItemDto.fromJson(r)).toList(growable: false);
  }

  Future<List<ItemDto>> upsertItems(List<ItemDto> items) async {
    if (items.isEmpty) return const [];
    final rows = await _client
        .from(_items)
        .upsert(items.map((i) => i.toJson()).toList())
        .select();
    return rows.map((r) => ItemDto.fromJson(r)).toList(growable: false);
  }

  Future<List<ParticipantDto>> listParticipants(String billId) async {
    final rows =
        await _client.from(_participants).select().eq('bill_id', billId);
    return rows.map((r) => ParticipantDto.fromJson(r)).toList(growable: false);
  }

  Future<ParticipantDto> upsertParticipant(ParticipantDto dto) async {
    final row = await _client
        .from(_participants)
        .upsert(dto.toJson())
        .select()
        .single();
    return ParticipantDto.fromJson(row);
  }

  Future<List<AssignmentDto>> listAssignments(String billId) async {
    // Assignments are joined via items.bill_id; assumes a SQL view or a
    // nested select policy is in place. Fallback: per-item fetch from caller.
    final rows = await _client
        .from(_assignments)
        .select('*, items!inner(bill_id)')
        .eq('items.bill_id', billId);
    return rows.map((r) => AssignmentDto.fromJson(r)).toList(growable: false);
  }

  Future<List<AssignmentDto>> replaceAssignments(
    String billId,
    List<AssignmentDto> next,
  ) async {
    // Replacement strategy: delete-then-insert in one transactional RPC would
    // be ideal; for now we do it as two PostgREST calls — acceptable because
    // assignments only change inside a single editor session.
    final itemIds = await _client
        .from(_items)
        .select('id')
        .eq('bill_id', billId);
    final ids = itemIds.map((r) => r['id'] as String).toList();
    if (ids.isNotEmpty) {
      await _client.from(_assignments).delete().inFilter('item_id', ids);
    }
    if (next.isEmpty) return const [];
    final rows = await _client
        .from(_assignments)
        .insert(next.map((a) => a.toJson()).toList())
        .select();
    return rows.map((r) => AssignmentDto.fromJson(r)).toList(growable: false);
  }
}
