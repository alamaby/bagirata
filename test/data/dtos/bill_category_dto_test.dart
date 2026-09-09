import 'package:bagistruk/data/dtos/bill_dto.dart';
import 'package:bagistruk/data/dtos/history_bill_dto.dart';
import 'package:bagistruk/domain/entities/bill.dart';
import 'package:bagistruk/domain/entities/shared_bill.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BillDto category/tags', () {
    test('old rows without keys read as lain and empty tags', () {
      final dto = BillDto.fromJson({
        'id': 'b1',
        'title': 'T',
        'total_amount': 1000,
        'created_at': '2026-09-01T00:00:00.000Z',
      });
      expect(dto.category, 'lain');
      expect(dto.tags, isEmpty);
      expect(dto.toEntity().category, 'lain');
    });

    test('roundtrip preserves category and tags', () {
      final bill = Bill(
        id: 'b1',
        title: 'T',
        totalAmount: 1000,
        createdAt: DateTime.utc(2026, 9, 1),
        category: 'makan',
        tags: ['kopi', 'kantor'],
      );
      final restored = BillDto.fromEntity(bill).toEntity();
      expect(restored.category, 'makan');
      expect(restored.tags, ['kopi', 'kantor']);
    });

    test('fromEntity/toJson carry bill_tags key', () {
      final bill = Bill(
        id: 'b1',
        title: 'T',
        totalAmount: 1000,
        createdAt: DateTime.utc(2026, 9, 1),
        category: 'transport',
        tags: ['a'],
      );
      final json = BillDto.fromEntity(bill).toJson();
      expect(json['category'], 'transport');
      expect(json['bill_tags'], ['a']);
      expect(BillDto.fromJson(json).toEntity().category, 'transport');
    });
  });

  group('HistoryBillDto category/tags', () {
    Map<String, dynamic> row() => {
      'id': 'b1',
      'title': 'T',
      'total_amount': 1000,
      'created_at': '2026-09-01T00:00:00.000Z',
      'participant_count': 1,
      'paid_participant_count': 0,
      'payment_status': 'unpaid',
    };

    test('missing keys default without crash', () {
      final entity = HistoryBillDto.fromJson(row()).toEntity();
      expect(entity.category, 'lain');
      expect(entity.tags, isEmpty);
    });

    test('reads category and tags when present', () {
      final entity = HistoryBillDto.fromJson(
        row()
          ..['category'] = 'belanja'
          ..['bill_tags'] = ['x', 'y'],
      ).toEntity();
      expect(entity.category, 'belanja');
      expect(entity.tags, ['x', 'y']);
    });
  });

  group('SharedBill category', () {
    test('reads preset category, never tags', () {
      final shared = SharedBill.fromJson({
        'bill': {
          'id': 'b1',
          'title': 'T',
          'total_amount': 1000,
          'created_at': '2026-09-01T00:00:00.000Z',
          'category': 'groceries',
        },
        'items': <Map<String, dynamic>>[],
        'participants': <Map<String, dynamic>>[],
        'assignments': <Map<String, dynamic>>[],
        'expires_at': '2026-09-09T00:00:00.000Z',
      });
      expect(shared.bill.category, 'groceries');
      expect(shared.bill.tags, isEmpty);
    });
  });
}
