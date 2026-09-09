import 'package:bagistruk/domain/entities/shared_bill.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _rpcJson() => {
  'bill': {
    'id': 'bill-1',
    'title': 'Bukber',
    'total_amount': 150000,
    'currency_code': 'IDR',
    'tax': 10000,
    'service': 5000,
    'is_settled': false,
    'receipt_date': '2026-09-01T00:00:00.000Z',
    'created_at': '2026-09-02T00:00:00.000Z',
  },
  'items': [
    {'id': 'i1', 'name': 'Nasi goreng', 'price': 50000, 'qty': 2},
    {'id': 'i2', 'name': 'Es teh', 'price': 10000, 'qty': 5},
  ],
  'participants': [
    {'id': 'p1', 'name': 'Ani', 'is_paid': true},
    {'id': 'p2', 'name': 'Budi', 'is_paid': false},
  ],
  'assignments': [
    {'item_id': 'i1', 'participant_id': 'p1'},
    {'item_id': 'i1', 'participant_id': 'p2'},
    {'item_id': 'i2', 'participant_id': 'p2'},
  ],
  'expires_at': '2026-09-09T00:00:00.000Z',
};

void main() {
  group('SharedBill.fromJson', () {
    test('parses full RPC snapshot without bank info or phones', () {
      final shared = SharedBill.fromJson(_rpcJson());

      expect(shared.bill.id, 'bill-1');
      expect(shared.bill.title, 'Bukber');
      expect(shared.bill.totalAmount, 150000);
      expect(shared.bill.currencyCode, 'IDR');
      expect(shared.bill.tax, 10000);
      expect(shared.bill.service, 5000);
      expect(shared.bill.isSettled, isFalse);
      expect(shared.items, hasLength(2));
      expect(shared.items.first.subtotal, 100000);
      expect(shared.participants.map((p) => p.name), ['Ani', 'Budi']);
      expect(shared.participants.first.isPaid, isTrue);
      // No phone numbers leak into the public snapshot.
      expect(shared.participants.every((p) => p.phone == null), isTrue);
      expect(shared.assignments, hasLength(3));
      expect(shared.expiresAt, DateTime.parse('2026-09-09T00:00:00.000Z'));
    });

    test('tolerates missing optionals and empty lists', () {
      final shared = SharedBill.fromJson({
        'bill': {'id': 'b', 'created_at': '2026-09-02T00:00:00.000Z'},
        'items': <Map<String, dynamic>>[],
        'participants': <Map<String, dynamic>>[],
        'assignments': <Map<String, dynamic>>[],
        'expires_at': '2026-09-09T00:00:00.000Z',
      });

      expect(shared.bill.title, '');
      expect(shared.bill.currencyCode, 'IDR');
      expect(shared.bill.receiptDate, isNull);
      expect(shared.items, isEmpty);
      expect(shared.participants, isEmpty);
      expect(shared.assignments, isEmpty);
    });
  });
}
