import 'package:bagistruk/domain/entities/assignment.dart';
import 'package:bagistruk/domain/entities/bill.dart';
import 'package:bagistruk/domain/entities/item.dart';
import 'package:bagistruk/domain/entities/participant.dart';

/// Read-only snapshot of a bill resolved from a share-link token
/// (`resolve_share_token`). No bank info, no phone numbers — safe to render
/// for viewers without an account.
class SharedBill {
  const SharedBill({
    required this.bill,
    required this.items,
    required this.participants,
    required this.assignments,
    required this.expiresAt,
  });

  final Bill bill;
  final List<Item> items;
  final List<Participant> participants;
  final List<Assignment> assignments;
  final DateTime expiresAt;

  static double _double(Object? v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  factory SharedBill.fromJson(Map<String, dynamic> json) {
    final bill = Map<String, dynamic>.from(json['bill'] as Map);
    final items = (json['items'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(
          (e) => Item(
            id: e['id'].toString(),
            billId: bill['id'].toString(),
            name: e['name']?.toString() ?? '',
            price: _double(e['price']),
            qty: _double(e['qty']),
          ),
        )
        .toList(growable: false);
    final participants = (json['participants'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(
          (e) => Participant(
            id: e['id'].toString(),
            billId: bill['id'].toString(),
            name: e['name']?.toString() ?? '',
            isPaid: e['is_paid'] == true,
          ),
        )
        .toList(growable: false);
    final assignments = (json['assignments'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(
          (e) => Assignment(
            id: '${e['item_id']}:${e['participant_id']}',
            itemId: e['item_id'].toString(),
            participantId: e['participant_id'].toString(),
          ),
        )
        .toList(growable: false);
    DateTime? receiptDate;
    final receiptRaw = bill['receipt_date'];
    if (receiptRaw != null) {
      receiptDate = DateTime.tryParse(receiptRaw.toString());
    }
    return SharedBill(
      bill: Bill(
        id: bill['id'].toString(),
        title: bill['title']?.toString() ?? '',
        totalAmount: _double(bill['total_amount']),
        currencyCode: bill['currency_code']?.toString() ?? 'IDR',
        tax: _double(bill['tax']),
        service: _double(bill['service']),
        isSettled: bill['is_settled'] == true,
        receiptDate: receiptDate,
        createdAt:
            DateTime.tryParse(bill['created_at']?.toString() ?? '') ??
            DateTime.now().toUtc(),
      ),
      items: items,
      participants: participants,
      assignments: assignments,
      expiresAt:
          DateTime.tryParse(json['expires_at']?.toString() ?? '') ??
          DateTime.now().toUtc(),
    );
  }
}

/// Active share-link state for one bill (owner view).
class BillShareLink {
  const BillShareLink({required this.tokenId, required this.expiresAt});

  final String tokenId;
  final DateTime expiresAt;
}
