import '../../core/error/exception_mapper.dart';
import '../../core/error/result.dart';
import '../../domain/entities/assignment.dart';
import '../../domain/entities/bill.dart';
import '../../domain/entities/deleted_bill.dart';
import '../../domain/entities/history_bill_page.dart';
import '../../domain/entities/history_summary.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/participant.dart';
import '../../domain/entities/shared_bill.dart';
import '../../domain/repositories/i_bill_repository.dart';
import '../datasources/bill_remote_datasource.dart';
import '../dtos/assignment_dto.dart';
import '../dtos/bill_dto.dart';
import '../dtos/history_bill_page_dto.dart';
import '../dtos/history_summary_dto.dart';
import '../dtos/item_dto.dart';
import '../dtos/participant_dto.dart';

class BillRepositoryImpl implements IBillRepository {
  BillRepositoryImpl(this._ds);
  final BillRemoteDataSource _ds;

  @override
  Future<Result<List<Bill>>> listBills({DateTime? createdAfter}) => guardAsync(
    () async => (await _ds.listBills(
      createdAfter: createdAfter,
    )).map((d) => d.toEntity()).toList(growable: false),
  );

  @override
  Future<Result<HistoryBillPage>> listHistoryBillsPage({
    required DateTime createdAfter,
    required int limit,
    required String sort,
    String? currencyCode,
    String? paymentStatus,
    String? cursorSortValue,
    DateTime? cursorCreatedAt,
    String? cursorId,
    String? query,
    String? category,
  }) =>
      guardAsync(
        () async => (await _ds.listHistoryBillsPage(
          createdAfter: createdAfter,
          limit: limit,
          sort: sort,
          currencyCode: currencyCode,
          paymentStatus: paymentStatus,
          cursorSortValue: cursorSortValue,
          cursorCreatedAt: cursorCreatedAt,
          cursorId: cursorId,
          query: query,
          category: category,
        )).toEntity(),
      );

  @override
  Future<Result<HistorySummary>> getHistorySummary({
    required DateTime createdAfter,
    String? query,
    String? category,
  }) =>
      guardAsync(
        () async => (await _ds.getHistorySummary(
          createdAfter: createdAfter,
          query: query,
          category: category,
        )).toEntity(),
      );

  @override
  Future<Result<Bill>> getBill(String id) =>
      guardAsync(() async => (await _ds.getBill(id)).toEntity());

  @override
  Future<Result<Bill>> createBill(Bill bill) async {
    final authResult = await _ds.authEnsureSignedIn();
    if (authResult is ResultFailure<String>) {
      return Result.failure(authResult.failure);
    }
    return guardAsync(
      () async => (await _ds.upsertBill(BillDto.fromEntity(bill))).toEntity(),
    );
  }

  @override
  Future<Result<Bill>> updateBill(Bill bill) => createBill(bill);

  @override
  Future<Result<void>> deleteBill(String id) =>
      guardAsync(() => _ds.deleteBill(id));

  @override
  Future<Result<void>> restoreDeletedBill(String id) =>
      guardAsync(() => _ds.restoreDeletedBill(id));

  @override
  Future<Result<void>> ensureSignedIn() async {
    final res = await _ds.authEnsureSignedIn();
    if (res is ResultFailure<String>) {
      return Result.failure(res.failure);
    }
    return const Result.success(null);
  }

  @override
  Future<Result<BillShareLink>> createShareToken({
    required String billId,
    required String tokenHash,
  }) => guardAsync(() async {
    final row = await _ds.createShareToken(
      billId: billId,
      tokenHash: tokenHash,
    );
    return BillShareLink(
      tokenId: row['token_id'].toString(),
      expiresAt: DateTime.parse(row['expires_at'].toString()),
    );
  });

  @override
  Future<Result<void>> revokeShareToken(String tokenId) =>
      guardAsync(() => _ds.revokeShareToken(tokenId));

  @override
  Future<Result<SharedBill?>> resolveShareToken(String tokenHash) =>
      guardAsync(() async {
        final json = await _ds.resolveShareToken(tokenHash);
        if (json == null) return null;
        return SharedBill.fromJson(json);
      });

  @override
  Future<Result<List<DeletedBill>>> listDeletedBills() => guardAsync(
    () async => (await _ds.listDeletedBills())
        .map(
          (d) => DeletedBill(
            id: d.id,
            title: d.title,
            totalAmount: d.totalAmount,
            currencyCode: d.currencyCode,
            isSettled: d.isSettled,
            createdAt: d.createdAt,
            deletedAt: d.deletedAt,
            deleteExpiresAt: d.deleteExpiresAt,
          ),
        )
        .toList(growable: false),
  );

  @override
  Future<Result<List<Item>>> listItems(String billId) => guardAsync(
    () async => (await _ds.listItems(
      billId,
    )).map((d) => d.toEntity()).toList(growable: false),
  );

  @override
  Future<Result<List<Item>>> upsertItems(List<Item> items) => guardAsync(
    () async => (await _ds.upsertItems(
      items.map(ItemDto.fromEntity).toList(),
    )).map((d) => d.toEntity()).toList(growable: false),
  );

  @override
  Future<Result<List<Participant>>> listParticipants(String billId) =>
      guardAsync(
        () async => (await _ds.listParticipants(
          billId,
        )).map((d) => d.toEntity()).toList(growable: false),
      );

  @override
  Future<Result<Participant>> upsertParticipant(Participant participant) =>
      guardAsync(
        () async => (await _ds.upsertParticipant(
          ParticipantDto.fromEntity(participant),
        )).toEntity(),
      );

  @override
  Future<Result<void>> deleteParticipant(String participantId) =>
      guardAsync(() => _ds.deleteParticipant(participantId));

  @override
  Future<Result<List<Assignment>>> listAssignments(String billId) => guardAsync(
    () async => (await _ds.listAssignments(
      billId,
    )).map((d) => d.toEntity()).toList(growable: false),
  );

  @override
  Future<Result<List<Assignment>>> replaceAssignments(
    String billId,
    List<Assignment> assignments,
  ) => guardAsync(
    () async => (await _ds.replaceAssignments(
      billId,
      assignments.map(AssignmentDto.fromEntity).toList(),
    )).map((d) => d.toEntity()).toList(growable: false),
  );
}
