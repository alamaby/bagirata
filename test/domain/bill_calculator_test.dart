import 'package:bagistruk/domain/entities/assignment.dart';
import 'package:bagistruk/domain/entities/item.dart';
import 'package:bagistruk/domain/services/bill_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calc = BillCalculator();

  group('BillCalculator.distributeProportionally', () {
    test('equal split — two diners share one item, no extras', () {
      final items = [
        const Item(id: 'i1', billId: 'b', name: 'Pizza', price: 100, qty: 1),
      ];
      final assignments = [
        const Assignment(id: 'a1', itemId: 'i1', participantId: 'alice'),
        const Assignment(id: 'a2', itemId: 'i1', participantId: 'bob'),
      ];

      final owed = calc.distributeProportionally(
        items: items, assignments: assignments, tax: 0, service: 0,
      );

      expect(owed, {'alice': 50.00, 'bob': 50.00});
    });

    test('uneven shareWeight — 2:1 split of a 90 item with no extras', () {
      final items = [
        const Item(id: 'i1', billId: 'b', name: 'Steak', price: 90, qty: 1),
      ];
      final assignments = [
        const Assignment(id: 'a1', itemId: 'i1', participantId: 'alice', shareWeight: 2),
        const Assignment(id: 'a2', itemId: 'i1', participantId: 'bob'),
      ];

      final owed = calc.distributeProportionally(
        items: items, assignments: assignments, tax: 0, service: 0,
      );

      expect(owed['alice'], closeTo(60.00, 0.001));
      expect(owed['bob'], closeTo(30.00, 0.001));
    });

    test('proportional tax — heavier orderer pays more tax', () {
      final items = [
        const Item(id: 'i1', billId: 'b', name: 'Wine', price: 80, qty: 1),
        const Item(id: 'i2', billId: 'b', name: 'Water', price: 20, qty: 1),
      ];
      final assignments = [
        const Assignment(id: 'a1', itemId: 'i1', participantId: 'alice'),
        const Assignment(id: 'a2', itemId: 'i2', participantId: 'bob'),
      ];

      // 10% tax + 5% service on a 100 subtotal = 15 extras.
      final owed = calc.distributeProportionally(
        items: items, assignments: assignments, tax: 10, service: 5,
      );

      // Alice: 80 + 80% of 15 = 92.00 ; Bob: 20 + 20% of 15 = 23.00
      expect(owed['alice'], closeTo(92.00, 0.001));
      expect(owed['bob'], closeTo(23.00, 0.001));
      // Reconciles exactly to the total.
      expect(owed.values.fold<double>(0, (a, b) => a + b), closeTo(115.00, 0.001));
    });

    test('cent-residual reconciliation — 100 split 3 ways with tax', () {
      final items = [
        const Item(id: 'i1', billId: 'b', name: 'Combo', price: 100, qty: 1),
      ];
      final assignments = [
        const Assignment(id: 'a1', itemId: 'i1', participantId: 'a'),
        const Assignment(id: 'a2', itemId: 'i1', participantId: 'b'),
        const Assignment(id: 'a3', itemId: 'i1', participantId: 'c'),
      ];

      final owed = calc.distributeProportionally(
        items: items, assignments: assignments, tax: 10, service: 0,
      );

      // Sum must equal 110.00 exactly even though 110/3 = 36.6666… cannot be
      // represented in cents.
      final total = owed.values.fold<double>(0, (a, b) => a + b);
      expect(total, closeTo(110.00, 0.0001));
      // Each share is within one cent of 36.67.
      for (final v in owed.values) {
        expect(v, anyOf(36.66, 36.67, 36.68));
      }
    });

    test('empty assignments returns empty map', () {
      final owed = calc.distributeProportionally(
        items: const [], assignments: const [], tax: 0, service: 0,
      );
      expect(owed, isEmpty);
    });
  });
}
