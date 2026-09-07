import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../dtos/assignment_dto.dart';
import '../dtos/bill_dto.dart';
import '../dtos/history_bill_dto.dart';
import '../dtos/history_bill_page_dto.dart';
import '../dtos/history_cursor_dto.dart';
import '../dtos/history_summary_dto.dart';
import '../dtos/item_dto.dart';
import '../dtos/participant_dto.dart';

class DeletedBillDto {
  const DeletedBillDto({
    required this.id,
    required this.title,
    required this.totalAmount,
    required this.currencyCode,
    required this.isSettled,
    required this.createdAt,
    required this.deletedAt,
    required this.deleteExpiresAt,
  });

  final String id;
  final String title;
  final double totalAmount;
  final String currencyCode;
  final bool isSettled;
  final DateTime createdAt;
  final DateTime deletedAt;
  final DateTime deleteExpiresAt;

  factory DeletedBillDto.fromJson(Map<String, dynamic> json) => DeletedBillDto(
    id: json['id'].toString(),
    title: json['title'].toString(),
    totalAmount: _readDouble(json['total_amount']),
    currencyCode: json['currency_code']?.toString() ?? 'IDR',
    isSettled: json['is_settled'] == true,
    createdAt: DateTime.parse(json['created_at'].toString()),
    deletedAt: DateTime.parse(json['deleted_at'].toString()),
    deleteExpiresAt: DateTime.parse(json['delete_expires_at'].toString()),
  );

  static double _readDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

/// Thin wrapper around PostgREST. No error handling here — exceptions bubble
/// up to be translated centrally by [guardAsync] in the repository layer.
class BillRemoteDataSource {
  BillRemoteDataSource(this._client);
  final SupabaseClient _client;

  static const _bills = 'bills';
  static const _items = 'items';
  static const _participants = 'participants';
  static const _assignments = 'item_assignments';

  static String _sortParam(String sort) => switch (sort) {
    'newest' => 'newest',
    'oldest' => 'oldest',
    'titleAsc' => 'title_asc',
    'amountDesc' => 'amount_desc',
    'amountAsc' => 'amount_asc',
    _ => 'newest',
  };

  static String? _statusParam(String? status) => switch (status) {
    'unassigned' => 'unassigned',
    'unpaid' => 'unpaid',
    'partial' => 'partial',
    'settled' => 'settled',
    _ => null,
  };

  static String _cursorSortValue(HistoryBillDto bill, String sort) =>
      switch (sort) {
        'newest' || 'oldest' => bill.createdAt.toUtc().toIso8601String(),
        'titleAsc' => bill.title,
        'amountDesc' || 'amountAsc' => bill.totalAmount.toString(),
        _ => bill.createdAt.toUtc().toIso8601String(),
      };

  /// Idempotent session guard. Returns the current user id if a session is
  /// attached, or signs in anonymously otherwise. Callers (notably
  /// [BillRepositoryImpl.createBill]) use this to prevent RLS 42501 on the
  /// first PostgREST request after a cold start where the in-memory session
  /// was lost but the local persisted session hasn't been re-attached yet.
  Future<Result<String>> authEnsureSignedIn() async {
    try {
      // Cek currentSession + accessToken, bukan hanya currentUser. Di beberapa
      // race condition (mis. sesi baru saja berakhir di background, atau
      // Supabase client emit `AuthStateChange` null session) `currentUser`
      // masih bisa berisi value non-null tapi JWT sudah tidak valid lagi.
      // PostgREST hanya percaya `Authorization: Bearer <access_token>` di
      // header — kalau tidak ada token valid, RLS menilai `auth.uid()` = NULL
      // dan menolak INSERT/UPDATE. Cek session + accessToken memastikan kita
      // selalu sign-in ulang sebelum request pertama setelah cold start.
      final session = _client.auth.currentSession;
      final existingToken = session?.accessToken;
      final existingUserId = session?.user.id;
      if (existingToken != null &&
          existingToken.isNotEmpty &&
          existingUserId != null) {
        return Result.success(existingUserId);
      }
      final res = await _client.auth.signInAnonymously();
      final user = res.user;
      if (user == null) {
        return const Result.failure(
          Failure.auth('Anonymous sign-in returned no user'),
        );
      }
      return Result.success(user.id);
    } on AuthException catch (e) {
      return Result.failure(Failure.auth(e.message));
    } catch (e, st) {
      return Result.failure(Failure.unknown(e, st));
    }
  }

  Future<List<BillDto>> listBills({DateTime? createdAfter}) async {
    var query = _client
        .from(_bills)
        .select('*, $_participants(is_paid)')
        .isFilter('deleted_at', null);
    if (createdAfter != null) {
      query = query.gte('created_at', createdAfter.toUtc().toIso8601String());
    }

    final rows = await query.order('created_at', ascending: false);
    return rows.map((r) => BillDto.fromJsonWithParticipants(r)).toList(growable: false);
  }

  Future<HistoryBillPageDto> listHistoryBillsPage({
    required DateTime createdAfter,
    required int limit,
    required String sort,
    String? currencyCode,
    String? paymentStatus,
    String? cursorSortValue,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final rows = await _client.rpc<List<dynamic>>('list_history_bills_page', params: {
      'p_created_after': createdAfter.toUtc().toIso8601String(),
      'p_limit': limit,
      'p_sort': _sortParam(sort),
      if (currencyCode != null) 'p_currency_code': currencyCode,
      if (paymentStatus != null) 'p_payment_status': _statusParam(paymentStatus),
      if (cursorSortValue != null) 'p_cursor_sort_value': cursorSortValue,
      if (cursorCreatedAt != null)
        'p_cursor_created_at': cursorCreatedAt.toUtc().toIso8601String(),
      if (cursorId != null) 'p_cursor_id': cursorId,
    });
    final rawList = rows;
    final hasMore = rawList.length > limit;
    final billRows = hasMore ? rawList.sublist(0, limit) : rawList;
    final bills = billRows
        .map((r) => HistoryBillDto.fromJson(r as Map<String, dynamic>))
        .toList(growable: false);

    HistoryCursorDto? cursor;
    if (hasMore && bills.isNotEmpty) {
      final last = bills.last;
      cursor = HistoryCursorDto(
        sortValue: _cursorSortValue(last, sort),
        createdAt: last.createdAt,
        id: last.id,
      );
    }

    return HistoryBillPageDto(
      bills: bills,
      cursor: cursor,
      hasMore: hasMore,
    );
  }

  Future<HistorySummaryDto> getHistorySummary({
    required DateTime createdAfter,
  }) async {
    final json = await _client.rpc<Map<String, dynamic>>(
      'get_history_page_summary',
      params: {
        'p_created_after': createdAfter.toUtc().toIso8601String(),
      },
    );
    return HistorySummaryDto.fromJson(json);
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
      _client.rpc('soft_delete_bill', params: {'p_bill_id': id});

  Future<void> restoreDeletedBill(String id) =>
      _client.rpc('restore_deleted_bill', params: {'p_bill_id': id});

  Future<List<DeletedBillDto>> listDeletedBills() async {
    final rows = await _client
        .from(_bills)
        .select(
          'id,title,total_amount,currency_code,is_settled,created_at,deleted_at,delete_expires_at',
        )
        .not('deleted_at', 'is', null)
        .order('deleted_at', ascending: false);
    return rows.map((r) => DeletedBillDto.fromJson(r)).toList(growable: false);
  }

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
    final rows = await _client
        .from(_participants)
        .select()
        .eq('bill_id', billId);
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

  Future<void> deleteParticipant(String participantId) =>
      _client.from(_participants).delete().eq('id', participantId);

  /// Creates (or rotates, for Plus) a share-link token. Only the SHA-256 of
  /// the opaque [tokenHash] is sent — the raw token never leaves the device
  /// except via the deep link the owner shares.
  Future<Map<String, dynamic>> createShareToken({
    required String billId,
    required String tokenHash,
  }) async {
    final rows = await _client.rpc<Map<String, dynamic>>(
      'create_bill_share_token',
      params: {'p_bill_id': billId, 'p_token_hash': tokenHash},
    );
    final list = (rows as List?) ?? const [];
    if (list.isEmpty) throw const FormatException('empty create response');
    return Map<String, dynamic>.from(list.first as Map);
  }

  Future<void> revokeShareToken(String tokenId) => _client.rpc(
    'revoke_bill_share_token',
    params: {'p_token_id': tokenId},
  );

  /// Public resolve (no login required). Returns null when the token is
  /// invalid, expired, revoked, or the bill was deleted.
  Future<Map<String, dynamic>?> resolveShareToken(String tokenHash) async {
    final res = await _client.rpc(
      'resolve_share_token',
      params: {'p_token_hash': tokenHash},
    );
    if (res == null) return null;
    if (res is Map<String, dynamic>) return res;
    if (res is Map) return Map<String, dynamic>.from(res);
    return null;
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
