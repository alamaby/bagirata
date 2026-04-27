import '../../core/error/result.dart';
import '../entities/assignment.dart';
import '../entities/bill.dart';
import '../entities/item.dart';
import '../entities/participant.dart';

abstract interface class IBillRepository {
  Future<Result<List<Bill>>> listBills();
  Future<Result<Bill>> getBill(String id);
  Future<Result<Bill>> createBill(Bill bill);
  Future<Result<Bill>> updateBill(Bill bill);
  Future<Result<void>> deleteBill(String id);

  Future<Result<List<Item>>> listItems(String billId);
  Future<Result<List<Item>>> upsertItems(List<Item> items);

  Future<Result<List<Participant>>> listParticipants(String billId);
  Future<Result<Participant>> upsertParticipant(Participant participant);

  Future<Result<List<Assignment>>> listAssignments(String billId);
  Future<Result<List<Assignment>>> replaceAssignments(
    String billId,
    List<Assignment> assignments,
  );
}
