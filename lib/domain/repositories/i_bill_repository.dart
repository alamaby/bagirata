import '../../core/error/result.dart';
import '../entities/assignment.dart';
import '../entities/bill.dart';
import '../entities/deleted_bill.dart';
import '../entities/history_bill_page.dart';
import '../entities/history_summary.dart';
import '../entities/item.dart';
import '../entities/participant.dart';
import '../entities/shared_bill.dart';

abstract interface class IBillRepository {
  Future<Result<List<Bill>>> listBills({DateTime? createdAfter});

  Future<Result<HistoryBillPage>> listHistoryBillsPage({
    required DateTime createdAfter,
    required int limit,
    required String sort,
    String? currencyCode,
    String? paymentStatus,
    String? cursorSortValue,
    DateTime? cursorCreatedAt,
    String? cursorId,
  });

  Future<Result<HistorySummary>> getHistorySummary({
    required DateTime createdAfter,
  });
  Future<Result<Bill>> getBill(String id);
  Future<Result<Bill>> createBill(Bill bill);
  Future<Result<Bill>> updateBill(Bill bill);
  Future<Result<void>> deleteBill(String id);
  Future<Result<void>> restoreDeletedBill(String id);
  Future<Result<List<DeletedBill>>> listDeletedBills();

  Future<Result<List<Item>>> listItems(String billId);
  Future<Result<List<Item>>> upsertItems(List<Item> items);

  Future<Result<List<Participant>>> listParticipants(String billId);
  Future<Result<Participant>> upsertParticipant(Participant participant);
  Future<Result<void>> deleteParticipant(String participantId);

  Future<Result<List<Assignment>>> listAssignments(String billId);
  Future<Result<List<Assignment>>> replaceAssignments(
    String billId,
    List<Assignment> assignments,
  );

  /// Idempotent session guard. Ensures a valid Supabase user session is
  /// available before write operations that require RLS authorization.
  Future<Result<void>> ensureSignedIn();

  /// Share-link (M2/F5): create/rotate a token (server enforces Free 1-active
  /// via `plan_code`), revoke it, or resolve it publicly (no login).
  Future<Result<BillShareLink>> createShareToken({
    required String billId,
    required String tokenHash,
  });
  Future<Result<void>> revokeShareToken(String tokenId);
  Future<Result<SharedBill?>> resolveShareToken(String tokenHash);
}
